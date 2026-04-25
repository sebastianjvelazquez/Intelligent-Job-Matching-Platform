"""
app/routes.py
-------------
Flask Blueprint with browser and JSON routes.

Content negotiation strategy:
  - GET routes render HTML for browsers and JSON for API clients.
  - JSON POST/PUT/DELETE routes stay available for tests and API usage.
  - Browser form submissions use dedicated POST endpoints plus flash messages.
"""

import math

from flask import (
    Blueprint,
    abort,
    flash,
    jsonify,
    redirect,
    render_template,
    request,
    url_for,
)
import mysql.connector

from app import get_db_connection
from app import queries as q

main = Blueprint("main", __name__)

APPLICATION_STATUSES = ("submitted", "reviewed", "accepted", "rejected")
PAGE_SIZE = 10


def _db():
    """Open a connection and return (connection, cursor)."""
    conn = get_db_connection()
    return conn, conn.cursor()


def _wants_html():
    """True when the caller is a browser (prefers text/html over JSON)."""
    return "text/html" in request.headers.get("Accept", "")


def _paginate(items, per_page=PAGE_SIZE):
    """Return the items for the requested page plus template metadata."""
    page = request.args.get("page", default=1, type=int) or 1
    if page < 1:
        page = 1

    total = len(items)
    page_count = max(1, math.ceil(total / per_page)) if total else 1
    if page > page_count:
        page = page_count

    start = (page - 1) * per_page
    end = start + per_page
    page_items = items[start:end]
    meta = {
        "page": page,
        "page_count": page_count,
        "total": total,
        "has_prev": page > 1,
        "has_next": page < page_count,
    }
    return page_items, meta


def _safe_next(default):
    """Return a local redirect target from form/query params or a default."""
    target = request.form.get("next") or request.args.get("next")
    if target and target.startswith("/"):
        return target
    return default


def _to_int(value):
    """Convert a value to int, returning None on invalid input."""
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


# --- Home --------------------------------------------------------------------


@main.route("/")
def index():
    """Landing page with navigation links to all sections."""
    return render_template("index.html")


# --- Students ----------------------------------------------------------------


@main.route("/students")
def list_students():
    """Return all students. HTML for browsers, JSON for API clients."""
    conn, cur = _db()
    try:
        students = q.get_all_students(cur)
    finally:
        cur.close()
        conn.close()

    if _wants_html():
        students_page, pagination = _paginate(students)
        return render_template(
            "students/list.html",
            students=students_page,
            pagination=pagination,
        )
    return jsonify(students), 200


@main.route("/students/new")
def new_student_form():
    """Render the Add Student form."""
    return render_template("students/form.html", student=None)


@main.route("/students/<int:user_id>")
def get_student(user_id):
    """Return one student with skills and applications."""
    conn, cur = _db()
    try:
        student = q.get_student_by_id(cur, user_id)
    finally:
        cur.close()
        conn.close()

    if student is None:
        abort(404)

    if _wants_html():
        return render_template("students/detail.html", student=student)
    return jsonify(student), 200


@main.route("/students/<int:user_id>/edit")
def edit_student_form(user_id):
    """Render the Edit Student form pre-filled with existing data."""
    conn, cur = _db()
    try:
        student = q.get_student_by_id(cur, user_id)
    finally:
        cur.close()
        conn.close()

    if student is None:
        abort(404)
    return render_template("students/form.html", student=student)


@main.route("/students", methods=["POST"])
def create_student():
    """Create a new student from JSON or an HTML form."""
    data = request.get_json(silent=True) or {} if request.is_json else request.form

    name = (data.get("name") or "").strip()
    email = (data.get("email") or "").strip()
    major = (data.get("major") or "").strip()
    location = (data.get("location") or "").strip()
    resume = (data.get("resume") or "").strip() or None

    if not all([name, email, major, location]):
        if request.is_json:
            return jsonify({"error": "name, email, major, and location are required"}), 400
        flash("All fields except resume are required.")
        return redirect(url_for("main.new_student_form"))

    conn, cur = _db()
    try:
        new_id = q.create_student(cur, name, email, major, location, resume)
        conn.commit()
    except mysql.connector.IntegrityError:
        conn.rollback()
        if request.is_json:
            return jsonify({"error": "email already exists"}), 409
        flash("That email address is already in use.")
        return redirect(url_for("main.new_student_form"))
    finally:
        cur.close()
        conn.close()

    if request.is_json:
        return jsonify(
            {
                "user_id": new_id,
                "name": name,
                "email": email,
                "major": major,
                "location": location,
            }
        ), 201

    flash("Student created successfully.")
    return redirect(url_for("main.get_student", user_id=new_id))


@main.route("/students/<int:user_id>", methods=["PUT"])
def update_student(user_id):
    """Update editable fields for a student. JSON API route."""
    data = request.get_json(silent=True) or {}

    conn, cur = _db()
    try:
        updated = q.update_student(cur, user_id, data)
        conn.commit()
        if not updated:
            return jsonify({"error": "student not found or no valid fields provided"}), 404
        student = q.get_student_by_id(cur, user_id)
    except mysql.connector.IntegrityError:
        conn.rollback()
        return jsonify({"error": "email already exists"}), 409
    finally:
        cur.close()
        conn.close()

    return jsonify(student), 200


@main.route("/students/<int:user_id>/edit", methods=["POST"])
def update_student_form(user_id):
    """Update a student from a browser form."""
    data = dict(request.form)

    conn, cur = _db()
    try:
        updated = q.update_student(cur, user_id, data)
        conn.commit()
    except mysql.connector.IntegrityError:
        conn.rollback()
        flash("That email address is already in use.")
        return redirect(url_for("main.edit_student_form", user_id=user_id))
    finally:
        cur.close()
        conn.close()

    if not updated:
        flash("No changes were saved.")
        return redirect(url_for("main.edit_student_form", user_id=user_id))

    flash("Student updated successfully.")
    return redirect(url_for("main.get_student", user_id=user_id))


@main.route("/students/<int:user_id>", methods=["DELETE"])
def delete_student(user_id):
    """Delete a student. Returns JSON for API clients."""
    conn, cur = _db()
    try:
        deleted = q.delete_student(cur, user_id)
        conn.commit()
    finally:
        cur.close()
        conn.close()

    if not deleted:
        return jsonify({"error": "student not found"}), 404
    return jsonify({"message": "student deleted", "user_id": user_id}), 200


@main.route("/students/<int:user_id>/delete", methods=["POST"])
def delete_student_form(user_id):
    """Delete a student from a browser form."""
    conn, cur = _db()
    try:
        deleted = q.delete_student(cur, user_id)
        conn.commit()
    finally:
        cur.close()
        conn.close()

    if not deleted:
        flash("Student not found.")
    else:
        flash("Student deleted successfully.")
    return redirect(url_for("main.list_students"))


# --- Opportunities -----------------------------------------------------------


@main.route("/opportunities")
def list_opportunities():
    """Return all opportunities. HTML for browsers, JSON for API clients."""
    conn, cur = _db()
    try:
        opportunities = q.get_all_opportunities(cur)
    finally:
        cur.close()
        conn.close()

    if _wants_html():
        opportunities_page, pagination = _paginate(opportunities)
        return render_template(
            "opportunities/list.html",
            opportunities=opportunities_page,
            pagination=pagination,
        )
    return jsonify(opportunities), 200


@main.route("/opportunities/new")
def new_opportunity_form():
    """Render the Add Opportunity form."""
    conn, cur = _db()
    try:
        companies = q.get_all_companies(cur)
    finally:
        cur.close()
        conn.close()
    return render_template("opportunities/form.html", opp=None, companies=companies)


@main.route("/opportunities/<int:opp_id>")
def get_opportunity(opp_id):
    """Return one opportunity with skills."""
    conn, cur = _db()
    try:
        opp = q.get_opportunity_by_id(cur, opp_id)
    finally:
        cur.close()
        conn.close()

    if opp is None:
        abort(404)

    if _wants_html():
        return render_template("opportunities/detail.html", opp=opp)
    return jsonify(opp), 200


@main.route("/opportunities/<int:opp_id>/edit")
def edit_opportunity_form(opp_id):
    """Render the Edit Opportunity form."""
    conn, cur = _db()
    try:
        opp = q.get_opportunity_by_id(cur, opp_id)
        companies = q.get_all_companies(cur)
    finally:
        cur.close()
        conn.close()

    if opp is None:
        abort(404)
    return render_template("opportunities/form.html", opp=opp, companies=companies)


@main.route("/opportunities", methods=["POST"])
def create_opportunity():
    """Create a new opportunity from JSON or an HTML form."""
    data = request.get_json(silent=True) or {} if request.is_json else request.form

    title = (data.get("title") or "").strip()
    location = (data.get("location") or "").strip()
    company_id = _to_int(data.get("company_id"))

    if not title or not location or company_id is None:
        if request.is_json:
            return jsonify({"error": "title, location, and company_id are required"}), 400
        flash("Title, location, and company are required.")
        return redirect(url_for("main.new_opportunity_form"))

    conn, cur = _db()
    try:
        opp_id = q.create_opportunity(cur, title, location, company_id)
        conn.commit()
        created = q.get_opportunity_by_id(cur, opp_id)
    except mysql.connector.Error:
        conn.rollback()
        if request.is_json:
            return jsonify({"error": "unable to create opportunity"}), 409
        flash("Unable to create opportunity with the selected company.")
        return redirect(url_for("main.new_opportunity_form"))
    finally:
        cur.close()
        conn.close()

    if request.is_json:
        return jsonify(created), 201

    flash("Opportunity created successfully.")
    return redirect(url_for("main.get_opportunity", opp_id=opp_id))


@main.route("/opportunities/<int:opp_id>", methods=["PUT"])
def update_opportunity(opp_id):
    """Update editable fields for an opportunity. JSON API route."""
    data = request.get_json(silent=True) or {}
    if "company_id" in data:
        data["company_id"] = _to_int(data.get("company_id"))

    conn, cur = _db()
    try:
        updated = q.update_opportunity(cur, opp_id, data)
        conn.commit()
        if not updated:
            return jsonify({"error": "opportunity not found or no valid fields provided"}), 404
        opp = q.get_opportunity_by_id(cur, opp_id)
    except mysql.connector.Error:
        conn.rollback()
        return jsonify({"error": "unable to update opportunity"}), 409
    finally:
        cur.close()
        conn.close()

    return jsonify(opp), 200


@main.route("/opportunities/<int:opp_id>/edit", methods=["POST"])
def update_opportunity_form(opp_id):
    """Update an opportunity from a browser form."""
    data = {
        "title": (request.form.get("title") or "").strip(),
        "location": (request.form.get("location") or "").strip(),
        "company_id": _to_int(request.form.get("company_id")),
    }

    if not data["title"] or not data["location"] or data["company_id"] is None:
        flash("Title, location, and company are required.")
        return redirect(url_for("main.edit_opportunity_form", opp_id=opp_id))

    conn, cur = _db()
    try:
        updated = q.update_opportunity(cur, opp_id, data)
        conn.commit()
    except mysql.connector.Error:
        conn.rollback()
        flash("Unable to update opportunity.")
        return redirect(url_for("main.edit_opportunity_form", opp_id=opp_id))
    finally:
        cur.close()
        conn.close()

    if not updated:
        flash("No changes were saved.")
        return redirect(url_for("main.edit_opportunity_form", opp_id=opp_id))

    flash("Opportunity updated successfully.")
    return redirect(url_for("main.get_opportunity", opp_id=opp_id))


@main.route("/opportunities/<int:opp_id>", methods=["DELETE"])
def delete_opportunity(opp_id):
    """Delete an opportunity. Returns JSON for API clients."""
    conn, cur = _db()
    try:
        deleted = q.delete_opportunity(cur, opp_id)
        conn.commit()
    finally:
        cur.close()
        conn.close()

    if not deleted:
        return jsonify({"error": "opportunity not found"}), 404
    return jsonify({"message": "opportunity deleted", "opportunity_id": opp_id}), 200


@main.route("/opportunities/<int:opp_id>/delete", methods=["POST"])
def delete_opportunity_form(opp_id):
    """Delete an opportunity from a browser form."""
    conn, cur = _db()
    try:
        deleted = q.delete_opportunity(cur, opp_id)
        conn.commit()
    finally:
        cur.close()
        conn.close()

    if not deleted:
        flash("Opportunity not found.")
    else:
        flash("Opportunity deleted successfully.")
    return redirect(url_for("main.list_opportunities"))


# --- Matching ----------------------------------------------------------------


@main.route("/match")
def match_form():
    """Render the match form."""
    conn, cur = _db()
    try:
        students = q.get_all_students(cur)
    finally:
        cur.close()
        conn.close()
    return render_template("match/index.html", students=students)


@main.route("/match/<int:user_id>")
def match_results(user_id):
    """Return ranked match scores for a student."""
    conn, cur = _db()
    try:
        results = q.compute_match_scores(cur, user_id)
        student = q.get_student_by_id(cur, user_id)
    except ValueError:
        abort(404)
    finally:
        cur.close()
        conn.close()

    if student is None:
        abort(404)

    if _wants_html():
        return render_template("match/results.html", student=student, results=results)
    return jsonify(results), 200


@main.route("/match/<int:user_id>/<int:opportunity_id>")
def match_detail(user_id, opportunity_id):
    """Return the detailed match breakdown for one student and opportunity."""
    conn, cur = _db()
    try:
        results = q.compute_match_scores(cur, user_id)
        student = q.get_student_by_id(cur, user_id)
    except ValueError:
        abort(404)
    finally:
        cur.close()
        conn.close()

    if student is None:
        abort(404)

    result = next(
        (item for item in results if item["opportunity_id"] == opportunity_id),
        None,
    )
    if result is None:
        abort(404)

    if _wants_html():
        return render_template("match/detail.html", student=student, result=result)
    return jsonify(result), 200


# --- Applications ------------------------------------------------------------


@main.route("/applications")
def list_applications():
    """Return applications, optionally filtered by student, opportunity, or status."""
    user_id = request.args.get("user_id", type=int)
    opportunity_id = request.args.get("opportunity_id", type=int)
    status = (request.args.get("status") or "").strip()
    if status not in APPLICATION_STATUSES:
        status = None

    conn, cur = _db()
    try:
        applications = q.get_all_applications(
            cur,
            user_id=user_id,
            opportunity_id=opportunity_id,
            status=status,
        )
        if _wants_html():
            students = q.get_all_students(cur)
            opportunities = q.get_all_opportunities(cur)
    finally:
        cur.close()
        conn.close()

    if _wants_html():
        return render_template(
            "applications/list.html",
            applications=applications,
            students=students,
            opportunities=opportunities,
            statuses=APPLICATION_STATUSES,
            selected_user_id=user_id,
            selected_opportunity_id=opportunity_id,
            selected_status=status,
        )
    return jsonify(applications), 200


@main.route("/applications/new")
def new_application_form():
    """Render the application submission form."""
    selected_user_id = request.args.get("user_id", type=int)
    selected_opportunity_id = request.args.get("opportunity_id", type=int)

    conn, cur = _db()
    try:
        students = q.get_all_students(cur)
        opportunities = q.get_all_opportunities(cur)
    finally:
        cur.close()
        conn.close()

    return render_template(
        "applications/form.html",
        students=students,
        opportunities=opportunities,
        selected_user_id=selected_user_id,
        selected_opportunity_id=selected_opportunity_id,
    )


@main.route("/applications", methods=["POST"])
def create_application():
    """Create a new application. Supports JSON and HTML form submissions."""
    data = request.get_json(silent=True) or {} if request.is_json else request.form

    user_id = _to_int(data.get("user_id"))
    opp_id = _to_int(data.get("opportunity_id"))

    if user_id is None or opp_id is None:
        if request.is_json:
            return jsonify({"error": "user_id and opportunity_id are required"}), 400
        flash("Select both a student and an opportunity.")
        return redirect(
            url_for(
                "main.new_application_form",
                user_id=data.get("user_id"),
                opportunity_id=data.get("opportunity_id"),
            )
        )

    conn, cur = _db()
    try:
        app_row = q.create_application(cur, user_id, opp_id)
        conn.commit()
    except (mysql.connector.IntegrityError, ValueError):
        conn.rollback()
        if request.is_json:
            return jsonify({"error": "application already exists or invalid IDs"}), 409
        flash("Unable to submit that application. It may already exist.")
        return redirect(
            url_for(
                "main.new_application_form",
                user_id=user_id,
                opportunity_id=opp_id,
            )
        )
    finally:
        cur.close()
        conn.close()

    if request.is_json:
        return jsonify(app_row), 201

    flash("Application submitted successfully.")
    return redirect(
        url_for(
            "main.list_applications",
            user_id=user_id,
            opportunity_id=opp_id,
        )
    )


@main.route("/applications/<int:user_id>/<int:opportunity_id>", methods=["PUT"])
def update_application_status(user_id, opportunity_id):
    """Update an application's status. JSON API route."""
    data = request.get_json(silent=True) or {}
    status = (data.get("status") or "").strip()

    if status not in APPLICATION_STATUSES:
        return jsonify({"error": "invalid application status"}), 400

    conn, cur = _db()
    try:
        updated = q.update_application_status(cur, user_id, opportunity_id, status)
        conn.commit()
        if not updated:
            return jsonify({"error": "application not found"}), 404
        applications = q.get_all_applications(
            cur,
            user_id=user_id,
            opportunity_id=opportunity_id,
        )
    finally:
        cur.close()
        conn.close()

    return jsonify(applications[0]), 200


@main.route("/applications/<int:user_id>/<int:opportunity_id>/status", methods=["POST"])
def update_application_status_form(user_id, opportunity_id):
    """Update an application's status from a browser form."""
    status = (request.form.get("status") or "").strip()
    if status not in APPLICATION_STATUSES:
        flash("Select a valid application status.")
        return redirect(_safe_next(url_for("main.list_applications", user_id=user_id)))

    conn, cur = _db()
    try:
        updated = q.update_application_status(cur, user_id, opportunity_id, status)
        conn.commit()
    finally:
        cur.close()
        conn.close()

    if not updated:
        flash("Application not found.")
    else:
        flash("Application status updated.")
    return redirect(_safe_next(url_for("main.list_applications", user_id=user_id)))


@main.route("/applications", methods=["DELETE"])
def delete_application():
    """Withdraw an application. Returns JSON or 404 if not found."""
    data = request.get_json(silent=True) or {} if request.is_json else request.form

    user_id = _to_int(data.get("user_id"))
    opp_id = _to_int(data.get("opportunity_id"))

    if user_id is None or opp_id is None:
        return jsonify({"error": "user_id and opportunity_id are required"}), 400

    conn, cur = _db()
    try:
        deleted = q.delete_application(cur, user_id, opp_id)
        conn.commit()
    finally:
        cur.close()
        conn.close()

    if not deleted:
        return jsonify({"error": "application not found"}), 404
    return jsonify({"message": "application withdrawn"}), 200


@main.route("/applications/<int:user_id>/<int:opportunity_id>/delete", methods=["POST"])
def delete_application_form(user_id, opportunity_id):
    """Withdraw an application from a browser form."""
    conn, cur = _db()
    try:
        deleted = q.delete_application(cur, user_id, opportunity_id)
        conn.commit()
    finally:
        cur.close()
        conn.close()

    if not deleted:
        flash("Application not found.")
    else:
        flash("Application withdrawn successfully.")
    return redirect(_safe_next(url_for("main.list_applications", user_id=user_id)))


# --- Companies ----------------------------------------------------------------


@main.route("/companies")
def list_companies():
    """Return all companies. HTML for browsers, JSON for API."""
    conn, cur = _db()
    try:
        companies = q.get_all_companies(cur)
    finally:
        cur.close()
        conn.close()

    if _wants_html():
        return render_template("companies/list.html", companies=companies)
    return jsonify(companies), 200


# --- Skills -------------------------------------------------------------------


@main.route("/skills")
def list_skills():
    """Return all skills. HTML for browsers, JSON for API."""
    conn, cur = _db()
    try:
        skills = q.get_all_skills(cur)
    finally:
        cur.close()
        conn.close()

    if _wants_html():
        return render_template("skills/list.html", skills=skills)
    return jsonify(skills), 200


# --- Search -------------------------------------------------------------------


@main.route("/search")
def search():
    """Unified search page for students and opportunities."""
    major = (request.args.get("major") or "").strip()
    location = (request.args.get("location") or "").strip()
    skill_id = request.args.get("skill_id", type=int)
    searched = any([major, location, skill_id])

    conn, cur = _db()
    try:
        student_results = (
            q.search_students(
                cur,
                major=major or None,
                location=location or None,
                skill_id=skill_id,
            )
            if searched
            else []
        )
        opportunity_results = (
            q.search_opportunities(
                cur,
                location=location or None,
                skill_id=skill_id,
            )
            if searched
            else []
        )
        if _wants_html():
            majors = q.get_student_majors(cur)
            locations = q.get_search_locations(cur)
            skills = q.get_all_skills(cur)
    finally:
        cur.close()
        conn.close()

    if _wants_html():
        return render_template(
            "search.html",
            majors=majors,
            locations=locations,
            skills=skills,
            students=student_results,
            opportunities=opportunity_results,
            searched=searched,
            selected_major=major,
            selected_location=location,
            selected_skill_id=skill_id,
        )

    return jsonify(
        {
            "students": student_results,
            "opportunities": opportunity_results,
        }
    ), 200

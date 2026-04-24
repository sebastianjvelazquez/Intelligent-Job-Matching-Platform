"""
app/routes.py
-------------
Flask Blueprint with all HTTP routes.

Content negotiation strategy:
  - GET routes: return HTML (Jinja2 template) when the client sends
    Accept: text/html (i.e. a browser); return JSON otherwise (curl / API).
  - POST / PUT / DELETE routes: always return JSON so API clients get clean
    responses.  When a POST is submitted from an HTML form (no JSON body),
    the route redirects to the relevant list page on success.
"""

from flask import (
    Blueprint, render_template, request, jsonify,
    redirect, url_for, abort, flash,
)
import mysql.connector

from app import get_db_connection
from app import queries as q

main = Blueprint("main", __name__)


def _db():
    """Open a connection and return (connection, cursor)."""
    conn = get_db_connection()
    return conn, conn.cursor()


def _wants_html():
    """True when the caller is a browser (prefers text/html over JSON)."""
    return "text/html" in request.headers.get("Accept", "")


# ─── Home ────────────────────────────────────────────────────────────────────

@main.route("/")
def index():
    """Landing page with navigation links to all sections."""
    return render_template("index.html")


# ─── Students ────────────────────────────────────────────────────────────────

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
        return render_template("students/list.html", students=students)
    return jsonify(students), 200


@main.route("/students/new")
def new_student_form():
    """Render the Add Student form."""
    return render_template("students/form.html", student=None)


@main.route("/students/<int:user_id>")
def get_student(user_id):
    """Return one student with skills. HTML for browsers, JSON for API."""
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
    """Create a new student.

    Accepts JSON body (API) or HTML form data (browser).
    Returns 201 JSON on success; redirects on form submission.
    Returns 409 if the email already exists.
    """
    if request.is_json:
        data = request.get_json(silent=True) or {}
    else:
        data = request.form

    name     = (data.get("name")     or "").strip()
    email    = (data.get("email")    or "").strip()
    major    = (data.get("major")    or "").strip()
    location = (data.get("location") or "").strip()
    resume   = (data.get("resume")   or "").strip() or None

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
            {"user_id": new_id, "name": name, "email": email,
             "major": major, "location": location}
        ), 201
    flash("Student created successfully.")
    return redirect(url_for("main.list_students"))


@main.route("/students/<int:user_id>", methods=["PUT"])
def update_student(user_id):
    """Update editable fields for a student. Returns 200 JSON with updated data."""
    if request.is_json:
        data = request.get_json(silent=True) or {}
    else:
        data = dict(request.form)

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


@main.route("/students/<int:user_id>", methods=["DELETE"])
def delete_student(user_id):
    """Delete a student. Returns 200 JSON on success, 404 if not found."""
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


# ─── Opportunities ─────────────────────────────────────────────────────────────

@main.route("/opportunities")
def list_opportunities():
    """Return all opportunities. HTML for browsers, JSON for API."""
    conn, cur = _db()
    try:
        opps = q.get_all_opportunities(cur)
    finally:
        cur.close()
        conn.close()

    if _wants_html():
        return render_template("opportunities/list.html", opportunities=opps)
    return jsonify(opps), 200


@main.route("/opportunities/<int:opp_id>")
def get_opportunity(opp_id):
    """Return one opportunity with skills. HTML for browsers, JSON for API."""
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


# ─── Matching Algorithm ───────────────────────────────────────────────────────

@main.route("/match")
def match_form():
    """Render the match form (student dropdown)."""
    conn, cur = _db()
    try:
        students = q.get_all_students(cur)
    finally:
        cur.close()
        conn.close()
    return render_template("match/index.html", students=students)


@main.route("/match/<int:user_id>")
def match_results(user_id):
    """Return ranked match scores for a student.

    HTML results page for browsers, JSON array for API clients.
    Returns 404 if the student does not exist.
    """
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


# ─── Applications ─────────────────────────────────────────────────────────────

@main.route("/applications")
def list_applications():
    """Return all applications. HTML for browsers, JSON for API."""
    conn, cur = _db()
    try:
        apps = q.get_all_applications(cur)
    finally:
        cur.close()
        conn.close()

    if _wants_html():
        return render_template("applications/list.html", applications=apps)
    return jsonify(apps), 200


@main.route("/applications", methods=["POST"])
def create_application():
    """Create a new application. Returns 201 JSON or 409 on duplicate."""
    if request.is_json:
        data = request.get_json(silent=True) or {}
    else:
        data = request.form

    user_id = data.get("user_id")
    opp_id  = data.get("opportunity_id")

    if user_id is None or opp_id is None:
        return jsonify({"error": "user_id and opportunity_id are required"}), 400

    conn, cur = _db()
    try:
        app_row = q.create_application(cur, int(user_id), int(opp_id))
        conn.commit()
    except (mysql.connector.IntegrityError, ValueError):
        conn.rollback()
        return jsonify({"error": "application already exists or invalid IDs"}), 409
    finally:
        cur.close()
        conn.close()

    return jsonify(app_row), 201


@main.route("/applications", methods=["DELETE"])
def delete_application():
    """Withdraw an application. Returns 200 JSON or 404 if not found."""
    if request.is_json:
        data = request.get_json(silent=True) or {}
    else:
        data = request.form

    user_id = data.get("user_id")
    opp_id  = data.get("opportunity_id")

    if user_id is None or opp_id is None:
        return jsonify({"error": "user_id and opportunity_id are required"}), 400

    conn, cur = _db()
    try:
        deleted = q.delete_application(cur, int(user_id), int(opp_id))
        conn.commit()
    finally:
        cur.close()
        conn.close()

    if not deleted:
        return jsonify({"error": "application not found"}), 404
    return jsonify({"message": "application withdrawn"}), 200


# ─── Companies ────────────────────────────────────────────────────────────────

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


# ─── Skills ──────────────────────────────────────────────────────────────────

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

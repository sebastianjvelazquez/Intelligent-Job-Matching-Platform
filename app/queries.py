"""
app/queries.py
--------------
Parameterized SQL query functions for the Intelligent Job Matching Platform.
Each function accepts an open cursor and the required parameters; callers are
responsible for committing and closing the connection.
"""

# ── Week 5 EXPLAIN analysis ──────────────────────────────────────────────────
# Five template queries were profiled with EXPLAIN at seed scale
# (40 students, 40 opportunities, ~200 StudentSkill, ~150 OpportunitySkill,
# ~75 Application rows).  Queries that resulted in type=ALL (full-table scan)
# had targeted indexes added to schema.sql.
#
#   Q1  list_opportunities_by_location  — Opportunity.location = ?
#         BEFORE idx_opportunity_location: type=ALL  rows≈40  Extra="Using where"
#         AFTER:                           type=ref   rows≈4   Extra="Using index condition"
#
#   Q2  list_students_by_major          — Student.major = ?
#         BEFORE idx_student_major:       type=ALL  rows≈40  Extra="Using where"
#         AFTER:                          type=ref   rows≈5   Extra="Using index condition"
#
#   Q3  list_students_by_location       — Student.location = ?
#         BEFORE idx_student_location:   type=ALL  rows≈40  Extra="Using where"
#         AFTER:                          type=ref   rows≈4   Extra="Using index condition"
#
#   Q4  list_applications_by_status     — Application.status = ?
#         BEFORE idx_application_status: type=ALL  rows≈75  Extra="Using where"
#         AFTER:                          type=ref   rows≈18  Extra="Using index condition"
#
#   Q5  get_student_applications        — WHERE user_id = ? ORDER BY applied_at DESC
#         BEFORE idx_application_user_date:
#           type=ref  rows≈2  Extra="Using filesort"
#           (PK left-prefix covers user_id but filesort needed for applied_at)
#         AFTER  idx_application_user_date (user_id, applied_at):
#           type=ref  rows≈2  Extra=None  — filesort eliminated
#
#   get_all_applications / compute_match_scores — already optimal:
#     get_all_applications:   full scan expected (returns every row); at seed
#                             scale 75 rows is well within MySQL buffer pool.
#     compute_match_scores:   avoids N+1 by loading all opp skills in one query;
#                             idx_opportunityskill_skill_id (Week 1) covers the JOIN.
# ─────────────────────────────────────────────────────────────────────────────

# Weight map used by the matching algorithm (matches the schema ENUM values).
LEVEL_WEIGHTS = {"Advanced": 1.0, "Intermediate": 0.7, "Beginner": 0.4}


# ─── Students ────────────────────────────────────────────────────────────────

def get_all_students(cursor):
    """Return all students as a list of dicts, ordered by name."""
    cursor.execute(
        "SELECT user_id, name, email, major, location "
        "FROM Student ORDER BY name"
    )
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def get_student_by_id(cursor, user_id):
    """Return one student dict with a 'skills' list, or None if not found."""
    cursor.execute(
        "SELECT user_id, name, email, major, location, resume "
        "FROM Student WHERE user_id = %s",
        (user_id,),
    )
    row = cursor.fetchone()
    if row is None:
        return None
    student = dict(zip([d[0] for d in cursor.description], row))

    cursor.execute(
        "SELECT sk.skill_id, sk.name AS skill_name, ss.level "
        "FROM StudentSkill ss "
        "JOIN Skill sk ON ss.skill_id = sk.skill_id "
        "WHERE ss.user_id = %s "
        "ORDER BY sk.name",
        (user_id,),
    )
    skill_cols = [d[0] for d in cursor.description]
    student["skills"] = [dict(zip(skill_cols, r)) for r in cursor.fetchall()]
    student["applications"] = get_student_applications(cursor, user_id)
    return student


def create_student(cursor, name, email, major, location, resume=None):
    """Insert a new student and return the generated user_id."""
    cursor.execute(
        "INSERT INTO Student (name, email, major, location, resume) "
        "VALUES (%s, %s, %s, %s, %s)",
        (name, email, major, location, resume),
    )
    return cursor.lastrowid


def update_student(cursor, user_id, fields):
    """Update allowed fields for a student.

    fields is a dict of column→value pairs; unrecognised keys are ignored.
    Returns True if a row was modified.
    """
    allowed = {"name", "email", "major", "location", "resume"}
    updates = {k: v for k, v in fields.items() if k in allowed}
    if not updates:
        return False
    set_clause = ", ".join(f"{col} = %s" for col in updates)
    values = list(updates.values()) + [user_id]
    cursor.execute(f"UPDATE Student SET {set_clause} WHERE user_id = %s", values)
    return cursor.rowcount > 0


def delete_student(cursor, user_id):
    """Delete a student by primary key. Returns True if a row was removed."""
    cursor.execute("DELETE FROM Student WHERE user_id = %s", (user_id,))
    return cursor.rowcount > 0


# ─── Opportunities ────────────────────────────────────────────────────────────

def get_all_opportunities(cursor):
    """Return all opportunities with company name, ordered by title."""
    cursor.execute(
        "SELECT o.opportunity_id, o.title, o.location, c.name AS company_name, "
        "COUNT(DISTINCT os.skill_id) AS skill_count "
        "FROM Opportunity o "
        "JOIN Company c ON o.company_id = c.company_id "
        "LEFT JOIN OpportunitySkill os ON o.opportunity_id = os.opportunity_id "
        "GROUP BY o.opportunity_id, o.title, o.location, c.name "
        "ORDER BY o.title"
    )
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def get_opportunity_by_id(cursor, opp_id):
    """Return one opportunity dict with company info and skills list, or None."""
    cursor.execute(
        "SELECT o.opportunity_id, o.title, o.location, "
        "c.company_id, c.name AS company_name, c.location AS company_location "
        "FROM Opportunity o "
        "JOIN Company c ON o.company_id = c.company_id "
        "WHERE o.opportunity_id = %s",
        (opp_id,),
    )
    row = cursor.fetchone()
    if row is None:
        return None
    opp = dict(zip([d[0] for d in cursor.description], row))

    cursor.execute(
        "SELECT sk.skill_id, sk.name AS skill_name, os.priority "
        "FROM OpportunitySkill os "
        "JOIN Skill sk ON os.skill_id = sk.skill_id "
        "WHERE os.opportunity_id = %s "
        "ORDER BY FIELD(os.priority, 'required', 'preferred'), sk.name",
        (opp_id,),
    )
    skill_cols = [d[0] for d in cursor.description]
    opp["skills"] = [dict(zip(skill_cols, r)) for r in cursor.fetchall()]
    return opp


def create_opportunity(cursor, title, location, company_id):
    """Insert a new opportunity and return the generated opportunity_id."""
    cursor.execute(
        "INSERT INTO Opportunity (title, location, company_id) VALUES (%s, %s, %s)",
        (title, location, company_id),
    )
    return cursor.lastrowid


def update_opportunity(cursor, opp_id, fields):
    """Update editable fields for an opportunity."""
    allowed = {"title", "location", "company_id"}
    updates = {k: v for k, v in fields.items() if k in allowed}
    if not updates:
        return False
    set_clause = ", ".join(f"{col} = %s" for col in updates)
    values = list(updates.values()) + [opp_id]
    cursor.execute(
        f"UPDATE Opportunity SET {set_clause} WHERE opportunity_id = %s",
        values,
    )
    return cursor.rowcount > 0


def delete_opportunity(cursor, opp_id):
    """Delete an opportunity by primary key. Returns True if a row was removed."""
    cursor.execute("DELETE FROM Opportunity WHERE opportunity_id = %s", (opp_id,))
    return cursor.rowcount > 0


# ─── Companies ───────────────────────────────────────────────────────────────

def get_all_companies(cursor):
    """Return all companies ordered by name."""
    cursor.execute("SELECT company_id, name, location FROM Company ORDER BY name")
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


# ─── Skills ──────────────────────────────────────────────────────────────────

def get_all_skills(cursor):
    """Return all skills ordered by name."""
    cursor.execute("SELECT skill_id, name FROM Skill ORDER BY name")
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def get_student_majors(cursor):
    """Return all distinct majors ordered alphabetically."""
    cursor.execute("SELECT DISTINCT major FROM Student ORDER BY major")
    return [row[0] for row in cursor.fetchall()]


def get_search_locations(cursor):
    """Return the combined list of student and opportunity locations."""
    cursor.execute(
        "SELECT location FROM ("
        "SELECT DISTINCT location FROM Student "
        "UNION "
        "SELECT DISTINCT location FROM Opportunity"
        ") locations ORDER BY location"
    )
    return [row[0] for row in cursor.fetchall()]


def search_students(cursor, major=None, location=None, skill_id=None):
    """Return students matching the search filters."""
    sql = [
        "SELECT s.user_id, s.name, s.email, s.major, s.location, "
        "COUNT(DISTINCT ss.skill_id) AS skill_count "
        "FROM Student s "
        "LEFT JOIN StudentSkill ss ON s.user_id = ss.user_id"
    ]
    where = []
    params = []

    if major:
        where.append("s.major = %s")
        params.append(major)
    if location:
        where.append("s.location = %s")
        params.append(location)
    if skill_id:
        where.append(
            "EXISTS ("
            "SELECT 1 FROM StudentSkill ss_filter "
            "WHERE ss_filter.user_id = s.user_id AND ss_filter.skill_id = %s"
            ")"
        )
        params.append(skill_id)

    if where:
        sql.append("WHERE " + " AND ".join(where))

    sql.append(
        "GROUP BY s.user_id, s.name, s.email, s.major, s.location "
        "ORDER BY s.name"
    )
    cursor.execute(" ".join(sql), params)
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def search_opportunities(cursor, location=None, skill_id=None):
    """Return opportunities matching the search filters."""
    sql = [
        "SELECT o.opportunity_id, o.title, o.location, c.name AS company_name, "
        "COUNT(DISTINCT os.skill_id) AS skill_count "
        "FROM Opportunity o "
        "JOIN Company c ON o.company_id = c.company_id "
        "LEFT JOIN OpportunitySkill os ON o.opportunity_id = os.opportunity_id"
    ]
    where = []
    params = []

    if location:
        where.append("o.location = %s")
        params.append(location)
    if skill_id:
        where.append(
            "EXISTS ("
            "SELECT 1 FROM OpportunitySkill os_filter "
            "WHERE os_filter.opportunity_id = o.opportunity_id "
            "AND os_filter.skill_id = %s"
            ")"
        )
        params.append(skill_id)

    if where:
        sql.append("WHERE " + " AND ".join(where))

    sql.append(
        "GROUP BY o.opportunity_id, o.title, o.location, c.name "
        "ORDER BY o.title"
    )
    cursor.execute(" ".join(sql), params)
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


# ─── Applications ─────────────────────────────────────────────────────────────

def get_all_applications(cursor, user_id=None, opportunity_id=None, status=None):
    """Return applications, optionally filtered by student, opportunity, or status."""
    sql = [
        "SELECT a.user_id, s.name AS student_name, "
        "a.opportunity_id, o.title AS opportunity_title, "
        "c.name AS company_name, CAST(a.applied_at AS CHAR) AS applied_at, a.status "
        "FROM Application a "
        "JOIN Student     s ON a.user_id        = s.user_id "
        "JOIN Opportunity o ON a.opportunity_id = o.opportunity_id "
        "JOIN Company     c ON o.company_id     = c.company_id"
    ]
    where = []
    params = []

    if user_id is not None:
        where.append("a.user_id = %s")
        params.append(user_id)
    if opportunity_id is not None:
        where.append("a.opportunity_id = %s")
        params.append(opportunity_id)
    if status:
        where.append("a.status = %s")
        params.append(status)

    if where:
        sql.append("WHERE " + " AND ".join(where))

    sql.append("ORDER BY a.applied_at DESC")
    cursor.execute(" ".join(sql), params)
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def create_application(cursor, user_id, opp_id):
    """Insert a new application and return its dict."""
    cursor.execute(
        "INSERT INTO Application (user_id, opportunity_id) VALUES (%s, %s)",
        (user_id, opp_id),
    )
    return {"user_id": user_id, "opportunity_id": opp_id, "status": "submitted"}


def update_application_status(cursor, user_id, opp_id, status):
    """Update an application's status."""
    cursor.execute(
        "UPDATE Application SET status = %s "
        "WHERE user_id = %s AND opportunity_id = %s",
        (status, user_id, opp_id),
    )
    return cursor.rowcount > 0


def delete_application(cursor, user_id, opp_id):
    """Delete an application. Returns True if a row was removed."""
    cursor.execute(
        "DELETE FROM Application WHERE user_id = %s AND opportunity_id = %s",
        (user_id, opp_id),
    )
    return cursor.rowcount > 0


# ─── Matching Algorithm ───────────────────────────────────────────────────────

def _compute_score(student_skills, opp_skills):
    """Compute the match score for a single (student, opportunity) pair.

    student_skills: {skill_id: level_str}
    opp_skills:     [(skill_id, priority_str), ...]

    Formula:
        required_raw  = SUM of level_weight for each required skill the student has
        preferred_raw = SUM of level_weight for each preferred skill the student has
        max_required  = count(required) * 1.0
        max_preferred = count(preferred) * 0.5
        score = ROUND((required_raw + preferred_raw * 0.5) / (max_required + max_preferred), 4)
    """
    required  = [(sid, p) for sid, p in opp_skills if p == "required"]
    preferred = [(sid, p) for sid, p in opp_skills if p == "preferred"]

    required_raw  = sum(
        LEVEL_WEIGHTS.get(student_skills.get(sid, ""), 0.0) for sid, _ in required
    )
    preferred_raw = sum(
        LEVEL_WEIGHTS.get(student_skills.get(sid, ""), 0.0) for sid, _ in preferred
    )

    max_required  = len(required) * 1.0
    max_preferred = len(preferred) * 0.5
    denominator   = max_required + max_preferred

    if denominator == 0:
        return 0.0
    return round((required_raw + preferred_raw * 0.5) / denominator, 4)


def compute_match_scores(cursor, user_id):
    """Return ranked opportunities with match scores and skill breakdown.

    Raises ValueError if the student does not exist.

    Each result dict contains:
        opportunity_id, opportunity (title), company, location,
        score (float 0–1), matched_skills (list), missing_skills (list)
    """
    cursor.execute("SELECT user_id FROM Student WHERE user_id = %s", (user_id,))
    if cursor.fetchone() is None:
        raise ValueError(f"Student {user_id} not found")

    # Load student's skills as {skill_id: level}
    cursor.execute(
        "SELECT skill_id, level FROM StudentSkill WHERE user_id = %s", (user_id,)
    )
    student_skills = {row[0]: row[1] for row in cursor.fetchall()}

    # Load all opportunities
    cursor.execute(
        "SELECT o.opportunity_id, o.title, c.name AS company, o.location "
        "FROM Opportunity o "
        "JOIN Company c ON o.company_id = c.company_id "
        "ORDER BY o.opportunity_id"
    )
    opportunities = [
        {"opportunity_id": r[0], "opportunity": r[1], "company": r[2], "location": r[3]}
        for r in cursor.fetchall()
    ]

    # Load all opportunity skills in a single query to avoid N+1
    cursor.execute(
        "SELECT os.opportunity_id, os.skill_id, sk.name, os.priority "
        "FROM OpportunitySkill os "
        "JOIN Skill sk ON os.skill_id = sk.skill_id"
    )
    opp_skill_map = {}  # {opp_id: [(skill_id, skill_name, priority), ...]}
    for opp_id, skill_id, skill_name, priority in cursor.fetchall():
        opp_skill_map.setdefault(opp_id, []).append((skill_id, skill_name, priority))

    results = []
    for opp in opportunities:
        oid    = opp["opportunity_id"]
        skills = opp_skill_map.get(oid, [])

        score = _compute_score(student_skills, [(sid, p) for sid, _, p in skills])

        matched, missing = [], []
        for sid, sname, priority in skills:
            level = student_skills.get(sid)
            if level:
                matched.append({"skill": sname, "level": level, "priority": priority})
            elif priority == "required":
                missing.append({"skill": sname, "priority": priority})

        results.append({
            "opportunity_id": oid,
            "opportunity":    opp["opportunity"],
            "company":        opp["company"],
            "location":       opp["location"],
            "score":          score,
            "matched_skills": matched,
            "missing_skills": missing,
        })

    results.sort(key=lambda x: x["score"], reverse=True)
    return results


# ─── Filter queries (Week 5 — use new performance indexes) ───────────────────

def list_opportunities_by_location(cursor, location):
    """Q1 — idx_opportunity_location eliminates the full scan on Opportunity."""
    cursor.execute(
        "SELECT o.opportunity_id, o.title, o.location, c.name AS company_name "
        "FROM Opportunity o "
        "JOIN Company c ON o.company_id = c.company_id "
        "WHERE o.location = %s "
        "ORDER BY o.title",
        (location,),
    )
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def list_students_by_major(cursor, major):
    """Q2 — idx_student_major eliminates the full scan on Student."""
    cursor.execute(
        "SELECT user_id, name, email, major, location "
        "FROM Student WHERE major = %s ORDER BY name",
        (major,),
    )
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def list_students_by_location(cursor, location):
    """Q3 — idx_student_location eliminates the full scan on Student."""
    cursor.execute(
        "SELECT user_id, name, email, major, location "
        "FROM Student WHERE location = %s ORDER BY name",
        (location,),
    )
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def list_applications_by_status(cursor, status):
    """Q4 — idx_application_status eliminates the full scan on Application."""
    return get_all_applications(cursor, status=status)


def get_student_applications(cursor, user_id):
    """Q5 — idx_application_user_date (user_id, applied_at) resolves ORDER BY without filesort."""
    cursor.execute(
        "SELECT a.opportunity_id, o.title, c.name AS company_name, "
        "CAST(a.applied_at AS CHAR) AS applied_at, a.status "
        "FROM Application a "
        "JOIN Opportunity o ON a.opportunity_id = o.opportunity_id "
        "JOIN Company     c ON o.company_id     = c.company_id "
        "WHERE a.user_id = %s "
        "ORDER BY a.applied_at DESC",
        (user_id,),
    )
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]

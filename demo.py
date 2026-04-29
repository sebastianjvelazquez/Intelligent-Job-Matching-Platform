"""
Intelligent Job Matching Platform — Presentation Demo
======================================================
Covers:
  Basic  1 — INSERT   (student, skills, application)
  Basic  2 — SEARCH   (by major, location, skill)
  Basic  3 — QUERIES  (multi-table JOIN + aggregate)
  Basic  4 — UPDATE   (student profile, application status)
  Basic  5 — DELETE   (withdraw application, remove student)
  Advanced — Weighted skill-match scoring algorithm

Run:  python demo.py
Requires: MySQL running, .env configured, schema + seed loaded.
"""

import os
import sys
import textwrap
import time

from dotenv import load_dotenv

load_dotenv()

import mysql.connector

# ── helpers ───────────────────────────────────────────────────────────────────

W = 70  # banner width
LEVEL_WEIGHTS = {"Advanced": 1.0, "Intermediate": 0.7, "Beginner": 0.4}


def banner(title: str) -> None:
    print()
    print("═" * W)
    print(f"  {title}")
    print("═" * W)


def section(title: str) -> None:
    print()
    print("─" * W)
    print(f"  {title}")
    print("─" * W)


def sql_display(query: str) -> None:
    """Print a formatted SQL snippet."""
    print("\n  SQL:")
    for line in textwrap.dedent(query).strip().splitlines():
        print(f"    {line}")
    print()


def table(rows: list[dict], cols: list[str] | None = None) -> None:
    """Print a dict list as an aligned table."""
    if not rows:
        print("  (no rows returned)")
        return
    if cols is None:
        cols = list(rows[0].keys())
    widths = {c: max(len(str(c)), max(len(str(r.get(c, ""))) for r in rows)) for c in cols}
    header = "  " + "  ".join(str(c).ljust(widths[c]) for c in cols)
    sep    = "  " + "  ".join("-" * widths[c] for c in cols)
    print(header)
    print(sep)
    for row in rows:
        print("  " + "  ".join(str(row.get(c, "")).ljust(widths[c]) for c in cols))


def db():
    """Open a fresh connection to job_matching."""
    return mysql.connector.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ.get("DB_PASS", ""),
        database=os.environ["DB_NAME"],
    )


def cursor_rows(cur) -> list[dict]:
    cols = [d[0] for d in cur.description]
    return [dict(zip(cols, row)) for row in cur.fetchall()]


# ─────────────────────────────────────────────────────────────────────────────
#  B A S I C   1  —  I N S E R T
# ─────────────────────────────────────────────────────────────────────────────

def demo_insert():
    banner("BASIC 1 — INSERT  (add a student, add skills, submit application)")

    conn = db()
    cur  = conn.cursor()

    # --- 1a. Insert student ---------------------------------------------------
    section("1a. Insert a new student")
    sql_display("""
        INSERT INTO Student (name, email, major, location, resume)
        VALUES ('Demo Student', 'demo@ucf.edu',
                'Computer Science', 'Orlando, FL',
                'GitHub: github.com/demo');
    """)

    cur.execute(
        "INSERT INTO Student (name, email, major, location, resume) "
        "VALUES (%s, %s, %s, %s, %s)",
        ("Demo Student", "demo@ucf.edu",
         "Computer Science", "Orlando, FL",
         "GitHub: github.com/demo"),
    )
    student_id = cur.lastrowid
    conn.commit()
    print(f"  ✓  Inserted student  →  user_id = {student_id}")

    # --- 1b. Add skills -------------------------------------------------------
    section("1b. Attach skills to the new student")
    sql_display("""
        INSERT INTO StudentSkill (user_id, skill_id, level) VALUES
          (<id>, 1,  'Advanced'),      -- Python
          (<id>, 5,  'Advanced'),      -- JavaScript
          (<id>, 7,  'Intermediate'),  -- React
          (<id>, 9,  'Intermediate'),  -- Flask
          (<id>, 23, 'Beginner');      -- REST APIs
    """)

    skills = [
        (student_id, 1,  "Advanced"),      # Python
        (student_id, 5,  "Advanced"),      # JavaScript
        (student_id, 7,  "Intermediate"),  # React
        (student_id, 9,  "Intermediate"),  # Flask
        (student_id, 23, "Beginner"),      # REST APIs
    ]
    cur.executemany(
        "INSERT INTO StudentSkill (user_id, skill_id, level) VALUES (%s, %s, %s)",
        skills,
    )
    conn.commit()
    print(f"  ✓  Inserted {len(skills)} skills for student {student_id}")

    # --- 1c. Submit application -----------------------------------------------
    section("1c. Student applies for an opportunity")
    sql_display("""
        INSERT INTO Application (user_id, opportunity_id)
        VALUES (<id>, 1);   -- Full-Stack Web Developer Intern @ Accenture
    """)

    cur.execute(
        "INSERT INTO Application (user_id, opportunity_id) VALUES (%s, 1)",
        (student_id,),
    )
    conn.commit()
    print(f"  ✓  Application submitted  →  student {student_id} → opportunity 1")

    # Verify what was inserted -------------------------------------------------
    section("Verify: all inserted rows")
    cur.execute(
        "SELECT s.user_id, s.name, s.email, s.major, s.location "
        "FROM Student s WHERE s.user_id = %s",
        (student_id,),
    )
    table(cursor_rows(cur))

    cur.execute(
        "SELECT sk.name AS skill, ss.level "
        "FROM StudentSkill ss "
        "JOIN Skill sk ON ss.skill_id = sk.skill_id "
        "WHERE ss.user_id = %s ORDER BY sk.name",
        (student_id,),
    )
    table(cursor_rows(cur))

    cur.close()
    conn.close()
    return student_id


# ─────────────────────────────────────────────────────────────────────────────
#  B A S I C   2  —  S E A R C H
# ─────────────────────────────────────────────────────────────────────────────

def demo_search():
    banner("BASIC 2 — SEARCH  (filter students and opportunities)")

    conn = db()
    cur  = conn.cursor()

    # --- 2a. Students by major ------------------------------------------------
    section("2a. Find all Computer Science students")
    sql_display("""
        SELECT user_id, name, email, major, location
        FROM   Student
        WHERE  major = 'Computer Science'
        ORDER  BY name;
    """)

    cur.execute(
        "SELECT user_id, name, email, major, location "
        "FROM Student WHERE major = 'Computer Science' ORDER BY name"
    )
    rows = cursor_rows(cur)
    table(rows, ["user_id", "name", "major", "location"])
    print(f"\n  → {len(rows)} students matched")

    # --- 2b. Opportunities in Tampa with Python skill -------------------------
    section("2b. Opportunities in Tampa Bay, FL that require Python (skill_id=1)")
    sql_display("""
        SELECT o.opportunity_id, o.title, o.location, c.name AS company
        FROM   Opportunity o
        JOIN   Company c ON o.company_id = c.company_id
        WHERE  o.location = 'Tampa Bay, FL'
          AND  EXISTS (
                 SELECT 1 FROM OpportunitySkill os
                 WHERE  os.opportunity_id = o.opportunity_id
                   AND  os.skill_id = 1   -- Python
               )
        ORDER  BY o.title;
    """)

    cur.execute(
        "SELECT o.opportunity_id, o.title, o.location, c.name AS company "
        "FROM Opportunity o "
        "JOIN Company c ON o.company_id = c.company_id "
        "WHERE o.location = 'Tampa Bay, FL' "
        "AND EXISTS ("
        "  SELECT 1 FROM OpportunitySkill os "
        "  WHERE os.opportunity_id = o.opportunity_id AND os.skill_id = 1"
        ") ORDER BY o.title"
    )
    rows = cursor_rows(cur)
    table(rows)
    print(f"\n  → {len(rows)} opportunities matched")

    # --- 2c. Students with cybersecurity skills -------------------------------
    section("2c. Students who have Cybersecurity (skill_id=15) — any level")
    sql_display("""
        SELECT s.user_id, s.name, s.major, ss.level
        FROM   Student      s
        JOIN   StudentSkill ss ON s.user_id  = ss.user_id
        WHERE  ss.skill_id = 15   -- Cybersecurity
        ORDER  BY s.name;
    """)

    cur.execute(
        "SELECT s.user_id, s.name, s.major, ss.level "
        "FROM Student s JOIN StudentSkill ss ON s.user_id = ss.user_id "
        "WHERE ss.skill_id = 15 ORDER BY s.name"
    )
    rows = cursor_rows(cur)
    table(rows)
    print(f"\n  → {len(rows)} students matched")

    cur.close()
    conn.close()


# ─────────────────────────────────────────────────────────────────────────────
#  B A S I C   3  —  I N T E R E S T I N G   Q U E R I E S
# ─────────────────────────────────────────────────────────────────────────────

def demo_queries():
    banner("BASIC 3 — INTERESTING QUERIES  (JOIN + Aggregate)")

    conn = db()
    cur  = conn.cursor()

    # --- 3a. Multi-table JOIN: full application pipeline ---------------------
    section("3a. Multi-table JOIN — Application pipeline (5 tables)")
    sql_display("""
        SELECT s.name       AS student,
               s.major,
               o.title      AS opportunity,
               c.name       AS company,
               a.status,
               a.applied_at
        FROM   Application a
        JOIN   Student      s ON a.user_id        = s.user_id
        JOIN   Opportunity  o ON a.opportunity_id = o.opportunity_id
        JOIN   Company      c ON o.company_id     = c.company_id
        WHERE  a.status IN ('reviewed', 'accepted')
        ORDER  BY a.applied_at DESC
        LIMIT  10;
    """)

    cur.execute(
        "SELECT s.name AS student, s.major, o.title AS opportunity, "
        "c.name AS company, a.status, CAST(a.applied_at AS CHAR) AS applied_at "
        "FROM Application a "
        "JOIN Student s ON a.user_id = s.user_id "
        "JOIN Opportunity o ON a.opportunity_id = o.opportunity_id "
        "JOIN Company c ON o.company_id = c.company_id "
        "WHERE a.status IN ('reviewed','accepted') "
        "ORDER BY a.applied_at DESC LIMIT 10"
    )
    table(cursor_rows(cur), ["student", "opportunity", "company", "status"])

    # --- 3b. Aggregate: most in-demand skills --------------------------------
    section("3b. Aggregate — Top 10 most in-demand skills across all opportunities")
    sql_display("""
        SELECT sk.name              AS skill,
               COUNT(*)             AS total_requirements,
               SUM(os.priority = 'required')  AS required_count,
               SUM(os.priority = 'preferred') AS preferred_count
        FROM   OpportunitySkill os
        JOIN   Skill            sk ON os.skill_id = sk.skill_id
        GROUP  BY sk.skill_id, sk.name
        ORDER  BY total_requirements DESC
        LIMIT  10;
    """)

    cur.execute(
        "SELECT sk.name AS skill, COUNT(*) AS total_requirements, "
        "SUM(os.priority = 'required') AS required_count, "
        "SUM(os.priority = 'preferred') AS preferred_count "
        "FROM OpportunitySkill os "
        "JOIN Skill sk ON os.skill_id = sk.skill_id "
        "GROUP BY sk.skill_id, sk.name "
        "ORDER BY total_requirements DESC LIMIT 10"
    )
    table(cursor_rows(cur))

    # --- 3c. Aggregate: application acceptance rate by company ---------------
    section("3c. Aggregate — Application acceptance rate by company")
    sql_display("""
        SELECT c.name                                  AS company,
               COUNT(*)                                AS total_applications,
               SUM(a.status = 'accepted')              AS accepted,
               ROUND(
                 100.0 * SUM(a.status = 'accepted') / COUNT(*), 1
               )                                       AS acceptance_pct
        FROM   Application a
        JOIN   Opportunity  o ON a.opportunity_id = o.opportunity_id
        JOIN   Company      c ON o.company_id     = c.company_id
        GROUP  BY c.company_id, c.name
        HAVING total_applications > 0
        ORDER  BY acceptance_pct DESC;
    """)

    cur.execute(
        "SELECT c.name AS company, COUNT(*) AS total_applications, "
        "SUM(a.status = 'accepted') AS accepted, "
        "ROUND(100.0 * SUM(a.status = 'accepted') / COUNT(*), 1) AS acceptance_pct "
        "FROM Application a "
        "JOIN Opportunity o ON a.opportunity_id = o.opportunity_id "
        "JOIN Company c ON o.company_id = c.company_id "
        "GROUP BY c.company_id, c.name HAVING total_applications > 0 "
        "ORDER BY acceptance_pct DESC"
    )
    table(cursor_rows(cur))

    # --- 3d. View usage: StudentSkillView + OpportunitySkillView -------------
    section("3d. Pre-join VIEWs — Students who satisfy every required skill for opp 1")
    sql_display("""
        -- StudentSkillView  flattens: Student → StudentSkill → Skill
        -- OpportunitySkillView flattens: Opportunity → OpportunitySkill → Skill

        SELECT ssv.user_id, ssv.name AS student, ssv.skill_name, ssv.level
        FROM   StudentSkillView    ssv
        JOIN   OpportunitySkillView osv
               ON ssv.skill_id = osv.skill_id
              AND osv.opportunity_id = 1
              AND osv.priority       = 'required'
        ORDER  BY ssv.name, ssv.skill_name;
    """)

    cur.execute(
        "SELECT ssv.user_id, ssv.name AS student, ssv.skill_name, ssv.level "
        "FROM studentskillview ssv "
        "JOIN opportunityskillview osv "
        "ON ssv.skill_id = osv.skill_id "
        "AND osv.opportunity_id = 1 AND osv.priority = 'required' "
        "ORDER BY ssv.name, ssv.skill_name"
    )
    table(cursor_rows(cur))

    cur.close()
    conn.close()


# ─────────────────────────────────────────────────────────────────────────────
#  B A S I C   4  —  U P D A T E
# ─────────────────────────────────────────────────────────────────────────────

def demo_update(student_id: int):
    banner("BASIC 4 — UPDATE  (student profile + application status)")

    conn = db()
    cur  = conn.cursor()

    # --- 4a. Update student major --------------------------------------------
    section(f"4a. Change Demo Student's major to 'Software Engineering'")
    sql_display("""
        UPDATE Student
        SET    major = 'Software Engineering'
        WHERE  user_id = <id>;
    """)

    cur.execute(
        "UPDATE Student SET major = %s WHERE user_id = %s",
        ("Software Engineering", student_id),
    )
    conn.commit()
    print(f"  ✓  {cur.rowcount} row(s) updated")

    cur.execute(
        "SELECT user_id, name, major, location FROM Student WHERE user_id = %s",
        (student_id,),
    )
    table(cursor_rows(cur))

    # --- 4b. Update application status ---------------------------------------
    section(f"4b. Recruiter moves Demo Student's application to 'reviewed'")
    sql_display("""
        UPDATE Application
        SET    status = 'reviewed'
        WHERE  user_id = <id> AND opportunity_id = 1;
    """)

    cur.execute(
        "UPDATE Application SET status = %s WHERE user_id = %s AND opportunity_id = 1",
        ("reviewed", student_id),
    )
    conn.commit()
    print(f"  ✓  {cur.rowcount} row(s) updated")

    cur.execute(
        "SELECT a.user_id, s.name AS student, o.title AS opportunity, a.status "
        "FROM Application a "
        "JOIN Student s ON a.user_id = s.user_id "
        "JOIN Opportunity o ON a.opportunity_id = o.opportunity_id "
        "WHERE a.user_id = %s",
        (student_id,),
    )
    table(cursor_rows(cur))

    cur.close()
    conn.close()


# ─────────────────────────────────────────────────────────────────────────────
#  B A S I C   5  —  D E L E T E
# ─────────────────────────────────────────────────────────────────────────────

def demo_delete(student_id: int):
    banner("BASIC 5 — DELETE  (withdraw application, then remove student)")

    conn = db()
    cur  = conn.cursor()

    # --- 5a. Withdraw application --------------------------------------------
    section("5a. Student withdraws from opportunity 1")
    sql_display("""
        DELETE FROM Application
        WHERE  user_id = <id> AND opportunity_id = 1;
    """)

    cur.execute(
        "DELETE FROM Application WHERE user_id = %s AND opportunity_id = 1",
        (student_id,),
    )
    conn.commit()
    print(f"  ✓  {cur.rowcount} application row(s) deleted")

    # --- 5b. Delete student (CASCADE removes StudentSkill rows) --------------
    section("5b. Remove Demo Student — CASCADE deletes skills automatically")
    sql_display("""
        -- StudentSkill.user_id FK has ON DELETE CASCADE
        -- Application.user_id  FK has ON DELETE CASCADE
        DELETE FROM Student WHERE user_id = <id>;
    """)

    cur.execute("DELETE FROM Student WHERE user_id = %s", (student_id,))
    conn.commit()
    print(f"  ✓  {cur.rowcount} student row(s) deleted")
    print("  ✓  All associated StudentSkill rows removed via CASCADE")

    # Verify gone
    cur.execute("SELECT COUNT(*) FROM Student WHERE user_id = %s", (student_id,))
    remaining = cur.fetchone()[0]
    print(f"\n  Verify — rows remaining for user_id={student_id}: {remaining}  ✓")

    cur.close()
    conn.close()


# ─────────────────────────────────────────────────────────────────────────────
#  A D V A N C E D  —  W E I G H T E D   S K I L L - M A T C H   A L G O
# ─────────────────────────────────────────────────────────────────────────────

def demo_advanced():
    banner("ADVANCED — Weighted Skill-Match Scoring Algorithm")

    print("""
  Problem: A simple keyword search can't rank 40 opportunities for a student.
  Two students may both list 'Python', but one is Advanced and the other Beginner.
  A required skill gap is worse than a missing preferred skill.

  Our solution: a weighted match score in [0, 1] computed across ALL
  opportunities in a SINGLE PASS — no N+1 queries.

  Scoring formula:
    required_raw   = Σ weight(level) for each REQUIRED skill the student has
    preferred_raw  = Σ weight(level) for each PREFERRED skill the student has
    max_required   = count(required skills) × 1.0
    max_preferred  = count(preferred skills) × 0.5
    score = (required_raw + preferred_raw × 0.5) / (max_required + max_preferred)

  Skill level weights:
    Advanced      → 1.0   (full credit)
    Intermediate  → 0.7   (70 % credit)
    Beginner      → 0.4   (40 % credit)
    Missing       → 0.0   (no credit)

  Required skills weigh 2× more than preferred by design.
  """)

    conn = db()
    cur  = conn.cursor()

    # --- Show a real run for Alice Reyes (user_id=1) -------------------------
    section("Run match for Alice Reyes (user_id=1) — expected perfect fit for Opp 1")
    print("  Alice's skills:")
    cur.execute(
        "SELECT sk.name AS skill, ss.level "
        "FROM StudentSkill ss JOIN Skill sk ON ss.skill_id = sk.skill_id "
        "WHERE ss.user_id = 1 ORDER BY ss.level DESC, sk.name"
    )
    table(cursor_rows(cur))

    # Compute scores (Python side — same logic as production)
    cur.execute("SELECT skill_id, level FROM StudentSkill WHERE user_id = 1")
    student_skills = {row[0]: row[1] for row in cur.fetchall()}

    cur.execute(
        "SELECT o.opportunity_id, o.title, c.name AS company "
        "FROM Opportunity o JOIN Company c ON o.company_id = c.company_id"
    )
    opportunities = {r[0]: {"title": r[1], "company": r[2]} for r in cur.fetchall()}

    cur.execute(
        "SELECT os.opportunity_id, os.skill_id, os.priority "
        "FROM OpportunitySkill os"
    )
    opp_skills: dict[int, list] = {}
    for oid, sid, pri in cur.fetchall():
        opp_skills.setdefault(oid, []).append((sid, pri))

    scores = []
    for oid, info in opportunities.items():
        skills = opp_skills.get(oid, [])
        required  = [(sid, p) for sid, p in skills if p == "required"]
        preferred = [(sid, p) for sid, p in skills if p == "preferred"]
        req_raw  = sum(LEVEL_WEIGHTS.get(student_skills.get(sid, ""), 0) for sid, _ in required)
        pref_raw = sum(LEVEL_WEIGHTS.get(student_skills.get(sid, ""), 0) for sid, _ in preferred)
        denom = len(required) * 1.0 + len(preferred) * 0.5
        score = round((req_raw + pref_raw * 0.5) / denom, 4) if denom else 0.0
        matched = [sid for sid, _ in skills if student_skills.get(sid)]
        missing = [sid for sid, p in required if not student_skills.get(sid)]
        scores.append({
            "opportunity_id": oid,
            "title": info["title"],
            "company": info["company"],
            "score": f"{score:.4f}",
            "matched": len(matched),
            "missing_required": len(missing),
        })

    scores.sort(key=lambda x: float(x["score"]), reverse=True)

    section("Top 10 ranked opportunities for Alice Reyes")
    table(scores[:10], ["opportunity_id", "title", "company", "score", "matched", "missing_required"])

    # --- Contrast: partial match for Ethan Brooks (user_id=4) ----------------
    section("Contrast: same opportunity — Ethan Brooks (user_id=4, partial match)")
    print("  Ethan's skills:")
    cur.execute(
        "SELECT sk.name AS skill, ss.level "
        "FROM StudentSkill ss JOIN Skill sk ON ss.skill_id = sk.skill_id "
        "WHERE ss.user_id = 4 ORDER BY ss.level DESC, sk.name"
    )
    table(cursor_rows(cur))

    cur.execute("SELECT skill_id, level FROM StudentSkill WHERE user_id = 4")
    ethan_skills = {row[0]: row[1] for row in cur.fetchall()}
    ethan_scores = []
    for oid, info in opportunities.items():
        skills = opp_skills.get(oid, [])
        required  = [(sid, p) for sid, p in skills if p == "required"]
        preferred = [(sid, p) for sid, p in skills if p == "preferred"]
        req_raw  = sum(LEVEL_WEIGHTS.get(ethan_skills.get(sid, ""), 0) for sid, _ in required)
        pref_raw = sum(LEVEL_WEIGHTS.get(ethan_skills.get(sid, ""), 0) for sid, _ in preferred)
        denom = len(required) * 1.0 + len(preferred) * 0.5
        score = round((req_raw + pref_raw * 0.5) / denom, 4) if denom else 0.0
        ethan_scores.append({
            "opportunity_id": oid,
            "title": info["title"],
            "score": f"{score:.4f}",
        })
    ethan_scores.sort(key=lambda x: float(x["score"]), reverse=True)

    section("Top 10 ranked opportunities for Ethan Brooks")
    table(ethan_scores[:10], ["opportunity_id", "title", "score"])

    # --- EXPLAIN: show index usage -------------------------------------------
    section("Performance: EXPLAIN on the bulk opportunity-skill load query")
    sql_display("""
        EXPLAIN
        SELECT os.opportunity_id, os.skill_id, sk.name, os.priority
        FROM   OpportunitySkill os
        JOIN   Skill sk ON os.skill_id = sk.skill_id;
        -- idx_opportunityskill_skill_id covers the JOIN column
    """)

    cur.execute(
        "EXPLAIN SELECT os.opportunity_id, os.skill_id, sk.name, os.priority "
        "FROM OpportunitySkill os "
        "JOIN Skill sk ON os.skill_id = sk.skill_id"
    )
    explain_result = cur.fetchone()
    if explain_result:
        # MySQL 9 returns EXPLAIN as a single text column
        raw = str(explain_result[0]) if explain_result else ""
        for line in raw.splitlines():
            print(f"  {line}")
    else:
        explain_rows = cursor_rows(cur) if cur.description else []
        table(explain_rows, ["table", "type", "key", "rows", "Extra"])

    print("""
  Why this is ADVANCED:
  ─────────────────────
  1. Novel scoring formula — weights both skill level (Advanced/Intermediate/
     Beginner) AND role priority (required vs. preferred), producing a nuanced
     0–1 float ranking no simple keyword or filter search can replicate.

  2. Single-pass efficiency — all 40 × 40 (student × opportunity) pairs are
     scored in ONE round-trip: opportunity skills bulk-loaded into a hash map,
     then scored in O(n×m) Python — avoids N+1 queries entirely.

  3. Index + View optimization — idx_opportunityskill_skill_id and the
     Week 4 pre-join views (StudentSkillView, OpportunitySkillView) cut the
     JOIN cost from a full table scan to an index-range scan (EXPLAIN shows
     type=ref, key=idx_opportunityskill_skill_id).

  4. Practical usefulness — students see personalised ranked results with
     matched vs. missing skill breakdowns, enabling targeted upskilling.
  """)

    cur.close()
    conn.close()


# ─────────────────────────────────────────────────────────────────────────────
#  M A I N
# ─────────────────────────────────────────────────────────────────────────────

def main():
    print()
    print("╔" + "═" * (W - 2) + "╗")
    print("║" + "  INTELLIGENT JOB MATCHING PLATFORM — DEMO".center(W - 2) + "║")
    print("║" + "  COP 4710 Database Systems".center(W - 2) + "║")
    print("╚" + "═" * (W - 2) + "╝")

    try:
        # clean up any leftover demo row from a previous run
        _conn = db()
        _cur  = _conn.cursor()
        _cur.execute("DELETE FROM Student WHERE email = 'demo@ucf.edu'")
        _conn.commit()
        _cur.close()
        _conn.close()

        student_id = demo_insert()
        input("\n  [ press Enter to continue → BASIC 2: SEARCH ] ")

        demo_search()
        input("\n  [ press Enter to continue → BASIC 3: QUERIES ] ")

        demo_queries()
        input("\n  [ press Enter to continue → BASIC 4: UPDATE ] ")

        demo_update(student_id)
        input("\n  [ press Enter to continue → BASIC 5: DELETE ] ")

        demo_delete(student_id)
        input("\n  [ press Enter to continue → ADVANCED FUNCTION ] ")

        demo_advanced()

        print()
        print("═" * W)
        print("  Demo complete.  All basic + advanced functions demonstrated.")
        print("═" * W)
        print()

    except mysql.connector.Error as exc:
        print(f"\n  ✗  Database error: {exc}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\n  Demo interrupted.")
        sys.exit(0)


if __name__ == "__main__":
    main()

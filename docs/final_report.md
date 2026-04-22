# Final Report — Intelligent Job Matching Platform
## COP 4710: Theory and Structure of Databases
**Group 10:** Sebastian Velazquez · Pedro De Lana · Jimmy Moreno · Jorge Fraile
**Florida State University — Spring 2026**

---

## 1. Project Overview

The Intelligent Job Matching Platform is a web application that connects students with job opportunities based on skill compatibility. Students maintain a profile of skills at varying proficiency levels; companies post opportunities with required and preferred skill sets. The platform computes a numeric match score for every (student, opportunity) pair and surfaces ranked results through a browser interface.

The project was built as a full-stack academic prototype demonstrating relational database design, normalization through BCNF, and a multi-table SQL matching algorithm — all integrated through a Python Flask backend and a Jinja2 frontend.

---

## 2. Relational Schema and ER Diagram

### Core Entity Tables

| Table | Primary Key | Notable Columns |
|---|---|---|
| `Student` | `user_id` | `name`, `email` (UNIQUE), `major`, `location`, `resume` |
| `Company` | `company_id` | `name` (UNIQUE), `location` |
| `Skill` | `skill_id` | `name` (UNIQUE) |
| `Opportunity` | `opportunity_id` | `title`, `location`, `company_id` FK → Company |

### Associative Tables

| Table | Primary Key | FK References |
|---|---|---|
| `StudentSkill` | `(user_id, skill_id)` | Student, Skill — `level` ENUM |
| `Application` | `(user_id, opportunity_id)` | Student, Opportunity — `status` ENUM |
| `OpportunitySkill` | `(opportunity_id, skill_id)` | Opportunity, Skill — `priority` ENUM |

### Functional Dependencies and Normal Forms

Every non-key attribute depends solely on its table's primary key, satisfying **BCNF**:

- `user_id → name, email, major, location, resume`
- `company_id → name, location`
- `skill_id → name`
- `opportunity_id → title, location, company_id`
- `(user_id, skill_id) → level`

Multi-valued attributes (student skills, opportunity requirements) are resolved into dedicated associative tables rather than repeating groups, satisfying **1NF**. No partial or transitive dependencies exist across any table, placing all relations in at least **3NF**.

### Indexes

Three explicit indexes were added on high-join columns to improve matching query performance:
- `idx_studentskill_skill_id` on `StudentSkill(skill_id)`
- `idx_opportunityskill_skill_id` on `OpportunitySkill(skill_id)`
- `idx_application_opportunity` on `Application(opportunity_id)`

---

## 3. Technology Stack

| Layer | Technology | Justification |
|---|---|---|
| Database | MySQL 8.0 (InnoDB, utf8mb4) | Industry-standard RDBMS with full FK enforcement, ENUM types, and excellent join/aggregate performance at demo scale |
| Backend | Python 3 + Flask | Lightweight framework; blueprint-based routing separates concerns cleanly; Python's ecosystem simplifies parameterized query execution |
| Frontend | HTML / CSS / Jinja2 | Jinja2 integrates natively with Flask, enabling dynamic rendering without a separate framework |
| DB Connector | mysql-connector-python | Official connector; enforces parameterized queries, preventing SQL injection |
| Config | python-dotenv | Loads secrets from `.env` at startup; `.env.example` committed so setup is self-documenting |

---

## 4. Implementation Summary

### Database Layer (Sebastian)
- Finalized relational schema in Week 1; implemented all tables with InnoDB engine, `utf8mb4` charset, and FK `ON DELETE` actions in Week 2
- Created synthetic seed data covering 5 students, 3 companies, 10 skills, and 6 opportunities with realistic FSU-style emails and job titles
- Added `OpportunitySkill.priority` (`required`/`preferred`) to support weighted matching, and `Application.status` ENUM for CRUD demonstration

### Backend Layer (Pedro)
- Implemented all parameterized CRUD functions in `app/queries.py` (INSERT, SELECT with joins, UPDATE, DELETE) and wired them to Flask routes in `app/routes.py`
- Built the matching algorithm query returning scored, ranked results for any student (see Section 5)
- Returned JSON responses from all `/api/*` endpoints; HTML responses from browser-facing routes

### Frontend Layer (Jimmy)
- Built Jinja2 templates extending a shared `base.html` layout with consistent navigation
- Created student list, student detail, opportunity list, match results, and application management pages
- Connected all HTML forms to Flask routes via `POST` with proper CSRF handling

### Testing and Documentation (Jorge)
- Wrote `tests/test_constraints.sql` validating all 12 FK, UNIQUE, and ENUM constraints against the schema
- Wrote `tests/test_routes.sh` with curl-based assertions covering every API route (status codes + body content)
- Wrote `tests/test_matching.sql` and `tests/test_matching.py` with three hand-calculated algorithm validation cases
- Created `scripts/generate_seed.py` for reproducible large-scale dataset generation
- Authored this final report and the demo script

---

## 5. Matching Algorithm

### Formula

For each (student, opportunity) pair:

```
weight map:
  Advanced     → 1.0
  Intermediate → 0.7
  Beginner     → 0.4
  (missing)    → 0.0

required_raw  = SUM(level_weight) for each REQUIRED skill the student has
preferred_raw = SUM(level_weight) for each PREFERRED skill the student has
max_required  = COUNT(required skills) × 1.0
max_preferred = COUNT(preferred skills) × 0.5

match_score = ROUND(
    (required_raw + preferred_raw × 0.5)
    / (max_required + max_preferred)
  , 4)
```

Required skills carry full weight; preferred skills are worth half their level weight at maximum. The denominator normalizes the score to the range [0.0, 1.0].

### Hand-Calculated Validation Examples

| Student | Opportunity | Calculation | Score |
|---|---|---|---|
| Alice Torres | Software Engineering Intern | Python(1.0) + Flask(0.7) required; SQL(0.7)×0.5 preferred; denom = 2.5 | **0.8200** |
| Derek Smith | Systems Integration Engineer | Linux(1.0) + Docker(0.7) + Java(0.7) required; no preferred; denom = 3.0 | **0.8000** |
| Carla Reyes | ML Platform Engineer Intern | ML(0.7) + Python(1.0) required; Docker(missing) preferred; denom = 2.5 | **0.6800** |

All three were validated by running `python3 tests/test_matching.py` — 4/4 tests pass.

---

## 6. Testing Methodology

| Test Suite | File | Method | Coverage |
|---|---|---|---|
| Constraint tests | `tests/test_constraints.sql` | Each statement intentionally violates a constraint; expected error documented | 12 constraints (UNIQUE, FK RESTRICT/CASCADE, ENUM) |
| Integration tests | `tests/test_routes.sh` | curl assertions on every route; validates HTTP status codes and JSON body fields | All CRUD routes + /match + 404 cases |
| Algorithm tests | `tests/test_matching.py` | Standalone Python; runs against embedded seed data without a live DB | 3 hand-calculated cases + ranking sanity check |
| Algorithm tests (SQL) | `tests/test_matching.sql` | Same cases executed as SQL queries; PASS/FAIL column returned | Same 3 cases; also produces ranked results |

Tests were run on all four development machines after each data reseed to confirm environment independence.

---

## 7. Division of Labor (Actual)

| Member | Delivered |
|---|---|
| Sebastian Velazquez | `schema.sql`, `seed.sql`, MySQL setup, `scripts/generate_seed.py` scaffold |
| Pedro De Lana | `app/queries.py`, `app/routes.py`, matching algorithm SQL, Flask CRUD |
| Jimmy Moreno | `templates/`, `static/`, all Jinja2 UI pages, form→route wiring |
| Jorge Fraile | All test suites, `scripts/generate_seed.py`, `docs/`, final report, demo prep |

All members participated in integration testing and contributed to the final demo rehearsals.

---

## 8. Challenges and Lessons Learned

**Challenge 1 — FK `ON DELETE` semantics across 7 tables.**
Choosing between RESTRICT and CASCADE required thinking carefully about data ownership. We settled on CASCADE for associative tables (StudentSkill, Application, OpportunitySkill) so that deleting a parent record automatically cleans up derived data, while using RESTRICT on Opportunity→Company to prevent accidental orphaning of opportunities.

**Challenge 2 — Divide-by-zero in the matching algorithm.**
An opportunity with zero required and zero preferred skills would cause a division-by-zero error. We added a denominator guard (`IF(denominator = 0, 0.0, ...)`) so such opportunities return a score of 0.0 rather than crashing.

**Challenge 3 — Consistent database state across four machines.**
Each teammate ran a slightly different MySQL version with different `sql_mode` settings. Documenting the exact reset command and adding `SET FOREIGN_KEY_CHECKS = 0` around truncation in the generated seed resolved inconsistencies.

**Lesson — Design for testability from the start.**
Separating query logic (`queries.py`) from route handlers (`routes.py`) made the algorithm much easier to test in isolation. If we had embedded SQL strings in route functions, writing the test suites would have been significantly harder.

---

## 9. Screenshots

> Add screenshots before Canvas submission.
> Suggested captures:
> - Student list page
> - Student detail page (with skills)
> - Match results page (ranked scores for Alice Torres)
> - Add Student form
> - Opportunity list page

---

## 10. Repository Tag

After the live demo, tag the repository:

```bash
git tag -a v1.0-final -m "Final submission tag — COP 4710 Group 10"
git push origin v1.0-final
```

#!/usr/bin/env zsh
# Creates all remaining branch issues (#19 – #41)
# Run from repo root: zsh scripts/create_issues.sh
set -e
cd "$(git rev-parse --show-toplevel)"

GH() { /opt/homebrew/bin/gh issue create "$@"; }

# ── WEEK 2 ───────────────────────────────────────────────────────────────────
GH \
  --title "[Week 2] feat/week2-constraints-indexes: FK ON DELETE actions, indexes, UNIQUE constraints" \
  --body "Part of #10

**Branch:** \`feat/week2-constraints-indexes\`

## Tasks
- [ ] Add \`ON DELETE CASCADE\` to \`OpportunitySkill.opportunity_id\`, \`StudentSkill.user_id\`, \`Application\` (both FKs)
- [ ] Add \`ON DELETE RESTRICT\` to \`OpportunitySkill.skill_id\`, \`StudentSkill.skill_id\`, \`Opportunity.company_id\`
- [ ] Add explicit indexes on \`StudentSkill.skill_id\`, \`OpportunitySkill.skill_id\`, \`Application.opportunity_id\`
- [ ] Add \`UNIQUE\` constraint on \`Student.email\` and \`Company.name\`
- [ ] Write \`tests/test_constraints.sql\` — insert bad data and document expected errors
- [ ] Verify all tables report \`Engine=InnoDB\` via \`SHOW TABLE STATUS\`

**Parent milestone:** #10" \
  --assignee "sebastianjvelazquez" \
  --label "feat,week-2" \
  --milestone "Week 2"

GH \
  --title "[Week 2] feat/week2-flask-scaffold: Blueprint, connection pool, and /health route" \
  --body "Part of #10

**Branch:** \`feat/week2-flask-scaffold\`

## Tasks
- [ ] Set up Flask blueprint structure in \`app/routes.py\`
- [ ] Implement MySQL connection pool using \`mysql.connector.pooling\`
- [ ] Build \`/health\` route that executes \`SELECT 1\` and returns HTTP 200 JSON \`{\"status\": \"ok\"}\`
- [ ] Confirm \`/health\` returns green on all four dev machines

**Parent milestone:** #10" \
  --assignee "pedrode1ana" \
  --label "feat,week-2" \
  --milestone "Week 2"

GH \
  --title "[Week 2] feat/week2-base-template: base.html with nav and block structure" \
  --body "Part of #10

**Branch:** \`feat/week2-base-template\`

## Tasks
- [ ] Create \`templates/base.html\` with nav bar linking to Students, Opportunities, Companies, Search, and Match sections
- [ ] Define Jinja2 blocks: \`{% block title %}\`, \`{% block content %}\`, \`{% block scripts %}\`
- [ ] Add CSS framework link (Pico.css or Bootstrap CDN)
- [ ] Verify template renders without errors from a stub Flask route

**Parent milestone:** #10" \
  --assignee "jimmymoreno2312-cyber" \
  --label "feat,week-2" \
  --milestone "Week 2"

# ── WEEK 3 ───────────────────────────────────────────────────────────────────
GH \
  --title "[Week 3] feat/week3-seed-data: Layered seed SQL files and Python generator script" \
  --body "Part of #11

**Branch:** \`feat/week3-seed-data\`

## Tasks
- [ ] Write layered seed files in load order: \`seed_companies.sql\` (10–15), \`seed_skills.sql\` (25–40), \`seed_students.sql\` (30–50), \`seed_opportunities.sql\` (30–60), \`seed_student_skills.sql\`, \`seed_opportunity_skills.sql\`, \`seed_applications.sql\`
- [ ] Write \`scripts/generate_seed.py\` using \`faker\` to produce reproducible synthetic data
- [ ] Ensure at least 3 students with a clear \"perfect match\" and 3 with a \"partial match\" for demo purposes
- [ ] Verify \`seed.sql\` loads cleanly on a fresh schema and is idempotent (safe to reload)
- [ ] Test seed reload at least twice during the week

**Parent milestone:** #11" \
  --assignee "sebastianjvelazquez" \
  --label "feat,week-3" \
  --milestone "Week 3"

GH \
  --title "[Week 3] feat/week3-seed-validation: Seed data validation queries" \
  --body "Part of #11

**Branch:** \`feat/week3-seed-validation\`

## Tasks
- [ ] Write \`scripts/validate_seed.sql\` with queries that: count rows per table, check no student has zero skills, check no opportunity has zero required skills, check every application references a valid student and opportunity
- [ ] Run validation against the seeded database and confirm all checks pass
- [ ] Document expected counts in query comments

**Parent milestone:** #11" \
  --assignee "pedrode1ana" \
  --label "feat,week-3" \
  --milestone "Week 3"

GH \
  --title "[Week 3] docs/week3-readme-seed-process: README seeding process documentation" \
  --body "Part of #11

**Branch:** \`docs/week3-readme-seed-process\`

## Tasks
- [ ] Add \"Reset database\" section to README with a single copy-paste command block
- [ ] Document the layered seed file load order
- [ ] Document \`scripts/generate_seed.py\` usage

**Parent milestone:** #11" \
  --assignee "Jfraile05" \
  --label "docs,week-3" \
  --milestone "Week 3"

# ── WEEK 4 ───────────────────────────────────────────────────────────────────
GH \
  --title "[Week 4] feat/week4-prejoin-views: StudentSkillView and OpportunitySkillView" \
  --body "Part of #12

**Branch:** \`feat/week4-prejoin-views\`

## Tasks
- [ ] Create \`StudentSkillView\`: joins Student, StudentSkill, Skill — exposes \`user_id\`, \`name\`, \`skill_id\`, \`skill_name\`, \`level\`
- [ ] Create \`OpportunitySkillView\`: joins Opportunity, OpportunitySkill, Skill — exposes \`opportunity_id\`, \`title\`, \`skill_id\`, \`skill_name\`, \`priority\`
- [ ] Add CREATE VIEW statements to \`schema.sql\` after all table definitions
- [ ] Confirm both views return expected rows against seed data

**Parent milestone:** #12" \
  --assignee "sebastianjvelazquez" \
  --label "feat,week-4" \
  --milestone "Week 4"

GH \
  --title "[Week 4] feat/week4-students-crud: Student CRUD routes and query layer" \
  --body "Part of #12

**Branch:** \`feat/week4-students-crud\`

## Tasks
- [ ] Add to \`app/queries.py\`: \`list_students()\`, \`get_student(user_id)\`, \`create_student(data)\`, \`update_student(user_id, data)\`, \`delete_student(user_id)\`, \`search_students(major, location)\`
- [ ] Add at least one query using JOIN and one using GROUP BY/aggregate (e.g., count applications per student)
- [ ] Wire routes in \`app/routes.py\`: GET /students, GET /students/<id>, POST /students, PUT /students/<id>, DELETE /students/<id>
- [ ] All SQL parameters passed as tuples — no f-strings or % formatting

**Parent milestone:** #12" \
  --assignee "pedrode1ana" \
  --label "feat,week-4" \
  --milestone "Week 4"

GH \
  --title "[Week 4] feat/week4-opportunities-crud: Opportunity CRUD routes and query layer" \
  --body "Part of #12

**Branch:** \`feat/week4-opportunities-crud\`

## Tasks
- [ ] Add to \`app/queries.py\`: \`list_opportunities()\`, \`get_opportunity(opportunity_id)\`, \`create_opportunity(data)\`, \`search_opportunities(title, company, location)\`
- [ ] Include a query joining Opportunity with Company and OpportunitySkill
- [ ] Wire routes: GET /opportunities, GET /opportunities/<id>, POST /opportunities
- [ ] All queries parameterized

**Parent milestone:** #12" \
  --assignee "pedrode1ana" \
  --label "feat,week-4" \
  --milestone "Week 4"

GH \
  --title "[Week 4] feat/week4-applications-crud: Application CRUD routes and query layer" \
  --body "Part of #12

**Branch:** \`feat/week4-applications-crud\`

## Tasks
- [ ] Add to \`app/queries.py\`: \`list_applications_for_student(user_id)\`, \`list_applications_for_opportunity(opportunity_id)\`, \`create_application(user_id, opportunity_id)\`, \`update_application_status(user_id, opportunity_id, status)\`, \`delete_application(user_id, opportunity_id)\`
- [ ] Include a GROUP BY aggregate query: applications per opportunity
- [ ] Wire routes: GET /applications?student=<id>, POST /applications, PUT /applications/<uid>/<oid>, DELETE /applications/<uid>/<oid>

**Parent milestone:** #12" \
  --assignee "pedrode1ana" \
  --label "feat,week-4" \
  --milestone "Week 4"

GH \
  --title "[Week 4] feat/week4-basic-forms: Basic HTML forms for CRUD operations" \
  --body "Part of #12

**Branch:** \`feat/week4-basic-forms\`

## Tasks
- [ ] Create minimal HTML form stubs for: create student, create opportunity, submit application, update application status
- [ ] Forms POST to the correct Flask routes
- [ ] Functionality over polish — just enough for Pedro to test end-to-end

**Parent milestone:** #12" \
  --assignee "jimmymoreno2312-cyber" \
  --label "feat,week-4" \
  --milestone "Week 4"

GH \
  --title "[Week 4] feat/week4-integration-tests: curl-based route integration tests" \
  --body "Part of #12

**Branch:** \`feat/week4-integration-tests\`

## Tasks
- [ ] Write \`tests/test_routes.sh\` with curl assertions for every route
- [ ] Each test checks HTTP response code and (where applicable) JSON shape
- [ ] Tests pass on all four dev machines after reseeding
- [ ] Derive test plan from the Week 2 constraint documentation

**Parent milestone:** #12" \
  --assignee "Jfraile05" \
  --label "feat,week-4" \
  --milestone "Week 4"

# ── WEEK 5 ───────────────────────────────────────────────────────────────────
GH \
  --title "[Week 5] feat/week5-student-templates: Student list, detail, and form templates" \
  --body "Part of #13

**Branch:** \`feat/week5-student-templates\`

## Tasks
- [ ] Create \`templates/students/list.html\` — paginated table of students
- [ ] Create \`templates/students/detail.html\` — student profile with skills and applications
- [ ] Create \`templates/students/form.html\` — create/edit form with flash messages
- [ ] All templates extend \`base.html\`; use \`{% block %}\` tags throughout

**Parent milestone:** #13" \
  --assignee "jimmymoreno2312-cyber" \
  --label "feat,week-5" \
  --milestone "Week 5"

GH \
  --title "[Week 5] feat/week5-opportunity-templates: Opportunity list, detail, and form templates" \
  --body "Part of #13

**Branch:** \`feat/week5-opportunity-templates\`

## Tasks
- [ ] Create \`templates/opportunities/list.html\` — paginated table with company and skill count
- [ ] Create \`templates/opportunities/detail.html\` — full opportunity view with required/preferred skills
- [ ] Create \`templates/opportunities/form.html\` — create/edit form with flash messages
- [ ] All templates extend \`base.html\`

**Parent milestone:** #13" \
  --assignee "jimmymoreno2312-cyber" \
  --label "feat,week-5" \
  --milestone "Week 5"

GH \
  --title "[Week 5] feat/week5-application-templates: Application list and form templates" \
  --body "Part of #13

**Branch:** \`feat/week5-application-templates\`

## Tasks
- [ ] Create \`templates/applications/list.html\` — list all applications for a student or opportunity
- [ ] Create \`templates/applications/form.html\` — apply to opportunity + status update form
- [ ] Display \`applied_at\` and current \`status\`; flash confirmation on create/update/delete

**Parent milestone:** #13" \
  --assignee "jimmymoreno2312-cyber" \
  --label "feat,week-5" \
  --milestone "Week 5"

GH \
  --title "[Week 5] feat/week5-search-page: Unified search page with filter dropdowns" \
  --body "Part of #13

**Branch:** \`feat/week5-search-page\`

## Tasks
- [ ] Create \`templates/search.html\` — unified search with filter dropdowns for major, location, and skills
- [ ] Connect search form to backend query in \`routes.py\`
- [ ] Results rendered in a table below the form without page reload (standard form GET)

**Parent milestone:** #13" \
  --assignee "jimmymoreno2312-cyber" \
  --label "feat,week-5" \
  --milestone "Week 5"

GH \
  --title "[Week 5] feat/week5-route-fixes: Route gaps surfaced by template integration" \
  --body "Part of #13

**Branch:** \`feat/week5-route-fixes\`

## Tasks
- [ ] Add missing routes discovered during template integration (commonly: pagination, sorting, redirect-after-POST)
- [ ] Add CSRF protection via \`flask-wtf\` or manual token checks on all state-mutating forms
- [ ] Update \`requirements.txt\` if new dependencies are added

**Parent milestone:** #13" \
  --assignee "pedrode1ana" \
  --label "feat,week-5" \
  --milestone "Week 5"

GH \
  --title "[Week 5] feat/week5-query-perf: Query optimizations for slow template queries" \
  --body "Part of #13

**Branch:** \`feat/week5-query-perf\`

## Tasks
- [ ] Run \`EXPLAIN\` on any query taking >100ms at seed scale
- [ ] Add targeted indexes for any slow queries identified
- [ ] Document findings in a comment in \`queries.py\`

**Parent milestone:** #13" \
  --assignee "sebastianjvelazquez" \
  --label "feat,week-5" \
  --milestone "Week 5"

# ── WEEK 6 ───────────────────────────────────────────────────────────────────
GH \
  --title "[Week 6] feat/week6-matching-algorithm: Skill-based compatibility scoring query and routes" \
  --body "Part of #14

**Branch:** \`feat/week6-matching-algorithm\`

## Tasks
- [ ] Implement ranked opportunity query using \`COUNT(DISTINCT CASE WHEN ...)\` / \`NULLIF\` pattern for match_score
- [ ] Build second query returning matched vs. missing skills for a given (student, opportunity) pair
- [ ] Optionally implement weighted scoring: Advanced=1.0, Intermediate=0.7, Beginner=0.4 — document choice
- [ ] Wire \`/match/<student_id>\` route (ranked list) and \`/match/<student_id>/<opportunity_id>\` route (detail breakdown)
- [ ] Run \`EXPLAIN\` on the matching query; confirm <100ms at seed scale

**Parent milestone:** #14" \
  --assignee "pedrode1ana" \
  --label "feat,week-6" \
  --milestone "Week 6"

GH \
  --title "[Week 6] feat/week6-match-ui: Match results and skill breakdown pages" \
  --body "Part of #14

**Branch:** \`feat/week6-match-ui\`

## Tasks
- [ ] Create \`templates/match/results.html\` — ranked opportunities with match % as a progress bar or badge
- [ ] Create \`templates/match/detail.html\` — matched skills in green, missing skills in red
- [ ] Branch off \`feat/week6-matching-algorithm\` so templates build against real route output
- [ ] Rebase onto \`main\` before opening final PR

**Parent milestone:** #14" \
  --assignee "jimmymoreno2312-cyber" \
  --label "feat,week-6" \
  --milestone "Week 6"

GH \
  --title "[Week 6] feat/week6-algorithm-tests: Hand-calculated algorithm validation test cases" \
  --body "Part of #14

**Branch:** \`feat/week6-algorithm-tests\`

## Tasks
- [ ] Pick 3 students and 3 opportunities from seed data
- [ ] Calculate match scores by hand and document expected output
- [ ] Compare hand-calculated scores against algorithm output — any mismatch is a bug
- [ ] Add test cases to \`tests/test_matching.sql\` or a Python test script

**Parent milestone:** #14" \
  --assignee "Jfraile05" \
  --label "feat,week-6" \
  --milestone "Week 6"

# ── WEEK 7 ───────────────────────────────────────────────────────────────────
GH \
  --title "[Week 7] release/v1.0: Release branch, code freeze, and demo environment setup" \
  --body "Part of #15

**Branch:** \`release/v1.0\`

## Tasks
- [ ] Cut \`release/v1.0\` from \`main\` after all Week 6 branches merge
- [ ] Run full integration test suite (\`tests/test_routes.sh\`) against latest code — fix any regressions
- [ ] Manual end-to-end demo script: seed → create student → add skills → post opportunity → apply → view matches → manage applications
- [ ] Time the demo script to confirm it fits the allotted window
- [ ] Prepare demo environment with pre-loaded hero data (student with strong matches and clear missing skills)
- [ ] Commit \`mysqldump\` backup to \`backups/demo_seed.sql\`
- [ ] Rehearse demo walkthrough ×2 as a group with narration assigned
- [ ] Prepare fallback screenshots or pre-recorded video

**Parent milestone:** #15" \
  --assignee "Jfraile05" \
  --label "chore,week-7" \
  --milestone "Week 7"

# ── WEEK 8 ───────────────────────────────────────────────────────────────────
GH \
  --title "[Week 8] docs/week8-final-report: Final written report and submission assets" \
  --body "Part of #16

**Branch:** \`docs/week8-final-report\`

## Tasks
- [ ] Write Project Overview section
- [ ] Write Relational Schema section with ER diagram
- [ ] Write Technology Stack + Justification section
- [ ] Write Implementation Summary (what actually got built)
- [ ] Write Matching Algorithm section with formula and worked example
- [ ] Write Testing Approach section
- [ ] Write Division of Labor section (actual, not planned)
- [ ] Write Challenges and Lessons Learned section
- [ ] Add screenshots of each major page
- [ ] Export to PDF and submit to Canvas dropbox
- [ ] Tag repo \`v1.0-final\` after demo completes

**Parent milestone:** #16" \
  --assignee "Jfraile05" \
  --label "docs,week-8" \
  --milestone "Week 8"

echo ""
echo "All issues created successfully."

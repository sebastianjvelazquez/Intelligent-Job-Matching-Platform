# Intelligent Job Matching Platform

> A Flask + MySQL web application that matches students to job opportunities based on skill compatibility.

**COP 4710 · Group 10** — Florida State University

| Member | GitHub | Role |
|---|---|---|
| Sebastian Velazquez | [@sebastianjvelazquez](https://github.com/sebastianjvelazquez) | Database design, schema, seed data |
| Pedro De Lana | [@pedrode1ana](https://github.com/pedrode1ana) | Backend: Flask routes, CRUD, matching algorithm |
| Jimmy Moreno | [@jimmymoreno2312-cyber](https://github.com/jimmymoreno2312-cyber) | Frontend: Jinja2 templates, UI/UX |
| Jorge Fraile | [@Jfraile05](https://github.com/Jfraile05) | Testing, debugging, documentation, demo |

---

## Tech Stack

| Layer | Technology | Notes |
|---|---|---|
| Database | MySQL 8.0 | InnoDB engine; `utf8mb4` charset throughout |
| Backend | Python 3 + Flask | Lightweight framework; blueprint-based routing |
| Frontend | HTML / Jinja2 | Pico.css or Bootstrap via CDN for styling |
| DB Connector | mysql-connector-python | Official connector; parameterized queries enforced |
| Config | python-dotenv | Loads `.env` at startup; never commit secrets |

---

## Prerequisites

- **MySQL 8.0** — running locally or accessible via a remote host
- **Python 3.10+** — verify with `python3 --version`
- **pip** — bundled with Python 3.10+
- **git** — for cloning and branch management

---

## Setup

### 1. Clone & create a virtual environment

```bash
git clone https://github.com/sebastianjvelazquez/Intelligent-Job-Matching-Platform.git
cd Intelligent-Job-Matching-Platform

python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate

pip install -r requirements.txt
```

### 2. Configure environment variables

```bash
cp .env.example .env
```

Open `.env` and fill in your MySQL credentials:

```
DB_HOST=localhost
DB_USER=root
DB_PASS=yourpassword
DB_NAME=job_matching
```

### 3. Initialize the database

```bash
mysql -u <user> -p -e "CREATE DATABASE job_matching CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u <user> -p job_matching < schema.sql
mysql -u <user> -p job_matching < seed.sql
```

### 4. Run the application

```bash
flask run
```

Navigate to **http://localhost:5000**.

### Reset the database (clean state)

Use this whenever you need to reload from a known-good state (e.g., before the demo):

```bash
mysql -u <user> -p -e "DROP DATABASE IF EXISTS job_matching; \
  CREATE DATABASE job_matching CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u <user> -p job_matching < schema.sql
mysql -u <user> -p job_matching < seed.sql
```

---

## Project Structure

```
Intelligent-Job-Matching-Platform/
├── app/
│   ├── __init__.py       # Flask app factory + get_db_connection() helper
│   ├── routes.py         # Flask blueprints and route handlers
│   └── queries.py        # Parameterized SQL query functions
├── templates/            # Jinja2 HTML templates (extends base.html)
├── static/               # CSS, JS, and image assets
├── scripts/              # Utility scripts (seed generator, validation queries)
├── tests/                # SQL constraint tests and route integration tests
├── app.py                # Application entry point; loads .env
├── schema.sql            # CREATE TABLE statements in FK-safe order
├── seed.sql              # Synthetic seed data (reset-safe)
├── requirements.txt      # Python dependencies
└── .env.example          # Environment variable template (safe to commit)
```

---

## Branching Strategy

`main` is protected — no direct commits after the initial scaffold. All work goes through pull requests with at least one teammate's review before merging. **Squash-merge** to keep `main`'s history clean, then delete the branch.

| Prefix | Purpose | Example |
|---|---|---|
| `feat/` | New features | `feat/week4-crud-routes` |
| `fix/` | Bug fixes | `fix/match-score-rounding` |
| `docs/` | README and report updates | `docs/week3-readme-seed-process` |
| `chore/` | Tooling, config, cleanup | `chore/setup-jimmy-env` |
| `release/` | Release preparation (Week 7+) | `release/v1.0` |
| `hotfix/` | Urgent fixes after code freeze | `hotfix/demo-env-crash` |

Branch names follow the pattern `<prefix>/weekN-short-desc` for feature work and `<prefix>/short-desc` for fixes and housekeeping.

---

## Contributing Workflow

1. **Create a branch** off the latest `main`:
   ```bash
   git checkout main && git pull
   git checkout -b feat/weekN-short-desc
   ```

2. **Commit** with atomic, imperative messages:
   ```bash
   git add <files>
   git commit -m "Add OpportunitySkill FK constraints"
   ```

3. **Push** your branch and open a pull request:
   ```bash
   git push -u origin feat/weekN-short-desc
   gh pr create --fill
   ```

4. **Request a review** from at least one teammate in the PR.

5. **Squash-merge** once approved — keep the commit message clean.

6. **Delete the branch** after merge:
   ```bash
   git branch -d feat/weekN-short-desc
   ```

---

## Roadmap

- [ ] **Week 1 (Mar 13–19) — Schema Finalization & DB Setup:** Lock down the relational schema, stand up MySQL, and get `flask run` working on every teammate's machine.
- [ ] **Week 2 (Mar 20–26) — Table Implementation:** Add FK `ON DELETE` actions, indexes on join columns, UNIQUE constraints, and verify all constraints with a test script.
- [ ] **Week 3 (Mar 27–Apr 2) — Data Population:** Load 30–50 students, 10–15 companies, 25–40 skills, and 30–60 opportunities via layered SQL seed scripts.
- [ ] **Week 4 (Apr 3–9) — Core Queries & CRUD:** Implement all parameterized INSERT/SELECT/UPDATE/DELETE functions in `queries.py` and wire them to Flask routes.
- [ ] **Week 5 (Apr 10–16) — Frontend Integration:** Build the full Jinja2 template set (list, detail, form pages); connect every CRUD route to a browser-usable form.
- [ ] **Week 6 (Apr 17–20) — Advanced Matching Algorithm:** Implement skill-based compatibility scoring with ranked opportunity results and a per-skill matched/missing breakdown.
- [ ] **Week 7 (Apr 21–23) — Testing & Demo Prep:** End-to-end integration tests, demo script rehearsal (×2), `mysqldump` backup committed, code freeze.
- [ ] **Week 8 (Apr 24) — Final Report & Demo:** Submit written report to Canvas; live demo to TA; tag repo `v1.0-final`.

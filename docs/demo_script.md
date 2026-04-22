# Demo Script — Intelligent Job Matching Platform
## COP 4710 · Group 10 · Week 7 Release

> **Code freeze:** No changes to `release/v1.0` in the 24 hours before the demo
> unless fixing a critical bug. Open a `hotfix/` branch and merge immediately.

---

## Before the Demo (30 min prior)

- [ ] Reset the database to a clean seed state:
  ```bash
  mysql -u <user> -p -e "DROP DATABASE IF EXISTS job_matching; CREATE DATABASE job_matching CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" && mysql -u <user> -p job_matching < schema.sql && mysql -u <user> -p job_matching < seed.sql
  ```
- [ ] Start Flask: `flask run` — confirm **http://localhost:5000** loads
- [ ] Run integration tests: `bash tests/test_routes.sh` — all green
- [ ] Run algorithm tests: `python3 tests/test_matching.py` — all green
- [ ] Connect laptop to classroom projector and verify display resolution
- [ ] Disable notifications / sleep / screensaver on demo machine

---

## Demo Flow (~10 minutes)

### 1. Project Overview (1 min) — **Sebastian**
> "This is the Intelligent Job Matching Platform, a Flask + MySQL application
> that scores students against job opportunities based on skill compatibility.
> We'll walk through the schema, CRUD operations, and the matching algorithm."

### 2. Database Schema (1 min) — **Sebastian**
- Open MySQL Workbench or run:
  ```sql
  SHOW TABLES;
  DESCRIBE Student;
  DESCRIBE OpportunitySkill;
  ```
- Point out the 7 tables, FK relationships, and the `priority` column on `OpportunitySkill`.

### 3. CRUD Operations (3 min) — **Pedro**

#### Create
- Navigate to **Add Student** form
- Fill in: Name = `Demo Student`, Email = `demo@fsu.edu`, Major = `Computer Science`, Location = `Tallahassee, FL`
- Submit → confirm success flash and redirect to student list

#### Read
- Navigate to **Students** list — show all 5 seed students + new one
- Click **Alice Torres** → show detail page with her skills listed

#### Update
- On Alice's detail page, click **Edit**
- Change location to `Miami, FL` → save → confirm update reflected

#### Delete
- Navigate back to student list
- Delete `Demo Student` → confirm removal

### 4. Advanced Matching Algorithm (3 min) — **Pedro / Jorge**
- Navigate to **Match** page
- Select **Alice Torres** from the dropdown → submit
- Walk through the ranked results:
  > "Alice scores **0.82** on Software Engineering Intern because she has Python
  > at Advanced (1.0) and Flask at Intermediate (0.7), which are both required.
  > SQL is preferred and adds a 0.35 bonus. The denominator is 2.5, giving 2.05/2.5 = 0.82."
- Select **Carla Reyes** → show ML Platform Engineer ranks highest for her
- Point out the matched/missing skill breakdown on the results page

### 5. Testing Demonstration (1 min) — **Jorge**
- In terminal (visible on projector):
  ```bash
  python3 tests/test_matching.py -v
  bash tests/test_routes.sh
  ```
- All green — briefly explain what each suite validates

### 6. Q&A / Wrap-up (1 min)
- Be ready to answer:
  - "Why BCNF?" → Every non-key attribute depends only on the PK
  - "Why ENUM for level?" → Cleaner display; constrained domain; maps directly to weight
  - "What if a student has no skills?" → Score = 0.0; denominator guard prevents divide-by-zero

---

## Narrator Assignment

| Section | Narrator |
|---|---|
| Project Overview + Schema | Sebastian |
| CRUD Operations | Pedro |
| Matching Algorithm | Pedro (runs demo), Jorge (explains formula) |
| Testing Demonstration | Jorge |
| Q&A | All |

---

## Backup Materials

If the live app fails:
1. Load `docs/db_backup.sql` into any MySQL instance and re-run
2. Screenshots are in `docs/screenshots/` (add before demo day)
3. Terminal recording: `script demo_recording.txt` before rehearsal

---

## Rehearsal Checklist

- [ ] Rehearsal 1 completed without failure — date: ___________
- [ ] Rehearsal 2 completed without failure — date: ___________
- [ ] All narrators agree on who says what
- [ ] Timer checked — full flow ≤ 10 minutes

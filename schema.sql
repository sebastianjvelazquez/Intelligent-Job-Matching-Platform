-- Intelligent Job Matching Platform
-- Schema: creation order respects FK dependencies
--
-- Design decisions (Week 1):
--   • Charset:  utf8mb4 / utf8mb4_unicode_ci throughout (handles full Unicode)
--   • StudentSkill.level: ENUM('Beginner','Intermediate','Advanced') — clearer
--     for display and sufficient for the matching algorithm weight map
--   • Opportunity.location added per project description (overrides Stage 3)
--   • Application.applied_at + status added per project description
--   • OpportunitySkill.priority added to support required/preferred weighting
--     in the Week 6 matching algorithm
--
-- FK ON DELETE actions (applied in Week 2 branch):
--   • Opportunity.company_id         → RESTRICT  (don't orphan opportunities)
--   • StudentSkill.user_id           → CASCADE   (student deleted → skills go)
--   • StudentSkill.skill_id          → RESTRICT  (can't delete a used skill)
--   • Application (both FKs)         → CASCADE   (derived data)
--   • OpportunitySkill.opportunity_id → CASCADE   (opportunity deleted → reqs go)
--   • OpportunitySkill.skill_id      → RESTRICT  (can't delete a used skill)

CREATE TABLE IF NOT EXISTS Company (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL UNIQUE,
    location   VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Skill (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
    name     VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Student (
    user_id  INT AUTO_INCREMENT PRIMARY KEY,
    name     VARCHAR(255) NOT NULL,
    email    VARCHAR(255) NOT NULL UNIQUE,
    major    VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    resume   TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Opportunity (
    opportunity_id INT AUTO_INCREMENT PRIMARY KEY,
    title          VARCHAR(255) NOT NULL,
    location       VARCHAR(255) NOT NULL,
    company_id     INT NOT NULL,
    CONSTRAINT fk_opportunity_company
        FOREIGN KEY (company_id) REFERENCES Company(company_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS StudentSkill (
    user_id  INT NOT NULL,
    skill_id INT NOT NULL,
    -- ENUM chosen over integer: cleaner display, sufficient for algo weight map
    -- (Advanced=1.0, Intermediate=0.7, Beginner=0.4)
    level    ENUM('Beginner', 'Intermediate', 'Advanced') NOT NULL DEFAULT 'Beginner',
    PRIMARY KEY (user_id, skill_id),
    CONSTRAINT fk_studentskill_student
        FOREIGN KEY (user_id)  REFERENCES Student(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_studentskill_skill
        FOREIGN KEY (skill_id) REFERENCES Skill(skill_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS Application (
    user_id        INT NOT NULL,
    opportunity_id INT NOT NULL,
    applied_at     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status         ENUM('submitted', 'reviewed', 'accepted', 'rejected')
                       NOT NULL DEFAULT 'submitted',
    PRIMARY KEY (user_id, opportunity_id),
    CONSTRAINT fk_application_student
        FOREIGN KEY (user_id)        REFERENCES Student(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_application_opportunity
        FOREIGN KEY (opportunity_id) REFERENCES Opportunity(opportunity_id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS OpportunitySkill (
    opportunity_id INT NOT NULL,
    skill_id       INT NOT NULL,
    -- 'required' skills count in match scoring; 'preferred' are bonus
    priority       ENUM('required', 'preferred') NOT NULL DEFAULT 'required',
    PRIMARY KEY (opportunity_id, skill_id),
    CONSTRAINT fk_opskill_opportunity
        FOREIGN KEY (opportunity_id) REFERENCES Opportunity(opportunity_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_opskill_skill
        FOREIGN KEY (skill_id)       REFERENCES Skill(skill_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Indexes on high-join columns (applied after table creation)
CREATE INDEX IF NOT EXISTS idx_studentskill_skill_id    ON StudentSkill   (skill_id);
CREATE INDEX IF NOT EXISTS idx_opportunityskill_skill_id ON OpportunitySkill (skill_id);
CREATE INDEX IF NOT EXISTS idx_application_opportunity  ON Application    (opportunity_id);

-- ──────────────────────────────────────────────────────────────────────────────
-- Pre-join Views (Week 4)
--
-- Purpose: flatten the most common multi-table joins into reusable views so
-- that the Week 5/6 matching algorithm queries stay concise and readable.
--
-- StudentSkillView  — one row per (student, skill) pair
--   Columns: user_id, name, skill_id, skill_name, level
--
-- OpportunitySkillView — one row per (opportunity, skill) pair
--   Columns: opportunity_id, title, skill_id, skill_name, priority
--
-- Both views are created with CREATE OR REPLACE so this file stays idempotent.
-- ──────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE VIEW StudentSkillView AS
    SELECT
        s.user_id,
        s.name,
        sk.skill_id,
        sk.name  AS skill_name,
        ss.level
    FROM Student      s
    JOIN StudentSkill ss ON s.user_id   = ss.user_id
    JOIN Skill        sk ON ss.skill_id = sk.skill_id;

CREATE OR REPLACE VIEW OpportunitySkillView AS
    SELECT
        o.opportunity_id,
        o.title,
        sk.skill_id,
        sk.name    AS skill_name,
        os.priority
    FROM Opportunity     o
    JOIN OpportunitySkill os ON o.opportunity_id  = os.opportunity_id
    JOIN Skill            sk ON os.skill_id        = sk.skill_id;

-- ──────────────────────────────────────────────────────────────────────────────
-- Week 5 — Query-performance indexes
--
-- Identified by running EXPLAIN on the five template queries in queries.py at
-- seed scale (40 students, 40 opportunities, ~200 StudentSkill rows,
-- ~150 OpportunitySkill rows, ~75 Application rows).
--
-- Q1  list_opportunities_by_location — type=ALL (full scan ~40 rows) without index
-- Q2  list_students_by_major         — type=ALL (full scan ~40 rows) without index
-- Q3  list_students_by_location      — type=ALL (full scan ~40 rows) without index
-- Q4  list_applications_by_status    — type=ALL (full scan ~75 rows) without index
-- Q5  get_student_applications       — type=ref, Extra="Using filesort" without index
--                                       (PK prefix covers user_id but filesort needed
--                                        for ORDER BY applied_at DESC)
-- ──────────────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_student_location       ON Student     (location);
CREATE INDEX IF NOT EXISTS idx_student_major          ON Student     (major);
CREATE INDEX IF NOT EXISTS idx_opportunity_location   ON Opportunity (location);
CREATE INDEX IF NOT EXISTS idx_application_status     ON Application (status);
-- Composite: covers WHERE user_id = ? ORDER BY applied_at DESC (eliminates filesort)
CREATE INDEX IF NOT EXISTS idx_application_user_date  ON Application (user_id, applied_at);


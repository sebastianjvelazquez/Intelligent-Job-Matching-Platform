-- tests/test_constraints.sql
-- Constraint verification test script for the Intelligent Job Matching Platform.
--
-- PURPOSE: Each block attempts an INSERT or UPDATE that violates a constraint.
--          The expected MySQL error code and message are documented above each
--          statement.  Run this file against a database that has been loaded
--          with schema.sql and seed.sql.  Every statement below MUST fail —
--          if any succeeds the schema is misconfigured.
--
-- Usage:
--   mysql -u <user> -p job_matching < tests/test_constraints.sql 2>&1
--
-- Every error line in the output should match one of the "Expected:" notes.
-- Zero successful rows inserted/updated means all constraints are enforced.
-- ---------------------------------------------------------------------------

-- Confirm InnoDB engine on every table (FKs silently ignored on MyISAM)
SELECT table_name, engine
FROM   information_schema.tables
WHERE  table_schema = DATABASE()
  AND  table_name IN ('Company','Skill','Student','Opportunity',
                      'StudentSkill','Application','OpportunitySkill')
ORDER  BY table_name;
-- Expected: all rows show Engine = InnoDB

-- Confirm utf8mb4 charset on every table
SELECT table_name, table_collation
FROM   information_schema.tables
WHERE  table_schema = DATABASE()
  AND  table_name IN ('Company','Skill','Student','Opportunity',
                      'StudentSkill','Application','OpportunitySkill')
ORDER  BY table_name;
-- Expected: all rows show table_collation LIKE 'utf8mb4%'

-- Confirm explicit indexes exist
SELECT table_name, index_name, column_name
FROM   information_schema.statistics
WHERE  table_schema = DATABASE()
  AND  (   (table_name = 'StudentSkill'    AND column_name = 'skill_id')
        OR (table_name = 'OpportunitySkill' AND column_name = 'skill_id')
        OR (table_name = 'Application'     AND column_name = 'opportunity_id') )
ORDER  BY table_name, index_name;
-- Expected: 3 rows (one per index)

-- ===========================================================================
-- TEST 1: Duplicate Student email (UNIQUE constraint on Student.email)
-- Expected: ERROR 1062 (23000): Duplicate entry 'at23@fsu.edu' for key 'email'
-- ===========================================================================
INSERT INTO Student (name, email, major, location)
VALUES ('Duplicate Alice', 'at23@fsu.edu', 'Computer Science', 'Tallahassee, FL');

-- ===========================================================================
-- TEST 2: Duplicate Company name (UNIQUE constraint on Company.name)
-- Expected: ERROR 1062 (23000): Duplicate entry 'Accenture' for key 'name'
-- ===========================================================================
INSERT INTO Company (name, location) VALUES ('Accenture', 'New York, NY');

-- ===========================================================================
-- TEST 3: Orphan FK — Opportunity referencing a non-existent company
-- Expected: ERROR 1452 (23000): Cannot add or update a child row:
--           a foreign key constraint fails (fk_opportunity_company)
-- ===========================================================================
INSERT INTO Opportunity (title, location, company_id)
VALUES ('Ghost Role', 'Nowhere, FL', 9999);

-- ===========================================================================
-- TEST 4: RESTRICT on Opportunity.company_id — delete a company that has
--         opportunities still referencing it
-- Expected: ERROR 1451 (23000): Cannot delete or update a parent row:
--           a foreign key constraint fails (fk_opportunity_company)
-- ===========================================================================
DELETE FROM Company WHERE company_id = 1;

-- ===========================================================================
-- TEST 5: Orphan FK — StudentSkill referencing a non-existent student
-- Expected: ERROR 1452 (23000): Cannot add or update a child row:
--           a foreign key constraint fails (fk_studentskill_student)
-- ===========================================================================
INSERT INTO StudentSkill (user_id, skill_id, level) VALUES (9999, 1, 'Beginner');

-- ===========================================================================
-- TEST 6: Orphan FK — StudentSkill referencing a non-existent skill
-- Expected: ERROR 1452 (23000): Cannot add or update a child row:
--           a foreign key constraint fails (fk_studentskill_skill)
-- ===========================================================================
INSERT INTO StudentSkill (user_id, skill_id, level) VALUES (1, 9999, 'Beginner');

-- ===========================================================================
-- TEST 7: RESTRICT on StudentSkill.skill_id — delete a skill that is still
--         referenced by at least one StudentSkill row
-- Expected: ERROR 1451 (23000): Cannot delete or update a parent row:
--           a foreign key constraint fails (fk_studentskill_skill)
-- ===========================================================================
DELETE FROM Skill WHERE skill_id = 1;  -- Python is used by students

-- ===========================================================================
-- TEST 8: Invalid ENUM value for StudentSkill.level
-- Expected: ERROR 1265 (01000): Data truncated for column 'level'
--           (or a warning that inserts NULL / default depending on sql_mode)
--           With STRICT_TRANS_TABLES (MySQL 8 default): ERROR 1292
-- ===========================================================================
INSERT INTO StudentSkill (user_id, skill_id, level) VALUES (1, 3, 'Expert');

-- ===========================================================================
-- TEST 9: Orphan FK — Application referencing a non-existent opportunity
-- Expected: ERROR 1452 (23000): Cannot add or update a child row:
--           a foreign key constraint fails (fk_application_opportunity)
-- ===========================================================================
INSERT INTO Application (user_id, opportunity_id) VALUES (1, 9999);

-- ===========================================================================
-- TEST 10: Invalid ENUM value for Application.status
-- Expected: ERROR 1292 (strict mode) — invalid value for 'status'
-- ===========================================================================
INSERT INTO Application (user_id, opportunity_id, status) VALUES (1, 3, 'pending');

-- ===========================================================================
-- TEST 11: RESTRICT on OpportunitySkill.skill_id — delete a skill still
--          referenced by at least one OpportunitySkill row
-- Expected: ERROR 1451 (23000): Cannot delete or update a parent row:
--           a foreign key constraint fails (fk_opskill_skill)
-- ===========================================================================
DELETE FROM Skill WHERE skill_id = 2;  -- SQL is used by opportunities

-- ===========================================================================
-- TEST 12: Invalid ENUM value for OpportunitySkill.priority
-- Expected: ERROR 1292 (strict mode) — invalid value for 'priority'
-- ===========================================================================
INSERT INTO OpportunitySkill (opportunity_id, skill_id, priority)
VALUES (1, 4, 'optional');

-- ===========================================================================
-- POSITIVE CONTROL: verify seed data is still intact after all failed inserts
-- Expected: students=5, companies=3, skills=10, opportunities=6
-- ===========================================================================
SELECT 'Student'        AS tbl, COUNT(*) AS rows FROM Student
UNION ALL
SELECT 'Company',                COUNT(*)         FROM Company
UNION ALL
SELECT 'Skill',                  COUNT(*)         FROM Skill
UNION ALL
SELECT 'Opportunity',            COUNT(*)         FROM Opportunity
UNION ALL
SELECT 'StudentSkill',           COUNT(*)         FROM StudentSkill
UNION ALL
SELECT 'Application',            COUNT(*)         FROM Application
UNION ALL
SELECT 'OpportunitySkill',       COUNT(*)         FROM OpportunitySkill;

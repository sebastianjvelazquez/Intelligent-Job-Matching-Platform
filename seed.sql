-- seed.sql  — Master seed file for Intelligent Job Matching Platform
-- Run AFTER schema.sql
--
-- This file is idempotent: it clears all tables in reverse FK order before
-- re-inserting, so it is safe to reload at any time to reset demo data.
--
-- Scale:  10 companies · 30 skills · 40 students · 40 opportunities
--         with matching student-skill and opportunity-skill rows + applications
-- Demo:   Students 1–3 are "perfect match" for Opportunities 1, 8, 12
--         Students 4–6 are "partial match" for those same opportunities

-- ──────────────────────────────────────────────────────────────────────────────
-- 0. Reset: truncate in reverse FK-dependency order
-- ──────────────────────────────────────────────────────────────────────────────
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Application;
TRUNCATE TABLE OpportunitySkill;
TRUNCATE TABLE StudentSkill;
TRUNCATE TABLE Opportunity;
TRUNCATE TABLE Student;
TRUNCATE TABLE Skill;
TRUNCATE TABLE Company;
SET FOREIGN_KEY_CHECKS = 1;

-- ──────────────────────────────────────────────────────────────────────────────
-- 1. Companies (10)
-- ──────────────────────────────────────────────────────────────────────────────
INSERT INTO Company (name, location) VALUES
    ('Accenture',                  'Tampa, FL'),
    ('Lockheed Martin',            'Orlando, FL'),
    ('CrowdStrike',                'Austin, TX'),
    ('Deloitte',                   'Atlanta, GA'),
    ('Booz Allen Hamilton',        'McLean, VA'),
    ('Palo Alto Networks',         'Santa Clara, CA'),
    ('IBM',                        'Armonk, NY'),
    ('Amazon Web Services',        'Seattle, WA'),
    ('Leidos',                     'Reston, VA'),
    ('Cisco Systems',              'San Jose, CA');

-- ──────────────────────────────────────────────────────────────────────────────
-- 2. Skills (30)
-- ──────────────────────────────────────────────────────────────────────────────
INSERT INTO Skill (name) VALUES
    ('Python'),              --  1
    ('Java'),                --  2
    ('C++'),                 --  3
    ('SQL'),                 --  4
    ('JavaScript'),          --  5
    ('TypeScript'),          --  6
    ('React'),               --  7
    ('Node.js'),             --  8
    ('Flask'),               --  9
    ('Spring Boot'),         -- 10
    ('Docker'),              -- 11
    ('Kubernetes'),          -- 12
    ('AWS'),                 -- 13
    ('Azure'),               -- 14
    ('Cybersecurity'),       -- 15
    ('Network Security'),    -- 16
    ('Penetration Testing'), -- 17
    ('Machine Learning'),    -- 18
    ('Data Analysis'),       -- 19
    ('Data Engineering'),    -- 20
    ('Linux'),               -- 21
    ('Git'),                 -- 22
    ('REST APIs'),           -- 23
    ('GraphQL'),             -- 24
    ('PostgreSQL'),          -- 25
    ('MongoDB'),             -- 26
    ('Redis'),               -- 27
    ('Agile / Scrum'),       -- 28
    ('Technical Writing'),   -- 29
    ('Cloud Architecture');  -- 30

-- ──────────────────────────────────────────────────────────────────────────────
-- 3. Students (40)
--    IDs 1–3:  perfect-match students
--    IDs 4–6:  partial-match students
--    IDs 7–40: general population
-- ──────────────────────────────────────────────────────────────────────────────
INSERT INTO Student (name, email, major, location) VALUES
    ('Alice Reyes',         'alice.reyes@ucf.edu',         'Computer Science',      'Orlando, FL'),
    ('Carlos Mendez',       'carlos.mendez@fiu.edu',       'Cybersecurity',         'Miami, FL'),
    ('Diana Pham',          'diana.pham@usf.edu',          'Data Science',          'Tampa, FL'),
    ('Ethan Brooks',        'ethan.brooks@fsu.edu',        'Computer Science',      'Tallahassee, FL'),
    ('Fiona Torres',        'fiona.torres@unf.edu',        'Information Technology','Jacksonville, FL'),
    ('George Nguyen',       'george.nguyen@fau.edu',       'Software Engineering',  'Boca Raton, FL'),
    ('Hannah Kim',          'hannah.kim@miami.edu',        'Computer Science',      'Coral Gables, FL'),
    ('Ian Walker',          'ian.walker@ucf.edu',          'Information Systems',   'Orlando, FL'),
    ('Julia Santos',        'julia.santos@fiu.edu',        'Computer Science',      'Miami, FL'),
    ('Kevin Osei',          'kevin.osei@usf.edu',          'Data Science',          'Tampa, FL'),
    ('Laura Chen',          'laura.chen@fsu.edu',          'Software Engineering',  'Tallahassee, FL'),
    ('Marco Rivera',        'marco.rivera@unf.edu',        'Cybersecurity',         'Jacksonville, FL'),
    ('Nina Patel',          'nina.patel@fau.edu',          'Computer Science',      'Boca Raton, FL'),
    ('Oscar Grant',         'oscar.grant@miami.edu',       'Information Technology','Coral Gables, FL'),
    ('Paula Hernandez',     'paula.hernandez@ucf.edu',     'Data Science',          'Orlando, FL'),
    ('Quincy Adams',        'quincy.adams@fiu.edu',        'Software Engineering',  'Miami, FL'),
    ('Rachel Lee',          'rachel.lee@usf.edu',          'Computer Science',      'Tampa, FL'),
    ('Samuel Ortiz',        'samuel.ortiz@fsu.edu',        'Cybersecurity',         'Tallahassee, FL'),
    ('Tara Johansson',      'tara.johansson@unf.edu',      'Data Science',          'Jacksonville, FL'),
    ('Ulises Ferreira',     'ulises.ferreira@fau.edu',     'Computer Science',      'Boca Raton, FL'),
    ('Victoria Huang',      'victoria.huang@miami.edu',    'Software Engineering',  'Coral Gables, FL'),
    ('Wesley Clark',        'wesley.clark@ucf.edu',        'Information Systems',   'Orlando, FL'),
    ('Xiomara Diaz',        'xiomara.diaz@fiu.edu',        'Cybersecurity',         'Miami, FL'),
    ('Yasmine Tremblay',    'yasmine.tremblay@usf.edu',    'Data Science',          'Tampa, FL'),
    ('Zachary Moore',       'zachary.moore@fsu.edu',       'Computer Science',      'Tallahassee, FL'),
    ('Amara Okonkwo',       'amara.okonkwo@unf.edu',       'Information Technology','Jacksonville, FL'),
    ('Benjamin Scott',      'benjamin.scott@fau.edu',      'Software Engineering',  'Boca Raton, FL'),
    ('Camille Bouchard',    'camille.bouchard@miami.edu',  'Computer Science',      'Coral Gables, FL'),
    ('Dante Morales',       'dante.morales@ucf.edu',       'Data Science',          'Orlando, FL'),
    ('Elena Vasquez',       'elena.vasquez@fiu.edu',       'Cybersecurity',         'Miami, FL'),
    ('Felix Schmidt',       'felix.schmidt@usf.edu',       'Computer Science',      'Tampa, FL'),
    ('Gabriela Rojas',      'gabriela.rojas@fsu.edu',      'Software Engineering',  'Tallahassee, FL'),
    ('Hassan Ali',          'hassan.ali@unf.edu',          'Information Systems',   'Jacksonville, FL'),
    ('Isabella Russo',      'isabella.russo@fau.edu',      'Data Science',          'Boca Raton, FL'),
    ('Javier Cruz',         'javier.cruz@miami.edu',       'Computer Science',      'Coral Gables, FL'),
    ('Kayla Bennett',       'kayla.bennett@ucf.edu',       'Cybersecurity',         'Orlando, FL'),
    ('Liam O\'Brien',       'liam.obrien@fiu.edu',         'Software Engineering',  'Miami, FL'),
    ('Maya Robinson',       'maya.robinson@usf.edu',       'Data Science',          'Tampa, FL'),
    ('Noah Thompson',       'noah.thompson@fsu.edu',       'Computer Science',      'Tallahassee, FL'),
    ('Olivia Martinez',     'olivia.martinez@unf.edu',     'Information Technology','Jacksonville, FL');

-- ──────────────────────────────────────────────────────────────────────────────
-- 4. Opportunities (40)
--    company_id: 1=Accenture, 2=Lockheed, 3=CrowdStrike, 4=Deloitte,
--                5=Booz Allen, 6=Palo Alto, 7=IBM, 8=AWS, 9=Leidos, 10=Cisco
-- ──────────────────────────────────────────────────────────────────────────────
INSERT INTO Opportunity (title, location, company_id) VALUES
    ('Full-Stack Web Developer Intern',      'Tampa, FL',       1),  --  1
    ('Cloud Solutions Engineer',             'Atlanta, GA',     1),  --  2
    ('Data Analyst Intern',                  'Tampa, FL',       1),  --  3
    ('Embedded Systems Engineer Intern',     'Orlando, FL',     2),  --  4
    ('Systems Integration Engineer',         'Orlando, FL',     2),  --  5
    ('Security Operations Center Analyst',   'Austin, TX',      3),  --  6
    ('Threat Intelligence Intern',           'Austin, TX',      3),  --  7
    ('Penetration Tester',                   'Austin, TX',      3),  --  8
    ('IT Consulting Analyst',                'Atlanta, GA',     4),  --  9
    ('Business Intelligence Developer',      'Atlanta, GA',     4),  -- 10
    ('Cloud Infrastructure Intern',          'Atlanta, GA',     4),  -- 11
    ('Cybersecurity Analyst Intern',         'McLean, VA',      5),  -- 12
    ('Data Scientist Intern',                'McLean, VA',      5),  -- 13
    ('Software Developer Intern',            'McLean, VA',      5),  -- 14
    ('Network Security Engineer Intern',     'Santa Clara, CA', 6),  -- 15
    ('Cloud Security Analyst',               'Santa Clara, CA', 6),  -- 16
    ('DevSecOps Engineer',                   'Santa Clara, CA', 6),  -- 17
    ('AI / ML Research Intern',              'Armonk, NY',      7),  -- 18
    ('Backend Developer Intern',             'Armonk, NY',      7),  -- 19
    ('Data Engineering Intern',              'Armonk, NY',      7),  -- 20
    ('Cloud Support Engineer Intern',        'Seattle, WA',     8),  -- 21
    ('Site Reliability Engineer Intern',     'Seattle, WA',     8),  -- 22
    ('Solutions Architect Intern',           'Seattle, WA',     8),  -- 23
    ('Systems Software Engineer Intern',     'Reston, VA',      9),  -- 24
    ('Cybersecurity Operations Intern',      'Reston, VA',      9),  -- 25
    ('Technical Documentation Specialist',   'Reston, VA',      9),  -- 26
    ('Network Engineer Intern',              'San Jose, CA',   10),  -- 27
    ('Software QA Engineer Intern',          'San Jose, CA',   10),  -- 28
    ('DevOps Engineer Intern',               'San Jose, CA',   10),  -- 29
    ('React Front-End Developer Intern',     'Remote',          1),  -- 30
    ('Python Backend Engineer Intern',       'Remote',          7),  -- 31
    ('Database Administrator Intern',        'Tampa, FL',       4),  -- 32
    ('GraphQL API Developer Intern',         'Remote',          8),  -- 33
    ('Agile Project Coordinator',            'Atlanta, GA',     4),  -- 34
    ('Linux Systems Administrator Intern',   'McLean, VA',      5),  -- 35
    ('Machine Learning Engineer Intern',     'Remote',          7),  -- 36
    ('Redis / Cache Engineer Intern',        'Remote',          8),  -- 37
    ('Technical Writer Intern',              'Remote',          9),  -- 38
    ('Kubernetes Platform Engineer Intern',  'Seattle, WA',     8),  -- 39
    ('MongoDB Developer Intern',             'Austin, TX',      3);  -- 40

-- ──────────────────────────────────────────────────────────────────────────────
-- 5. StudentSkill rows
--    skill_id: 1=Python,2=Java,3=C++,4=SQL,5=JS,6=TS,7=React,8=Node.js,
--              9=Flask,10=SpringBoot,11=Docker,12=K8s,13=AWS,14=Azure,
--              15=Cybersec,16=NetSec,17=PenTest,18=ML,19=DataAnalysis,
--              20=DataEng,21=Linux,22=Git,23=REST,24=GraphQL,25=PG,
--              26=Mongo,27=Redis,28=Agile,29=TechWrite,30=CloudArch
-- ──────────────────────────────────────────────────────────────────────────────
INSERT INTO StudentSkill (user_id, skill_id, level) VALUES
    -- Student 1: Alice Reyes — perfect match for opp 1 (Full-Stack Web Dev)
    (1,  7, 'Advanced'),     (1,  8, 'Advanced'),     (1,  6, 'Intermediate'),
    (1,  4, 'Intermediate'), (1, 22, 'Advanced'),     (1,  5, 'Intermediate'),
    -- Student 2: Carlos Mendez — perfect match for opp 8 (Penetration Tester)
    (2, 15, 'Advanced'),     (2, 17, 'Advanced'),     (2, 21, 'Advanced'),
    (2,  1, 'Intermediate'), (2, 16, 'Intermediate'), (2, 22, 'Intermediate'),
    -- Student 3: Diana Pham — perfect match for opp 12 (Cybersecurity Analyst)
    (3, 15, 'Advanced'),     (3, 16, 'Intermediate'), (3,  1, 'Advanced'),
    (3,  4, 'Advanced'),     (3, 21, 'Intermediate'), (3, 19, 'Intermediate'),
    -- Student 4: Ethan Brooks — partial match for opp 1
    (4,  7, 'Intermediate'), (4,  5, 'Intermediate'), (4, 22, 'Intermediate'), (4,  4, 'Beginner'),
    -- Student 5: Fiona Torres — partial match for opp 8
    (5, 15, 'Intermediate'), (5, 21, 'Intermediate'), (5, 22, 'Advanced'),     (5,  1, 'Beginner'),
    -- Student 6: George Nguyen — partial match for opp 13
    (6,  1, 'Intermediate'), (6,  4, 'Intermediate'), (6, 19, 'Intermediate'), (6, 22, 'Beginner'),
    -- General population
    (7,  1, 'Intermediate'), (7,  4, 'Intermediate'), (7,  5, 'Beginner'),     (7, 22, 'Intermediate'),
    (8,  2, 'Intermediate'), (8, 10, 'Beginner'),     (8, 23, 'Beginner'),     (8, 22, 'Intermediate'),
    (9,  1, 'Advanced'),     (9,  9, 'Intermediate'), (9, 23, 'Advanced'),     (9, 22, 'Advanced'),
    (10,18, 'Intermediate'), (10,  1, 'Advanced'),    (10,  4, 'Advanced'),    (10, 19, 'Intermediate'),
    (11,  5, 'Advanced'),    (11,  7, 'Advanced'),    (11,  6, 'Advanced'),    (11,  8, 'Intermediate'),
    (12, 15, 'Intermediate'),(12, 21, 'Intermediate'),(12, 22, 'Intermediate'),(12, 16, 'Beginner'),
    (13,  1, 'Intermediate'),(13,  4, 'Advanced'),    (13, 25, 'Intermediate'),(13, 20, 'Beginner'),
    (14, 28, 'Advanced'),    (14, 29, 'Intermediate'),(14, 22, 'Intermediate'),(14,  4, 'Beginner'),
    (15,  1, 'Intermediate'),(15, 18, 'Advanced'),    (15, 19, 'Advanced'),    (15, 20, 'Intermediate'),
    (16,  1, 'Advanced'),    (16,  2, 'Intermediate'),(16, 23, 'Advanced'),    (16, 22, 'Advanced'),
    (17,  1, 'Intermediate'),(17,  4, 'Intermediate'),(17, 22, 'Beginner'),    (17,  9, 'Beginner'),
    (18, 15, 'Advanced'),    (18, 17, 'Intermediate'),(18, 21, 'Advanced'),    (18, 16, 'Intermediate'),
    (19,  1, 'Advanced'),    (19, 18, 'Advanced'),    (19, 19, 'Advanced'),    (19, 20, 'Advanced'),
    (20,  1, 'Intermediate'),(20,  4, 'Intermediate'),(20, 25, 'Beginner'),    (20, 22, 'Beginner'),
    (21,  5, 'Intermediate'),(21,  7, 'Intermediate'),(21,  6, 'Beginner'),    (21, 22, 'Intermediate'),
    (22, 13, 'Intermediate'),(22, 11, 'Intermediate'),(22, 12, 'Beginner'),    (22, 30, 'Beginner'),
    (23, 15, 'Advanced'),    (23, 17, 'Advanced'),    (23, 16, 'Intermediate'),(23, 21, 'Intermediate'),
    (24,  1, 'Intermediate'),(24, 18, 'Intermediate'),(24, 19, 'Intermediate'),(24,  4, 'Beginner'),
    (25,  1, 'Advanced'),    (25,  2, 'Advanced'),    (25, 21, 'Advanced'),    (25, 22, 'Advanced'),
    (26, 13, 'Advanced'),    (26, 30, 'Advanced'),    (26, 11, 'Advanced'),    (26, 12, 'Intermediate'),
    (27,  5, 'Advanced'),    (27,  7, 'Advanced'),    (27,  8, 'Intermediate'),(27, 23, 'Intermediate'),
    (28,  1, 'Intermediate'),(28,  4, 'Intermediate'),(28, 26, 'Intermediate'),(28, 22, 'Intermediate'),
    (29,  1, 'Advanced'),    (29, 18, 'Advanced'),    (29,  4, 'Advanced'),    (29, 20, 'Advanced'),
    (30, 15, 'Intermediate'),(30, 16, 'Intermediate'),(30, 21, 'Beginner'),    (30, 22, 'Intermediate'),
    (31,  1, 'Intermediate'),(31,  9, 'Intermediate'),(31, 23, 'Intermediate'),(31, 22, 'Intermediate'),
    (32,  2, 'Advanced'),    (32, 10, 'Advanced'),    (32, 23, 'Advanced'),    (32, 25, 'Intermediate'),
    (33,  4, 'Advanced'),    (33, 25, 'Advanced'),    (33, 26, 'Advanced'),    (33, 19, 'Intermediate'),
    (34, 29, 'Advanced'),    (34, 28, 'Intermediate'),(34, 22, 'Advanced'),    (34,  4, 'Beginner'),
    (35,  1, 'Intermediate'),(35,  5, 'Intermediate'),(35, 22, 'Intermediate'),(35, 23, 'Beginner'),
    (36, 15, 'Advanced'),    (36, 17, 'Advanced'),    (36, 16, 'Advanced'),    (36, 21, 'Advanced'),
    (37,  1, 'Advanced'),    (37, 18, 'Advanced'),    (37,  4, 'Intermediate'),(37, 20, 'Intermediate'),
    (38, 27, 'Advanced'),    (38, 13, 'Intermediate'),(38, 11, 'Intermediate'),(38, 22, 'Intermediate'),
    (39, 29, 'Intermediate'),(39, 28, 'Intermediate'),(39,  4, 'Beginner'),    (39, 22, 'Beginner'),
    (40, 11, 'Intermediate'),(40, 12, 'Advanced'),    (40, 13, 'Intermediate'),(40, 21, 'Intermediate');

-- ──────────────────────────────────────────────────────────────────────────────
-- 6. OpportunitySkill rows
-- ──────────────────────────────────────────────────────────────────────────────
INSERT INTO OpportunitySkill (opportunity_id, skill_id, priority) VALUES
    (1,  7, 'required'), (1,  8, 'required'), (1,  6, 'required'),
    (1,  4, 'required'), (1, 22, 'required'), (1,  5, 'preferred'),
    (2, 13, 'required'), (2, 11, 'required'), (2, 12, 'required'),
    (2, 30, 'required'), (2, 21, 'preferred'),
    (3,  4, 'required'), (3, 19, 'required'), (3,  1, 'required'), (3, 28, 'preferred'),
    (4,  3, 'required'), (4, 21, 'required'), (4, 22, 'required'), (4,  2, 'preferred'),
    (5,  2, 'required'), (5, 23, 'required'), (5, 22, 'required'), (5, 28, 'preferred'),
    (6, 15, 'required'), (6, 16, 'required'), (6, 21, 'required'), (6,  1, 'preferred'),
    (7, 15, 'required'), (7,  1, 'required'), (7, 19, 'required'), (7, 29, 'preferred'),
    (8, 15, 'required'), (8, 17, 'required'), (8, 21, 'required'),
    (8,  1, 'required'), (8, 16, 'required'),
    (9, 28, 'required'), (9,  4, 'required'), (9, 29, 'preferred'),
    (10,  4, 'required'),(10, 19, 'required'),(10, 25, 'required'),(10,  1, 'preferred'),
    (11, 13, 'required'),(11, 14, 'required'),(11, 11, 'required'),(11, 22, 'preferred'),
    (12, 15, 'required'),(12, 16, 'required'),(12,  1, 'required'),
    (12,  4, 'required'),(12, 21, 'required'),
    (13, 18, 'required'),(13,  1, 'required'),(13,  4, 'required'),(13, 19, 'preferred'),
    (14,  1, 'required'),(14,  2, 'preferred'),(14, 22, 'required'),(14, 23, 'required'),
    (15, 16, 'required'),(15, 15, 'required'),(15, 21, 'required'),(15, 22, 'preferred'),
    (16, 15, 'required'),(16, 13, 'required'),(16, 30, 'required'),(16, 11, 'preferred'),
    (17, 11, 'required'),(17, 12, 'required'),(17, 15, 'required'),
    (17, 21, 'required'),(17, 22, 'required'),
    (18, 18, 'required'),(18,  1, 'required'),(18, 19, 'required'),(18, 20, 'preferred'),
    (19,  1, 'required'),(19,  9, 'required'),(19, 23, 'required'),
    (19, 22, 'required'),(19,  4, 'preferred'),
    (20, 20, 'required'),(20,  1, 'required'),(20,  4, 'required'),(20, 25, 'preferred'),
    (21, 13, 'required'),(21, 21, 'required'),(21, 22, 'required'),(21, 11, 'preferred'),
    (22, 21, 'required'),(22, 11, 'required'),(22, 12, 'required'),(22, 22, 'required'),
    (23, 13, 'required'),(23, 30, 'required'),(23, 11, 'required'),(23, 23, 'preferred'),
    (24,  1, 'required'),(24,  2, 'required'),(24, 21, 'required'),(24, 22, 'required'),
    (25, 15, 'required'),(25, 21, 'required'),(25, 16, 'preferred'),(25, 22, 'preferred'),
    (26, 29, 'required'),(26, 28, 'required'),(26,  4, 'preferred'),
    (27, 16, 'required'),(27, 21, 'required'),(27, 22, 'required'),(27, 15, 'preferred'),
    (28,  1, 'required'),(28, 22, 'required'),(28, 28, 'preferred'),
    (29, 11, 'required'),(29, 12, 'required'),(29, 21, 'required'),
    (29, 22, 'required'),(29, 13, 'preferred'),
    (30,  7, 'required'),(30,  5, 'required'),(30,  6, 'preferred'),(30, 22, 'preferred'),
    (31,  1, 'required'),(31, 23, 'required'),(31,  4, 'preferred'),(31, 22, 'required'),
    (32,  4, 'required'),(32, 25, 'required'),(32, 26, 'preferred'),
    (33, 24, 'required'),(33, 23, 'required'),(33,  1, 'preferred'),
    (34, 28, 'required'),(34, 29, 'preferred'),(34, 22, 'preferred'),
    (35, 21, 'required'),(35, 22, 'required'),(35, 11, 'preferred'),
    (36, 18, 'required'),(36,  1, 'required'),(36, 20, 'required'),(36, 19, 'preferred'),
    (37, 27, 'required'),(37, 13, 'required'),(37, 11, 'preferred'),
    (38, 29, 'required'),(38, 28, 'preferred'),
    (39, 12, 'required'),(39, 11, 'required'),(39, 21, 'required'),(39, 13, 'preferred'),
    (40, 26, 'required'),(40,  1, 'required'),(40, 22, 'preferred');

-- ──────────────────────────────────────────────────────────────────────────────
-- 7. Applications
-- ──────────────────────────────────────────────────────────────────────────────
INSERT INTO Application (user_id, opportunity_id, status) VALUES
    (1,  1, 'accepted'),  (2,  8, 'accepted'),  (3, 12, 'accepted'),
    (4,  1, 'reviewed'),  (4, 30, 'submitted'), (5,  6, 'reviewed'),
    (5, 25, 'submitted'), (6, 13, 'reviewed'),
    (7,  3, 'submitted'), (7, 10, 'submitted'), (8,  5, 'submitted'),
    (8, 14, 'reviewed'),  (9, 19, 'accepted'),  (9, 31, 'submitted'),
    (10, 18, 'reviewed'), (10, 36, 'submitted'),(11, 30, 'submitted'),
    (11,  1, 'rejected'), (12,  6, 'submitted'),(12, 25, 'reviewed'),
    (13, 32, 'submitted'),(13, 10, 'accepted'), (14, 34, 'submitted'),
    (14, 38, 'submitted'),(15, 36, 'submitted'),(15, 18, 'reviewed'),
    (16, 14, 'submitted'),(16, 31, 'accepted'), (17, 19, 'submitted'),
    (17,  3, 'rejected'), (18,  8, 'reviewed'), (18, 15, 'submitted'),
    (19, 18, 'accepted'), (19, 36, 'submitted'),(20, 32, 'submitted'),
    (20,  3, 'reviewed'), (21, 30, 'submitted'),(21,  1, 'reviewed'),
    (22, 21, 'submitted'),(22, 23, 'reviewed'), (23,  8, 'submitted'),
    (23, 15, 'reviewed'), (24, 13, 'submitted'),(24, 18, 'submitted'),
    (25, 14, 'accepted'), (25, 24, 'submitted'),(26, 23, 'accepted'),
    (26, 21, 'reviewed'), (27, 30, 'submitted'),(27, 33, 'submitted'),
    (28, 32, 'submitted'),(28, 40, 'reviewed'), (29, 18, 'submitted'),
    (29, 36, 'accepted'), (30,  6, 'submitted'),(30, 25, 'reviewed'),
    (31, 19, 'submitted'),(31, 14, 'reviewed'), (32,  5, 'submitted'),
    (32, 14, 'accepted'), (33, 32, 'accepted'), (33, 10, 'submitted'),
    (34, 26, 'submitted'),(34, 38, 'reviewed'), (35, 31, 'submitted'),
    (35, 14, 'reviewed'), (36,  8, 'submitted'),(36, 15, 'reviewed'),
    (37, 18, 'submitted'),(37, 36, 'reviewed'), (38, 37, 'submitted'),
    (38, 23, 'reviewed'), (39, 26, 'submitted'),(39, 38, 'submitted'),
    (40, 22, 'submitted'),(40, 39, 'reviewed');

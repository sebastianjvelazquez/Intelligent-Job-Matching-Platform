-- Seed data for Intelligent Job Matching Platform
-- Run after schema.sql
-- Safe to reload: all inserts use literal IDs; wipe tables in reverse FK order
-- to reset: truncate Application, OpportunitySkill, StudentSkill, Opportunity,
--           Student, Skill, Company (in that order), then re-run this file.

-- Companies (3)
INSERT INTO Company (name, location) VALUES
    ('Accenture',       'Tampa, FL'),
    ('Lockheed Martin', 'Orlando, FL'),
    ('CrowdStrike',     'Austin, TX');

-- Skills (10)
INSERT INTO Skill (name) VALUES
    ('Python'),
    ('SQL'),
    ('Docker'),
    ('Java'),
    ('Cybersecurity'),
    ('Communication'),
    ('Machine Learning'),
    ('Linux'),
    ('Flask'),
    ('Teamwork');

-- Students (5)
INSERT INTO Student (name, email, major, location, resume) VALUES
    ('Alice Torres',   'at23@fsu.edu', 'Computer Science',      'Tallahassee, FL',  'Junior CS student interested in backend development.'),
    ('Brian Nguyen',   'bn45@fsu.edu', 'Information Technology', 'Miami, FL',        'IT student with a focus on cybersecurity fundamentals.'),
    ('Carla Reyes',    'cr67@fsu.edu', 'Computer Science',      'Orlando, FL',      'CS student passionate about machine learning and data.'),
    ('Derek Smith',    'ds89@fsu.edu', 'Computer Engineering',  'Tampa, FL',        'CE student experienced with embedded Linux systems.'),
    ('Elena Vasquez',  'ev12@fsu.edu', 'Information Technology', 'Jacksonville, FL', 'IT student with strong communication and teamwork skills.');

-- Opportunities (6) — includes location per project description
INSERT INTO Opportunity (title, location, company_id) VALUES
    ('Software Engineering Intern',   'Tampa, FL',    1),  -- Accenture
    ('Database Administrator Intern', 'Tampa, FL',    1),  -- Accenture
    ('Systems Integration Engineer',  'Orlando, FL',  2),  -- Lockheed Martin
    ('Cybersecurity Analyst Intern',   'Orlando, FL',  2),  -- Lockheed Martin
    ('Threat Intelligence Intern',     'Austin, TX',   3),  -- CrowdStrike
    ('ML Platform Engineer Intern',    'Austin, TX',   3);  -- CrowdStrike

-- StudentSkill entries
INSERT INTO StudentSkill (user_id, skill_id, level) VALUES
    -- Alice: Python(Adv), SQL(Int), Flask(Int) → perfect match for opp #1 & #2
    (1, 1, 'Advanced'),
    (1, 2, 'Intermediate'),
    (1, 9, 'Intermediate'),
    -- Brian: Cybersecurity(Int), Linux(Int), Communication(Adv) → perfect match for opp #4 & #5
    (2, 5, 'Intermediate'),
    (2, 8, 'Intermediate'),
    (2, 6, 'Advanced'),
    -- Carla: Python(Adv), Machine Learning(Int), SQL(Beg) → perfect match for opp #6
    (3, 1, 'Advanced'),
    (3, 7, 'Intermediate'),
    (3, 2, 'Beginner'),
    -- Derek: Linux(Adv), Docker(Int), Java(Int) → perfect match for opp #3
    (4, 8, 'Advanced'),
    (4, 3, 'Intermediate'),
    (4, 4, 'Intermediate'),
    -- Elena: Communication(Adv), Teamwork(Adv), SQL(Beg) → partial match only
    (5, 6, 'Advanced'),
    (5, 10,'Advanced'),
    (5, 2, 'Beginner');

-- OpportunitySkill entries (with priority — 'required' unless noted)
INSERT INTO OpportunitySkill (opportunity_id, skill_id, priority) VALUES
    -- Software Engineering Intern: Python(req), Flask(req), SQL(preferred)
    (1, 1, 'required'),
    (1, 9, 'required'),
    (1, 2, 'preferred'),
    -- Database Administrator Intern: SQL(req), Python(preferred)
    (2, 2, 'required'),
    (2, 1, 'preferred'),
    -- Systems Integration Engineer: Linux(req), Docker(req), Java(req)
    (3, 8, 'required'),
    (3, 3, 'required'),
    (3, 4, 'required'),
    -- Cybersecurity Analyst Intern: Cybersecurity(req), Linux(req)
    (4, 5, 'required'),
    (4, 8, 'required'),
    -- Threat Intelligence Intern: Cybersecurity(req), Communication(req)
    (5, 5, 'required'),
    (5, 6, 'required'),
    -- ML Platform Engineer Intern: Machine Learning(req), Python(req), Docker(preferred)
    (6, 7, 'required'),
    (6, 1, 'required'),
    (6, 3, 'preferred');

-- Application entries (applied_at and status use column defaults)
INSERT INTO Application (user_id, opportunity_id) VALUES
    (1, 1),  -- Alice   -> Software Eng Intern
    (1, 2),  -- Alice   -> DBA Intern
    (2, 4),  -- Brian   -> Cybersecurity Analyst Intern
    (2, 5),  -- Brian   -> Threat Intelligence Intern
    (3, 6),  -- Carla   -> ML Platform Intern
    (4, 3),  -- Derek   -> Systems Integration
    (5, 1);  -- Elena   -> Software Eng Intern (partial match demo)

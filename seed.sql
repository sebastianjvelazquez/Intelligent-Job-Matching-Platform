-- Seed data for Intelligent Job Matching Platform
-- Run after schema.sql

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
    ('Alice Torres',   'at23@fsu.edu', 'Computer Science',      'Tallahassee, FL', 'Junior CS student interested in backend development.'),
    ('Brian Nguyen',   'bn45@fsu.edu', 'Information Technology', 'Miami, FL',       'IT student with a focus on cybersecurity fundamentals.'),
    ('Carla Reyes',    'cr67@fsu.edu', 'Computer Science',      'Orlando, FL',     'CS student passionate about machine learning and data.'),
    ('Derek Smith',    'ds89@fsu.edu', 'Computer Engineering',  'Tampa, FL',       'CE student experienced with embedded Linux systems.'),
    ('Elena Vasquez',  'ev12@fsu.edu', 'Information Technology', 'Jacksonville, FL','IT student with strong communication and teamwork skills.');

-- Opportunities (6)
INSERT INTO Opportunity (title, company_id) VALUES
    ('Software Engineering Intern',  1),  -- Accenture
    ('Database Administrator Intern',1),  -- Accenture
    ('Systems Integration Engineer', 2),  -- Lockheed Martin
    ('Cybersecurity Analyst Intern',  2),  -- Lockheed Martin
    ('Threat Intelligence Intern',    3),  -- CrowdStrike
    ('ML Platform Engineer Intern',   3);  -- CrowdStrike

-- StudentSkill entries
INSERT INTO StudentSkill (user_id, skill_id, level) VALUES
    -- Alice: Python(Adv), SQL(Int), Flask(Int)
    (1, 1, 'Advanced'),
    (1, 2, 'Intermediate'),
    (1, 9, 'Intermediate'),
    -- Brian: Cybersecurity(Int), Linux(Int), Communication(Adv)
    (2, 5, 'Intermediate'),
    (2, 8, 'Intermediate'),
    (2, 6, 'Advanced'),
    -- Carla: Python(Adv), Machine Learning(Int), SQL(Beg)
    (3, 1, 'Advanced'),
    (3, 7, 'Intermediate'),
    (3, 2, 'Beginner'),
    -- Derek: Linux(Adv), Docker(Int), Java(Int)
    (4, 8, 'Advanced'),
    (4, 3, 'Intermediate'),
    (4, 4, 'Intermediate'),
    -- Elena: Communication(Adv), Teamwork(Adv), SQL(Beg)
    (5, 6, 'Advanced'),
    (5, 10,'Advanced'),
    (5, 2, 'Beginner');

-- OpportunitySkill entries
INSERT INTO OpportunitySkill (opportunity_id, skill_id) VALUES
    -- Software Engineering Intern: Python, Flask, SQL
    (1, 1), (1, 9), (1, 2),
    -- Database Administrator Intern: SQL, Python
    (2, 2), (2, 1),
    -- Systems Integration Engineer: Linux, Docker, Java
    (3, 8), (3, 3), (3, 4),
    -- Cybersecurity Analyst Intern: Cybersecurity, Linux
    (4, 5), (4, 8),
    -- Threat Intelligence Intern: Cybersecurity, Communication
    (5, 5), (5, 6),
    -- ML Platform Engineer Intern: Machine Learning, Python, Docker
    (6, 7), (6, 1), (6, 3);

-- Application entries
INSERT INTO Application (user_id, opportunity_id) VALUES
    (1, 1),  -- Alice -> Software Eng Intern
    (1, 2),  -- Alice -> DBA Intern
    (2, 4),  -- Brian -> Cybersecurity Analyst Intern
    (2, 5),  -- Brian -> Threat Intelligence Intern
    (3, 6),  -- Carla -> ML Platform Intern
    (4, 3),  -- Derek -> Systems Integration
    (5, 1);  -- Elena -> Software Eng Intern

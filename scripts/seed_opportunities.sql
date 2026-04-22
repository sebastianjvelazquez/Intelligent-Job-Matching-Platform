-- seed_opportunities.sql  (40 opportunities, referencing company_ids 1–10)
-- Load order: 4 of 7
-- company_id mapping (from seed_companies.sql insertion order):
--  1=Accenture, 2=Lockheed Martin, 3=CrowdStrike, 4=Deloitte,
--  5=Booz Allen Hamilton, 6=Palo Alto Networks, 7=IBM, 8=Amazon Web Services,
--  9=Leidos, 10=Cisco Systems
INSERT INTO Opportunity (title, location, company_id) VALUES
    -- Accenture (1)
    ('Full-Stack Web Developer Intern',      'Tampa, FL',       1),
    ('Cloud Solutions Engineer',             'Atlanta, GA',     1),
    ('Data Analyst Intern',                  'Tampa, FL',       1),
    -- Lockheed Martin (2)
    ('Embedded Systems Engineer Intern',     'Orlando, FL',     2),
    ('Systems Integration Engineer',         'Orlando, FL',     2),
    -- CrowdStrike (3)
    ('Security Operations Center Analyst',   'Austin, TX',      3),
    ('Threat Intelligence Intern',           'Austin, TX',      3),
    ('Penetration Tester',                   'Austin, TX',      3),
    -- Deloitte (4)
    ('IT Consulting Analyst',                'Atlanta, GA',     4),
    ('Business Intelligence Developer',      'Atlanta, GA',     4),
    ('Cloud Infrastructure Intern',          'Atlanta, GA',     4),
    -- Booz Allen Hamilton (5)
    ('Cybersecurity Analyst Intern',         'McLean, VA',      5),
    ('Data Scientist Intern',                'McLean, VA',      5),
    ('Software Developer Intern',            'McLean, VA',      5),
    -- Palo Alto Networks (6)
    ('Network Security Engineer Intern',     'Santa Clara, CA', 6),
    ('Cloud Security Analyst',               'Santa Clara, CA', 6),
    ('DevSecOps Engineer',                   'Santa Clara, CA', 6),
    -- IBM (7)
    ('AI / ML Research Intern',              'Armonk, NY',      7),
    ('Backend Developer Intern',             'Armonk, NY',      7),
    ('Data Engineering Intern',              'Armonk, NY',      7),
    -- Amazon Web Services (8)
    ('Cloud Support Engineer Intern',        'Seattle, WA',     8),
    ('Site Reliability Engineer Intern',     'Seattle, WA',     8),
    ('Solutions Architect Intern',           'Seattle, WA',     8),
    -- Leidos (9)
    ('Systems Software Engineer Intern',     'Reston, VA',      9),
    ('Cybersecurity Operations Intern',      'Reston, VA',      9),
    ('Technical Documentation Specialist',   'Reston, VA',      9),
    -- Cisco Systems (10)
    ('Network Engineer Intern',              'San Jose, CA',   10),
    ('Software QA Engineer Intern',          'San Jose, CA',   10),
    ('DevOps Engineer Intern',               'San Jose, CA',   10),
    -- Remote / mixed additional roles
    ('React Front-End Developer Intern',     'Remote',          1),
    ('Python Backend Engineer Intern',       'Remote',          7),
    ('Database Administrator Intern',        'Tampa, FL',       4),
    ('GraphQL API Developer Intern',         'Remote',          8),
    ('Agile Project Coordinator',            'Atlanta, GA',     4),
    ('Linux Systems Administrator Intern',   'McLean, VA',      5),
    ('Machine Learning Engineer Intern',     'Remote',          7),
    ('Redis / Cache Engineer Intern',        'Remote',          8),
    ('Technical Writer Intern',              'Remote',          9),
    ('Kubernetes Platform Engineer Intern',  'Seattle, WA',     8),
    ('MongoDB Developer Intern',             'Austin, TX',      3);

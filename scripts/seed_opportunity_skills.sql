-- seed_opportunity_skills.sql
-- Load order: 6 of 7
--
-- opportunity_id map (from seed_opportunities.sql):
--  1=Full-Stack Web Developer Intern (Accenture)
--  2=Cloud Solutions Engineer (Accenture)
--  3=Data Analyst Intern (Accenture)
--  4=Embedded Systems Engineer Intern (Lockheed)
--  5=Systems Integration Engineer (Lockheed)
--  6=SOC Analyst (CrowdStrike)
--  7=Threat Intelligence Intern (CrowdStrike)
--  8=Penetration Tester (CrowdStrike)
--  9=IT Consulting Analyst (Deloitte)
-- 10=Business Intelligence Developer (Deloitte)
-- 11=Cloud Infrastructure Intern (Deloitte)
-- 12=Cybersecurity Analyst Intern (Booz Allen)
-- 13=Data Scientist Intern (Booz Allen)
-- 14=Software Developer Intern (Booz Allen)
-- 15=Network Security Engineer Intern (Palo Alto)
-- 16=Cloud Security Analyst (Palo Alto)
-- 17=DevSecOps Engineer (Palo Alto)
-- 18=AI/ML Research Intern (IBM)
-- 19=Backend Developer Intern (IBM)
-- 20=Data Engineering Intern (IBM)
-- 21=Cloud Support Engineer Intern (AWS)
-- 22=SRE Intern (AWS)
-- 23=Solutions Architect Intern (AWS)
-- 24=Systems Software Engineer Intern (Leidos)
-- 25=Cybersecurity Operations Intern (Leidos)
-- 26=Technical Documentation Specialist (Leidos)
-- 27=Network Engineer Intern (Cisco)
-- 28=Software QA Engineer Intern (Cisco)
-- 29=DevOps Engineer Intern (Cisco)
-- 30=React Front-End Developer Intern (Accenture)
-- 31=Python Backend Engineer Intern (IBM)
-- 32=Database Administrator Intern (Deloitte)
-- 33=GraphQL API Developer Intern (AWS)
-- 34=Agile Project Coordinator (Deloitte)
-- 35=Linux Systems Administrator Intern (Booz Allen)
-- 36=Machine Learning Engineer Intern (IBM)
-- 37=Redis / Cache Engineer Intern (AWS)
-- 38=Technical Writer Intern (Leidos)
-- 39=Kubernetes Platform Engineer Intern (AWS)
-- 40=MongoDB Developer Intern (CrowdStrike)
--
-- skill_id map: 1=Python,2=Java,3=C++,4=SQL,5=JavaScript,6=TypeScript,7=React,
--   8=Node.js,9=Flask,10=Spring Boot,11=Docker,12=Kubernetes,13=AWS,14=Azure,
--   15=Cybersecurity,16=Network Security,17=Penetration Testing,18=Machine Learning,
--   19=Data Analysis,20=Data Engineering,21=Linux,22=Git,23=REST APIs,24=GraphQL,
--   25=PostgreSQL,26=MongoDB,27=Redis,28=Agile/Scrum,29=Technical Writing,30=Cloud Architecture
INSERT INTO OpportunitySkill (opportunity_id, skill_id, priority) VALUES
    -- opp 1: Full-Stack Web Developer Intern — perfect match for student 1
    (1,  7, 'required'),   -- React
    (1,  8, 'required'),   -- Node.js
    (1,  6, 'required'),   -- TypeScript
    (1,  4, 'required'),   -- SQL
    (1, 22, 'required'),   -- Git
    (1,  5, 'preferred'),  -- JavaScript
    -- opp 2: Cloud Solutions Engineer
    (2, 13, 'required'),   -- AWS
    (2, 11, 'required'),   -- Docker
    (2, 12, 'required'),   -- Kubernetes
    (2, 30, 'required'),   -- Cloud Architecture
    (2, 21, 'preferred'),  -- Linux
    -- opp 3: Data Analyst Intern
    (3,  4, 'required'),   -- SQL
    (3, 19, 'required'),   -- Data Analysis
    (3,  1, 'required'),   -- Python
    (3, 28, 'preferred'),  -- Agile/Scrum
    -- opp 4: Embedded Systems Engineer Intern
    (4,  3, 'required'),   -- C++
    (4, 21, 'required'),   -- Linux
    (4, 22, 'required'),   -- Git
    (4,  2, 'preferred'),  -- Java
    -- opp 5: Systems Integration Engineer
    (5,  2, 'required'),   -- Java
    (5, 23, 'required'),   -- REST APIs
    (5, 22, 'required'),   -- Git
    (5, 28, 'preferred'),  -- Agile/Scrum
    -- opp 6: SOC Analyst
    (6, 15, 'required'),   -- Cybersecurity
    (6, 16, 'required'),   -- Network Security
    (6, 21, 'required'),   -- Linux
    (6,  1, 'preferred'),  -- Python
    -- opp 7: Threat Intelligence Intern
    (7, 15, 'required'),   -- Cybersecurity
    (7,  1, 'required'),   -- Python
    (7, 19, 'required'),   -- Data Analysis
    (7, 29, 'preferred'),  -- Technical Writing
    -- opp 8: Penetration Tester — perfect match for student 2
    (8, 15, 'required'),   -- Cybersecurity
    (8, 17, 'required'),   -- Penetration Testing
    (8, 21, 'required'),   -- Linux
    (8,  1, 'required'),   -- Python
    (8, 16, 'required'),   -- Network Security
    -- opp 9: IT Consulting Analyst
    (9, 28, 'required'),   -- Agile/Scrum
    (9,  4, 'required'),   -- SQL
    (9, 29, 'preferred'),  -- Technical Writing
    -- opp 10: Business Intelligence Developer
    (10,  4, 'required'),  -- SQL
    (10, 19, 'required'),  -- Data Analysis
    (10, 25, 'required'),  -- PostgreSQL
    (10,  1, 'preferred'), -- Python
    -- opp 11: Cloud Infrastructure Intern
    (11, 13, 'required'),  -- AWS
    (11, 14, 'required'),  -- Azure
    (11, 11, 'required'),  -- Docker
    (11, 22, 'preferred'), -- Git
    -- opp 12: Cybersecurity Analyst Intern — perfect match for student 3
    (12, 15, 'required'),  -- Cybersecurity
    (12, 16, 'required'),  -- Network Security
    (12,  1, 'required'),  -- Python
    (12,  4, 'required'),  -- SQL
    (12, 21, 'required'),  -- Linux
    -- opp 13: Data Scientist Intern
    (13, 18, 'required'),  -- Machine Learning
    (13,  1, 'required'),  -- Python
    (13,  4, 'required'),  -- SQL
    (13, 19, 'preferred'), -- Data Analysis
    -- opp 14: Software Developer Intern
    (14,  1, 'required'),  -- Python
    (14,  2, 'preferred'), -- Java
    (14, 22, 'required'),  -- Git
    (14, 23, 'required'),  -- REST APIs
    -- opp 15: Network Security Engineer Intern
    (15, 16, 'required'),  -- Network Security
    (15, 15, 'required'),  -- Cybersecurity
    (15, 21, 'required'),  -- Linux
    (15, 22, 'preferred'), -- Git
    -- opp 16: Cloud Security Analyst
    (16, 15, 'required'),  -- Cybersecurity
    (16, 13, 'required'),  -- AWS
    (16, 30, 'required'),  -- Cloud Architecture
    (16, 11, 'preferred'), -- Docker
    -- opp 17: DevSecOps Engineer
    (17, 11, 'required'),  -- Docker
    (17, 12, 'required'),  -- Kubernetes
    (17, 15, 'required'),  -- Cybersecurity
    (17, 21, 'required'),  -- Linux
    (17, 22, 'required'),  -- Git
    -- opp 18: AI/ML Research Intern
    (18, 18, 'required'),  -- Machine Learning
    (18,  1, 'required'),  -- Python
    (18, 19, 'required'),  -- Data Analysis
    (18, 20, 'preferred'), -- Data Engineering
    -- opp 19: Backend Developer Intern
    (19,  1, 'required'),  -- Python
    (19,  9, 'required'),  -- Flask
    (19, 23, 'required'),  -- REST APIs
    (19, 22, 'required'),  -- Git
    (19,  4, 'preferred'), -- SQL
    -- opp 20: Data Engineering Intern
    (20, 20, 'required'),  -- Data Engineering
    (20,  1, 'required'),  -- Python
    (20,  4, 'required'),  -- SQL
    (20, 25, 'preferred'), -- PostgreSQL
    -- opp 21: Cloud Support Engineer Intern
    (21, 13, 'required'),  -- AWS
    (21, 21, 'required'),  -- Linux
    (21, 22, 'required'),  -- Git
    (21, 11, 'preferred'), -- Docker
    -- opp 22: SRE Intern
    (22, 21, 'required'),  -- Linux
    (22, 11, 'required'),  -- Docker
    (22, 12, 'required'),  -- Kubernetes
    (22, 22, 'required'),  -- Git
    -- opp 23: Solutions Architect Intern
    (23, 13, 'required'),  -- AWS
    (23, 30, 'required'),  -- Cloud Architecture
    (23, 11, 'required'),  -- Docker
    (23, 23, 'preferred'), -- REST APIs
    -- opp 24: Systems Software Engineer Intern
    (24,  1, 'required'),  -- Python
    (24,  2, 'required'),  -- Java
    (24, 21, 'required'),  -- Linux
    (24, 22, 'required'),  -- Git
    -- opp 25: Cybersecurity Operations Intern
    (25, 15, 'required'),  -- Cybersecurity
    (25, 21, 'required'),  -- Linux
    (25, 16, 'preferred'), -- Network Security
    (25, 22, 'preferred'), -- Git
    -- opp 26: Technical Documentation Specialist
    (26, 29, 'required'),  -- Technical Writing
    (26, 28, 'required'),  -- Agile/Scrum
    (26,  4, 'preferred'), -- SQL
    -- opp 27: Network Engineer Intern
    (27, 16, 'required'),  -- Network Security
    (27, 21, 'required'),  -- Linux
    (27, 22, 'required'),  -- Git
    (27, 15, 'preferred'), -- Cybersecurity
    -- opp 28: Software QA Engineer Intern
    (28,  1, 'required'),  -- Python
    (28, 22, 'required'),  -- Git
    (28, 28, 'preferred'), -- Agile/Scrum
    -- opp 29: DevOps Engineer Intern
    (29, 11, 'required'),  -- Docker
    (29, 12, 'required'),  -- Kubernetes
    (29, 21, 'required'),  -- Linux
    (29, 22, 'required'),  -- Git
    (29, 13, 'preferred'), -- AWS
    -- opp 30: React Front-End Developer Intern
    (30,  7, 'required'),  -- React
    (30,  5, 'required'),  -- JavaScript
    (30,  6, 'preferred'), -- TypeScript
    (30, 22, 'preferred'), -- Git
    -- opp 31: Python Backend Engineer Intern
    (31,  1, 'required'),  -- Python
    (31, 23, 'required'),  -- REST APIs
    (31,  4, 'preferred'), -- SQL
    (31, 22, 'required'),  -- Git
    -- opp 32: Database Administrator Intern
    (32,  4, 'required'),  -- SQL
    (32, 25, 'required'),  -- PostgreSQL
    (32, 26, 'preferred'), -- MongoDB
    -- opp 33: GraphQL API Developer Intern
    (33, 24, 'required'),  -- GraphQL
    (33, 23, 'required'),  -- REST APIs
    (33,  1, 'preferred'), -- Python
    -- opp 34: Agile Project Coordinator
    (34, 28, 'required'),  -- Agile/Scrum
    (34, 29, 'preferred'), -- Technical Writing
    (34, 22, 'preferred'), -- Git
    -- opp 35: Linux Systems Administrator Intern
    (35, 21, 'required'),  -- Linux
    (35, 22, 'required'),  -- Git
    (35, 11, 'preferred'), -- Docker
    -- opp 36: Machine Learning Engineer Intern
    (36, 18, 'required'),  -- Machine Learning
    (36,  1, 'required'),  -- Python
    (36, 20, 'required'),  -- Data Engineering
    (36, 19, 'preferred'), -- Data Analysis
    -- opp 37: Redis / Cache Engineer Intern
    (37, 27, 'required'),  -- Redis
    (37, 13, 'required'),  -- AWS
    (37, 11, 'preferred'), -- Docker
    -- opp 38: Technical Writer Intern
    (38, 29, 'required'),  -- Technical Writing
    (38, 28, 'preferred'), -- Agile/Scrum
    -- opp 39: Kubernetes Platform Engineer Intern
    (39, 12, 'required'),  -- Kubernetes
    (39, 11, 'required'),  -- Docker
    (39, 21, 'required'),  -- Linux
    (39, 13, 'preferred'), -- AWS
    -- opp 40: MongoDB Developer Intern
    (40, 26, 'required'),  -- MongoDB
    (40,  1, 'required'),  -- Python
    (40, 22, 'preferred'); -- Git

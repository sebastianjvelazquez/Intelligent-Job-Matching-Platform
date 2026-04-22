-- seed_student_skills.sql
-- Load order: 5 of 7
--
-- skill_id map (from seed_skills.sql order):
--  1=Python, 2=Java, 3=C++, 4=SQL, 5=JavaScript, 6=TypeScript, 7=React,
--  8=Node.js, 9=Flask, 10=Spring Boot, 11=Docker, 12=Kubernetes, 13=AWS,
--  14=Azure, 15=Cybersecurity, 16=Network Security, 17=Penetration Testing,
--  18=Machine Learning, 19=Data Analysis, 20=Data Engineering, 21=Linux,
--  22=Git, 23=REST APIs, 24=GraphQL, 25=PostgreSQL, 26=MongoDB, 27=Redis,
--  28=Agile/Scrum, 29=Technical Writing, 30=Cloud Architecture
--
-- Students 1–3: perfect-match for opportunities 1, 8, 12 respectively
-- Student 1 (Alice Reyes) — perfect match for opp 1 (Full-Stack Web Dev Intern)
--   opp 1 requires: React(7), Node.js(8), TypeScript(6), SQL(4), Git(22)
INSERT INTO StudentSkill (user_id, skill_id, level) VALUES
    (1,  7, 'Advanced'),     -- React
    (1,  8, 'Advanced'),     -- Node.js
    (1,  6, 'Intermediate'), -- TypeScript
    (1,  4, 'Intermediate'), -- SQL
    (1, 22, 'Advanced'),     -- Git
    (1,  5, 'Intermediate'), -- JavaScript (bonus)
    -- Student 2 (Carlos Mendez) — perfect match for opp 8 (Penetration Tester)
    --   opp 8 requires: Cybersecurity(15), Penetration Testing(17), Linux(21), Python(1), Network Security(16)
    (2, 15, 'Advanced'),     -- Cybersecurity
    (2, 17, 'Advanced'),     -- Penetration Testing
    (2, 21, 'Advanced'),     -- Linux
    (2,  1, 'Intermediate'), -- Python
    (2, 16, 'Intermediate'), -- Network Security
    (2, 22, 'Intermediate'), -- Git (bonus)
    -- Student 3 (Diana Pham) — perfect match for opp 12 (Cybersecurity Analyst Intern / Booz Allen)
    --   opp 12 requires: Cybersecurity(15), Network Security(16), Python(1), SQL(4), Linux(21)
    (3, 15, 'Advanced'),     -- Cybersecurity
    (3, 16, 'Intermediate'), -- Network Security
    (3,  1, 'Advanced'),     -- Python
    (3,  4, 'Advanced'),     -- SQL
    (3, 21, 'Intermediate'), -- Linux
    (3, 19, 'Intermediate'), -- Data Analysis (bonus)
    -- Student 4 (Ethan Brooks) — partial match for opp 1 (Full-Stack Web Dev)
    --   has React, JavaScript, Git but NOT Node.js or TypeScript
    (4,  7, 'Intermediate'), -- React
    (4,  5, 'Intermediate'), -- JavaScript
    (4, 22, 'Intermediate'), -- Git
    (4,  4, 'Beginner'),     -- SQL
    -- Student 5 (Fiona Torres) — partial match for opp 8 (Penetration Tester)
    --   has Cybersecurity, Linux but NOT Penetration Testing
    (5, 15, 'Intermediate'), -- Cybersecurity
    (5, 21, 'Intermediate'), -- Linux
    (5, 22, 'Advanced'),     -- Git
    (5,  1, 'Beginner'),     -- Python
    -- Student 6 (George Nguyen) — partial match for opp 13 (Data Scientist Intern)
    --   has Python, SQL, Data Analysis but NOT Machine Learning
    (6,  1, 'Intermediate'), -- Python
    (6,  4, 'Intermediate'), -- SQL
    (6, 19, 'Intermediate'), -- Data Analysis
    (6, 22, 'Beginner'),     -- Git
    -- General population (students 7–40) — varied skill sets
    (7,  1, 'Intermediate'), (7,  4, 'Intermediate'), (7,  5, 'Beginner'),  (7, 22, 'Intermediate'),
    (8,  2, 'Intermediate'), (8, 10, 'Beginner'),     (8, 23, 'Beginner'),  (8, 22, 'Intermediate'),
    (9,  1, 'Advanced'),     (9,  9, 'Intermediate'), (9, 23, 'Advanced'),  (9, 22, 'Advanced'),
    (10, 18, 'Intermediate'),(10,  1, 'Advanced'),    (10,  4, 'Advanced'), (10, 19, 'Intermediate'),
    (11,  5, 'Advanced'),    (11,  7, 'Advanced'),    (11,  6, 'Advanced'), (11,  8, 'Intermediate'),
    (12, 15, 'Intermediate'),(12, 21, 'Intermediate'),(12, 22, 'Intermediate'),(12, 16, 'Beginner'),
    (13,  1, 'Intermediate'),(13,  4, 'Advanced'),    (13, 25, 'Intermediate'),(13, 20, 'Beginner'),
    (14, 28, 'Advanced'),    (14, 29, 'Intermediate'),(14, 22, 'Intermediate'),(14,  4, 'Beginner'),
    (15,  1, 'Intermediate'),(15, 18, 'Advanced'),    (15, 19, 'Advanced'), (15, 20, 'Intermediate'),
    (16,  1, 'Advanced'),    (16,  2, 'Intermediate'),(16, 23, 'Advanced'), (16, 22, 'Advanced'),
    (17,  1, 'Intermediate'),(17,  4, 'Intermediate'),(17, 22, 'Beginner'), (17,  9, 'Beginner'),
    (18, 15, 'Advanced'),    (18, 17, 'Intermediate'),(18, 21, 'Advanced'), (18, 16, 'Intermediate'),
    (19,  1, 'Advanced'),    (19, 18, 'Advanced'),    (19, 19, 'Advanced'), (19, 20, 'Advanced'),
    (20,  1, 'Intermediate'),(20,  4, 'Intermediate'),(20, 25, 'Beginner'), (20, 22, 'Beginner'),
    (21,  5, 'Intermediate'),(21,  7, 'Intermediate'),(21,  6, 'Beginner'), (21, 22, 'Intermediate'),
    (22, 13, 'Intermediate'),(22, 11, 'Intermediate'),(22, 12, 'Beginner'), (22, 30, 'Beginner'),
    (23, 15, 'Advanced'),    (23, 17, 'Advanced'),    (23, 16, 'Intermediate'),(23, 21, 'Intermediate'),
    (24,  1, 'Intermediate'),(24, 18, 'Intermediate'),(24, 19, 'Intermediate'),(24,  4, 'Beginner'),
    (25,  1, 'Advanced'),    (25,  2, 'Advanced'),    (25, 21, 'Advanced'), (25, 22, 'Advanced'),
    (26, 13, 'Advanced'),    (26, 30, 'Advanced'),    (26, 11, 'Advanced'), (26, 12, 'Intermediate'),
    (27,  5, 'Advanced'),    (27,  7, 'Advanced'),    (27,  8, 'Intermediate'),(27, 23, 'Intermediate'),
    (28,  1, 'Intermediate'),(28,  4, 'Intermediate'),(28, 26, 'Intermediate'),(28, 22, 'Intermediate'),
    (29,  1, 'Advanced'),    (29, 18, 'Advanced'),    (29,  4, 'Advanced'), (29, 20, 'Advanced'),
    (30, 15, 'Intermediate'),(30, 16, 'Intermediate'),(30, 21, 'Beginner'), (30, 22, 'Intermediate'),
    (31,  1, 'Intermediate'),(31,  9, 'Intermediate'),(31, 23, 'Intermediate'),(31, 22, 'Intermediate'),
    (32,  2, 'Advanced'),    (32, 10, 'Advanced'),    (32, 23, 'Advanced'), (32, 25, 'Intermediate'),
    (33,  4, 'Advanced'),    (33, 25, 'Advanced'),    (33, 26, 'Advanced'), (33, 19, 'Intermediate'),
    (34, 29, 'Advanced'),    (34, 28, 'Intermediate'),(34, 22, 'Advanced'), (34,  4, 'Beginner'),
    (35,  1, 'Intermediate'),(35,  5, 'Intermediate'),(35, 22, 'Intermediate'),(35, 23, 'Beginner'),
    (36, 15, 'Advanced'),    (36, 17, 'Advanced'),    (36, 16, 'Advanced'), (36, 21, 'Advanced'),
    (37,  1, 'Advanced'),    (37, 18, 'Advanced'),    (37,  4, 'Intermediate'),(37, 20, 'Intermediate'),
    (38, 27, 'Advanced'),    (38, 13, 'Intermediate'),(38, 11, 'Intermediate'),(38, 22, 'Intermediate'),
    (39, 29, 'Intermediate'),(39, 28, 'Intermediate'),(39,  4, 'Beginner'),  (39, 22, 'Beginner'),
    (40, 11, 'Intermediate'),(40, 12, 'Advanced'),    (40, 13, 'Intermediate'),(40, 21, 'Intermediate');

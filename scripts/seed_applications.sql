-- seed_applications.sql
-- Load order: 7 of 7
-- Realistic application distribution across the 40 students / 40 opportunities
-- Perfect-match students apply to their matching opportunity (+ extras for realism)
-- status deliberately varied: submitted, reviewed, accepted, rejected
INSERT INTO Application (user_id, opportunity_id, status) VALUES
    -- Perfect-match applications
    (1,  1, 'accepted'),   -- Alice → Full-Stack Web Dev (perfect match)
    (2,  8, 'accepted'),   -- Carlos → Penetration Tester (perfect match)
    (3, 12, 'accepted'),   -- Diana → Cybersecurity Analyst (perfect match)
    -- Partial-match applications
    (4,  1, 'reviewed'),   -- Ethan → Full-Stack Web Dev (partial)
    (4, 30, 'submitted'),  -- Ethan → React Front-End (partial)
    (5,  6, 'reviewed'),   -- Fiona → SOC Analyst (partial)
    (5, 25, 'submitted'),  -- Fiona → Cybersecurity Ops (partial)
    (6, 13, 'reviewed'),   -- George → Data Scientist (partial)
    -- General applications
    (7,  3, 'submitted'),
    (7, 10, 'submitted'),
    (8,  5, 'submitted'),
    (8, 14, 'reviewed'),
    (9, 19, 'accepted'),
    (9, 31, 'submitted'),
    (10, 18, 'reviewed'),
    (10, 36, 'submitted'),
    (11, 30, 'submitted'),
    (11,  1, 'rejected'),
    (12,  6, 'submitted'),
    (12, 25, 'reviewed'),
    (13, 32, 'submitted'),
    (13, 10, 'accepted'),
    (14, 34, 'submitted'),
    (14, 38, 'submitted'),
    (15, 36, 'submitted'),
    (15, 18, 'reviewed'),
    (16, 14, 'submitted'),
    (16, 31, 'accepted'),
    (17, 19, 'submitted'),
    (17,  3, 'rejected'),
    (18,  8, 'reviewed'),
    (18, 15, 'submitted'),
    (19, 18, 'accepted'),
    (19, 36, 'submitted'),
    (20, 32, 'submitted'),
    (20,  3, 'reviewed'),
    (21, 30, 'submitted'),
    (21,  1, 'reviewed'),
    (22, 21, 'submitted'),
    (22, 23, 'reviewed'),
    (23,  8, 'submitted'),
    (23, 15, 'reviewed'),
    (24, 13, 'submitted'),
    (24, 18, 'submitted'),
    (25, 14, 'accepted'),
    (25, 24, 'submitted'),
    (26, 23, 'accepted'),
    (26, 21, 'reviewed'),
    (27, 30, 'submitted'),
    (27, 33, 'submitted'),
    (28, 32, 'submitted'),
    (28, 40, 'reviewed'),
    (29, 18, 'submitted'),
    (29, 36, 'accepted'),
    (30,  6, 'submitted'),
    (30, 25, 'reviewed'),
    (31, 19, 'submitted'),
    (31, 14, 'reviewed'),
    (32,  5, 'submitted'),
    (32, 14, 'accepted'),
    (33, 32, 'accepted'),
    (33, 10, 'submitted'),
    (34, 26, 'submitted'),
    (34, 38, 'reviewed'),
    (35, 31, 'submitted'),
    (35, 14, 'reviewed'),
    (36,  8, 'submitted'),
    (36, 15, 'reviewed'),
    (37, 18, 'submitted'),
    (37, 36, 'reviewed'),
    (38, 37, 'submitted'),
    (38, 23, 'reviewed'),
    (39, 26, 'submitted'),
    (39, 38, 'submitted'),
    (40, 22, 'submitted'),
    (40, 39, 'reviewed');

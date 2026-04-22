-- tests/test_matching.sql
-- ---------------------------------------------------------------------------
-- Hand-calculated algorithm validation test cases (Week 6)
--
-- PURPOSE: Verify that the matching algorithm in queries.py / routes.py
--          produces scores that match hand-computed expected values.
--
-- ALGORITHM (documented here so tests are self-contained):
--
--   Weight map:
--     Advanced     → 1.0
--     Intermediate → 0.7
--     Beginner     → 0.4
--     (missing)    → 0.0
--
--   For each (student, opportunity) pair:
--     required_raw   = SUM(level_weight) for each REQUIRED OpportunitySkill
--                      that the student has in StudentSkill
--     preferred_raw  = SUM(level_weight) for each PREFERRED OpportunitySkill
--                      that the student has in StudentSkill
--     max_required   = COUNT(required skills for that opportunity)  × 1.0
--     max_preferred  = COUNT(preferred skills for that opportunity) × 0.5
--
--     match_score = ROUND(
--                     (required_raw + preferred_raw * 0.5)
--                     / (max_required + max_preferred)
--                   , 4)
--
--   Score range: 0.0 (no skills match) → 1.0 (all required at Advanced,
--   all preferred at Advanced).
--
-- HAND-CALCULATED TEST CASES (using default seed.sql data):
--
--   Case 1: Alice (user_id=1) vs Software Engineering Intern (opp_id=1)
--     Required: Python (req), Flask (req) | Preferred: SQL (pref)
--     Alice skills: Python=Advanced(1.0), Flask=Intermediate(0.7), SQL=Intermediate(0.7)
--     required_raw  = 1.0 + 0.7 = 1.7
--     preferred_raw = 0.7
--     max_required  = 2 × 1.0 = 2.0
--     max_preferred = 1 × 0.5 = 0.5
--     score = (1.7 + 0.7×0.5) / (2.0 + 0.5) = (1.7 + 0.35) / 2.5 = 2.05/2.5 = 0.8200
--
--   Case 2: Derek (user_id=4) vs Systems Integration Engineer (opp_id=3)
--     Required: Linux (req), Docker (req), Java (req) | No preferred
--     Derek skills: Linux=Advanced(1.0), Docker=Intermediate(0.7), Java=Intermediate(0.7)
--     required_raw  = 1.0 + 0.7 + 0.7 = 2.4
--     preferred_raw = 0.0
--     max_required  = 3 × 1.0 = 3.0
--     max_preferred = 0
--     score = 2.4 / 3.0 = 0.8000
--
--   Case 3: Carla (user_id=3) vs ML Platform Engineer Intern (opp_id=6)
--     Required: Machine Learning (req), Python (req) | Preferred: Docker (pref)
--     Carla skills: Python=Advanced(1.0), Machine Learning=Intermediate(0.7)
--                   Docker: NOT in Carla's skills → 0.0
--     required_raw  = 0.7 + 1.0 = 1.7
--     preferred_raw = 0.0  (Docker missing)
--     max_required  = 2 × 1.0 = 2.0
--     max_preferred = 1 × 0.5 = 0.5
--     score = (1.7 + 0.0) / (2.0 + 0.5) = 1.7 / 2.5 = 0.6800
--
-- Usage:
--   mysql -u <user> -p job_matching < tests/test_matching.sql 2>&1
-- ---------------------------------------------------------------------------

-- Helper: weight function expressed as a CASE expression inline
-- Advanced=1.0, Intermediate=0.7, Beginner=0.4, NULL/missing=0.0

-- ===========================================================================
-- TEST CASE 1: Alice (user_id=1) vs Software Engineering Intern (opp_id=1)
-- Expected match_score: 0.8200
-- ===========================================================================
SELECT
    'Case 1: Alice vs Software Eng Intern' AS test_case,
    1   AS student_id,
    1   AS opportunity_id,

    ROUND(
        (
            -- required_raw: Python(1.0) + Flask(0.7)
            COALESCE(SUM(
                CASE os.priority
                    WHEN 'required' THEN
                        CASE ss.level
                            WHEN 'Advanced'     THEN 1.0
                            WHEN 'Intermediate' THEN 0.7
                            WHEN 'Beginner'     THEN 0.4
                            ELSE 0.0
                        END
                    ELSE 0.0
                END
            ), 0)
            +
            -- preferred_raw × 0.5: SQL(0.7) × 0.5
            COALESCE(SUM(
                CASE os.priority
                    WHEN 'preferred' THEN
                        0.5 * CASE ss.level
                            WHEN 'Advanced'     THEN 1.0
                            WHEN 'Intermediate' THEN 0.7
                            WHEN 'Beginner'     THEN 0.4
                            ELSE 0.0
                        END
                    ELSE 0.0
                END
            ), 0)
        )
        /
        (
            -- denominator: max_required + max_preferred × 0.5
            (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 1 AND priority = 'required') * 1.0
            + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 1 AND priority = 'preferred') * 0.5
        )
    , 4) AS actual_score,

    0.8200 AS expected_score,

    CASE
        WHEN ROUND(
            (COALESCE(SUM(CASE os.priority WHEN 'required' THEN
                CASE ss.level WHEN 'Advanced' THEN 1.0 WHEN 'Intermediate' THEN 0.7 WHEN 'Beginner' THEN 0.4 ELSE 0.0 END
                ELSE 0.0 END), 0)
            + COALESCE(SUM(CASE os.priority WHEN 'preferred' THEN 0.5 * CASE ss.level
                WHEN 'Advanced' THEN 1.0 WHEN 'Intermediate' THEN 0.7 WHEN 'Beginner' THEN 0.4 ELSE 0.0 END
                ELSE 0.0 END), 0))
            / ((SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 1 AND priority = 'required') * 1.0
               + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 1 AND priority = 'preferred') * 0.5)
        , 4) = 0.8200
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result

FROM OpportunitySkill os
LEFT JOIN StudentSkill ss
    ON ss.skill_id = os.skill_id AND ss.user_id = 1
WHERE os.opportunity_id = 1;


-- ===========================================================================
-- TEST CASE 2: Derek (user_id=4) vs Systems Integration Engineer (opp_id=3)
-- Expected match_score: 0.8000
-- ===========================================================================
SELECT
    'Case 2: Derek vs Systems Integration Eng' AS test_case,
    4   AS student_id,
    3   AS opportunity_id,

    ROUND(
        COALESCE(SUM(
            CASE os.priority
                WHEN 'required' THEN
                    CASE ss.level
                        WHEN 'Advanced'     THEN 1.0
                        WHEN 'Intermediate' THEN 0.7
                        WHEN 'Beginner'     THEN 0.4
                        ELSE 0.0
                    END
                WHEN 'preferred' THEN
                    0.5 * CASE ss.level
                        WHEN 'Advanced'     THEN 1.0
                        WHEN 'Intermediate' THEN 0.7
                        WHEN 'Beginner'     THEN 0.4
                        ELSE 0.0
                    END
                ELSE 0.0
            END
        ), 0)
        /
        (
            (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 3 AND priority = 'required') * 1.0
            + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 3 AND priority = 'preferred') * 0.5
        )
    , 4) AS actual_score,

    0.8000 AS expected_score,

    CASE
        WHEN ROUND(
            COALESCE(SUM(CASE os.priority
                WHEN 'required' THEN CASE ss.level WHEN 'Advanced' THEN 1.0 WHEN 'Intermediate' THEN 0.7 WHEN 'Beginner' THEN 0.4 ELSE 0.0 END
                WHEN 'preferred' THEN 0.5 * CASE ss.level WHEN 'Advanced' THEN 1.0 WHEN 'Intermediate' THEN 0.7 WHEN 'Beginner' THEN 0.4 ELSE 0.0 END
                ELSE 0.0 END), 0)
            / ((SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 3 AND priority = 'required') * 1.0
               + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 3 AND priority = 'preferred') * 0.5)
        , 4) = 0.8000
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result

FROM OpportunitySkill os
LEFT JOIN StudentSkill ss
    ON ss.skill_id = os.skill_id AND ss.user_id = 4
WHERE os.opportunity_id = 3;


-- ===========================================================================
-- TEST CASE 3: Carla (user_id=3) vs ML Platform Engineer Intern (opp_id=6)
-- Expected match_score: 0.6800
-- ===========================================================================
SELECT
    'Case 3: Carla vs ML Platform Engineer' AS test_case,
    3   AS student_id,
    6   AS opportunity_id,

    ROUND(
        COALESCE(SUM(
            CASE os.priority
                WHEN 'required' THEN
                    CASE ss.level
                        WHEN 'Advanced'     THEN 1.0
                        WHEN 'Intermediate' THEN 0.7
                        WHEN 'Beginner'     THEN 0.4
                        ELSE 0.0
                    END
                WHEN 'preferred' THEN
                    0.5 * CASE ss.level
                        WHEN 'Advanced'     THEN 1.0
                        WHEN 'Intermediate' THEN 0.7
                        WHEN 'Beginner'     THEN 0.4
                        ELSE 0.0
                    END
                ELSE 0.0
            END
        ), 0)
        /
        (
            (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 6 AND priority = 'required') * 1.0
            + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 6 AND priority = 'preferred') * 0.5
        )
    , 4) AS actual_score,

    0.6800 AS expected_score,

    CASE
        WHEN ROUND(
            COALESCE(SUM(CASE os.priority
                WHEN 'required' THEN CASE ss.level WHEN 'Advanced' THEN 1.0 WHEN 'Intermediate' THEN 0.7 WHEN 'Beginner' THEN 0.4 ELSE 0.0 END
                WHEN 'preferred' THEN 0.5 * CASE ss.level WHEN 'Advanced' THEN 1.0 WHEN 'Intermediate' THEN 0.7 WHEN 'Beginner' THEN 0.4 ELSE 0.0 END
                ELSE 0.0 END), 0)
            / ((SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 6 AND priority = 'required') * 1.0
               + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 6 AND priority = 'preferred') * 0.5)
        , 4) = 0.6800
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result

FROM OpportunitySkill os
LEFT JOIN StudentSkill ss
    ON ss.skill_id = os.skill_id AND ss.user_id = 3
WHERE os.opportunity_id = 6;


-- ===========================================================================
-- RANKING SANITY CHECK: Top matches for Alice (user_id=1)
-- Expected order: opp #1 (0.82) > opp #2 (0.76) — then others lower
-- ===========================================================================
SELECT
    s.name                         AS student,
    o.title                        AS opportunity,
    c.name                         AS company,
    ROUND(
        COALESCE(SUM(
            CASE os.priority
                WHEN 'required' THEN
                    CASE ss.level
                        WHEN 'Advanced'     THEN 1.0
                        WHEN 'Intermediate' THEN 0.7
                        WHEN 'Beginner'     THEN 0.4
                        ELSE 0.0
                    END
                WHEN 'preferred' THEN
                    0.5 * CASE ss.level
                        WHEN 'Advanced'     THEN 1.0
                        WHEN 'Intermediate' THEN 0.7
                        WHEN 'Beginner'     THEN 0.4
                        ELSE 0.0
                    END
                ELSE 0.0
            END
        ), 0)
        /
        (
            (SELECT COUNT(*) FROM OpportunitySkill os2 WHERE os2.opportunity_id = o.opportunity_id AND os2.priority = 'required') * 1.0
            + (SELECT COUNT(*) FROM OpportunitySkill os3 WHERE os3.opportunity_id = o.opportunity_id AND os3.priority = 'preferred') * 0.5
        )
    , 4)                           AS match_score
FROM Opportunity o
JOIN Company c ON c.company_id = o.company_id
JOIN OpportunitySkill os ON os.opportunity_id = o.opportunity_id
LEFT JOIN StudentSkill ss ON ss.skill_id = os.skill_id AND ss.user_id = 1
JOIN Student s ON s.user_id = 1
GROUP BY o.opportunity_id, o.title, c.name, s.name
ORDER BY match_score DESC;
-- Expected: Software Engineering Intern scores highest for Alice

-- tests/test_matching.sql
-- ---------------------------------------------------------------------------
-- Hand-calculated algorithm validation for the current (full-scale) seed.
--
-- Run AFTER schema.sql + seed.sql:
--   mysql -u <user> -p job_matching < tests/test_matching.sql 2>&1
--
-- ALGORITHM:
--   Weight map:  Advanced=1.0 · Intermediate=0.7 · Beginner=0.4 · missing=0.0
--
--   required_raw  = SUM(level_weight) for each REQUIRED skill the student has
--   preferred_raw = SUM(level_weight) for each PREFERRED skill the student has
--   max_required  = COUNT(required skills) × 1.0
--   max_preferred = COUNT(preferred skills) × 0.5
--   score = ROUND( (required_raw + preferred_raw × 0.5)
--                   / (max_required + max_preferred), 4 )
--
-- TEST CASES (verified against seed.sql, updated for full-scale data):
--
--   Case 1: Alice Reyes (user_id=1) vs Full-Stack Web Developer Intern (opp_id=1)
--     Required: React(Adv=1.0) + Node.js(Adv=1.0) + TypeScript(Int=0.7)
--               + SQL(Int=0.7) + Git(Adv=1.0)  → required_raw = 4.4
--     Preferred: JavaScript(Int=0.7)            → preferred_raw = 0.7
--     max_req=5.0  max_pref=0.5  denom=5.5
--     score = (4.4 + 0.7×0.5) / 5.5 = 4.75 / 5.5 = 0.8636
--
--   Case 2: Carlos Mendez (user_id=2) vs Penetration Tester (opp_id=8)
--     Required: Cybersec(Adv=1.0) + PenTest(Adv=1.0) + Linux(Adv=1.0)
--               + Python(Int=0.7) + NetSec(Int=0.7)  → required_raw = 4.4
--     Preferred: none
--     max_req=5.0  denom=5.0
--     score = 4.4 / 5.0 = 0.8800
--
--   Case 3: Diana Pham (user_id=3) vs Cybersecurity Analyst Intern (opp_id=12)
--     Required: Cybersec(Adv=1.0) + NetSec(Int=0.7) + Python(Adv=1.0)
--               + SQL(Adv=1.0) + Linux(Int=0.7)     → required_raw = 4.4
--     Preferred: none
--     max_req=5.0  denom=5.0
--     score = 4.4 / 5.0 = 0.8800
-- ---------------------------------------------------------------------------


-- ===========================================================================
-- TEST CASE 1: Alice Reyes (user_id=1) vs Full-Stack Web Developer Intern (opp_id=1)
-- Expected match_score: 0.8636
-- ===========================================================================
SELECT
    'Case 1: Alice Reyes vs Full-Stack Web Developer Intern' AS test_case,
    1    AS student_id,
    1    AS opportunity_id,

    ROUND(
        (
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
            (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 1 AND priority = 'required') * 1.0
            + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 1 AND priority = 'preferred') * 0.5
        )
    , 4) AS actual_score,

    0.8636 AS expected_score,

    CASE
        WHEN ROUND(
            (COALESCE(SUM(CASE os.priority WHEN 'required' THEN
                CASE ss.level WHEN 'Advanced' THEN 1.0 WHEN 'Intermediate' THEN 0.7
                WHEN 'Beginner' THEN 0.4 ELSE 0.0 END ELSE 0.0 END), 0)
            + COALESCE(SUM(CASE os.priority WHEN 'preferred' THEN
                0.5 * CASE ss.level WHEN 'Advanced' THEN 1.0 WHEN 'Intermediate' THEN 0.7
                WHEN 'Beginner' THEN 0.4 ELSE 0.0 END ELSE 0.0 END), 0))
            / ((SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 1 AND priority = 'required') * 1.0
               + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 1 AND priority = 'preferred') * 0.5)
        , 4) = 0.8636
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result

FROM OpportunitySkill os
LEFT JOIN StudentSkill ss
    ON ss.skill_id = os.skill_id AND ss.user_id = 1
WHERE os.opportunity_id = 1;


-- ===========================================================================
-- TEST CASE 2: Carlos Mendez (user_id=2) vs Penetration Tester (opp_id=8)
-- Expected match_score: 0.8800
-- ===========================================================================
SELECT
    'Case 2: Carlos Mendez vs Penetration Tester' AS test_case,
    2    AS student_id,
    8    AS opportunity_id,

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
            (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 8 AND priority = 'required') * 1.0
            + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 8 AND priority = 'preferred') * 0.5
        )
    , 4) AS actual_score,

    0.8800 AS expected_score,

    CASE
        WHEN ROUND(
            COALESCE(SUM(CASE os.priority
                WHEN 'required' THEN CASE ss.level WHEN 'Advanced' THEN 1.0 WHEN 'Intermediate' THEN 0.7
                    WHEN 'Beginner' THEN 0.4 ELSE 0.0 END
                WHEN 'preferred' THEN 0.5 * CASE ss.level WHEN 'Advanced' THEN 1.0
                    WHEN 'Intermediate' THEN 0.7 WHEN 'Beginner' THEN 0.4 ELSE 0.0 END
                ELSE 0.0 END), 0)
            / ((SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 8 AND priority = 'required') * 1.0
               + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 8 AND priority = 'preferred') * 0.5)
        , 4) = 0.8800
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result

FROM OpportunitySkill os
LEFT JOIN StudentSkill ss
    ON ss.skill_id = os.skill_id AND ss.user_id = 2
WHERE os.opportunity_id = 8;


-- ===========================================================================
-- TEST CASE 3: Diana Pham (user_id=3) vs Cybersecurity Analyst Intern (opp_id=12)
-- Expected match_score: 0.8800
-- ===========================================================================
SELECT
    'Case 3: Diana Pham vs Cybersecurity Analyst Intern' AS test_case,
    3    AS student_id,
    12   AS opportunity_id,

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
            (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 12 AND priority = 'required') * 1.0
            + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 12 AND priority = 'preferred') * 0.5
        )
    , 4) AS actual_score,

    0.8800 AS expected_score,

    CASE
        WHEN ROUND(
            COALESCE(SUM(CASE os.priority
                WHEN 'required' THEN CASE ss.level WHEN 'Advanced' THEN 1.0 WHEN 'Intermediate' THEN 0.7
                    WHEN 'Beginner' THEN 0.4 ELSE 0.0 END
                WHEN 'preferred' THEN 0.5 * CASE ss.level WHEN 'Advanced' THEN 1.0
                    WHEN 'Intermediate' THEN 0.7 WHEN 'Beginner' THEN 0.4 ELSE 0.0 END
                ELSE 0.0 END), 0)
            / ((SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 12 AND priority = 'required') * 1.0
               + (SELECT COUNT(*) FROM OpportunitySkill WHERE opportunity_id = 12 AND priority = 'preferred') * 0.5)
        , 4) = 0.8800
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result

FROM OpportunitySkill os
LEFT JOIN StudentSkill ss
    ON ss.skill_id = os.skill_id AND ss.user_id = 3
WHERE os.opportunity_id = 12;


-- ===========================================================================
-- RANKING SANITY CHECK: Top matches for Alice Reyes (user_id=1)
-- Expected: Full-Stack Web Developer Intern (opp_id=1) scores highest (0.8636)
-- ===========================================================================
SELECT
    s.name                          AS student,
    o.title                         AS opportunity,
    c.name                          AS company,
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
            (SELECT COUNT(*) FROM OpportunitySkill os2
             WHERE os2.opportunity_id = o.opportunity_id AND os2.priority = 'required') * 1.0
            + (SELECT COUNT(*) FROM OpportunitySkill os3
               WHERE os3.opportunity_id = o.opportunity_id AND os3.priority = 'preferred') * 0.5
        )
    , 4)                            AS match_score
FROM Opportunity o
JOIN Company          c  ON c.company_id      = o.company_id
JOIN OpportunitySkill os ON os.opportunity_id = o.opportunity_id
LEFT JOIN StudentSkill ss ON ss.skill_id      = os.skill_id AND ss.user_id = 1
JOIN Student          s  ON s.user_id         = 1
GROUP BY o.opportunity_id, o.title, c.name, s.name
ORDER BY match_score DESC
LIMIT 5;
-- Expected top result: Full-Stack Web Developer Intern (0.8636)

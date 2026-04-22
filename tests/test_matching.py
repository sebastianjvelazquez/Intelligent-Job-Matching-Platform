#!/usr/bin/env python3
"""
tests/test_matching.py
----------------------
Python-level validation of the matching algorithm against hand-calculated
expected scores.  Runs without a live database — uses the same seed data
embedded here so results are reproducible on any machine.

Usage:
    python3 tests/test_matching.py          # run all cases
    python3 tests/test_matching.py -v       # verbose output

Algorithm (matches queries.py implementation):
    Weight map: Advanced=1.0, Intermediate=0.7, Beginner=0.4, missing=0.0

    required_raw  = SUM(level_weight) for each REQUIRED skill student has
    preferred_raw = SUM(level_weight) for each PREFERRED skill student has
    max_required  = COUNT(required skills) × 1.0
    max_preferred = COUNT(preferred skills) × 0.5
    score = ROUND((required_raw + preferred_raw × 0.5) / (max_required + max_preferred), 4)
"""

import sys
from typing import Optional

# ---------------------------------------------------------------------------
# Algorithm
# ---------------------------------------------------------------------------
LEVEL_WEIGHTS = {
    "Advanced":     1.0,
    "Intermediate": 0.7,
    "Beginner":     0.4,
}


def compute_match_score(
    student_skills: dict[int, str],          # {skill_id: level}
    opportunity_skills: list[tuple[int, str]], # [(skill_id, priority), ...]
) -> float:
    """Return the match score for one (student, opportunity) pair."""
    required = [(sid, pri) for sid, pri in opportunity_skills if pri == "required"]
    preferred = [(sid, pri) for sid, pri in opportunity_skills if pri == "preferred"]

    required_raw = sum(
        LEVEL_WEIGHTS.get(student_skills.get(sid, ""), 0.0)
        for sid, _ in required
    )
    preferred_raw = sum(
        LEVEL_WEIGHTS.get(student_skills.get(sid, ""), 0.0)
        for sid, _ in preferred
    )

    max_required  = len(required) * 1.0
    max_preferred = len(preferred) * 0.5
    denominator   = max_required + max_preferred

    if denominator == 0:
        return 0.0

    return round((required_raw + preferred_raw * 0.5) / denominator, 4)


# ---------------------------------------------------------------------------
# Seed data (mirrors seed.sql exactly)
# ---------------------------------------------------------------------------

# StudentSkill: {user_id: {skill_id: level}}
STUDENT_SKILLS: dict[int, dict[int, str]] = {
    1: {1: "Advanced", 2: "Intermediate", 9: "Intermediate"},   # Alice
    2: {5: "Intermediate", 8: "Intermediate", 6: "Advanced"},   # Brian
    3: {1: "Advanced", 7: "Intermediate", 2: "Beginner"},       # Carla
    4: {8: "Advanced", 3: "Intermediate", 4: "Intermediate"},   # Derek
    5: {6: "Advanced", 10: "Advanced", 2: "Beginner"},          # Elena
}

# OpportunitySkill: {opp_id: [(skill_id, priority), ...]}
OPP_SKILLS: dict[int, list[tuple[int, str]]] = {
    1: [(1, "required"), (9, "required"), (2, "preferred")],          # Software Eng Intern
    2: [(2, "required"), (1, "preferred")],                           # DBA Intern
    3: [(8, "required"), (3, "required"), (4, "required")],           # Systems Integration Eng
    4: [(5, "required"), (8, "required")],                            # Cybersecurity Analyst Intern
    5: [(5, "required"), (6, "required")],                            # Threat Intelligence Intern
    6: [(7, "required"), (1, "required"), (3, "preferred")],          # ML Platform Engineer Intern
}

STUDENT_NAMES = {1: "Alice", 2: "Brian", 3: "Carla", 4: "Derek", 5: "Elena"}
OPP_NAMES = {
    1: "Software Engineering Intern",
    2: "Database Administrator Intern",
    3: "Systems Integration Engineer",
    4: "Cybersecurity Analyst Intern",
    5: "Threat Intelligence Intern",
    6: "ML Platform Engineer Intern",
}

# ---------------------------------------------------------------------------
# Test cases
# ---------------------------------------------------------------------------
TEST_CASES = [
    {
        "description": "Alice (user_id=1) vs Software Engineering Intern (opp_id=1)",
        "student_id":  1,
        "opp_id":      1,
        "expected":    0.8200,
        "workings": (
            "required: Python(1.0) + Flask(0.7) = 1.7 | preferred: SQL(0.7)×0.5 = 0.35 | "
            "denom: 2×1.0 + 1×0.5 = 2.5 | score: 2.05/2.5 = 0.82"
        ),
    },
    {
        "description": "Derek (user_id=4) vs Systems Integration Engineer (opp_id=3)",
        "student_id":  4,
        "opp_id":      3,
        "expected":    0.8000,
        "workings": (
            "required: Linux(1.0) + Docker(0.7) + Java(0.7) = 2.4 | preferred: none | "
            "denom: 3×1.0 = 3.0 | score: 2.4/3.0 = 0.80"
        ),
    },
    {
        "description": "Carla (user_id=3) vs ML Platform Engineer Intern (opp_id=6)",
        "student_id":  3,
        "opp_id":      6,
        "expected":    0.6800,
        "workings": (
            "required: ML(0.7) + Python(1.0) = 1.7 | preferred: Docker(missing=0)×0.5 = 0 | "
            "denom: 2×1.0 + 1×0.5 = 2.5 | score: 1.7/2.5 = 0.68"
        ),
    },
]


# ---------------------------------------------------------------------------
# Runner
# ---------------------------------------------------------------------------
def run_tests(verbose: bool = False) -> bool:
    passed = 0
    failed = 0

    print("=" * 60)
    print("  Matching Algorithm — Hand-Calculated Validation")
    print("=" * 60)

    for tc in TEST_CASES:
        student_id = tc["student_id"]
        opp_id     = tc["opp_id"]
        expected   = tc["expected"]

        actual = compute_match_score(
            STUDENT_SKILLS[student_id],
            OPP_SKILLS[opp_id],
        )

        ok = abs(actual - expected) < 1e-9

        status = "PASS" if ok else "FAIL"
        colour = "\033[0;32m" if ok else "\033[0;31m"
        reset  = "\033[0m"

        print(f"\n{colour}{status}{reset}  {tc['description']}")
        if verbose or not ok:
            print(f"       Expected : {expected:.4f}")
            print(f"       Actual   : {actual:.4f}")
            print(f"       Workings : {tc['workings']}")

        if ok:
            passed += 1
        else:
            failed += 1

    # Ranking sanity check for Alice
    print("\n--- Ranking sanity: Alice (user_id=1) across all opportunities ---")
    alice_scores = []
    for oid, oname in OPP_NAMES.items():
        score = compute_match_score(STUDENT_SKILLS[1], OPP_SKILLS[oid])
        alice_scores.append((score, oname))
    alice_scores.sort(reverse=True)
    for score, name in alice_scores:
        print(f"  {score:.4f}  {name}")
    top_name = alice_scores[0][1]
    if top_name == "Software Engineering Intern":
        print("\033[0;32mPASS\033[0m  Alice's top match is Software Engineering Intern (expected)")
        passed += 1
    else:
        print(f"\033[0;31mFAIL\033[0m  Alice's top match is '{top_name}' (expected Software Engineering Intern)")
        failed += 1

    # Summary
    total = passed + failed
    print("\n" + "=" * 60)
    print(f"  Results: {passed}/{total} passed")
    if failed:
        print(f"\033[0;31m  {failed} test(s) failed\033[0m")
    else:
        print("\033[0;32m  All tests passed\033[0m")
    print("=" * 60)

    return failed == 0


if __name__ == "__main__":
    verbose = "-v" in sys.argv or "--verbose" in sys.argv
    success = run_tests(verbose=verbose)
    sys.exit(0 if success else 1)

#!/usr/bin/env bash
# tests/test_routes.sh
# ---------------------------------------------------------------------------
# curl-based integration tests for every Flask route.
#
# Prerequisites:
#   1. Flask app running:  flask run  (default: http://localhost:5000)
#   2. Database seeded:   mysql ... < schema.sql && mysql ... < seed.sql
#
# Usage:
#   bash tests/test_routes.sh [BASE_URL]
#
# Default BASE_URL: http://localhost:5000
#
# Exit codes:
#   0 — all assertions passed
#   1 — one or more assertions failed
# ---------------------------------------------------------------------------

BASE_URL="${1:-http://localhost:5000}"
PASS=0
FAIL=0

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

assert_status() {
    local label="$1"
    local expected="$2"
    local actual="$3"
    if [ "$actual" -eq "$expected" ]; then
        echo -e "${GREEN}PASS${RESET}  [$label] HTTP $actual"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}FAIL${RESET}  [$label] expected HTTP $expected, got HTTP $actual"
        FAIL=$((FAIL + 1))
    fi
}

assert_body_contains() {
    local label="$1"
    local needle="$2"
    local body="$3"
    if echo "$body" | grep -q "$needle"; then
        echo -e "${GREEN}PASS${RESET}  [$label] body contains '$needle'"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}FAIL${RESET}  [$label] body missing '$needle'"
        FAIL=$((FAIL + 1))
    fi
}

echo "======================================================"
echo "  Integration Tests — $BASE_URL"
echo "======================================================"
echo ""

# ---------------------------------------------------------------------------
# GET /students  — list all students
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" "$BASE_URL/students")
BODY=$(cat /tmp/body.txt)
assert_status "GET /students" 200 "$RESP"
assert_body_contains "GET /students body" "Alice" "$BODY"

# ---------------------------------------------------------------------------
# GET /students/1  — fetch student by ID
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" "$BASE_URL/students/1")
BODY=$(cat /tmp/body.txt)
assert_status "GET /students/1" 200 "$RESP"
assert_body_contains "GET /students/1 email" "at23@fsu.edu" "$BODY"

# ---------------------------------------------------------------------------
# GET /students/9999  — non-existent student → 404
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/students/9999")
assert_status "GET /students/9999 (not found)" 404 "$RESP"

# ---------------------------------------------------------------------------
# POST /students  — create a new student
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" \
    -X POST "$BASE_URL/students" \
    -H "Content-Type: application/json" \
    -d '{"name":"Test Student","email":"ts99@fsu.edu","major":"Computer Science","location":"Tallahassee, FL","resume":"Test resume."}')
BODY=$(cat /tmp/body.txt)
assert_status "POST /students" 201 "$RESP"
assert_body_contains "POST /students body" "ts99@fsu.edu" "$BODY"

# ---------------------------------------------------------------------------
# POST /students — duplicate email → 409
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$BASE_URL/students" \
    -H "Content-Type: application/json" \
    -d '{"name":"Dup Student","email":"at23@fsu.edu","major":"IT","location":"Miami, FL"}')
assert_status "POST /students duplicate email" 409 "$RESP"

# ---------------------------------------------------------------------------
# PUT /students/1  — update student
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" \
    -X PUT "$BASE_URL/students/1" \
    -H "Content-Type: application/json" \
    -d '{"location":"Miami, FL"}')
BODY=$(cat /tmp/body.txt)
assert_status "PUT /students/1" 200 "$RESP"
assert_body_contains "PUT /students/1 body" "Miami" "$BODY"

# Restore original location
curl -s -o /dev/null -X PUT "$BASE_URL/students/1" \
    -H "Content-Type: application/json" \
    -d '{"location":"Tallahassee, FL"}'

# ---------------------------------------------------------------------------
# DELETE /students/<new>  — delete the student created above
# ---------------------------------------------------------------------------
# Fetch the new student's ID first
NEW_ID=$(curl -s "$BASE_URL/students" | grep -o '"user_id":[0-9]*' | tail -1 | grep -o '[0-9]*')
if [ -n "$NEW_ID" ]; then
    RESP=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$BASE_URL/students/$NEW_ID")
    assert_status "DELETE /students/$NEW_ID" 200 "$RESP"
else
    echo -e "${RED}SKIP${RESET}  DELETE /students — could not determine new student ID"
    FAIL=$((FAIL + 1))
fi

# ---------------------------------------------------------------------------
# GET /opportunities  — list all opportunities
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" "$BASE_URL/opportunities")
BODY=$(cat /tmp/body.txt)
assert_status "GET /opportunities" 200 "$RESP"
assert_body_contains "GET /opportunities body" "Software Engineering Intern" "$BODY"

# ---------------------------------------------------------------------------
# GET /opportunities/1  — fetch opportunity by ID
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" "$BASE_URL/opportunities/1")
BODY=$(cat /tmp/body.txt)
assert_status "GET /opportunities/1" 200 "$RESP"
assert_body_contains "GET /opportunities/1 body" "Accenture" "$BODY"

# ---------------------------------------------------------------------------
# GET /opportunities/9999  — non-existent → 404
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/opportunities/9999")
assert_status "GET /opportunities/9999 (not found)" 404 "$RESP"

# ---------------------------------------------------------------------------
# GET /match/1  — match scores for student 1 (Alice)
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" "$BASE_URL/match/1")
BODY=$(cat /tmp/body.txt)
assert_status "GET /match/1" 200 "$RESP"
assert_body_contains "GET /match/1 has score" "score" "$BODY"
assert_body_contains "GET /match/1 has opportunity" "opportunity" "$BODY"

# ---------------------------------------------------------------------------
# GET /match/9999  — non-existent student → 404
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/match/9999")
assert_status "GET /match/9999 (not found)" 404 "$RESP"

# ---------------------------------------------------------------------------
# GET /applications  — list all applications
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" "$BASE_URL/applications")
BODY=$(cat /tmp/body.txt)
assert_status "GET /applications" 200 "$RESP"
assert_body_contains "GET /applications body" "user_id" "$BODY"

# ---------------------------------------------------------------------------
# POST /applications  — create a new application
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" \
    -X POST "$BASE_URL/applications" \
    -H "Content-Type: application/json" \
    -d '{"user_id":3,"opportunity_id":1}')
BODY=$(cat /tmp/body.txt)
assert_status "POST /applications" 201 "$RESP"

# ---------------------------------------------------------------------------
# POST /applications — duplicate → 409
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$BASE_URL/applications" \
    -H "Content-Type: application/json" \
    -d '{"user_id":1,"opportunity_id":1}')
assert_status "POST /applications duplicate" 409 "$RESP"

# ---------------------------------------------------------------------------
# DELETE /applications  — withdraw an application
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /dev/null -w "%{http_code}" \
    -X DELETE "$BASE_URL/applications" \
    -H "Content-Type: application/json" \
    -d '{"user_id":3,"opportunity_id":1}')
assert_status "DELETE /applications" 200 "$RESP"

# ---------------------------------------------------------------------------
# GET /companies  — list all companies
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" "$BASE_URL/companies")
BODY=$(cat /tmp/body.txt)
assert_status "GET /companies" 200 "$RESP"
assert_body_contains "GET /companies body" "Accenture" "$BODY"

# ---------------------------------------------------------------------------
# GET /skills  — list all skills
# ---------------------------------------------------------------------------
RESP=$(curl -s -o /tmp/body.txt -w "%{http_code}" "$BASE_URL/skills")
BODY=$(cat /tmp/body.txt)
assert_status "GET /skills" 200 "$RESP"
assert_body_contains "GET /skills body" "Python" "$BODY"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "======================================================"
TOTAL=$((PASS + FAIL))
echo "  Results: $PASS/$TOTAL passed"
if [ "$FAIL" -gt 0 ]; then
    echo -e "  ${RED}$FAIL assertion(s) failed${RESET}"
    echo "======================================================"
    exit 1
else
    echo -e "  ${GREEN}All assertions passed${RESET}"
    echo "======================================================"
    exit 0
fi

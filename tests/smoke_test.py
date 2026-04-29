"""
Smoke tests — runs against a live Flask server on http://127.0.0.1:5000.
Usage:  python tests/smoke_test.py
"""
import json
import sys
import urllib.error
import urllib.request

BASE = "http://127.0.0.1:5000"
PASS_LIST: list[str] = []
FAIL_LIST: list[str] = []


def check(label, url, method="GET", data=None, expected_status=200):
    req = urllib.request.Request(
        url,
        headers={"Accept": "application/json", "Content-Type": "application/json"},
    )
    req.method = method
    if data is not None:
        req.data = json.dumps(data).encode()
    try:
        with urllib.request.urlopen(req, timeout=5) as r:
            status = r.status
            body = json.loads(r.read())
    except urllib.error.HTTPError as e:
        status = e.code
        try:
            body = json.loads(e.read())
        except Exception:
            body = {}
    except Exception as exc:
        FAIL_LIST.append(f"  FAIL  {label}: {exc}")
        print(FAIL_LIST[-1])
        return None

    ok = status == expected_status
    tag = "  PASS" if ok else "  FAIL"
    line = f"{tag}  [{status}] {label}"
    (PASS_LIST if ok else FAIL_LIST).append(line)
    print(line)
    return body


# ── List endpoints ────────────────────────────────────────────────────────────
check("GET /students",        f"{BASE}/students")
check("GET /opportunities",   f"{BASE}/opportunities")
check("GET /applications",    f"{BASE}/applications")
check("GET /students/1",      f"{BASE}/students/1")
check("GET /opportunities/1", f"{BASE}/opportunities/1")
check("GET /match/1",         f"{BASE}/match/1")
check("GET /match/1/1",       f"{BASE}/match/1/1")
check("GET /students/99999 (404)", f"{BASE}/students/99999", expected_status=404)

# ── Create / read / update / delete student ───────────────────────────────────
new_s = check(
    "POST /students (create)",
    f"{BASE}/students",
    method="POST",
    data={"name": "Smoke Test User", "email": "smoke_test_99@example.com",
          "major": "Computer Science", "location": "Orlando, FL"},
    expected_status=201,
)
if new_s:
    uid = new_s.get("user_id")
    check(f"PUT /students/{uid} (update major)",
          f"{BASE}/students/{uid}", method="PUT",
          data={"major": "Data Science"}, expected_status=200)
    updated = check(f"GET /students/{uid} (verify update)",
                    f"{BASE}/students/{uid}", expected_status=200)
    if updated and updated.get("major") != "Data Science":
        FAIL_LIST.append(f"  FAIL  Student major not updated: {updated.get('major')}")
        print(FAIL_LIST[-1])
    check(f"DELETE /students/{uid}",
          f"{BASE}/students/{uid}", method="DELETE", expected_status=200)
    check(f"GET /students/{uid} (after delete — 404)",
          f"{BASE}/students/{uid}", expected_status=404)

# ── Duplicate email rejected ───────────────────────────────────────────────────
check(
    "POST /students (duplicate email → 409)",
    f"{BASE}/students",
    method="POST",
    data={"name": "Alice Duplicate", "email": "alice.reyes@fiu.edu",
          "major": "CS", "location": "Miami, FL"},
    expected_status=409,
)

# ── Create / update / delete application ─────────────────────────────────────
check(
    "POST /applications (create)",
    f"{BASE}/applications",
    method="POST",
    data={"user_id": 2, "opportunity_id": 3},
    expected_status=201,
)
check(
    "PUT /applications/2/3 (set reviewed)",
    f"{BASE}/applications/2/3",
    method="PUT",
    data={"status": "reviewed"},
    expected_status=200,
)
check(
    "PUT /applications/2/3 (invalid status → 400)",
    f"{BASE}/applications/2/3",
    method="PUT",
    data={"status": "promoted"},
    expected_status=400,
)
check(
    "DELETE /applications (withdraw)",
    f"{BASE}/applications",
    method="DELETE",
    data={"user_id": 2, "opportunity_id": 3},
    expected_status=200,
)

# ── Summary ───────────────────────────────────────────────────────────────────
print(f"\n{'='*55}")
print(f"PASSED: {len(PASS_LIST)}   FAILED: {len(FAIL_LIST)}")
if FAIL_LIST:
    print("\nFailures:")
    for line in FAIL_LIST:
        print(line)
    sys.exit(1)
else:
    print("All smoke tests passed!")

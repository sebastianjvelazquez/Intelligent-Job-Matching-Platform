#!/usr/bin/env python3
"""
scripts/generate_seed.py
------------------------
Generates a larger, randomized seed.sql for the Intelligent Job Matching Platform.

Usage:
    python3 scripts/generate_seed.py [--students N] [--companies N] [--output PATH]

Defaults:
    --students  30   (project spec: 30–50)
    --companies 10   (project spec: 10–15)
    --output    seed.sql

The generated file is safe to reload: it truncates all tables in reverse FK
order before inserting. Run against an existing database with:
    mysql -u <user> -p job_matching < seed.sql
"""

import argparse
import random
import textwrap
from datetime import datetime

# ---------------------------------------------------------------------------
# Master data pools
# ---------------------------------------------------------------------------
FIRST_NAMES = [
    "Alice", "Brian", "Carla", "Derek", "Elena", "Fabian", "Grace", "Hector",
    "Isabel", "Jason", "Karen", "Luis", "Mia", "Nathan", "Olivia", "Pedro",
    "Quinn", "Rosa", "Samuel", "Tina", "Ulysses", "Vera", "Will", "Xena",
    "Yara", "Zane", "Ana", "Ben", "Carmen", "Diego",
]
LAST_NAMES = [
    "Torres", "Nguyen", "Reyes", "Smith", "Vasquez", "Garcia", "Martinez",
    "Johnson", "Brown", "Davis", "Wilson", "Anderson", "Thomas", "Jackson",
    "White", "Harris", "Clark", "Lewis", "Robinson", "Walker", "Young",
    "Allen", "King", "Wright", "Scott", "Green", "Hall", "Adams", "Nelson",
    "Carter",
]
MAJORS = [
    "Computer Science", "Information Technology", "Computer Engineering",
    "Electrical Engineering", "Cybersecurity", "Data Science",
]
CITIES = [
    "Tallahassee, FL", "Miami, FL", "Orlando, FL", "Tampa, FL",
    "Jacksonville, FL", "Gainesville, FL", "Atlanta, GA", "Austin, TX",
    "Charlotte, NC", "Houston, TX",
]
COMPANY_NAMES = [
    "Accenture", "Lockheed Martin", "CrowdStrike", "Deloitte", "Booz Allen Hamilton",
    "Raytheon Technologies", "SAIC", "Leidos", "Northrop Grumman", "IBM",
    "Microsoft", "Amazon", "Google", "Meta", "Salesforce",
]
COMPANY_CITIES = [
    "Tampa, FL", "Orlando, FL", "Austin, TX", "McLean, VA", "Reston, VA",
    "San Antonio, TX", "Herndon, VA", "Falls Church, VA", "Fairfax, VA",
    "Armonk, NY", "Redmond, WA", "Seattle, WA", "Mountain View, CA",
    "Menlo Park, CA", "San Francisco, CA",
]
SKILLS = [
    ("Python",          "technical"),
    ("SQL",             "technical"),
    ("Docker",          "technical"),
    ("Java",            "technical"),
    ("Cybersecurity",   "technical"),
    ("Communication",   "soft"),
    ("Machine Learning","technical"),
    ("Linux",           "technical"),
    ("Flask",           "technical"),
    ("Teamwork",        "soft"),
    ("JavaScript",      "technical"),
    ("React",           "technical"),
    ("AWS",             "technical"),
    ("Git",             "technical"),
    ("Networking",      "technical"),
    ("Kubernetes",      "technical"),
    ("Bash",            "technical"),
    ("C++",             "technical"),
    ("Data Analysis",   "technical"),
    ("Problem Solving", "soft"),
    ("Agile",           "soft"),
    ("REST APIs",       "technical"),
    ("Azure",           "technical"),
    ("R",               "technical"),
    ("Penetration Testing", "technical"),
]
JOB_TITLES = [
    "Software Engineering Intern",
    "Database Administrator Intern",
    "Systems Integration Engineer",
    "Cybersecurity Analyst Intern",
    "Threat Intelligence Intern",
    "ML Platform Engineer Intern",
    "Cloud Infrastructure Intern",
    "Backend Developer Intern",
    "Data Engineering Intern",
    "Network Security Intern",
    "DevOps Intern",
    "Full Stack Developer Intern",
]
LEVELS = ["Beginner", "Intermediate", "Advanced"]


def esc(s: str) -> str:
    return s.replace("'", "\\'")


def generate(n_students: int, n_companies: int, output: str) -> None:
    random.seed(42)  # reproducible output

    companies = []
    for i in range(n_companies):
        name = COMPANY_NAMES[i % len(COMPANY_NAMES)]
        loc = COMPANY_CITIES[i % len(COMPANY_CITIES)]
        companies.append((i + 1, name, loc))

    skills = [(i + 1, s[0]) for i, s in enumerate(SKILLS)]

    students = []
    used_emails: set[str] = set()
    for i in range(n_students):
        fn = FIRST_NAMES[i % len(FIRST_NAMES)]
        ln = LAST_NAMES[i % len(LAST_NAMES)]
        base = f"{fn[0].lower()}{ln[:3].lower()}{random.randint(10,99)}"
        email = f"{base}@fsu.edu"
        while email in used_emails:
            email = f"{base}{random.randint(0,9)}@fsu.edu"
        used_emails.add(email)
        major = random.choice(MAJORS)
        loc = random.choice(CITIES)
        resume = f"{major} student seeking opportunities in {random.choice(['cloud', 'security', 'backend', 'data', 'systems'])} engineering."
        students.append((i + 1, fn, ln, email, major, loc, resume))

    opportunities = []
    opp_id = 1
    for cid, cname, cloc in companies:
        n_opps = random.randint(2, 5)
        titles = random.sample(JOB_TITLES, min(n_opps, len(JOB_TITLES)))
        for title in titles:
            opportunities.append((opp_id, title, cloc, cid))
            opp_id += 1

    student_skills = []
    for sid, *_ in students:
        n_skills = random.randint(3, 8)
        chosen = random.sample(skills, min(n_skills, len(skills)))
        for skill_id, _ in chosen:
            level = random.choice(LEVELS)
            student_skills.append((sid, skill_id, level))

    opp_skills = []
    skill_ids = [s[0] for s in skills]
    for oid, *_ in opportunities:
        n_req = random.randint(2, 4)
        n_pref = random.randint(0, 2)
        pool = random.sample(skill_ids, min(n_req + n_pref, len(skill_ids)))
        for j, sid in enumerate(pool):
            priority = "required" if j < n_req else "preferred"
            opp_skills.append((oid, sid, priority))

    applications = []
    opp_ids = [o[0] for o in opportunities]
    for sid, *_ in students:
        n_apps = random.randint(0, 3)
        targets = random.sample(opp_ids, min(n_apps, len(opp_ids)))
        for oid in targets:
            applications.append((sid, oid))

    lines = [
        f"-- Auto-generated seed data ({datetime.utcnow().strftime('%Y-%m-%d')})",
        f"-- Students: {n_students}  Companies: {n_companies}",
        f"-- Skills: {len(skills)}  Opportunities: {len(opportunities)}",
        "--",
        "-- Reset: truncate in reverse FK order, then reload.",
        "",
        "SET FOREIGN_KEY_CHECKS = 0;",
        "TRUNCATE TABLE Application;",
        "TRUNCATE TABLE OpportunitySkill;",
        "TRUNCATE TABLE StudentSkill;",
        "TRUNCATE TABLE Opportunity;",
        "TRUNCATE TABLE Student;",
        "TRUNCATE TABLE Skill;",
        "TRUNCATE TABLE Company;",
        "SET FOREIGN_KEY_CHECKS = 1;",
        "",
        "-- Companies",
        "INSERT INTO Company (name, location) VALUES",
    ]
    rows = [f"    ('{esc(name)}', '{esc(loc)}')" for _, name, loc in companies]
    lines.append(",\n".join(rows) + ";")

    lines += ["", "-- Skills", "INSERT INTO Skill (name) VALUES"]
    rows = [f"    ('{esc(name)}')" for _, name in skills]
    lines.append(",\n".join(rows) + ";")

    lines += ["", "-- Students", "INSERT INTO Student (name, email, major, location, resume) VALUES"]
    rows = [f"    ('{esc(fn+\" \"+ln)}', '{esc(email)}', '{esc(major)}', '{esc(loc)}', '{esc(resume)}')"
            for _, fn, ln, email, major, loc, resume in students]
    lines.append(",\n".join(rows) + ";")

    lines += ["", "-- Opportunities", "INSERT INTO Opportunity (title, location, company_id) VALUES"]
    rows = [f"    ('{esc(title)}', '{esc(loc)}', {cid})" for _, title, loc, cid in opportunities]
    lines.append(",\n".join(rows) + ";")

    lines += ["", "-- StudentSkill", "INSERT INTO StudentSkill (user_id, skill_id, level) VALUES"]
    rows = [f"    ({uid}, {sid}, '{level}')" for uid, sid, level in student_skills]
    lines.append(",\n".join(rows) + ";")

    lines += ["", "-- OpportunitySkill", "INSERT INTO OpportunitySkill (opportunity_id, skill_id, priority) VALUES"]
    rows = [f"    ({oid}, {sid}, '{priority}')" for oid, sid, priority in opp_skills]
    lines.append(",\n".join(rows) + ";")

    lines += ["", "-- Application", "INSERT INTO Application (user_id, opportunity_id) VALUES"]
    rows = [f"    ({uid}, {oid})" for uid, oid in applications]
    lines.append(",\n".join(rows) + ";")

    with open(output, "w") as f:
        f.write("\n".join(lines) + "\n")

    print(f"Generated {output}")
    print(f"  {n_students} students, {n_companies} companies, {len(skills)} skills, "
          f"{len(opportunities)} opportunities, {len(student_skills)} student-skills, "
          f"{len(opp_skills)} opportunity-skills, {len(applications)} applications")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate seed SQL for the Job Matching Platform")
    parser.add_argument("--students",  type=int, default=30, help="Number of students (default: 30)")
    parser.add_argument("--companies", type=int, default=10, help="Number of companies (default: 10)")
    parser.add_argument("--output",    default="seed.sql",   help="Output file path (default: seed.sql)")
    args = parser.parse_args()
    generate(args.students, args.companies, args.output)

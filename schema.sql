-- Intelligent Job Matching Platform
-- Schema: creation order respects FK dependencies

CREATE TABLE IF NOT EXISTS Company (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(255) NOT NULL,
    location   VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Skill (
    skill_id INT AUTO_INCREMENT PRIMARY KEY,
    name     VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Student (
    user_id  INT AUTO_INCREMENT PRIMARY KEY,
    name     VARCHAR(255) NOT NULL,
    email    VARCHAR(255) NOT NULL UNIQUE,
    major    VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    resume   TEXT
);

CREATE TABLE IF NOT EXISTS Opportunity (
    opportunity_id INT AUTO_INCREMENT PRIMARY KEY,
    title          VARCHAR(255) NOT NULL,
    company_id     INT NOT NULL,
    CONSTRAINT fk_opportunity_company
        FOREIGN KEY (company_id) REFERENCES Company(company_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS StudentSkill (
    user_id  INT NOT NULL,
    skill_id INT NOT NULL,
    level    ENUM('Beginner', 'Intermediate', 'Advanced') NOT NULL DEFAULT 'Beginner',
    PRIMARY KEY (user_id, skill_id),
    CONSTRAINT fk_studentskill_student
        FOREIGN KEY (user_id)  REFERENCES Student(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_studentskill_skill
        FOREIGN KEY (skill_id) REFERENCES Skill(skill_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Application (
    user_id        INT NOT NULL,
    opportunity_id INT NOT NULL,
    PRIMARY KEY (user_id, opportunity_id),
    CONSTRAINT fk_application_student
        FOREIGN KEY (user_id)        REFERENCES Student(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_application_opportunity
        FOREIGN KEY (opportunity_id) REFERENCES Opportunity(opportunity_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS OpportunitySkill (
    opportunity_id INT NOT NULL,
    skill_id       INT NOT NULL,
    PRIMARY KEY (opportunity_id, skill_id),
    CONSTRAINT fk_opskill_opportunity
        FOREIGN KEY (opportunity_id) REFERENCES Opportunity(opportunity_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_opskill_skill
        FOREIGN KEY (skill_id)       REFERENCES Skill(skill_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

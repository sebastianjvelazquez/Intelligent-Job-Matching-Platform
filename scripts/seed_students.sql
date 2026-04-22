-- seed_students.sql  (40 students)
-- Load order: 3 of 7
-- Students 1–3  : perfect-match candidates (skills align exactly with demo opportunities)
-- Students 4–6  : partial-match candidates (≥50 % skill overlap with a demo opportunity)
-- Students 7–40 : general population (varied backgrounds)
INSERT INTO Student (name, email, major, location) VALUES
    -- Perfect-match students (IDs 1–3)
    ('Alice Reyes',         'alice.reyes@ucf.edu',         'Computer Science',      'Orlando, FL'),
    ('Carlos Mendez',       'carlos.mendez@fiu.edu',       'Cybersecurity',         'Miami, FL'),
    ('Diana Pham',          'diana.pham@usf.edu',          'Data Science',          'Tampa, FL'),
    -- Partial-match students (IDs 4–6)
    ('Ethan Brooks',        'ethan.brooks@fsu.edu',        'Computer Science',      'Tallahassee, FL'),
    ('Fiona Torres',        'fiona.torres@unf.edu',        'Information Technology','Jacksonville, FL'),
    ('George Nguyen',       'george.nguyen@fau.edu',       'Software Engineering',  'Boca Raton, FL'),
    -- General population (IDs 7–40)
    ('Hannah Kim',          'hannah.kim@miami.edu',        'Computer Science',      'Coral Gables, FL'),
    ('Ian Walker',          'ian.walker@ucf.edu',          'Information Systems',   'Orlando, FL'),
    ('Julia Santos',        'julia.santos@fiu.edu',        'Computer Science',      'Miami, FL'),
    ('Kevin Osei',          'kevin.osei@usf.edu',          'Data Science',          'Tampa, FL'),
    ('Laura Chen',          'laura.chen@fsu.edu',          'Software Engineering',  'Tallahassee, FL'),
    ('Marco Rivera',        'marco.rivera@unf.edu',        'Cybersecurity',         'Jacksonville, FL'),
    ('Nina Patel',          'nina.patel@fau.edu',          'Computer Science',      'Boca Raton, FL'),
    ('Oscar Grant',         'oscar.grant@miami.edu',       'Information Technology','Coral Gables, FL'),
    ('Paula Hernandez',     'paula.hernandez@ucf.edu',     'Data Science',          'Orlando, FL'),
    ('Quincy Adams',        'quincy.adams@fiu.edu',        'Software Engineering',  'Miami, FL'),
    ('Rachel Lee',          'rachel.lee@usf.edu',          'Computer Science',      'Tampa, FL'),
    ('Samuel Ortiz',        'samuel.ortiz@fsu.edu',        'Cybersecurity',         'Tallahassee, FL'),
    ('Tara Johansson',      'tara.johansson@unf.edu',      'Data Science',          'Jacksonville, FL'),
    ('Ulises Ferreira',     'ulises.ferreira@fau.edu',     'Computer Science',      'Boca Raton, FL'),
    ('Victoria Huang',      'victoria.huang@miami.edu',    'Software Engineering',  'Coral Gables, FL'),
    ('Wesley Clark',        'wesley.clark@ucf.edu',        'Information Systems',   'Orlando, FL'),
    ('Xiomara Diaz',        'xiomara.diaz@fiu.edu',        'Cybersecurity',         'Miami, FL'),
    ('Yasmine Tremblay',    'yasmine.tremblay@usf.edu',    'Data Science',          'Tampa, FL'),
    ('Zachary Moore',       'zachary.moore@fsu.edu',       'Computer Science',      'Tallahassee, FL'),
    ('Amara Okonkwo',       'amara.okonkwo@unf.edu',       'Information Technology','Jacksonville, FL'),
    ('Benjamin Scott',      'benjamin.scott@fau.edu',      'Software Engineering',  'Boca Raton, FL'),
    ('Camille Bouchard',    'camille.bouchard@miami.edu',  'Computer Science',      'Coral Gables, FL'),
    ('Dante Morales',       'dante.morales@ucf.edu',       'Data Science',          'Orlando, FL'),
    ('Elena Vasquez',       'elena.vasquez@fiu.edu',       'Cybersecurity',         'Miami, FL'),
    ('Felix Schmidt',       'felix.schmidt@usf.edu',       'Computer Science',      'Tampa, FL'),
    ('Gabriela Rojas',      'gabriela.rojas@fsu.edu',      'Software Engineering',  'Tallahassee, FL'),
    ('Hassan Ali',          'hassan.ali@unf.edu',          'Information Systems',   'Jacksonville, FL'),
    ('Isabella Russo',      'isabella.russo@fau.edu',      'Data Science',          'Boca Raton, FL'),
    ('Javier Cruz',         'javier.cruz@miami.edu',       'Computer Science',      'Coral Gables, FL'),
    ('Kayla Bennett',       'kayla.bennett@ucf.edu',       'Cybersecurity',         'Orlando, FL'),
    ('Liam O\'Brien',       'liam.obrien@fiu.edu',         'Software Engineering',  'Miami, FL'),
    ('Maya Robinson',       'maya.robinson@usf.edu',       'Data Science',          'Tampa, FL'),
    ('Noah Thompson',       'noah.thompson@fsu.edu',       'Computer Science',      'Tallahassee, FL'),
    ('Olivia Martinez',     'olivia.martinez@unf.edu',     'Information Technology','Jacksonville, FL');

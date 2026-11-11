-- ============================================================================
-- VERITAS UNIVERSITY, ABUJA
-- DEPARTMENT OF SOFTWARE ENGINEERING
-- Course: VUA-SEN307 Database Systems — Week 6 Practical
-- Lab 4: Data Manipulation Language (DML): Insert, Update, Delete
-- Student Name: Pam Patriarch Yeipyeng
-- Matric No: VUG/SEN/24/12478
-- File: data.sql
-- ============================================================================

USE sen307_vug_sen_24_12478;

-- ============================================================================
-- PART 1: DEPARTMENTS AND COURSES (PROVIDED)
-- ============================================================================

INSERT INTO Department (dept_name) VALUES
('Software Engineering'),
('Computer Science'),
('Artificial Intelligence'),
('Data Science'),
('Cybersecurity');

INSERT INTO Course (course_code, course_title, credit_units, description, dept_id) VALUES
('SEN307', 'Database Systems', 3,
 'Relational database design, SQL queries, normalization, transactions and indexing using MySQL.',
 (SELECT dept_id FROM Department WHERE dept_name = 'Software Engineering')),
('SEN301', 'Software Architecture', 3,
 'Architectural styles, design patterns, microservices and how to structure large software systems.',
 (SELECT dept_id FROM Department WHERE dept_name = 'Software Engineering')),
('COS301', 'Operating Systems', 3,
 'Processes, threads, CPU scheduling, memory management and file systems.',
 (SELECT dept_id FROM Department WHERE dept_name = 'Computer Science')),
('COS305', 'Computer Networks', 3,
 'TCP/IP, routing, switching, LAN and WAN design and network protocols.',
 (SELECT dept_id FROM Department WHERE dept_name = 'Computer Science')),
('AIN301', 'Introduction to Artificial Intelligence', 3,
 'Intelligent agents, search algorithms, knowledge representation and reasoning.',
 (SELECT dept_id FROM Department WHERE dept_name = 'Artificial Intelligence')),
('AIN305', 'Machine Learning', 3,
 'Supervised and unsupervised learning, neural networks, deep learning and model evaluation.',
 (SELECT dept_id FROM Department WHERE dept_name = 'Artificial Intelligence')),
('AIN307', 'Natural Language Processing', 3,
 'Text processing, word embeddings, language models, sentiment analysis and chatbots.',
 (SELECT dept_id FROM Department WHERE dept_name = 'Artificial Intelligence')),
('DTS301', 'Data Visualization and Analytics', 2,
 'Exploratory data analysis, charts, dashboards and telling stories with data.',
 (SELECT dept_id FROM Department WHERE dept_name = 'Data Science')),
('DTS305', 'Big Data Technologies', 3,
 'Distributed storage and processing of very large datasets with Hadoop and Spark.',
 (SELECT dept_id FROM Department WHERE dept_name = 'Data Science')),
('CYB301', 'Network Security', 3,
 'Firewalls, cryptography, intrusion detection and protecting networks from attacks.',
 (SELECT dept_id FROM Department WHERE dept_name = 'Cybersecurity'));

-- Verify 5 departments with 10 courses between them
SELECT d.dept_name, COUNT(c.course_id) AS courses
FROM Department d LEFT JOIN Course c ON d.dept_id = c.dept_id
GROUP BY d.dept_name;

-- Note the ID numbers needed for Part 2
SELECT dept_id, dept_name FROM Department;
SELECT course_id, course_code FROM Course;

-- ============================================================================
-- PART 2: YOUR OWN DATA
-- ============================================================================

-- Step 1: Lecturers (10 in total, spread across all 5 departments)
INSERT INTO Lecturer (staff_no, full_name, email, dept_id) VALUES
('VUA/ST/101', 'Dr Amaka Okafor',     'a.okafor@vua.edu.ng',    1),
('VUA/ST/102', 'Dr Musa Bello',       'm.bello@vua.edu.ng',     1),
('VUA/ST/103', 'Dr Chinedu Eze',      'c.eze@vua.edu.ng',       2),
('VUA/ST/104', 'Dr Funke Adeyemi',    'f.adeyemi@vua.edu.ng',   2),
('VUA/ST/105', 'Dr Ibrahim Danjuma',  'i.danjuma@vua.edu.ng',   3),
('VUA/ST/106', 'Dr Ngozi Nwosu',      'n.nwosu@vua.edu.ng',     3),
('VUA/ST/107', 'Dr Tunde Bakare',     't.bakare@vua.edu.ng',    4),
('VUA/ST/108', 'Dr Zainab Abdullahi', 'z.abdullahi@vua.edu.ng', 4),
('VUA/ST/109', 'Dr Emeka Nwachukwu',  'e.nwachukwu@vua.edu.ng', 5),
('VUA/ST/110', 'Dr Halima Suleiman',  'h.suleiman@vua.edu.ng',  5);

-- Step 2: Students (20 in total, including own name and matric number,
-- mix of genders and dates of birth between 2003 and 2007)
INSERT INTO Student (matric_no, full_name, gender, date_of_birth, dept_id) VALUES
('20231234',         'Ada Obi',                'F', '2005-03-14', 1),
('20231235',         'John Musa',              'M', '2004-11-02', 2),
('VUG/SEN/24/12478', 'Pam Patriarch Yeipyeng', 'M', '2005-06-15', 1),
('VUG/SEN/24/12004', 'Chidinma Okafor',        'F', '2006-01-22', 1),
('VUG/SEN/24/12005', 'Oluwaseun Adebayo',      'M', '2003-08-19', 1),
('VUG/CSC/24/12006', 'Fatima Abubakar',        'F', '2005-09-10', 2),
('VUG/CSC/24/12007', 'Kelechi Nnaji',          'M', '2004-04-05', 2),
('VUG/CSC/24/12008', 'Aisha Mohammed',         'F', '2007-02-18', 2),
('VUG/AIN/24/12009', 'Babatunde Ogunleye',     'M', '2003-12-01', 3),
('VUG/AIN/24/12010', 'Nneka Chukwu',           'F', '2006-07-25', 3),
('VUG/AIN/24/12011', 'Usman Garba',            'M', '2005-05-12', 3),
('VUG/AIN/24/12012', 'Blessing Eze',           'F', '2004-10-30', 3),
('VUG/DTS/24/12013', 'Damilola Ojo',           'F', '2006-03-08', 4),
('VUG/DTS/24/12014', 'Sadiq Lawal',            'M', '2003-06-27', 4),
('VUG/DTS/24/12015', 'Chiamaka Okeke',         'F', '2007-05-14', 4),
('VUG/DTS/24/12016', 'Tobi Akintola',          'M', '2004-01-19', 4),
('VUG/CYB/24/12017', 'Hauwa Yakubu',           'F', '2005-11-23', 5),
('VUG/CYB/24/12018', 'Ebuka Obi',              'M', '2006-08-03', 5),
('VUG/CYB/24/12019', 'Zainab Bello',           'F', '2003-09-17', 5),
('VUG/SEN/24/12020', 'Yakubu Danladi',         'M', '2007-04-21', 1);

-- Step 3: Enrolments (40 in total) and course allocations
-- First list the IDs
SELECT student_id, matric_no, full_name FROM Student;
SELECT lecturer_id, full_name FROM Lecturer;

-- 40 Enrolments in total:
-- * Course 1 (SEN307) has 10 students (> 5 students for Week 8 HAVING)
-- * Students 19 and 20 have no enrolments (for Weeks 7 & 8 LEFT JOIN and subqueries)
-- * No duplicate (student_id, course_id) pairs
INSERT INTO Enrolment (student_id, course_id) VALUES
(1, 1),  (1, 2),
(2, 1),  (2, 3),
(3, 1),  (3, 2),  (3, 5),
(4, 1),  (4, 2),
(5, 1),  (5, 2),
(6, 1),  (6, 3),  (6, 4),
(7, 1),  (7, 3),  (7, 4),
(8, 1),  (8, 3),  (8, 4),
(9, 1),  (9, 5),  (9, 6),
(10, 1), (10, 5), (10, 6),
(11, 5), (11, 6), (11, 7),
(12, 5), (12, 6), (12, 7),
(13, 8), (13, 9),
(14, 8), (14, 9),
(15, 8),
(16, 9),
(17, 10),
(18, 10);

-- Course allocations: every course (1 to 10) has at least one lecturer; course 1 has two
INSERT INTO CourseAllocation (course_id, lecturer_id) VALUES
(1, 1), (1, 2),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 5),
(8, 7),
(9, 8),
(10, 9);

-- ============================================================================
-- PART 3: UPDATE A RECORD
-- ============================================================================

-- Check student before update
SELECT matric_no, full_name, dept_id FROM Student WHERE matric_no = '20231234';

-- Move student 20231234 to department 2 (with safe update mode wrapper)
SET SQL_SAFE_UPDATES = 0;
UPDATE Student SET dept_id = 2 WHERE matric_no = '20231234';
SET SQL_SAFE_UPDATES = 1;

-- Check student after update
SELECT matric_no, full_name, dept_id FROM Student WHERE matric_no = '20231234';

-- ============================================================================
-- PART 4: REFERENTIAL INTEGRITY (DELETE)
-- ============================================================================

-- Step 1: Create a department with a student in it
INSERT INTO Department (dept_name) VALUES ('Library and Information Science');

INSERT INTO Student (matric_no, full_name, dept_id)
VALUES ('20239999', 'Transfer Student',
        (SELECT dept_id FROM Department WHERE dept_name = 'Library and Information Science'));

-- Step 2: Try to delete the department
-- Expected Error: Error 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails
DELETE FROM Department WHERE dept_name = 'Library and Information Science';

-- Step 3: Fix it the correct way
SET SQL_SAFE_UPDATES = 0;

-- Step 3.1: Reassign the dependent student to another department
UPDATE Student
SET dept_id = (SELECT dept_id FROM Department
               WHERE dept_name = 'Software Engineering')
WHERE matric_no = '20239999';

-- Step 3.2: Now the delete succeeds
DELETE FROM Department WHERE dept_name = 'Library and Information Science';

SET SQL_SAFE_UPDATES = 1;

SELECT * FROM Department;

-- ============================================================================
-- FINAL CHECK
-- ============================================================================

SELECT 'Departments' AS tbl, COUNT(*) AS total FROM Department
UNION ALL SELECT 'Lecturers',   COUNT(*) FROM Lecturer
UNION ALL SELECT 'Students',    COUNT(*) FROM Student
UNION ALL SELECT 'Courses',     COUNT(*) FROM Course
UNION ALL SELECT 'Enrolments',  COUNT(*) FROM Enrolment
UNION ALL SELECT 'Allocations', COUNT(*) FROM CourseAllocation;


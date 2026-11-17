-- ============================================================================
-- VUA-SEN307 Lab 5: SELECT, Filtering and Joins (Week 7 Practical)
-- Name: Pam Patriarch Yeipyeng      Matric: VUG/SEN/24/12478
-- ============================================================================

USE sen307_vug_sen_24_12478;

-- ============================================================================
-- RECAP: Verify Week 6 table row counts before running Week 7 queries
-- ============================================================================
SELECT 'Departments' AS tbl, COUNT(*) AS total FROM Department
UNION ALL SELECT 'Lecturers',   COUNT(*) FROM Lecturer
UNION ALL SELECT 'Students',    COUNT(*) FROM Student
UNION ALL SELECT 'Courses',     COUNT(*) FROM Course
UNION ALL SELECT 'Enrolments',  COUNT(*) FROM Enrolment
UNION ALL SELECT 'Allocations', COUNT(*) FROM CourseAllocation;


-- ============================================================================
-- Task 1: Students in one department, sorted A-Z
-- ============================================================================
SELECT s.student_id,
       s.matric_no,
       s.full_name,
       s.gender,
       s.date_of_birth,
       d.dept_name
FROM Student s
INNER JOIN Department d ON s.dept_id = d.dept_id
WHERE d.dept_name = 'Software Engineering'
ORDER BY s.full_name ASC;

-- Explanation (Task 1):
-- Joins the Student table to the Department table on dept_id, filters for students
-- belonging to the 'Software Engineering' department, and sorts the result
-- alphabetically (A to Z) by the student's full_name.


-- ============================================================================
-- Task 2: Courses with their lecturers (INNER JOIN)
-- ============================================================================
SELECT c.course_code,
       c.course_title,
       l.staff_no,
       l.full_name AS lecturer_name,
       ca.academic_session
FROM Course c
INNER JOIN CourseAllocation ca ON c.course_id = ca.course_id
INNER JOIN Lecturer l          ON ca.lecturer_id = l.lecturer_id
ORDER BY c.course_code ASC, l.full_name ASC;

-- Explanation (Task 2):
-- Links Course to Lecturer through the CourseAllocation junction table using two
-- INNER JOINs (Course -> CourseAllocation -> Lecturer). Every allocated course is
-- listed alongside its lecturer, and SEN307 (Database Systems) appears twice
-- because two lecturers (Dr Amaka Okafor and Dr Musa Bello) are assigned to it.


-- ============================================================================
-- Task 3: Students and their courses (LEFT JOIN)
-- ============================================================================

-- 3A: Worked example — every student and their enrolled courses (including NULLs)
SELECT s.full_name,
       c.course_title
FROM Student s
LEFT JOIN Enrolment e ON s.student_id = e.student_id
LEFT JOIN Course c    ON e.course_id = c.course_id
ORDER BY s.full_name ASC, c.course_title ASC;

-- 3B: Filter for ONLY the students with no course enrolments
SELECT s.student_id,
       s.matric_no,
       s.full_name,
       c.course_title
FROM Student s
LEFT JOIN Enrolment e ON s.student_id = e.student_id
LEFT JOIN Course c    ON e.course_id = c.course_id
WHERE c.course_title IS NULL
ORDER BY s.full_name ASC;

-- Explanation (Task 3):
-- Uses LEFT JOIN from Student to Enrolment and Course so that every student row is
-- preserved even when no matching enrolment exists (producing NULL in course_title).
-- Adding WHERE c.course_title IS NULL filters the result to show only the unenrolled
-- students created in Week 6 (Yakubu Danladi, Zainab Bello, and Transfer Student).


-- ============================================================================
-- Task 4: Filtering with AND / OR / IN / BETWEEN
-- ============================================================================
SELECT student_id,
       matric_no,
       full_name,
       gender,
       date_of_birth,
       dept_id
FROM Student
WHERE gender = 'F'
  AND (dept_id IN (1, 3) OR dept_id = 2)
  AND date_of_birth BETWEEN '2004-01-01' AND '2006-12-31'
ORDER BY date_of_birth ASC;

-- Explanation (Task 4):
-- Combines AND, OR (grouped in brackets for correct operator precedence), IN, and
-- BETWEEN in a single query to retrieve female students ('F') in Software Engineering
-- (dept_id 1), Artificial Intelligence (dept_id 3), or Computer Science (dept_id 2)
-- who were born between 1 January 2004 and 31 December 2006.


-- ============================================================================
-- Task 5: Paginating enrolments with LIMIT and OFFSET
-- ============================================================================

-- Page 1: Rows 1 to 10 (LIMIT 10 OFFSET 0)
SELECT e.enrolment_id,
       s.matric_no,
       s.full_name,
       c.course_code,
       c.course_title,
       e.academic_session,
       e.semester
FROM Enrolment e
INNER JOIN Student s ON e.student_id = s.student_id
INNER JOIN Course c  ON e.course_id = c.course_id
ORDER BY e.enrolment_id ASC
LIMIT 10 OFFSET 0;

-- Page 2: Rows 11 to 20 (LIMIT 10 OFFSET 10)
SELECT e.enrolment_id,
       s.matric_no,
       s.full_name,
       c.course_code,
       c.course_title,
       e.academic_session,
       e.semester
FROM Enrolment e
INNER JOIN Student s ON e.student_id = s.student_id
INNER JOIN Course c  ON e.course_id = c.course_id
ORDER BY e.enrolment_id ASC
LIMIT 10 OFFSET 10;

-- Explanation (Task 5):
-- Retrieves enrolment records 10 rows at a time: Page 1 uses LIMIT 10 OFFSET 0
-- (enrolment_id 1 to 10) and Page 2 uses LIMIT 10 OFFSET 10 (enrolment_id 11 to 20).
-- Why ORDER BY is mandatory with LIMIT: Relational tables have no guaranteed internal
-- row order. Without a deterministic ORDER BY enrolment_id, MySQL may return rows in
-- an unpredictable order across queries, causing rows to repeat or be skipped across pages.


-- ============================================================================
-- Challenge (Optional): Rewrite Task 3 using a RIGHT JOIN
-- ============================================================================
SELECT s.full_name,
       c.course_title
FROM Course c
INNER JOIN Enrolment e ON c.course_id = e.course_id
RIGHT JOIN Student s   ON e.student_id = s.student_id
ORDER BY s.full_name ASC, c.course_title ASC;

-- Explanation (Challenge):
-- Places Course and Enrolment on the left and Student on the right of a RIGHT JOIN
-- so all rows from Student are preserved (with NULL for course_title when a student
-- has no enrolments). The LEFT JOIN version in Task 3 is much easier to read because
-- SQL queries are naturally read top-to-bottom starting from the main entity being
-- queried (Student) and progressively attaching optional related tables.

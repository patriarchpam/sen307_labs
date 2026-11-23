-- ============================================================================
-- VUA-SEN307 Lab 6: Week 9 - Aggregate Functions, Grouping and Subqueries
-- Name: Pam Patriarch Yeipyeng      Matric: VUG/SEN/24/12478
-- ============================================================================

USE sen307_vug_sen_24_12478;

-- ============================================================================
-- Task 1: Count the students enrolled in each course, grouped by course
--         (including courses with zero students)
-- ============================================================================
SELECT c.course_id,
       c.course_code,
       c.course_title,
       COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_title
ORDER BY total_students DESC, c.course_code ASC;

-- Explanation (Task 1):
-- Uses LEFT JOIN from Course to Enrolment and groups by course so every course is
-- included even if no students are enrolled.
-- Why LEFT JOIN with COUNT(e.student_id) gives 0 rather than 1 for an empty course:
-- When a course has no matching rows in Enrolment, LEFT JOIN still outputs 1 row for
-- the course with NULL in all Enrolment columns (e.student_id IS NULL). Because
-- COUNT(e.student_id) counts only non-NULL values, it returns 0 (whereas COUNT(*)
-- counts rows regardless of NULLs and would return 1).


-- ============================================================================
-- Task 2: Find courses with more than a given number of students using HAVING
--         (Thresholds of 3, 5, and 7)
-- ============================================================================

-- 2A: Courses with more than 3 students (HAVING COUNT(e.student_id) > 3)
SELECT c.course_code,
       c.course_title,
       COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_title
HAVING COUNT(e.student_id) > 3
ORDER BY total_students DESC, c.course_code ASC;

-- 2B: Courses with more than 5 students (HAVING COUNT(e.student_id) > 5)
SELECT c.course_code,
       c.course_title,
       COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_title
HAVING COUNT(e.student_id) > 5
ORDER BY total_students DESC, c.course_code ASC;

-- 2C: Courses with more than 7 students (HAVING COUNT(e.student_id) > 7)
SELECT c.course_code,
       c.course_title,
       COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_title
HAVING COUNT(e.student_id) > 7
ORDER BY total_students DESC, c.course_code ASC;

-- Explanation (Task 2):
-- Groups enrolments by course and uses HAVING COUNT(e.student_id) > N to filter
-- groups after aggregation (since WHERE cannot filter on aggregate functions).
-- Threshold > 3 returns 5 courses (SEN307 with 10, AIN301 with 5, AIN305/COS301/SEN301
-- with 4 each); thresholds > 5 and > 7 return SEN307 (Database Systems, 10 students).


-- ============================================================================
-- Task 3: Calculate the average number of courses taken per student,
--         including students with zero courses
-- ============================================================================

-- 3A: Inner query — number of courses taken by each student (including 0)
SELECT s.student_id,
       s.matric_no,
       s.full_name,
       COUNT(e.course_id) AS course_count
FROM Student s
LEFT JOIN Enrolment e ON s.student_id = e.student_id
GROUP BY s.student_id, s.matric_no, s.full_name
ORDER BY course_count DESC, s.full_name ASC;

-- 3B: Wrapped derived-table query — average courses per student rounded to 2 d.p.
SELECT ROUND(AVG(course_count), 2) AS avg_courses_per_student
FROM (
    SELECT s.student_id,
           COUNT(e.course_id) AS course_count
    FROM Student s
    LEFT JOIN Enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id
) AS per_student;

-- Explanation (Task 3):
-- The inner subquery uses Student LEFT JOIN Enrolment and COUNT(e.course_id) grouped
-- by student_id so unenrolled students receive a course_count of 0. The outer query
-- computes AVG(course_count) across all 21 students (40 enrolments / 21 students)
-- and rounds the result to 2 decimal places (1.90 courses per student).


-- ============================================================================
-- Task 4 (Non-correlated subquery): Find students not enrolled in any course
-- ============================================================================
SELECT student_id,
       matric_no,
       full_name,
       dept_id
FROM Student
WHERE student_id NOT IN (
    SELECT student_id
    FROM Enrolment
)
ORDER BY full_name ASC;

-- Explanation (Task 4):
-- Uses a non-correlated subquery (SELECT student_id FROM Enrolment) that runs once
-- independently of the outer query, then filters Student for rows whose student_id
-- is NOT IN that list. It returns the exact same 3 unenrolled students (Transfer Student,
-- Yakubu Danladi, and Zainab Bello) as the LEFT JOIN ... WHERE c.course_title IS NULL
-- query from Lab 5 Task 3.


-- ============================================================================
-- Task 5 (Correlated subquery): For each department, find the student(s) with
--         the highest number of enrolments (ties allowed)
-- ============================================================================
SELECT d.dept_name,
       s.full_name,
       (SELECT COUNT(*) FROM Enrolment e WHERE e.student_id = s.student_id) AS courses
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
WHERE (SELECT COUNT(*) FROM Enrolment e WHERE e.student_id = s.student_id)
    = (
        SELECT COUNT(e2.enrolment_id)
        FROM Student s2
        LEFT JOIN Enrolment e2 ON s2.student_id = e2.student_id
        WHERE s2.dept_id = s.dept_id
        GROUP BY s2.student_id
        ORDER BY COUNT(e2.enrolment_id) DESC
        LIMIT 1
    )
ORDER BY d.dept_name ASC, s.full_name ASC;

-- Explanation (Task 5):
-- Uses a correlated subquery that references s.dept_id from the outer query to find
-- the maximum enrolment count among students in the same department. For each outer
-- student row s, MySQL compares that student's enrolment count against their
-- department's top count, returning the top-enrolled student(s) per department
-- including ties.

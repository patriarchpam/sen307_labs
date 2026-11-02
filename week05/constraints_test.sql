-- ============================================================================
-- VERITAS UNIVERSITY, ABUJA
-- DEPARTMENT OF SOFTWARE ENGINEERING
-- Course: VUA-SEN307 Database Systems — Week 5 Practical
-- Lab 3: Data Definition Language (DDL): Creating Schemas
-- Student Name: Pam Patriarch Yeipyeng
-- Matric No: VUG/SEN/24/12478
-- File: constraints_test.sql
-- ============================================================================

USE sen307_vug_sen_24_12478;

-- ============================================================================
-- PART 3: TESTING THE CONSTRAINTS
-- Each statement below deliberately violates a constraint to prove enforcement.
-- Every test should fail and no invalid rows should be persisted.
-- ============================================================================

-- Test 1: NOT NULL (should fail: dept_name is required)
-- Expected Error: ERROR 1048 (23000): Column 'dept_name' cannot be null
INSERT INTO Department (dept_name) VALUES (NULL);

-- Test 2: CHECK (should fail: credit_units must be 1 to 6)
-- Expected Error: ERROR 4025 (23000) / ERROR 3819 (HY000): Check constraint 'chk_credit_units' failed
INSERT INTO Course (course_code, course_title, credit_units) VALUES ('TST101', 'Test', 9);

-- Test 3: FOREIGN KEY (should fail: department 999 does not exist)
-- Expected Error: ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
INSERT INTO Student (matric_no, full_name, dept_id) VALUES ('TEST001', 'Test', 999);

-- Test 4: ENUM (should fail: gender must be 'M' or 'F')
-- Expected Error: ERROR 1265 (01000): Data truncated for column 'gender' at row 1
SET sql_mode = 'STRICT_TRANS_TABLES';
INSERT INTO Student (matric_no, full_name, gender) VALUES ('TEST002', 'Test', 'X');

-- Confirm every table is still empty after invalid attempts
SELECT COUNT(*) AS dept_count FROM Department;
SELECT COUNT(*) AS course_count FROM Course;
SELECT COUNT(*) AS student_count FROM Student;

-- ============================================================================
-- YOUR TURN: UNIQUE CONSTRAINT VIOLATION TEST
-- Goal: Demonstrate that Department.dept_name disallows duplicate names.
-- ============================================================================

-- Step A: Insert first valid department row
INSERT INTO Department (dept_name) VALUES ('Software Engineering');

-- Step B: Attempt to insert duplicate department name (should fail)
-- Expected Error: ERROR 1062 (23000): Duplicate entry 'Software Engineering' for key 'dept_name'
INSERT INTO Department (dept_name) VALUES ('Software Engineering');

-- Step C: Clean up test row so table remains clean
DELETE FROM Department WHERE dept_name = 'Software Engineering';

-- Confirm Department table is clean again
SELECT COUNT(*) AS dept_count_clean FROM Department;

-- ============================================================================
-- PART 4: VERIFY THE SCHEMA
-- Run these queries to inspect the table structure and definitions.
-- ============================================================================

SHOW TABLES;

DESCRIBE Department;
DESCRIBE Lecturer;
DESCRIBE Student;
DESCRIBE Course;
DESCRIBE Enrolment;
DESCRIBE CourseAllocation;

SHOW CREATE TABLE Enrolment;

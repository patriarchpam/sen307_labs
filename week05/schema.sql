-- ============================================================================
-- VERITAS UNIVERSITY, ABUJA
-- DEPARTMENT OF SOFTWARE ENGINEERING
-- Course: VUA-SEN307 Database Systems — Week 5 Practical
-- Lab 3: Data Definition Language (DDL): Creating Schemas
-- Student Name: Pam Patriarch Yeipyeng
-- Matric No: VUG/SEN/24/12478
-- File: schema.sql
-- ============================================================================

-- 1. Create and Select Database
CREATE DATABASE IF NOT EXISTS sen307_vug_sen_24_12478;
USE sen307_vug_sen_24_12478;

-- Drop child tables before parent tables to prevent foreign key conflicts during re-runs
DROP TABLE IF EXISTS CourseAllocation;
DROP TABLE IF EXISTS Enrolment;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Lecturer;
DROP TABLE IF EXISTS Department;

-- ============================================================================
-- PART 2: CREATE THE SIX TABLES
-- Order: Parent tables must exist before child tables can reference them.
-- ============================================================================

-- Table 1: Department (Parent Table)
CREATE TABLE Department (
    dept_id     INT PRIMARY KEY AUTO_INCREMENT,
    dept_name   VARCHAR(100) NOT NULL UNIQUE
);

-- Table 2: Lecturer (Child of Department)
CREATE TABLE Lecturer (
    lecturer_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_no    VARCHAR(20) NOT NULL UNIQUE,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE,
    dept_id     INT NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

-- Table 3: Student (Child of Department)
CREATE TABLE Student (
    student_id    INT PRIMARY KEY AUTO_INCREMENT,
    matric_no     VARCHAR(20) NOT NULL UNIQUE,
    full_name     VARCHAR(100) NOT NULL,
    gender        ENUM('M', 'F'),
    date_of_birth DATE,
    dept_id       INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

-- Table 4: Course (Child of Department)
CREATE TABLE Course (
    course_id     INT PRIMARY KEY AUTO_INCREMENT,
    course_code   VARCHAR(10) NOT NULL UNIQUE,
    course_title  VARCHAR(150) NOT NULL,
    credit_units  TINYINT NOT NULL DEFAULT 3,
    description   TEXT,
    dept_id       INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

-- Table 5: Enrolment (Junction Table: Student <-> Course, M:N relationship)
CREATE TABLE Enrolment (
    enrolment_id      INT PRIMARY KEY AUTO_INCREMENT,
    student_id        INT NOT NULL,
    course_id         INT NOT NULL,
    academic_session  VARCHAR(9) NOT NULL DEFAULT '2026/2027',
    semester          ENUM('First', 'Second') NOT NULL DEFAULT 'First',
    enrolled_on       DATE DEFAULT (CURRENT_DATE),
    UNIQUE (student_id, course_id, academic_session),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

-- Table 6: CourseAllocation (Junction Table: Course <-> Lecturer, M:N relationship)
CREATE TABLE CourseAllocation (
    allocation_id     INT PRIMARY KEY AUTO_INCREMENT,
    course_id         INT NOT NULL,
    lecturer_id       INT NOT NULL,
    academic_session  VARCHAR(9) NOT NULL DEFAULT '2026/2027',
    UNIQUE (course_id, lecturer_id, academic_session),
    FOREIGN KEY (course_id) REFERENCES Course(course_id),
    FOREIGN KEY (lecturer_id) REFERENCES Lecturer(lecturer_id)
);

-- ============================================================================
-- ALTER TABLE STATEMENTS
-- ============================================================================

-- Add a phone column to Student after full_name
ALTER TABLE Student ADD COLUMN phone VARCHAR(15) AFTER full_name;

-- Add CHECK constraint to enforce valid credit units (1 to 6)
ALTER TABLE Course ADD CONSTRAINT chk_credit_units CHECK (credit_units BETWEEN 1 AND 6);

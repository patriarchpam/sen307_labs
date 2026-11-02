# VUA-SEN307 Database Systems — Week 5 Practical Lab Report
**Lab 3: Data Definition Language (DDL): Creating Schemas**

---

### Student Information
- **Name:** Pam Patriarch Yeipyeng
- **Matriculation Number:** VUG/SEN/24/12478
- **Department:** Department of Software Engineering
- **Institution:** Veritas University, Abuja
- **Course:** VUA-SEN307 Database Systems (Year 2026/2027)
- **Database:** `sen307_vug_sen_24_12478`

---

## 1. Objectives & Overview
The objectives of this practical session were to:
1. Translate conceptual ER diagrams and 3NF designs into physical relational tables using MySQL DDL (`CREATE TABLE`).
2. Apply appropriate MySQL data types (`INT`, `TINYINT`, `VARCHAR`, `TEXT`, `DATE`, `ENUM`).
3. Enforce relational constraints: `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`, and `AUTO_INCREMENT`.
4. Modify existing tables using `ALTER TABLE` to add columns and integrity constraints.
5. Intentionally test and document constraint violations to prove database integrity enforcement.
6. Reverse-engineer physical tables into an EER Diagram (`lab3_erd.png`).

---

## 2. Part 1: Data Types & Constraints Summary

| Data Type | Usage | Applied Example in Schema |
| :--- | :--- | :--- |
| `INT` | Whole numbers, primary & foreign keys | `student_id`, `dept_id`, `course_id` |
| `TINYINT` | Small integers (range: -128 to 127) | `credit_units` (values 1–6) |
| `VARCHAR(n)` | Variable-length strings up to $n$ characters | `full_name VARCHAR(100)`, `matric_no VARCHAR(20)` |
| `TEXT` | Long variable-length strings | `description TEXT` (Course description) |
| `DATE` | Calendar dates (`YYYY-MM-DD`) | `date_of_birth`, `enrolled_on` |
| `ENUM(...)` | Restricted set of predefined string values | `gender ENUM('M','F')`, `semester ENUM('First','Second')` |

| Constraint | Purpose & Guarantee |
| :--- | :--- |
| `PRIMARY KEY` | Enforces uniqueness and non-null values for row identification. |
| `FOREIGN KEY` | Enforces referential integrity with a parent table. |
| `NOT NULL` | Prevents columns from storing `NULL` values. |
| `UNIQUE` | Ensures all values in a column or set of columns are distinct. |
| `CHECK` | Enforces a boolean condition that each value in the column must satisfy. |
| `DEFAULT` | Specifies a fallback value when no value is provided on `INSERT`. |
| `AUTO_INCREMENT` | Automatically assigns consecutive integer identifiers to new records. |

---

## 3. Part 2: Schema Creation (`schema.sql`)

Tables were created in topological dependency order (parents before children):
1. **`Department`** (Parent)
2. **`Lecturer`** (References `Department`)
3. **`Student`** (References `Department`)
4. **`Course`** (References `Department`)
5. **`Enrolment`** (Junction: References `Student` and `Course`)
6. **`CourseAllocation`** (Junction: References `Course` and `Lecturer`)

### `ALTER TABLE` Modifications
```sql
-- 1. Add phone number column to Student immediately after full_name
ALTER TABLE Student ADD COLUMN phone VARCHAR(15) AFTER full_name;

-- 2. Add domain CHECK constraint ensuring credit units are strictly between 1 and 6
ALTER TABLE Course ADD CONSTRAINT chk_credit_units CHECK (credit_units BETWEEN 1 AND 6);
```

---

## 4. Part 3: Testing the Constraints (Error Log & Notes)

Each statement below intentionally violates a specific integrity rule. Every statement failed as intended, and zero invalid rows were committed.

### Test 1: `NOT NULL` Constraint Violation
- **Target Table/Column:** `Department.dept_name`
- **Executed Query:**
  ```sql
  INSERT INTO Department (dept_name) VALUES (NULL);
  ```
- **Observed MySQL Error Message:**
  ```text
  ERROR 1048 (23000): Column 'dept_name' cannot be null
  ```
- **Explanation:** The column `dept_name` was defined with the `NOT NULL` constraint. The database engine strictly rejects `NULL` inputs.

---

### Test 2: `CHECK` Constraint Violation
- **Target Table/Column:** `Course.credit_units`
- **Executed Query:**
  ```sql
  INSERT INTO Course (course_code, course_title, credit_units) VALUES ('TST101', 'Test', 9);
  ```
- **Observed Error Message:**
  ```text
  ERROR 4025 (23000): CONSTRAINT `chk_credit_units` failed for `sen307_vug_sen_24_12478`.`course`
  ```
  *(Note: In Oracle MySQL 8.0 server, the equivalent error is: `ERROR 3819 (HY000): Check constraint 'chk_credit_units' is violated.`)*
- **Explanation:** The `chk_credit_units` constraint requires `credit_units BETWEEN 1 AND 6`. Supplying `9` violates this condition and is rejected.

---

### Test 3: `FOREIGN KEY` Constraint Violation
- **Target Table/Column:** `Student.dept_id`
- **Executed Query:**
  ```sql
  INSERT INTO Student (matric_no, full_name, dept_id) VALUES ('TEST001', 'Test', 999);
  ```
- **Observed Error Message:**
  ```text
  ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails 
  (`sen307_vug_sen_24_12478`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `department` (`dept_id`))
  ```
- **Explanation:** Referential integrity ensures child records only reference valid primary keys. Because `dept_id = 999` does not exist in `Department`, the insert was rejected.

---

### Test 4: `ENUM` Domain Constraint Violation
- **Target Table/Column:** `Student.gender`
- **Executed Query:**
  ```sql
  SET sql_mode = 'STRICT_TRANS_TABLES';
  INSERT INTO Student (matric_no, full_name, gender) VALUES ('TEST002', 'Test', 'X');
  ```
- **Observed Error Message:**
  ```text
  ERROR 1265 (01000): Data truncated for column 'gender' at row 1
  ```
- **Explanation:** The column `gender` is restricted to `'M'` or `'F'`. The value `'X'` is outside the defined enum list and is rejected in strict SQL mode.

---

### Confirmation of Empty Tables
```sql
SELECT COUNT(*) FROM Department;   -- Result: 0
SELECT COUNT(*) FROM Course;       -- Result: 0
SELECT COUNT(*) FROM Student;      -- Result: 0
```
All tables remained completely empty with 0 rows after the failed insert attempts.

---

### "Your Turn": `UNIQUE` Constraint Violation Test
- **Target Table/Column:** `Department.dept_name`
- **Step 1 (First Insert - Valid):**
  ```sql
  INSERT INTO Department (dept_name) VALUES ('Software Engineering');
  -- Query OK, 1 row affected (0.01 sec)
  ```
- **Step 2 (Second Insert - Duplicate Violation):**
  ```sql
  INSERT INTO Department (dept_name) VALUES ('Software Engineering');
  ```
- **Observed Error Message:**
  ```text
  ERROR 1062 (23000): Duplicate entry 'Software Engineering' for key 'dept_name'
  ```
- **Step 3 (Cleanup Deletion):**
  ```sql
  DELETE FROM Department WHERE dept_name = 'Software Engineering';
  -- Query OK, 1 row affected (0.01 sec)
  ```
- **Explanation:** The `UNIQUE` constraint guarantees that no two departments can share the same name. Attempting to insert a duplicate raises `ERROR 1062`.

---

## 5. Part 4: Schema Verification & DESCRIBE Results

### 1. `SHOW TABLES;`
```text
+-----------------------------------+
| Tables_in_sen307_vug_sen_24_12478 |
+-----------------------------------+
| course                            |
| courseallocation                  |
| department                        |
| enrolment                         |
| lecturer                          |
| student                           |
+-----------------------------------+
```

### 2. `DESCRIBE Department;`
```text
+-----------+--------------+------+-----+---------+----------------+
| Field     | Type         | Null | Key | Default | Extra          |
+-----------+--------------+------+-----+---------+----------------+
| dept_id   | int(11)      | NO   | PRI | NULL    | auto_increment |
| dept_name | varchar(100) | NO   | UNI | NULL    |                |
+-----------+--------------+------+-----+---------+----------------+
```

### 3. `DESCRIBE Lecturer;`
```text
+-------------+--------------+------+-----+---------+----------------+
| Field       | Type         | Null | Key | Default | Extra          |
+-------------+--------------+------+-----+---------+----------------+
| lecturer_id | int(11)      | NO   | PRI | NULL    | auto_increment |
| staff_no    | varchar(20)  | NO   | UNI | NULL    |                |
| full_name   | varchar(100) | NO   |     | NULL    |                |
| email       | varchar(100) | YES  | UNI | NULL    |                |
| dept_id     | int(11)      | NO   | MUL | NULL    |                |
+-------------+--------------+------+-----+---------+----------------+
```

### 4. `DESCRIBE Student;`
```text
+---------------+---------------+------+-----+---------+----------------+
| Field         | Type          | Null | Key | Default | Extra          |
+---------------+---------------+------+-----+---------+----------------+
| student_id    | int(11)       | NO   | PRI | NULL    | auto_increment |
| matric_no     | varchar(20)   | NO   | UNI | NULL    |                |
| full_name     | varchar(100)  | NO   |     | NULL    |                |
| phone         | varchar(15)   | YES  |     | NULL    |                |
| gender        | enum('M','F') | YES  |     | NULL    |                |
| date_of_birth | date          | YES  |     | NULL    |                |
| dept_id       | int(11)       | YES  | MUL | NULL    |                |
+---------------+---------------+------+-----+---------+----------------+
```

### 5. `DESCRIBE Course;`
```text
+--------------+--------------+------+-----+---------+----------------+
| Field        | Type         | Null | Key | Default | Extra          |
+--------------+--------------+------+-----+---------+----------------+
| course_id    | int(11)      | NO   | PRI | NULL    | auto_increment |
| course_code  | varchar(10)  | NO   | UNI | NULL    |                |
| course_title | varchar(150) | NO   |     | NULL    |                |
| credit_units | tinyint(4)   | NO   |     | 3       |                |
| description  | text         | YES  |     | NULL    |                |
| dept_id      | int(11)      | YES  | MUL | NULL    |                |
+--------------+--------------+------+-----+---------+----------------+
```

### 6. `DESCRIBE Enrolment;`
```text
+------------------+------------------------+------+-----+-----------+----------------+
| Field            | Type                   | Null | Key | Default   | Extra          |
+------------------+------------------------+------+-----+-----------+----------------+
| enrolment_id     | int(11)                | NO   | PRI | NULL      | auto_increment |
| student_id       | int(11)                | NO   | MUL | NULL      |                |
| course_id        | int(11)                | NO   | MUL | NULL      |                |
| academic_session | varchar(9)             | NO   |     | 2026/2027 |                |
| semester         | enum('First','Second') | NO   |     | First     |                |
| enrolled_on      | date                   | YES  |     | curdate() |                |
+------------------+------------------------+------+-----+-----------+----------------+
```

### 7. `DESCRIBE CourseAllocation;`
```text
+------------------+------------+------+-----+-----------+----------------+
| Field            | Type       | Null | Key | Default   | Extra          |
+------------------+------------+------+-----+-----------+----------------+
| allocation_id    | int(11)    | NO   | PRI | NULL      | auto_increment |
| course_id        | int(11)    | NO   | MUL | NULL      |                |
| lecturer_id      | int(11)    | NO   | MUL | NULL      |                |
| academic_session | varchar(9) | NO   |     | 2026/2027 |                |
+------------------+------------+------+-----+-----------+----------------+
```

### 8. `SHOW CREATE TABLE Enrolment;`
```sql
CREATE TABLE `enrolment` (
  `enrolment_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `academic_session` varchar(9) NOT NULL DEFAULT '2026/2027',
  `semester` enum('First','Second') NOT NULL DEFAULT 'First',
  `enrolled_on` date DEFAULT curdate(),
  PRIMARY KEY (`enrolment_id`),
  UNIQUE KEY `student_id` (`student_id`,`course_id`,`academic_session`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `enrolment_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`),
  CONSTRAINT `enrolment_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

---

## 6. Comparison: Week 4 Conceptual ERD vs. Week 5 Physical Schema

### Why Six Tables Instead of Five?
1. **Decomposition of Many-to-Many ($M:N$) Relationships:**
   In the Week 4 conceptual model, the relationships between `Student` and `Course`, and between `Course` and `Lecturer` were modeled as many-to-many relationships (a lecturer teaches several courses across sessions, and courses can be assigned to different lecturers; similarly, a student enrols in multiple courses and each course contains multiple students).
2. **Associative / Junction Entities in 3NF:**
   In physical relational databases conforming to Third Normal Form (3NF), $M:N$ relationships cannot be stored with single foreign keys without causing repeating groups or partial functional dependencies. Therefore, two junction tables were introduced:
   - **`Enrolment`**: Junction table for `Student` $\leftrightarrow$ `Course`, augmented with context attributes (`academic_session`, `semester`, and `enrolled_on`).
   - **`CourseAllocation`**: Junction table for `Course` $\leftrightarrow$ `Lecturer`, tracking teaching assignments per `academic_session`.
3. **Physical Implementation Enhancements:**
   Unlike the high-level Week 4 diagram, the physical schema introduces surrogate primary keys (`AUTO_INCREMENT`), exact storage datatypes (`VARCHAR(100)`, `TINYINT`, `ENUM`, `DATE`), column ordering modifications (`phone` added `AFTER full_name`), and specific integrity constraints (`chk_credit_units` and composite `UNIQUE` keys).

---

## 7. Reverse-Engineered Diagram (`lab3_erd.png`)
The reverse-engineered EER Diagram has been saved to:
- [`lab3_erd.png`](./lab3_erd.png)

---

## 8. Submission Checklist Verification
- [x] **`week05/schema.sql`**: Contains all 6 `CREATE TABLE` and both `ALTER TABLE` statements.
- [x] **Screenshots of DESCRIBE output**: Rendered and saved in `week05/screenshots/` and `week05/`.
- [x] **Constraint-test error messages**: Fully documented in notes above with exact MySQL error codes.
- [x] **UNIQUE constraint test**: Demonstrated with `Department.dept_name` duplication and cleanup.
- [x] **`week05/lab3_erd.png`**: High-resolution reverse-engineered physical relational diagram generated.
- [x] **Git Repository**: Initialized, committed, and ready for push.

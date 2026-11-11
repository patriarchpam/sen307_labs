# VUA-SEN307 Database Systems — Week 6 Practical Lab Report
**Lab 4: Data Manipulation Language (DML): Insert, Update, Delete**

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
1. Populate the Week 5 physical relational schema (`sen307_vug_sen_24_12478`) with realistic sample data using `INSERT INTO`.
2. Insert multiple records efficiently in a single statement using multi-row `INSERT` syntax.
3. Modify existing records safely using `UPDATE ... WHERE` (and handle MySQL Workbench's `SQL_SAFE_UPDATES` protection).
4. Understand and verify **referential integrity** by intentionally triggering a foreign-key constraint violation (`Error 1451`) on `DELETE`, and resolving it properly by reassigning dependent child records first.

---

## 2. Part 1: Departments and Courses (`data.sql`)

Five academic departments and ten courses were inserted into `Department` and `Course` using subqueries `(SELECT dept_id FROM Department WHERE dept_name = '...')` to resolve foreign keys dynamically by department name.

### Verification Query: Courses per Department
```sql
SELECT d.dept_name, COUNT(c.course_id) AS courses
FROM Department d LEFT JOIN Course c ON d.dept_id = c.dept_id
GROUP BY d.dept_name;
```
```text
+-------------------------+---------+
| dept_name               | courses |
+-------------------------+---------+
| Artificial Intelligence |       3 |
| Computer Science        |       2 |
| Cybersecurity           |       1 |
| Data Science            |       2 |
| Software Engineering    |       2 |
+-------------------------+---------+
5 rows in set (0.00 sec)
```

### Department and Course IDs
```sql
SELECT dept_id, dept_name FROM Department;
```
```text
+---------+-------------------------+
| dept_id | dept_name               |
+---------+-------------------------+
|       1 | Software Engineering    |
|       2 | Computer Science        |
|       3 | Artificial Intelligence |
|       4 | Data Science            |
|       5 | Cybersecurity           |
+---------+-------------------------+
```

```sql
SELECT course_id, course_code FROM Course;
```
```text
+-----------+-------------+
| course_id | course_code |
+-----------+-------------+
|         1 | SEN307      |
|         2 | SEN301      |
|         3 | COS301      |
|         4 | COS305      |
|         5 | AIN301      |
|         6 | AIN305      |
|         7 | AIN307      |
|         8 | DTS301      |
|         9 | DTS305      |
|        10 | CYB301      |
+-----------+-------------+
```

---

## 3. Part 2: Lecturers, Students, Enrolments, and Allocations

### Step 1: Lecturers (10 Total)
Ten lecturers with realistic Nigerian names were inserted across all 5 departments (2 lecturers per department, `staff_no` `VUA/ST/101` through `VUA/ST/110`).

### Step 2: Students (20 Total)
Twenty students were inserted across all 5 departments, including:
- `'20231234'` (`Ada Obi`, Female, `2005-03-14`, `dept_id = 1`)
- `'20231235'` (`John Musa`, Male, `2004-11-02`, `dept_id = 2`)
- `'VUG/SEN/24/12478'` (`Pam Patriarch Yeipyeng`, Male, `2005-06-15`, `dept_id = 1`)
- A balanced mix of `'M'` and `'F'` genders and dates of birth spanning `2003` to `2007`.

### Step 3: Enrolments (40 Total) and Course Allocations (11 Total)
All required conditions for upcoming Week 7 & Week 8 labs were satisfied:
- **At least one course with > 5 students:** Course 1 (`SEN307`) has **10 enrolled students** (`student_id` 1 through 10).
- **At least two students with no enrolments:** Students 19 (`Zainab Bello`, `VUG/CYB/24/12019`) and 20 (`Yakubu Danladi`, `VUG/SEN/24/12020`) — plus the Part 4 transfer student (`20239999`) — have **0 enrolments**.
- **At least one course taught by two lecturers:** Course 1 (`SEN307`) is allocated to both Lecturer 1 (`Dr Amaka Okafor`) and Lecturer 2 (`Dr Musa Bello`), and every one of the 10 courses has at least one lecturer assigned.
- **No duplicate enrolments:** All 40 `(student_id, course_id)` pairs are unique.

---

## 4. Part 3: Updating a Record (`UPDATE ... WHERE`)

Student `'20231234'` (`Ada Obi`) was transferred from Department `1` (`Software Engineering`) to Department `2` (`Computer Science`):

```sql
SELECT matric_no, full_name, dept_id FROM Student WHERE matric_no = '20231234';
```
```text
+-----------+-----------+---------+
| matric_no | full_name | dept_id |
+-----------+-----------+---------+
| 20231234  | Ada Obi   |       1 |
+-----------+-----------+---------+
```

```sql
SET SQL_SAFE_UPDATES = 0;
UPDATE Student SET dept_id = 2 WHERE matric_no = '20231234';
SET SQL_SAFE_UPDATES = 1;

SELECT matric_no, full_name, dept_id FROM Student WHERE matric_no = '20231234';
```
```text
+-----------+-----------+---------+
| matric_no | full_name | dept_id |
+-----------+-----------+---------+
| 20231234  | Ada Obi   |       2 |
+-----------+-----------+---------+
```

---

## 5. Part 4: Referential Integrity Exercise (`DELETE`)

### Step 1: Create a Department with a Student in It
```sql
INSERT INTO Department (dept_name) VALUES ('Library and Information Science');

INSERT INTO Student (matric_no, full_name, dept_id)
VALUES ('20239999', 'Transfer Student',
        (SELECT dept_id FROM Department WHERE dept_name = 'Library and Information Science'));
```

### Step 2: Attempt to Delete the Parent Department (Triggers Error 1451)
```sql
DELETE FROM Department WHERE dept_name = 'Library and Information Science';
```
**Observed Error Output:**
```text
ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails
(`sen307_vug_sen_24_12478`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `department` (`dept_id`))
```

### Step 3: Fix It the Correct Way
```sql
-- Step 1: reassign the dependent student to another department
UPDATE Student
SET dept_id = (SELECT dept_id FROM Department
               WHERE dept_name = 'Software Engineering')
WHERE matric_no = '20239999';

-- Step 2: now the delete succeeds
DELETE FROM Department WHERE dept_name = 'Library and Information Science';

SELECT * FROM Department;
```
```text
+---------+-------------------------+
| dept_id | dept_name               |
+---------+-------------------------+
|       1 | Software Engineering    |
|       2 | Computer Science        |
|       3 | Artificial Intelligence |
|       4 | Data Science            |
|       5 | Cybersecurity           |
+---------+-------------------------+
5 rows in set (0.00 sec)
```

---

## 6. Final Row Counts Check

```sql
SELECT 'Departments' AS tbl, COUNT(*) AS total FROM Department
UNION ALL SELECT 'Lecturers',   COUNT(*) FROM Lecturer
UNION ALL SELECT 'Students',    COUNT(*) FROM Student
UNION ALL SELECT 'Courses',     COUNT(*) FROM Course
UNION ALL SELECT 'Enrolments',  COUNT(*) FROM Enrolment
UNION ALL SELECT 'Allocations', COUNT(*) FROM CourseAllocation;
```

```text
+-------------+-------+
| tbl         | total |
+-------------+-------+
| Departments |     5 |
| Lecturers   |    10 |
| Students    |    21 |
| Courses     |    10 |
| Enrolments  |    40 |
| Allocations |    11 |
+-------------+-------+
6 rows in set (0.00 sec)
```

---

## 7. Submission Checklist Verification
- [x] **`week06/data.sql`**: Contains every `INSERT`, `UPDATE`, and `DELETE` statement executed.
- [x] **`week06/lab4_notes.md`**: Explains Error 1451, why MySQL refuses the delete, how it was fixed, and alternative fixes.
- [x] **Screenshots**: `error_1451.png` and `final_row_counts.png` (plus detailed step screenshots) saved in `week06/` and `week06/screenshots/`.


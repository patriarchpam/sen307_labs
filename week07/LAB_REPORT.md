# VUA-SEN307 Database Systems — Week 7 Practical Lab Report
**Lab 5: Querying Data: SELECT, Filtering and Joins**

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
1. Write `SELECT` queries using `WHERE`, `ORDER BY`, and `LIMIT` / `OFFSET`.
2. Combine multiple filtering conditions using `AND`, `OR`, `IN`, and `BETWEEN` with explicit parenthesis grouping.
3. Combine normalized relational tables using `INNER JOIN`, `LEFT JOIN`, and `RIGHT JOIN`, and explain how they differ.

---

## 2. Part 1: How Joins Work Summary

| Join Type | What It Returns |
| :--- | :--- |
| **`INNER JOIN`** | Only rows that have a matching key in **both** joined tables. |
| **`LEFT JOIN`** | **All** rows from the left table, plus matched columns from the right table (`NULL` where no match exists). |
| **`RIGHT JOIN`** | **All** rows from the right table, plus matched columns from the left table (`NULL` where no match exists). |

---

## 3. Part 2 & Part 3: Tasks 1–5 and Challenge (`lab5_queries.sql`)

### Task 1: Retrieve All Students in One Department, Sorted A–Z
```sql
SELECT s.student_id, s.matric_no, s.full_name, s.gender, s.date_of_birth, d.dept_name
FROM Student s
INNER JOIN Department d ON s.dept_id = d.dept_id
WHERE d.dept_name = 'Software Engineering'
ORDER BY s.full_name ASC;
```
**Explanation:** Joins `Student` to `Department` on `dept_id`, filters for `'Software Engineering'`, and sorts alphabetically (`ASC`) by `full_name`.

```text
+------------+------------------+------------------------+--------+---------------+----------------------+
| student_id | matric_no        | full_name              | gender | date_of_birth | dept_name            |
+------------+------------------+------------------------+--------+---------------+----------------------+
|          4 | VUG/SEN/24/12004 | Chidinma Okafor        | F      | 2006-01-22    | Software Engineering |
|          5 | VUG/SEN/24/12005 | Oluwaseun Adebayo      | M      | 2003-08-19    | Software Engineering |
|          3 | VUG/SEN/24/12478 | Pam Patriarch Yeipyeng | M      | 2005-06-15    | Software Engineering |
|         21 | 20239999         | Transfer Student       | NULL   | NULL          | Software Engineering |
|         20 | VUG/SEN/24/12020 | Yakubu Danladi         | M      | 2007-04-21    | Software Engineering |
+------------+------------------+------------------------+--------+---------------+----------------------+
```

---

### Task 2: Courses with Their Lecturers (`INNER JOIN`)
```sql
SELECT c.course_code, c.course_title, l.staff_no, l.full_name AS lecturer_name, ca.academic_session
FROM Course c
INNER JOIN CourseAllocation ca ON c.course_id = ca.course_id
INNER JOIN Lecturer l          ON ca.lecturer_id = l.lecturer_id
ORDER BY c.course_code ASC, l.full_name ASC;
```
**Explanation:** Connects `Course` to `Lecturer` across the `CourseAllocation` junction table (`Course -> CourseAllocation -> Lecturer`). `SEN307` (`Database Systems`) appears twice because it is co-taught by `Dr Amaka Okafor` and `Dr Musa Bello`.

```text
+-------------+-----------------------------------------+------------+---------------------+------------------+
| course_code | course_title                            | staff_no   | lecturer_name       | academic_session |
+-------------+-----------------------------------------+------------+---------------------+------------------+
| AIN301      | Introduction to Artificial Intelligence | VUA/ST/105 | Dr Ibrahim Danjuma  | 2026/2027        |
| AIN305      | Machine Learning                        | VUA/ST/106 | Dr Ngozi Nwosu      | 2026/2027        |
| AIN307      | Natural Language Processing             | VUA/ST/105 | Dr Ibrahim Danjuma  | 2026/2027        |
| COS301      | Operating Systems                       | VUA/ST/103 | Dr Chinedu Eze      | 2026/2027        |
| COS305      | Computer Networks                       | VUA/ST/104 | Dr Funke Adeyemi    | 2026/2027        |
| CYB301      | Network Security                        | VUA/ST/109 | Dr Emeka Nwachukwu  | 2026/2027        |
| DTS301      | Data Visualization and Analytics        | VUA/ST/107 | Dr Tunde Bakare     | 2026/2027        |
| DTS305      | Big Data Technologies                   | VUA/ST/108 | Dr Zainab Abdullahi | 2026/2027        |
| SEN301      | Software Architecture                   | VUA/ST/102 | Dr Musa Bello       | 2026/2027        |
| SEN307      | Database Systems                        | VUA/ST/101 | Dr Amaka Okafor     | 2026/2027        |
| SEN307      | Database Systems                        | VUA/ST/102 | Dr Musa Bello       | 2026/2027        |
+-------------+-----------------------------------------+------------+---------------------+------------------+
```

---

### Task 3: Students and Their Courses (`LEFT JOIN`)
```sql
-- Every student and their courses, including students with no enrolments
SELECT s.full_name, c.course_title
FROM Student s
LEFT JOIN Enrolment e ON s.student_id = e.student_id
LEFT JOIN Course c    ON e.course_id = c.course_id
ORDER BY s.full_name ASC, c.course_title ASC;

-- Show ONLY the students with no courses
SELECT s.student_id, s.matric_no, s.full_name, c.course_title
FROM Student s
LEFT JOIN Enrolment e ON s.student_id = e.student_id
LEFT JOIN Course c    ON e.course_id = c.course_id
WHERE c.course_title IS NULL
ORDER BY s.full_name ASC;
```
**Explanation:** `LEFT JOIN` keeps all rows from `Student` even when a student has no matching row in `Enrolment`, filling `c.course_title` with `NULL`. Adding `WHERE c.course_title IS NULL` isolates those unenrolled students.

```text
+------------+------------------+------------------+--------------+
| student_id | matric_no        | full_name        | course_title |
+------------+------------------+------------------+--------------+
|         21 | 20239999         | Transfer Student | NULL         |
|         20 | VUG/SEN/24/12020 | Yakubu Danladi   | NULL         |
|         19 | VUG/CYB/24/12019 | Zainab Bello     | NULL         |
+------------+------------------+------------------+--------------+
```

---

### Task 4: Filtering with `AND` / `OR` / `IN` / `BETWEEN`
```sql
SELECT student_id, matric_no, full_name, gender, date_of_birth, dept_id
FROM Student
WHERE gender = 'F'
  AND (dept_id IN (1, 3) OR dept_id = 2)
  AND date_of_birth BETWEEN '2004-01-01' AND '2006-12-31'
ORDER BY date_of_birth ASC;
```
**Explanation:** Combines `AND`, `OR` (wrapped in parentheses so `AND` does not bind more tightly than `OR`), `IN`, and `BETWEEN` to find female students in Software Engineering (`1`), Artificial Intelligence (`3`), or Computer Science (`2`) born between `2004-01-01` and `2006-12-31`.

```text
+------------+------------------+-----------------+--------+---------------+---------+
| student_id | matric_no        | full_name       | gender | date_of_birth | dept_id |
+------------+------------------+-----------------+--------+---------------+---------+
|         12 | VUG/AIN/24/12012 | Blessing Eze    | F      | 2004-10-30    |       3 |
|          1 | 20231234         | Ada Obi         | F      | 2005-03-14    |       2 |
|          6 | VUG/CSC/24/12006 | Fatima Abubakar | F      | 2005-09-10    |       2 |
|          4 | VUG/SEN/24/12004 | Chidinma Okafor | F      | 2006-01-22    |       1 |
|         10 | VUG/AIN/24/12010 | Nneka Chukwu    | F      | 2006-07-25    |       3 |
+------------+------------------+-----------------+--------+---------------+---------+
```

---

### Task 5: Paginating Enrolments with `LIMIT` and `OFFSET`
```sql
-- Page 1 (rows 1–10)
SELECT e.enrolment_id, s.matric_no, s.full_name, c.course_code, c.course_title
FROM Enrolment e
INNER JOIN Student s ON e.student_id = s.student_id
INNER JOIN Course c  ON e.course_id = c.course_id
ORDER BY e.enrolment_id ASC
LIMIT 10 OFFSET 0;

-- Page 2 (rows 11–20)
SELECT e.enrolment_id, s.matric_no, s.full_name, c.course_code, c.course_title
FROM Enrolment e
INNER JOIN Student s ON e.student_id = s.student_id
INNER JOIN Course c  ON e.course_id = c.course_id
ORDER BY e.enrolment_id ASC
LIMIT 10 OFFSET 10;
```
**Why `ORDER BY` must always be used with `LIMIT`:** Without `ORDER BY`, SQL does not guarantee any fixed row order. Across separate paginated queries (`OFFSET 0`, `OFFSET 10`), the database engine could return rows in a different sequence, causing some records to appear on both pages or be missed altogether.

---

### Challenge: Rewriting Task 3 Using `RIGHT JOIN`
```sql
SELECT s.full_name, c.course_title
FROM Course c
INNER JOIN Enrolment e ON c.course_id = e.course_id
RIGHT JOIN Student s   ON e.student_id = s.student_id
ORDER BY s.full_name ASC, c.course_title ASC;
```
**Which version is easier to read?** The `LEFT JOIN` version in Task 3 is much easier to read because SQL queries are read top-to-bottom starting from the primary subject (`FROM Student s`) and attaching optional details (`Enrolment`, `Course`) to the right.

---

## 4. Submission Checklist Verification
- [x] **`week07/lab5_queries.sql`**: Contains all five tasks (plus Recap and the `RIGHT JOIN` challenge) with explanatory comments below each query.
- [x] **Result Screenshots**: Windows Command Prompt screenshots saved for every task in `week07/` and `week07/screenshots/`.
- [x] **Pushed to GitHub**: Committed and pushed to `main`.

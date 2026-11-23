# VUA-SEN307 Database Systems — Lab 6: Week 9 Practical Lab Report
**Lab 6: Week 9 - Aggregate Functions, Grouping and Subqueries**

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
1. Summarize relational data using SQL aggregate functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`).
2. Group query results using `GROUP BY` and filter aggregated groups using `HAVING`.
3. Write and compare **non-correlated** and **correlated** subqueries.

---

## 2. Part 1: Aggregates and Grouping Summary

| Clause | Purpose |
| :--- | :--- |
| **`COUNT` / `SUM` / `AVG` / `MIN` / `MAX`** | Condense multiple rows into a single summary value. |
| **`GROUP BY`** | Calculate the summary value separately for each distinct group. |
| **`WHERE`** | Filters individual **rows** *before* grouping occurs (cannot use aggregates directly). |
| **`HAVING`** | Filters aggregated **groups** *after* `GROUP BY` (can use aggregate functions). |

---

## 3. Part 2: Tasks 1–3 (Aggregates, `GROUP BY`, and `HAVING`)

### Task 1: Count Students Enrolled in Each Course (Including Courses with Zero Students)
```sql
SELECT c.course_id,
       c.course_code,
       c.course_title,
       COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_title
ORDER BY total_students DESC, c.course_code ASC;
```
**Why `LEFT JOIN` with `COUNT(e.student_id)` gives `0` rather than `1` for an empty course:**
When a course has no rows in `Enrolment`, `LEFT JOIN` still outputs one row for that course with `e.student_id` set to `NULL`. Because `COUNT(column)` counts only non-`NULL` values, `COUNT(e.student_id)` ignores the `NULL` and returns `0`, whereas `COUNT(*)` counts rows regardless of `NULL` values and would return `1`.

```text
+-----------+-------------+-----------------------------------------+----------------+
| course_id | course_code | course_title                            | total_students |
+-----------+-------------+-----------------------------------------+----------------+
|         1 | SEN307      | Database Systems                        |             10 |
|         5 | AIN301      | Introduction to Artificial Intelligence |              5 |
|         6 | AIN305      | Machine Learning                        |              4 |
|         3 | COS301      | Operating Systems                       |              4 |
|         2 | SEN301      | Software Architecture                   |              4 |
|         4 | COS305      | Computer Networks                       |              3 |
|         8 | DTS301      | Data Visualization and Analytics        |              3 |
|         9 | DTS305      | Big Data Technologies                   |              3 |
|         7 | AIN307      | Natural Language Processing             |              2 |
|        10 | CYB301      | Network Security                        |              2 |
+-----------+-------------+-----------------------------------------+----------------+
```

---

### Task 2: Find Courses with More Than 3, 5, and 7 Students Using `HAVING`
```sql
-- Threshold > 3
SELECT c.course_code, c.course_title, COUNT(e.student_id) AS total_students
FROM Course c LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_title
HAVING COUNT(e.student_id) > 3
ORDER BY total_students DESC, c.course_code ASC;

-- Threshold > 5
SELECT c.course_code, c.course_title, COUNT(e.student_id) AS total_students
FROM Course c LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_title
HAVING COUNT(e.student_id) > 5
ORDER BY total_students DESC;

-- Threshold > 7
SELECT c.course_code, c.course_title, COUNT(e.student_id) AS total_students
FROM Course c LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_title
HAVING COUNT(e.student_id) > 7
ORDER BY total_students DESC;
```
**Results:**
- `HAVING COUNT(e.student_id) > 3`: Returns 5 courses (`SEN307` [10], `AIN301` [5], `AIN305` [4], `COS301` [4], `SEN301` [4]).
- `HAVING COUNT(e.student_id) > 5` and `> 7`: Both return `SEN307` (`Database Systems`, `10` students).

---

### Task 3: Average Number of Courses Taken per Student (Including Zero Courses)
```sql
SELECT ROUND(AVG(course_count), 2) AS avg_courses_per_student
FROM (
    SELECT s.student_id,
           COUNT(e.course_id) AS course_count
    FROM Student s
    LEFT JOIN Enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id
) AS per_student;
```
```text
+-------------------------+
| avg_courses_per_student |
+-------------------------+
|                    1.90 |
+-------------------------+
```
**Explanation:** With 40 total enrolments across all 21 students in the `Student` table (including the 3 students with `0` enrolments), the average is $40 / 21 \approx 1.90$ courses per student.

---

## 4. Part 3: Subqueries (Tasks 4–5)

### Task 4 (Non-Correlated Subquery): Students Not Enrolled in Any Course
```sql
SELECT student_id, matric_no, full_name, dept_id
FROM Student
WHERE student_id NOT IN (
    SELECT student_id
    FROM Enrolment
)
ORDER BY full_name ASC;
```
```text
+------------+------------------+------------------+---------+
| student_id | matric_no        | full_name        | dept_id |
+------------+------------------+------------------+---------+
|         21 | 20239999         | Transfer Student |       1 |
|         20 | VUG/SEN/24/12020 | Yakubu Danladi   |       1 |
|         19 | VUG/CYB/24/12019 | Zainab Bello     |       5 |
+------------+------------------+------------------+---------+
```
**Comparison with Lab 5 Task 3:** The non-correlated subquery runs once to fetch all `student_id` values present in `Enrolment`, and the outer query filters `Student` with `NOT IN`. It produces the exact same 3 unenrolled students as the `LEFT JOIN ... WHERE c.course_title IS NULL` query in Lab 5 Task 3.

---

### Task 5 (Correlated Subquery): Top-Enrolled Student(s) in Each Department
```sql
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
```
```text
+-------------------------+------------------------+---------+
| dept_name               | full_name              | courses |
+-------------------------+------------------------+---------+
| Artificial Intelligence | Babatunde Ogunleye     |       3 |
| Artificial Intelligence | Blessing Eze           |       3 |
| Artificial Intelligence | Nneka Chukwu           |       3 |
| Artificial Intelligence | Usman Garba            |       3 |
| Computer Science        | Aisha Mohammed         |       3 |
| Computer Science        | Fatima Abubakar        |       3 |
| Computer Science        | Kelechi Nnaji          |       3 |
| Cybersecurity           | Ebuka Obi              |       1 |
| Cybersecurity           | Hauwa Yakubu           |       1 |
| Data Science            | Damilola Ojo           |       2 |
| Data Science            | Sadiq Lawal            |       2 |
| Software Engineering    | Pam Patriarch Yeipyeng |       3 |
+-------------------------+------------------------+---------+
```
**Explanation:** The correlated subquery references `s.dept_id` from the outer query, computing the highest course count among students in that specific department (`ORDER BY COUNT(e2.enrolment_id) DESC LIMIT 1`). Every student whose enrolment count equals their department's maximum is returned (allowing ties).

---

## 5. Submission Checklist Verification
- [x] **`week09/lab6_queries.sql`**: Contains all five tasks with detailed explanatory comments.
- [x] **Result Screenshots**: Windows Command Prompt screenshots saved for each task in `week09/` and `week09/screenshots/`.
- [x] **Pushed to GitHub**: Committed and pushed to `main`.

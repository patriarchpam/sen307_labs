# VUA-SEN307 Database Systems — Week 6 Practical (Lab 4 Notes)

- **Name:** Pam Patriarch Yeipyeng
- **Matric Number:** VUG/SEN/24/12478
- **Course:** VUA-SEN307 Database Systems
- **Lab:** Lab 4 — Data Manipulation Language (DML): Insert, Update, Delete
- **Database:** `sen307_vug_sen_24_12478`

---

## Part 4 Write-Up: Referential Integrity (`DELETE` Error and Resolution)

When attempting to delete the `'Library and Information Science'` department in Part 4 Step 2 (`DELETE FROM Department WHERE dept_name = 'Library and Information Science';`), MySQL rejected the statement with **Error 1451 (23000): `Cannot delete or update a parent row: a foreign key constraint fails`**. MySQL refuses to delete this department row because of **referential integrity**: the `Student` table is a child table with a `FOREIGN KEY (dept_id) REFERENCES Department(dept_id)` constraint, and the newly inserted student (`matric_no = '20239999'`, `'Transfer Student'`) still points to that department's `dept_id`. Deleting the parent department while a child student record still references it would leave an orphan foreign key reference. I fixed the error by first executing an `UPDATE` statement on the `Student` table to reassign the dependent student (`'20239999'`) to the `'Software Engineering'` department (`dept_id = 1`), and once no child rows referenced `'Library and Information Science'`, re-running the `DELETE FROM Department` statement succeeded cleanly. As an alternative fix, I could have deleted the dependent student record from `Student` before deleting the department, updated the student's `dept_id` to `NULL` (since `Student.dept_id` is nullable), or configured the foreign key constraint at schema creation time with `ON DELETE SET NULL` (or `ON DELETE CASCADE`).

---

## Summary of Error and SQL Fix

### 1. Error Triggered (Part 4, Step 2)
```sql
DELETE FROM Department WHERE dept_name = 'Library and Information Science';
```
**Observed MySQL Error:**
```text
ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails
(`sen307_vug_sen_24_12478`.`student`, CONSTRAINT `student_ibfk_1` FOREIGN KEY (`dept_id`) REFERENCES `department` (`dept_id`))
```

### 2. Fix Applied (Part 4, Step 3)
```sql
-- Step 1: Reassign the dependent student to another department
UPDATE Student
SET dept_id = (SELECT dept_id FROM Department
               WHERE dept_name = 'Software Engineering')
WHERE matric_no = '20239999';

-- Step 2: Delete the department now that no child rows reference it
DELETE FROM Department WHERE dept_name = 'Library and Information Science';
```

### 3. Alternative Fixes
1. **Set the child's foreign key to `NULL` before deleting the parent:**
   ```sql
   UPDATE Student SET dept_id = NULL WHERE matric_no = '20239999';
   DELETE FROM Department WHERE dept_name = 'Library and Information Science';
   ```
2. **Delete the dependent child row first before deleting the parent row:**
   ```sql
   DELETE FROM Student WHERE matric_no = '20239999';
   DELETE FROM Department WHERE dept_name = 'Library and Information Science';
   ```
3. **Define referential actions (`ON DELETE SET NULL` or `ON DELETE CASCADE`) on the foreign key in DDL:**
   - `ON DELETE SET NULL` automatically sets `Student.dept_id` to `NULL` if the parent department is deleted.
   - `ON DELETE CASCADE` automatically deletes dependent rows when the parent row is deleted (though in a university database, reassigning or setting `NULL` is safer so student records are not lost).

---

## Final Row Counts Verification

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
```
*(Note: `Students` is 21 because the 20 students inserted in Part 2 were joined by `'Transfer Student'` (`20239999`) in Part 4, who was reassigned to `'Software Engineering'` rather than deleted. `Allocations` is 11 because all 10 courses have at least one lecturer and Course 1 (`SEN307`) is co-taught by 2 lecturers.)*


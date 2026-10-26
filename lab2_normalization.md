# VUA-SEN307 Database Systems — Week 4 Practical
## Lab 2: Database Design and Normalization

- **Student Name:** Pam Patriarch Yeipyeng
- **Matric Number:** VUG/SEN/24/12478
- **Department:** Software Engineering
- **Institution:** Veritas University, Abuja
- **Course:** VUA-SEN307 Database Systems
- **Session:** 2026/2027

---

## Part 1: Entities, Attributes and Relationships

### Step 1: Entity Attributes & Primary Keys
| Entity | Attributes | Primary Key |
| :--- | :--- | :--- |
| **Department** | `dept_id`, `dept_name` | `dept_id` |
| **Student** | `student_id`, `matric_no`, `full_name`, `dept_id` | `student_id` |
| **Lecturer** | `lecturer_id`, `lecturer_name`, `dept_id` | `lecturer_id` |
| **Course** | `course_id`, `course_code`, `course_title` | `course_id` |
| **Enrolment** | `enrolment_id`, `student_id`, `course_id`, `lecturer_id`, `session` | `enrolment_id` |

### Step 2: Relationships and Cardinalities
1. **Department to Student:** 
   - One student belongs to exactly one department, while a department can enroll many students.
   - **Cardinality:** **1:N (One-to-Many)** from Department to Student.
2. **Student to Course:** 
   - A student registers for multiple courses, and a single course is registered by multiple students.
   - **Cardinality:** **M:N (Many-to-Many)**, resolved using the linking/junction table **Enrolment**.
3. **Course to Lecturer:** 
   - A course can be taught by different lecturers across academic sessions, and a lecturer can teach multiple courses.
   - **Cardinality:** **M:N (Many-to-Many)**, linked through course assignment / enrolment records.

---

## Part 2: Normalization from 1NF to 3NF

### Given Unnormalized Table (UNF)
| matric_no | student_name | student_dept | course_codes | course_titles | lecturers | lecturer_depts | session |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 20231234 | Ada Obi | Software Engineering | SEN307, SEN301 | Database Systems, Software Architecture | Dr A. Okafor, Dr M. Bello | Software Eng., Software Eng. | 2026/2027 |
| 20231235 | John Musa | Computer Science | SEN307, COS301 | Database Systems, Operating Systems | Dr A. Okafor, Mrs F. Eze | Software Eng., Computer Sci. | 2026/2027 |
| 20231236 | Grace Okon | Software Engineering | SEN301 | Software Architecture | Dr M. Bello | Software Eng. | 2026/2027 |

---

### Step 1: First Normal Form (1NF)
Eliminated repeating groups and multi-valued comma-separated cells so that every cell holds a single atomic value, giving each student–course combination its own row identified by the composite primary key **`(matric_no, course_code)`**.

**Table: StudentCourse_1NF**
*(Primary Key: `(matric_no, course_code)`)*

| matric_no (PK) | course_code (PK) | student_name | student_dept | course_title | lecturer | lecturer_dept | session |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 20231234 | SEN307 | Ada Obi | Software Engineering | Database Systems | Dr A. Okafor | Software Eng. | 2026/2027 |
| 20231234 | SEN301 | Ada Obi | Software Engineering | Software Architecture | Dr M. Bello | Software Eng. | 2026/2027 |
| 20231235 | SEN307 | John Musa | Computer Science | Database Systems | Dr A. Okafor | Software Eng. | 2026/2027 |
| 20231235 | COS301 | John Musa | Computer Science | Operating Systems | Mrs F. Eze | Computer Sci. | 2026/2027 |
| 20231236 | SEN301 | Grace Okon | Software Engineering | Software Architecture | Dr M. Bello | Software Eng. | 2026/2027 |

> **Explanation:** All repeating multi-valued attributes were removed by expanding entries into atomic rows, with each row uniquely identifiable by the composite key `(matric_no, course_code)`.

---

### Step 2: Second Normal Form (2NF)
Identified and removed partial dependencies where non-key attributes depended on only a subset of the composite primary key `(matric_no, course_code)`:
- `matric_no` $\rightarrow$ `student_name`, `student_dept` *(Partial Dependency)*
- `course_code` $\rightarrow$ `course_title` *(Partial Dependency)*
- `(matric_no, course_code)` $\rightarrow$ `lecturer`, `lecturer_dept`, `session` *(Full Functional Dependency)*

**Table: Student_2NF**
| matric_no (PK) | student_name | student_dept |
| :--- | :--- | :--- |
| 20231234 | Ada Obi | Software Engineering |
| 20231235 | John Musa | Computer Science |
| 20231236 | Grace Okon | Software Engineering |

**Table: Course_2NF**
| course_code (PK) | course_title |
| :--- | :--- |
| SEN307 | Database Systems |
| SEN301 | Software Architecture |
| COS301 | Operating Systems |

**Table: Enrolment_2NF**
| matric_no (PK, FK) | course_code (PK, FK) | lecturer | lecturer_dept | session |
| :--- | :--- | :--- | :--- | :--- |
| 20231234 | SEN307 | Dr A. Okafor | Software Eng. | 2026/2027 |
| 20231234 | SEN301 | Dr M. Bello | Software Eng. | 2026/2027 |
| 20231235 | SEN307 | Dr A. Okafor | Software Eng. | 2026/2027 |
| 20231235 | COS301 | Mrs F. Eze | Computer Sci. | 2026/2027 |
| 20231236 | SEN301 | Dr M. Bello | Software Eng. | 2026/2027 |

> **Explanation:** Removed partial dependencies by decomposing the 1NF table into Student, Course, and Enrolment tables so that every non-key attribute depends entirely on the whole candidate key.

---

### Step 3: Third Normal Form (3NF)
Identified and removed transitive dependencies where non-key attributes depended on other non-key attributes:
- `student_dept` represents department data belonging to a distinct Department entity rather than the student.
- `lecturer` and `lecturer_dept` represent lecturer and department entities rather than enrolment properties.

Created separate `Department` and `Lecturer` tables and introduced integer surrogate primary keys (`dept_id`, `student_id`, `lecturer_id`, `course_id`, `enrolment_id`) with appropriate Foreign Keys.

**Table: Department**
| dept_id (PK) | dept_name |
| :--- | :--- |
| 1 | Software Engineering |
| 2 | Computer Science |

**Table: Lecturer**
| lecturer_id (PK) | lecturer_name | dept_id (FK → Department) |
| :--- | :--- | :--- |
| 1 | Dr A. Okafor | 1 |
| 2 | Dr M. Bello | 1 |
| 3 | Mrs F. Eze | 2 |

**Table: Student**
| student_id (PK) | matric_no | full_name | dept_id (FK → Department) |
| :--- | :--- | :--- | :--- |
| 1 | 20231234 | Ada Obi | 1 |
| 2 | 20231235 | John Musa | 2 |
| 3 | 20231236 | Grace Okon | 1 |

**Table: Course**
| course_id (PK) | course_code | course_title |
| :--- | :--- | :--- |
| 1 | SEN307 | Database Systems |
| 2 | SEN301 | Software Architecture |
| 3 | COS301 | Operating Systems |

**Table: Enrolment**
| enrolment_id (PK) | student_id (FK → Student) | course_id (FK → Course) | lecturer_id (FK → Lecturer) | session |
| :--- | :--- | :--- | :--- | :--- |
| 1 | 1 | 1 | 1 | 2026/2027 |
| 2 | 1 | 2 | 2 | 2026/2027 |
| 3 | 2 | 1 | 1 | 2026/2027 |
| 4 | 2 | 3 | 3 | 2026/2027 |
| 5 | 3 | 2 | 2 | 2026/2027 |

> **Explanation:** Removed transitive functional dependencies by extracting department and lecturer details into separate entities, replacing descriptive names with foreign key relationships to prevent update, insertion, and deletion anomalies.

---

## Step 4: Final Relational Schema

```text
Department (dept_id PK, dept_name)
Student    (student_id PK, matric_no, full_name, dept_id FK → Department.dept_id)
Lecturer   (lecturer_id PK, lecturer_name, dept_id FK → Department.dept_id)
Course     (course_id PK, course_code, course_title)
Enrolment  (enrolment_id PK, student_id FK → Student.student_id, course_id FK → Course.course_id, lecturer_id FK → Lecturer.lecturer_id, session)
```

---

## Part 3: MySQL Workbench EER Diagram Artifacts
- **Workbench Model File:** `week04/lab2_model.mwb`
- **Exported Diagram PNG:** `week04/lab2_erd.png`
- **Physical Schema Name:** `sen307_vug_sen_24_12478`

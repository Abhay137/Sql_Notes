-- ============================================================
--                  SQL COMPLETE NOTES
--              From Basics to Advanced Queries
-- ============================================================


-- ============================================================
-- SECTION 1: CREATING & MANAGING TABLES
-- ============================================================

-- Create a basic table
CREATE TABLE student (
    student_id INT,
    name       VARCHAR(20),
    major      VARCHAR(20),
    PRIMARY KEY(student_id)
);
-- PRIMARY KEY uniquely identifies each row. No duplicates, no NULLs allowed.

DESCRIBE student;       -- Shows table structure (columns, types, constraints)
DROP TABLE student;     -- Permanently deletes the table

-- Add a column to an existing table
ALTER TABLE student ADD gpa DECIMAL(3,2);
-- DECIMAL(3,2) = 3 total digits, 2 after the decimal point. e.g. 3.75

-- Remove a column from an existing table
ALTER TABLE student DROP COLUMN gpa;


-- ============================================================
-- SECTION 2: CONSTRAINTS
-- ============================================================
-- Constraints enforce rules on column data at the database level.

-- NOT NULL    → Column cannot be empty
-- UNIQUE      → All values in the column must be different
-- DEFAULT     → Sets a fallback value if none is provided
-- AUTO_INCREMENT → Automatically generates the next integer (great for primary keys)

CREATE TABLE student (
    student_id INT          AUTO_INCREMENT,
    name       VARCHAR(20)  NOT NULL,
    major      VARCHAR(20)  DEFAULT 'Undecided',
    PRIMARY KEY(student_id)
);

-- With AUTO_INCREMENT, you don't need to pass student_id manually
INSERT INTO student(name, major) VALUES('Jack', 'Biology');
INSERT INTO student(name, major) VALUES('Abhay', 'History');
INSERT INTO student(name)        VALUES('Arya');             -- major defaults to 'Undecided'


-- ============================================================
-- SECTION 3: INSERTING DATA
-- ============================================================

-- Insert a full row (values must match column order defined in CREATE TABLE)
INSERT INTO student VALUES(1, 'Jack', 'Biology');

-- Insert a partial row (specify only the columns you have data for)
-- NOTE: PRIMARY KEY cannot be skipped unless AUTO_INCREMENT is set
INSERT INTO student(student_id, name)  VALUES(3, 'Abhay');  -- major will be NULL
INSERT INTO student(student_id, major) VALUES(5, 'History');-- name will be NULL

SELECT * FROM student; -- View all rows in the table


-- ============================================================
-- SECTION 4: UPDATING & DELETING DATA
-- ============================================================

-- Sample data setup
INSERT INTO student(name, major) VALUES('Jack',   'Biology');
INSERT INTO student(name, major) VALUES('Kate',   'Sociology');
INSERT INTO student(name, major) VALUES('Claire', 'Chemistry');
INSERT INTO student(name, major) VALUES('Jack',   'Biology');
INSERT INTO student(name, major) VALUES('Mike',   'Computer Science');

-- UPDATE: Modify existing rows
-- Syntax: UPDATE <table> SET <column> = <value> WHERE <condition>

UPDATE student SET major = 'Bio'         WHERE major = 'Biology';
UPDATE student SET major = 'CS'          WHERE major = 'Computer Science';
UPDATE student SET major = 'Maths'       WHERE student_id = 2;
UPDATE student SET major = 'History'     WHERE name = 'Jack';

-- Update using OR: matches rows where either condition is true
UPDATE student SET major = 'Science'
WHERE major = 'Maths' OR major = 'Chemistry';

-- Update multiple columns at once
UPDATE student SET major = 'Undecided', name = 'Tom'
WHERE student_id = 1;

-- ⚠️ WARNING: Omitting WHERE updates EVERY row
UPDATE student SET major = 'Science'; -- Changes all rows!


-- DELETE: Remove rows
-- Syntax: DELETE FROM <table> WHERE <condition>

DELETE FROM student WHERE student_id = 5;
DELETE FROM student WHERE name = 'Tom'  AND major = 'Undecided'; -- Both must be true
DELETE FROM student WHERE name = 'Kate' OR  major = 'History';   -- Either must be true

-- ⚠️ WARNING: Omitting WHERE deletes ALL rows
DELETE FROM student; -- Clears the entire table!


-- ============================================================
-- SECTION 5: QUERYING DATA (SELECT)
-- ============================================================

SELECT * FROM student;                          -- All columns, all rows
SELECT name FROM student;                       -- Only the name column
SELECT name, major FROM student;                -- Multiple columns

-- Column aliases: rename output columns (does not change the table)
SELECT first_name AS forename, last_name AS surname FROM employee;

-- ORDER BY: Sort results
SELECT * FROM student ORDER BY name;               -- Alphabetical (A → Z)
SELECT * FROM student ORDER BY name DESC;          -- Reverse alphabetical (Z → A)
SELECT * FROM student ORDER BY major, student_id;  -- Sort by major, then by student_id for ties

-- LIMIT: Restrict number of rows returned
SELECT * FROM student ORDER BY student_id DESC LIMIT 2; -- Top 2 results

-- WHERE: Filter rows
SELECT * FROM student WHERE major = 'Biology';
SELECT * FROM student WHERE major = 'Biology' OR major = 'Chemistry';
SELECT * FROM student WHERE student_id <= 9 AND name <> 'Jack';
-- Comparison operators: =  <  >  <=  >=  <> (not equal)

-- IN: Shorthand for multiple OR conditions on the same column
SELECT * FROM student WHERE name IN ('Kate', 'Claire', 'Mike');
-- Equivalent to: WHERE name='Kate' OR name='Claire' OR name='Mike'

-- DISTINCT: Return only unique values
SELECT DISTINCT sex       FROM employee; -- Shows: M, F
SELECT DISTINCT branch_id FROM employee;


-- ============================================================
-- SECTION 6: AGGREGATE FUNCTIONS
-- ============================================================
-- Aggregate functions perform a calculation on a set of rows.

SELECT COUNT(emp_id)   FROM employee;                              -- Total employees
SELECT COUNT(super_id) FROM employee;                              -- Employees WITH a supervisor (NULLs excluded)
SELECT AVG(salary)     FROM employee;                              -- Average salary
SELECT AVG(salary)     FROM employee WHERE sex = 'M';             -- Average male salary
SELECT SUM(salary)     FROM employee;                              -- Total salary expenditure

-- GROUP BY: Group rows and apply aggregate per group
SELECT sex, COUNT(sex)       FROM employee GROUP BY sex;           -- Count of males vs females
SELECT emp_id, SUM(total_sales) FROM works_with GROUP BY emp_id;  -- Total sales per employee


-- ============================================================
-- SECTION 7: WILDCARDS (Pattern Matching with LIKE)
-- ============================================================
-- %  → Matches any number of characters (including zero)
-- _  → Matches exactly one character

SELECT * FROM client         WHERE cleint_name    LIKE '%LLC';       -- Names ending in LLC
SELECT * FROM branch_supplier WHERE supplier_name LIKE '%Labels';    -- Names ending in Labels
SELECT * FROM client         WHERE cleint_name    LIKE '%school';    -- Names ending in school

-- Use _ when you know the exact position of characters
-- Date format: YYYY-MM-DD → October = position 6-7
SELECT * FROM employee WHERE birth_day LIKE '_____10%'; -- Born in October


-- ============================================================
-- SECTION 8: UNION
-- ============================================================
-- Combines results of multiple SELECT statements into one result set.

-- Rules:
--   1. Each SELECT must return the SAME number of columns
--   2. Corresponding columns must have compatible data types

-- List of all employee names, branch names, and client names in one column
SELECT first_name  FROM employee
UNION
SELECT branch_name FROM branch
UNION
SELECT cleint_name FROM client;

-- Union with multiple columns
SELECT first_name, branch_id FROM employee
UNION
SELECT branch_name, branch_id FROM branch
UNION
SELECT cleint_name, branch_id FROM client;

-- All money flows (salaries paid + sales earned)
SELECT emp_id, salary      FROM employee
UNION
SELECT emp_id, total_sales FROM works_with;


-- ============================================================
-- SECTION 9: JOINS
-- ============================================================
-- Joins combine rows from two or more tables based on a related column.

-- Setup: Adding a branch with no manager to test join behavior
INSERT INTO branch VALUES(4, 'Buffalo', NULL, NULL);

-- INNER JOIN (default JOIN): Returns only rows with matching values in BOTH tables
SELECT e.emp_id, e.first_name, b.branch_name
FROM employee e
JOIN branch b ON e.emp_id = b.mgr_id;

-- LEFT JOIN: Returns ALL rows from the LEFT table + matched rows from the right
-- Unmatched right-side columns appear as NULL
SELECT e.emp_id, e.first_name, b.branch_name
FROM employee e
LEFT JOIN branch b ON e.emp_id = b.mgr_id;

-- RIGHT JOIN: Returns ALL rows from the RIGHT table + matched rows from the left
-- Unmatched left-side columns appear as NULL
SELECT e.emp_id, e.first_name, b.branch_name
FROM employee e
RIGHT JOIN branch b ON e.emp_id = b.mgr_id;

-- NOTE: FULL OUTER JOIN (combines LEFT + RIGHT) is NOT supported in MySQL.
--       Use UNION of LEFT and RIGHT JOIN as a workaround.


-- ============================================================
-- SECTION 10: NESTED QUERIES (SUBQUERIES)
-- ============================================================
-- A subquery is a SELECT statement nested inside another query.
-- The inner query runs first and passes its result to the outer query.

-- Find names of employees who made over $30,000 in a single sale
SELECT first_name, last_name
FROM employee
WHERE emp_id IN (
    SELECT emp_id
    FROM works_with
    WHERE total_sales > 30000
);

-- Find all clients handled by Michael Scott's branch (emp_id = 102)
SELECT client_id, cleint_name
FROM client
WHERE branch_id IN (
    SELECT branch_id
    FROM branch
    WHERE mgr_id = 102
);
-- You can also use = instead of IN when the subquery returns exactly one value


-- ============================================================
-- SECTION 11: ON DELETE BEHAVIOR (Foreign Key Rules)
-- ============================================================
-- Defines what happens to a child row when its referenced parent row is deleted.

-- ON DELETE SET NULL
--   → Sets the foreign key column to NULL in the child table
--   → Used when the child row can still exist without the parent
--   → Cannot be used if the foreign key is part of a PRIMARY KEY

-- ON DELETE CASCADE
--   → Automatically deletes the child row when the parent is deleted
--   → Used when the child row has no meaning without the parent
--   → Required when the foreign key is part of a composite PRIMARY KEY

-- Example: Deleting an employee who is a branch manager
DELETE FROM employee WHERE emp_id = 102;
-- The branch table's mgr_id (ON DELETE SET NULL) becomes NULL

-- Example: Deleting a branch
DELETE FROM branch WHERE branch_id = 2;
-- The branch_supplier rows for that branch (ON DELETE CASCADE) are also deleted


-- ============================================================
-- SECTION 12: TRIGGERS
-- ============================================================
-- A trigger automatically executes a defined action
-- BEFORE or AFTER an INSERT, UPDATE, or DELETE on a table.

-- Setup: Table to log trigger events
CREATE TABLE trigger_log (
    message VARCHAR(100)
);

-- Basic trigger: Log every new employee insertion
DELIMITER $$
CREATE TRIGGER log_new_employee
    BEFORE INSERT ON employee
    FOR EACH ROW
BEGIN
    INSERT INTO trigger_log VALUES('New employee added');
END$$
DELIMITER ;

-- Capture the new employee's first name in the log
DELIMITER $$
CREATE TRIGGER log_employee_name
    BEFORE INSERT ON employee
    FOR EACH ROW
BEGIN
    INSERT INTO trigger_log VALUES(NEW.first_name);
    -- NEW.column_name refers to the values being inserted
END$$
DELIMITER ;

-- Conditional trigger: Log based on employee gender
DELIMITER $$
CREATE TRIGGER log_employee_gender
    BEFORE INSERT ON employee
    FOR EACH ROW
BEGIN
    IF NEW.sex = 'M' THEN
        INSERT INTO trigger_log VALUES('Male employee added');
    ELSEIF NEW.sex = 'F' THEN
        INSERT INTO trigger_log VALUES('Female employee added');
    ELSE
        INSERT INTO trigger_log VALUES('Employee with other gender added');
    END IF;
END$$
DELIMITER ;

-- Drop a trigger
DROP TRIGGER log_new_employee;

-- NOTE: DELIMITER syntax is specific to the MySQL CLI.
--       Tools like PopSQL handle delimiters differently — run trigger blocks separately there.


-- ============================================================
-- SECTION 13: COMPANY DATABASE SCHEMA (Full Example)
-- ============================================================

-- Step 1: Create employee without foreign keys (branch table doesn't exist yet)
CREATE TABLE employee (
    emp_id     INT PRIMARY KEY,
    first_name VARCHAR(40),
    last_name  VARCHAR(40),
    birth_day  DATE,
    sex        VARCHAR(1),
    salary     INT,
    super_id   INT,   -- References another employee (self-referencing)
    branch_id  INT    -- References branch (added as FK after branch is created)
);

-- Step 2: Create branch, referencing employee for manager
CREATE TABLE branch (
    branch_id      INT PRIMARY KEY,
    branch_name    VARCHAR(40),
    mgr_id         INT,
    mgr_start_date DATE,
    FOREIGN KEY(mgr_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);

-- Step 3: Now add foreign keys to employee (branch table now exists)
ALTER TABLE employee ADD FOREIGN KEY(branch_id) REFERENCES branch(branch_id)   ON DELETE SET NULL;
ALTER TABLE employee ADD FOREIGN KEY(super_id)  REFERENCES employee(emp_id)    ON DELETE SET NULL;

-- Client table
CREATE TABLE client (
    client_id   INT PRIMARY KEY,
    cleint_name VARCHAR(40),
    branch_id   INT,
    FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE SET NULL
);

-- works_with: composite primary key (both columns are also foreign keys → CASCADE required)
CREATE TABLE works_with (
    emp_id      INT,
    client_id   INT,
    total_sales INT,
    PRIMARY KEY(emp_id, client_id),
    FOREIGN KEY(emp_id)    REFERENCES employee(emp_id) ON DELETE CASCADE,
    FOREIGN KEY(client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

-- branch_supplier: composite primary key → CASCADE required
CREATE TABLE branch_supplier (
    branch_id     INT,
    supplier_name VARCHAR(40),
    supply_type   VARCHAR(40),
    PRIMARY KEY(branch_id, supplier_name),
    FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE
);

-- ============================================================
-- END OF NOTES
-- ============================================================

/*----------------Snowflake Fundamentals 4-day class Lab:---------------------------
1) Analytic Functions 
2) QUALIFY clause
3) Advanced SQL Puzzles
----------------------------------------------------------------------------------*/

-- Get the top 1 row - traditional approaches

-- Using TOP option
SELECT TOP 1 *
FROM emp
ORDER BY hiredate;

-- Using LIMIT clause
SELECT *
FROM emp
ORDER BY hiredate 
LIMIT 1;

WITH x AS (
SELECT *, ROW_NUMBER() OVER(ORDER BY hiredate) rn 
FROM emp
)
SELECT *
FROM x
WHERE rn = 1

SELECT *, ROW_NUMBER() OVER(ORDER BY hiredate) rn 
FROM emp
QUALIFY rn = 1 

SELECT * 
FROM emp
QUALIFY ROW_NUMBER() OVER(ORDER BY hiredate) = 1 


-- Challenge #1: Identify all employees who were hired first (or tied for first) in each department.

-- Strategy #1: Using CTE

-- Step 1: Find MIN hiredate in each department
SELECT deptno, MIN(hiredate) first_hiredate
FROM emp
GROUP BY deptno
ORDER BY 1;

-- Step 2: Find employees hired on specific dates
WITH x AS (
    SELECT deptno, MIN(hiredate) first_hiredate
    FROM emp
    GROUP BY deptno
)
SELECT e.*
FROM emp e JOIN x ON e.deptno = x.deptno AND e.hiredate = x.first_hiredate
ORDER BY e.deptno;

-- Challenge #2: Identify all employees who were hired first or last in each department.

-- Strategy #1: Using CTE

WITH x AS (
    SELECT deptno, MIN(hiredate) first_hiredate, MAX(hiredate) last_hiredate
    FROM emp
    GROUP BY deptno
)
SELECT e.*
FROM emp e JOIN x ON e.deptno = x.deptno AND (e.hiredate = x.first_hiredate OR e.hiredate = x.last_hiredate)
ORDER BY e.deptno, e.hiredate;

-- Alternative syntax

WITH x AS (
    SELECT deptno, MIN(hiredate) first_hiredate, MAX(hiredate) last_hiredate
    FROM emp
    GROUP BY deptno
)
SELECT e.*
FROM emp e JOIN x ON e.deptno = x.deptno AND e.hiredate IN (x.first_hiredate, x.last_hiredate)
ORDER BY e.deptno, e.hiredate;

-- Strategy #2: Using CTE and UNION ALL

WITH x AS (
    SELECT deptno, MIN(hiredate) first_hiredate, MAX(hiredate) last_hiredate
    FROM emp
    GROUP BY deptno
)
SELECT e.*
FROM emp e JOIN x ON e.deptno = x.deptno AND e.hiredate = x.first_hiredate
UNION ALL
SELECT e.*
FROM emp e JOIN x ON e.deptno = x.deptno AND e.hiredate = x.last_hiredate
ORDER BY deptno, hiredate;

-- Strategy #3: Using MIN/MAX Analytic functions

--Step 1: Show first and last department hire dates next to employee's data
SELECT empno, ename, job, hiredate, deptno, 
       MIN(hiredate) OVER(PARTITION BY deptno) first_date,
       MAX(hiredate) OVER(PARTITION BY deptno) last_date
FROM emp
ORDER BY deptno;

-- Step 2: Apply filter on hiredate column
WITH x AS (
    SELECT empno, ename, job, hiredate, deptno, 
        MIN(hiredate) OVER(PARTITION BY deptno) first_date,
        MAX(hiredate) OVER(PARTITION BY deptno) last_date
    FROM emp
)
SELECT empno, ename, job, hiredate, deptno, first_date first_hiredate, last_date last_hiredate
FROM x 
WHERE hiredate IN (first_date, last_date)
ORDER BY deptno, hiredate;

-- Strategy #4: Using MIN/MAX Analytic functions and QUALIFY clause

SELECT empno, ename, job, hiredate, deptno, 
       MIN(hiredate) OVER(PARTITION BY deptno) first_hiredate,
	   MAX(hiredate) OVER(PARTITION BY deptno) last_hiredate
FROM emp
QUALIFY hiredate IN (first_hiredate, last_hiredate)
ORDER BY deptno, hiredate;

-- Improved query:

SELECT empno, ename, job, hiredate, deptno
FROM emp
QUALIFY hiredate IN (MIN(hiredate) OVER(PARTITION BY deptno), 
                     MAX(hiredate) OVER(PARTITION BY deptno))
ORDER BY deptno, hiredate;

-- Simulating duplicates

INSERT INTO SCOTT.EMP VALUES
(7782,'WILSON','MANAGER',7839,to_date('09-06-1981','dd-mm-yyyy') ,2450 ,NULL ,10),
(7783,'POOJA', 'MANAGER',7839,to_date('09-06-1981','dd-mm-yyyy') ,2450 ,NULL ,10)


-- Strategy #5: Using ROW_NUMBER function

SELECT empno, ename, job, hiredate, deptno
FROM emp
QUALIFY ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY hiredate, empno ASC) = 1
ORDER BY deptno;

DELETE FROM SCOTT.EMP 
WHERE ename IN ('WILSON','POOJA');


-- Demonstration: Using multiple analytic functions in the same query

SELECT empno, ename, job, hiredate, deptno, sal, 
       --MIN(hiredate) OVER(PARTITION BY deptno) first_date,
       --ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY hiredate) rn,
       --RANK() OVER(PARTITION BY deptno ORDER BY hiredate) rk,
       --MIN(hiredate) OVER(PARTITION BY job) first_date_job,
       --ROW_NUMBER() OVER(PARTITION BY job ORDER BY hiredate) rn_job,
       --RANK() OVER(PARTITION BY job ORDER BY hiredate) rk_job,
       MIN(sal) OVER(PARTITION BY job) min_sal_job,
       ROW_NUMBER() OVER(PARTITION BY job ORDER BY sal) rn_job_sal,
       RANK() OVER(ORDER BY sal) rk_job,
       DENSE_RANK() OVER(ORDER BY sal) drk_job,
       COUNT(*) OVER(PARTITION BY deptno) dept_count,
       COUNT(*) OVER() total_count
FROM emp
ORDER BY sal 

-- Advanced Challenges:

-- Challenge #3:

/* 
	Objective:
		Write a query to find all employees who work in the same department(s) as the president(s).

	Requirements:
		Your query must work even if there are multiple "PRESIDENT" records in the emp table.
		Ensure that Snowflake scans the emp table only once for efficiency.
*/


SELECT *, COUNT(CASE WHEN job='PRESIDENT' THEN 1 END) OVER(PARTITION BY deptno) num_of_presidents
FROM emp a
ORDER BY deptno

SELECT *
FROM emp a
QUALIFY COUNT(CASE WHEN job='PRESIDENT' THEN 1 END) OVER(PARTITION BY deptno) > 0
ORDER BY deptno

SELECT *
FROM emp a
QUALIFY SUM(CASE WHEN job='PRESIDENT' THEN 1 END) OVER(PARTITION BY deptno) > 0
ORDER BY deptno


SELECT *
FROM emp a
WHERE 0 < (SELECT COUNT(*) FROM emp WHERE job='PRESIDENT' and deptno = a.deptno)


-- Challenge #4: Employees in the Department of the Top-Paid Clerk

/* 
	Objective:
		Write a query to find all employees who work in the same department as the highest-paid "CLERK."

	Requirements:
		Ensure your query handles ties (i.e., if there are multiple top-paid clerks in different departments).
*/

SELECT *
FROM emp a
QUALIFY MAX(CASE WHEN job='CLERK' THEN sal END) OVER(PARTITION BY deptno) = MAX(CASE WHEN job='CLERK' THEN sal END) OVER()
ORDER BY deptno

-- Challenge #5: Employees Paid Above the Department Average


/* 
	Objective:
		Write a query to find all employees whose salary is above the average salary of their respective department.
*/

-- Challenge #6: Employees with the Same Department and Job Title as ADAMS

/*
	Objective:
		Write a query to list all employees who work in the same department and hold the same job title as the employee named "ADAMS."
*/

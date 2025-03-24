/*----------------Snowflake Fundamentals 3-day class Lab:---------------------------
1) Analytic Functions 
2) QUALIFY clause
3) Advanced SQL Puzzles
----------------------------------------------------------------------------------*/

CREATE DATABASE IF NOT EXISTS DEMO_DB;


CREATE SCHEMA IF NOT EXISTS SCOTT;

USE DATABASE DEMO_DB;

USE SCHEMA SCOTT;


CREATE TABLE SCOTT.DEPT
(DEPTNO     NUMBER(2) CONSTRAINT PK_DEPT PRIMARY KEY,
 DNAME      VARCHAR(14),
 LOC        VARCHAR(13));


CREATE TABLE SCOTT.EMP
(EMPNO      NUMBER(4) CONSTRAINT PK_EMP PRIMARY KEY,
 ENAME      VARCHAR(10),
 JOB        VARCHAR(9),
 MGR        NUMBER(4),
 HIREDATE   DATE,
 SAL        NUMBER(7,2),
 COMM       NUMBER(7,2),
 DEPTNO     NUMBER(2) CONSTRAINT FK_DEPTNO REFERENCES DEPT);


INSERT INTO SCOTT.DEPT VALUES
(10,'ACCOUNTING' ,'NEW YORK'),
(20,'RESEARCH'   ,'DALLAS'  ),
(30,'SALES'      ,'CHICAGO' ),
(40,'OPERATIONS' ,'BOSTON'  );


INSERT INTO SCOTT.EMP VALUES
(7369,'SMITH' ,'CLERK'    ,7902,to_date('17-12-1980','dd-mm-yyyy') ,800  ,NULL ,20),
(7499,'ALLEN' ,'SALESMAN' ,7698,to_date('20-02-1981','dd-mm-yyyy') ,1600 ,300  ,30),
(7521,'WARD'  ,'SALESMAN' ,7698,to_date('22-02-1981','dd-mm-yyyy') ,1250 ,500  ,30),
(7566,'JONES' ,'MANAGER'  ,7839,to_date('02-04-1981','dd-mm-yyyy') ,2975 ,NULL ,20),
(7654,'MARTIN','SALESMAN' ,7698,to_date('28-09-1981','dd-mm-yyyy') ,1250 ,1400 ,30),
(7698,'BLAKE' ,'MANAGER'  ,7839,to_date('01-05-1981','dd-mm-yyyy') ,2850 ,NULL ,30),
(7782,'CLARK' ,'MANAGER'  ,7839,to_date('09-06-1981','dd-mm-yyyy') ,2450 ,NULL ,10),
(7788,'SCOTT' ,'ANALYST'  ,7566,to_date('19-04-1987','dd-mm-yyyy') ,3000 ,NULL ,20),
(7839,'KING'  ,'PRESIDENT',NULL,to_date('17-11-1981','dd-mm-yyyy') ,5000 ,NULL ,10),
(7844,'TURNER','SALESMAN' ,7698,to_date('08-09-1981','dd-mm-yyyy') ,1500 ,0    ,30),
(7876,'ADAMS' ,'CLERK'    ,7788,to_date('23-05-1987','dd-mm-yyyy') ,1100 ,NULL ,20),
(7900,'JAMES' ,'CLERK'    ,7698,to_date('03-12-1981','dd-mm-yyyy') ,950  ,NULL ,30),
(7902,'FORD'  ,'ANALYST'  ,7566,to_date('03-12-1981','dd-mm-yyyy') ,3000 ,NULL ,20),
(7934,'MILLER','CLERK'    ,7782,to_date('23-01-1982','dd-mm-yyyy') ,1300 ,NULL ,10);


-- Get the top 1 row - traditional approaches

-- Using TOP option
SELECT TOP 1 *
FROM emp
ORDER BY hiredate;

- Using LIMIT clause
SELECT *
FROM emp
ORDER BY hiredate 
LIMIT 1 ;


-- Challenge #1: Identify all employees who were hired first (or tied for first) in each department.

-- Strategy #1: Using CTE

SELECT deptno, MIN(hiredate) first_hiredate
FROM emp
GROUP BY deptno
ORDER BY 1;


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
ORDER BY e.deptno;

-- Alternative syntax

WITH x AS (
    SELECT deptno, MIN(hiredate) first_hiredate, MAX(hiredate) last_hiredate
    FROM emp
    GROUP BY deptno
)
SELECT e.*
FROM emp e JOIN x ON e.deptno = x.deptno AND e.hiredate IN (x.first_hiredate, x.last_hiredate)
ORDER BY e.deptno;

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
ORDER BY deptno;

-- Strategy #3: Using MIN/MAX Analytic functions

SELECT empno, ename, job, hiredate, deptno, MIN(hiredate) OVER(PARTITION BY deptno) first_date
FROM emp
ORDER BY deptno;


WITH x AS (
    SELECT deptno, MIN(hiredate) first_hiredate, MAX(hiredate) last_hiredate
    FROM emp
    GROUP BY deptno
)
SELECT empno, ename, job, hiredate, e.deptno, first_hiredate
FROM emp e JOIN x ON e.deptno = x.deptno 
ORDER BY e.deptno;

-- Strategy #4: Using MIN/MAX Analytic functions and QUALIFY clause

SELECT empno, ename, job, hiredate, deptno, 
       MIN(hiredate) OVER(PARTITION BY deptno) first_date,
	   MIN(hiredate) OVER(PARTITION BY deptno) last_date
FROM emp
QUALIFY hiredate IN (first_date, last_date)
ORDER BY deptno;

-- Improved query:

SELECT empno, ename, job, hiredate, deptno--, MIN(hiredate) OVER(PARTITION BY deptno) first_date
FROM emp
QUALIFY hiredate IN (MIN(hiredate) OVER(PARTITION BY deptno), 
                     MAX(hiredate) OVER(PARTITION BY deptno))
ORDER BY deptno;

-- Simulating duplicates

INSERT INTO SCOTT.EMP VALUES
(7782,'CLARK' ,'MANAGER'  ,7839,to_date('09-06-1981','dd-mm-yyyy') ,2450 ,NULL ,10),
(7783,'POOJA' ,'MANAGER'  ,7839,to_date('09-06-1981','dd-mm-yyyy') ,2450 ,NULL ,10)


-- Strategy #5: Using ROW_NUMBER function

SELECT empno, ename, job, hiredate, deptno, 
       MIN(hiredate) OVER(PARTITION BY deptno) first_date,
       ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY hiredate, empno DESC) rn 
FROM emp
QUALIFY hiredate = MIN(hiredate) OVER(PARTITION BY deptno)
    AND rn = 1
ORDER BY deptno;

-- Improved query:

SELECT empno, ename, job, hiredate, deptno
FROM emp
QUALIFY ROW_NUMBER() OVER(PARTITION BY deptno ORDER BY hiredate, empno DESC) = 1
ORDER BY deptno;

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
       RANK() OVER(PARTITION BY job ORDER BY sal) rk_job_sal,
       DENSE_RANK() OVER(PARTITION BY job ORDER BY sal) drk_job_sal,
       COUNT(*) OVER(PARTITION BY deptno) dept_count,
       COUNT(*) OVER() total_count
FROM emp
ORDER BY job --deptno


-- Advanced Challenges:

-- Challenge #3:

/* 
	Objective:
		Write a query to find all employees who work in the same department(s) as the president(s).

	Requirements:
		Your query must work even if there are multiple "PRESIDENT" records in the emp table.
		Ensure that Snowflake scans the emp table only once for efficiency.
*/

-- Challenge #4: Employees in the Department of the Top-Paid Clerk

/* 
	Objective:
		Write a query to find all employees who work in the same department as the highest-paid "CLERK."

	Requirements:
		Ensure your query handles ties (i.e., if there are multiple top-paid clerks in different departments).
*/

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

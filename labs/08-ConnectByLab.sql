/*----------------Snowflake Fundamentals 4-day class Lab:---------------------------
1) CONNECT BY clause
2) START WITH clause
3) LEVEL pseudo-column
4) CONNECT_BY_ROOT function
5) Recursive CTEs
6) Range Generators
----------------------------------------------------------------------------------*/

use database demo_db;

use schema scott;

-- Review manager/employee relationship in emp table:
SELECT empno, ename, job, mgr 
FROM emp;


SELECT e.empno, e.ename, e.job, e.mgr, m.ename as mgr_name, m.job as mgr_title
FROM emp e LEFT JOIN emp m ON e.mgr = m.empno;

-- List the names of all employees alongside the names of their respective managers:

-- Strategy #1: Using UNION ALL and NOT EXISTS
SELECT e.empno, e.ename, e.job, e.mgr, m.ename as mgr_name, m.job as mgr_title
FROM emp e JOIN emp m ON e.mgr = m.empno 
UNION ALL
SELECT  e.empno, e.ename, e.job, NULL, NULL, NULL 
FROM emp e
WHERE NOT EXISTS(SELECT 1
                 FROM emp x
                 WHERE NVL(e.mgr, 0) = x.empno);
--WHERE mgr IS NULL;


-- Strategy #2: Using LEFT JOIN 
SELECT e.empno, e.ename, e.job, e.mgr, m.ename as mgr_name, m.job as mgr_title
FROM emp e LEFT JOIN emp m ON e.mgr = m.empno;


-- Strategy #3: Using Hierarchical Query with CONNECT BY
SELECT empno, ename, job, mgr, LEVEL
FROM emp
START WITH mgr IS NULL 
CONNECT BY mgr = PRIOR empno;

SELECT empno, LPAD('.', (LEVEL-1)*5, '.') || ename name, job, mgr, LEVEL, LTRIM(SYS_CONNECT_BY_PATH(empno, '>'), '>') path
FROM emp
START WITH mgr IS NULL 
CONNECT BY mgr = PRIOR empno
ORDER BY path

show functions

show functions;
SELECT *
FROM TABLE(RESULT_SCAN(last_query_id()))



-- Demonstration: More examples using CONNECT BY and START WITH clauses
SELECT empno, ename, job, mgr, LEVEL
FROM emp
START WITH empno = 7788
CONNECT BY mgr = PRIOR empno;

SELECT empno, ename, job, mgr, LEVEL
FROM emp
START WITH empno = 7788
CONNECT BY PRIOR mgr =  empno;

SELECT empno, ename, job, mgr, LEVEL
FROM emp
START WITH empno = 7788
CONNECT BY PRIOR mgr =  empno;


SELECT empno, ename, job, mgr, LEVEL, CONNECT_BY_ROOT(empno) root_empno
FROM emp
START WITH empno in (7369, 7499)
CONNECT BY PRIOR mgr =  empno
ORDER BY root_empno, LEVEL


SELECT empno, ename, job, mgr, LEVEL
FROM emp
START WITH empno = 7369
CONNECT BY PRIOR mgr =  empno
UNION ALL
SELECT empno, ename, job, mgr, LEVEL
FROM emp
START WITH empno = 7499
CONNECT BY PRIOR mgr =  empno


SELECT empno, ename, job, mgr, LEVEL, CONNECT_BY_ROOT(empno) root_empno
FROM emp
--START WITH empno in (7369, 7499)
CONNECT BY PRIOR mgr =  empno
ORDER BY root_empno, LEVEL


-- Recursive CTEs

-- Regular CTE:
WITH x(id, name, title) AS (
SELECT empno, ename, job
FROM emp
WHERE deptno = 10
)
SELECT *
FROM x

--compare the column names:

WITH x AS (
SELECT empno, ename, job
FROM emp
WHERE deptno = 10
)
SELECT *
FROM x


-- Recursive CTE:

SELECT empno, ename, job, mgr, LEVEL as level_
FROM emp
START WITH mgr IS NULL 
CONNECT BY mgr = PRIOR empno

INTERSECT

(

WITH RECURSIVE x(empno, ename, job, mgr, level_) AS (
SELECT empno, ename, job, mgr, 1
FROM emp
WHERE mgr IS NULL
UNION ALL
SELECT e.empno, e.ename, e.job, e.mgr, x.level_ + 1
FROM emp e JOIN x ON e.mgr = x.empno
)
SELECT *
FROM x

)


WITH x(empno, ename, job, mgr, level_) AS (
    SELECT empno, ename, job, mgr, 1
    FROM emp
    WHERE mgr IS NULL
    UNION ALL
    SELECT e.empno, e.ename, e.job, e.mgr, x.level_ + 1
    FROM emp e JOIN x ON e.mgr = x.empno
)
SELECT *
FROM x


-- Range generation:

-- Using CONNECT BY
SELECT LEVEL value
FROM dual
CONNECT BY NVL(PRIOR COLUMN1,0)=NVL(COLUMN1,0)
LIMIT 10


-- Using Recursive CTE
WITH x (value) AS (
    SELECT 1
    UNION ALL
    SELECT value + 1
    FROM x
    WHERE x.value < 10
)
SELECT *
FROM x

-- Using generator function
SELECT ROW_NUMBER() OVER(ORDER BY NULL) value
FROM TABLE(generator(ROWCOUNT=>10))



SELECT empno, ename, job, mgr, LEVEL, 
       CONNECT_BY_ROOT(empno) root_empno, SUBSTR(SYS_CONNECT_BY_PATH(ename, '=>'), 3) hier_path,
       CONNECT_BY_ISLEAF()
FROM emp
START WITH empno in (7369, 7499)
CONNECT BY PRIOR mgr =  empno
ORDER BY root_empno, LEVEL

WITH x(empno, ename, job, mgr, lvl, root_empno, hier_path) AS (
    SELECT empno, ename, job, mgr, 1, empno, ename
    FROM scott.emp
    WHERE empno IN (7369, 7499)
    UNION ALL
    SELECT e.empno, e.ename, e.job, e.mgr, x.lvl + 1, x.root_empno, x.hier_path || '=>' || e.ename
    FROM emp e JOIN x ON e.empno = x.mgr
)
SELECT *
FROM x
ORDER BY root_empno, lvl

/*----------------Snowflake Fundamentals 3-day class Lab:---------------------------
1) Clone objects
2) Cloning and Time Travel
----------------------------------------------------------------------------------*/

-- Set context
USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS DEMO_DB;

USE DATABASE DEMO_DB;

CREATE SCHEMA IF NOT EXISTS DEMO_SCHEMA;

USE SCHEMA DEMO_SCHEMA;

-- Cloning is metadata operation only, no data is transferred: "zero-copy" cloning
CREATE TABLE emp_clone CLONE scott.emp;

SELECT * FROM emp_clone;

-- We can create clones of clones
CREATE TABLE emp_clone_TWO CLONE emp_clone;

SELECT * FROM emp_clone_TWO;

-- Easily and quickly create entire database from existing database
CREATE DATABASE DEMO_DB_CLONE CLONE DEMO_DB;

USE DATABASE DEMO_DB_CLONE;
USE SCHEMA SCOTT;

-- Cloning is recursive for databases and schemas
SHOW TABLES;

SELECT * FROM dept;

-- Data added to cloned database table will start to store micro-partitions, incurring additional cost
INSERT INTO dept(deptno, dname, loc) VALUES (50, 'HR', 'MIAMI');

-- cloned table
SELECT * FROM dept;

-- source table unchanged
SELECT * FROM "DEMO_DB"."SCOTT"."DEPT";

-- Create clone from point in past with Time Travel 
CREATE OR REPLACE TABLE DEPT_CLONE_TIME_TRAVEL CLONE dept
AT(OFFSET => -60*3);

SELECT * FROM DEPT_CLONE_TIME_TRAVEL;

-- Clear-down resources
--DROP DATABASE DEMO_DB;
DROP DATABASE DEMO_DB_CLONE;
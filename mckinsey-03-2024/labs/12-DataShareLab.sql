/*----------------Snowflake Fundamentals 4-day class Lab:---------------------------
1) Data Share Object
2) Reader Account
3) Secure Views
----------------------------------------------------------------------------------*/

-- Create an empty stare 
-- CREATE SHARE privilege is required 

USE ROLE ACCOUNTADMIN;

CREATE SHARE my_share;

-- Share Objects
GRANT USAGE ON DATABASE DEMO_DB TO SHARE my_share;
GRANT USAGE ON SCHEMA DEMO_DB.SCOTT TO SHARE my_share;
GRANT SELECT ON TABLE DEMO_DB.SCOTT.EMP TO SHARE my_share;

-- Create a reader account
CREATE MANAGED ACCOUNT DEMO_READER_ACCOUNT 
admin_name='admin', 
admin_password='Passw0rd12345678', 
type=reader;

{
"accountName":"DEMO_READER_ACCOUNT",
"accountLocator":"OLB26468",
"url":"https://tyixbci-demo_reader_account.snowflakecomputing.com",
"accountLocatorUrl":"https://olb26468.us-east-1.snowflakecomputing.com"
}

SHOW MANAGED ACCOUNTS;

--ALTER MANAGED ACCOUNT DEMO_READER_ACCOUNT ADD SHARE my_share;

-- Add Accounts
ALTER SHARE my_share ADD ACCOUNTS = OLB26468;

SHOW SHARES;
SHOW GRANTS ON SHARE MY_SHARE;
SHOW GRANTS TO SHARE MY_SHARE;

SELECT CURRENT_ACCOUNT()

 
-- !!! EXECUTE FROM WITHIN READER ACCOUNT !!! --
USE ROLE ACCOUNTADMIN;

SHOW SHARES;

-- Create a database in the reader account from a share
CREATE DATABASE DEMO_DB_READER FROM SHARE DKB68178.MY_SHARE;

GRANT IMPORTED PRIVILEGES ON DATABASE DEMO_DB_READER TO ROLE SYSADMIN;

USE ROLE SYSADMIN;

--Create warehouse in reader account
CREATE OR REPLACE WAREHOUSE COMPUTE_XS WITH 
WAREHOUSE_SIZE = 'XSMALL'
WAREHOUSE_TYPE = 'STANDARD'
AUTO_SUSPEND = 600 
AUTO_RESUME = TRUE 
SCALING_POLICY = 'STANDARD';

-- Set context
USE WAREHOUSE COMPUTE_XS;
USE SCHEMA scott;

SELECT *
FROM emp;

--- After adding a view to the share:
SELECT *
FROM analysts;

-- !!! EXECUTE FROM WITHIN PROVIDER ACCOUNT !!! --

-- Add more objects to the share
CREATE OR REPLACE SECURE VIEW demo_db.scott.analysts AS
SELECT empno, ename, deptno, sal, comm, hiredate
FROM demo_db.scott.emp
WHERE job='ANALYST';

GRANT SELECT ON VIEW demo_db.scott.analysts TO SHARE MY_SHARE;
GRANT SELECT ON TABLE demo_db.scott.dept TO SHARE MY_SHARE;


CREATE TABLE DEMO_DB.DEMO_SCHEMA.TRIPS CLONE CITIBIKE.PUBLIC.TRIPS

GRANT USAGE ON SCHEMA DEMO_DB.DEMO_SCHEMA TO SHARE my_share;
GRANT SELECT ON TABLE DEMO_DB.DEMO_SCHEMA.TRIPS TO SHARE my_share;


REVOKE SELECT ON VIEW demo_db.scott.analysts FROM SHARE MY_SHARE;

-- !!! EXECUTE FROM WITHIN READER ACCOUNT !!! --

SELECT *
FROM demo_db_reader.scott.analysts;

-- !!! EXECUTE FROM WITHIN PROVIDER ACCOUNT !!! --

--ALTER SHARE DEMO_SHARE REMOVE ACCOUNTS = VKB39446

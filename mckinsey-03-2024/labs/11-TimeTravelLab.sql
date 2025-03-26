/*----------------Snowflake Fundamentals 4-day class Lab:---------------------------
1) Time Travel 
2) DATA_RETENTION_TIME_IN_DAYS parameter
3) Time Travel SQL extensions
----------------------------------------------------------------------------------*/

-- Set context
USE ROLE ACCOUNTADMIN;


CREATE DATABASE IF NOT EXISTS DEMO_DB;
use DATABASE DEMO_DB;

show schemas like 'DEMO_SCHEMA'

CREATE SCHEMA IF NOT EXISTS  DEMO_SCHEMA;

USE schema demo_schema;

show tables;

CREATE OR REPLACE TABLE dept_copy CLONE demo_db_clone.scott.dept;

-- Verify retention_time is set to default of 1
SHOW DATABASES LIKE 'DEMO_DB';

ALTER ACCOUNT SET DATA_RETENTION_TIME_IN_DAYS=90;

-- Verify updated retention_time 
SHOW DATABASES LIKE 'DEMO_DB';

ALTER DATABASE DEMO_DB SET DATA_RETENTION_TIME_IN_DAYS=45;

-- Verify updated retention_time 
SHOW DATABASES LIKE 'DEMO_DB';

-- Verify updated retention_time 
SHOW SCHEMAS LIKE 'DEMO_SCHEMA';
SHOW SCHEMAS;

-- Verify updated retention_time 
SHOW TABLES LIKE 'dept_copy';

ALTER SCHEMA DEMO_SCHEMA SET DATA_RETENTION_TIME_IN_DAYS=10;
ALTER TABLE dept_copy SET DATA_RETENTION_TIME_IN_DAYS=5;

-- Setting DATA_RETENTION_TIME_IN_DAYS to 0 effectively disables Time Travel
ALTER SCHEMA DEMO_SCHEMA SET DATA_RETENTION_TIME_IN_DAYS=0;


-- UNDROP 
SHOW TABLES HISTORY;

SELECT "name","retention_time","dropped_on" FROM TABLE(result_scan(LAST_QUERY_ID()));

DROP TABLE DEPT_COPY;

SHOW TABLES HISTORY;
SELECT "name","retention_time","dropped_on" FROM TABLE(result_scan(LAST_QUERY_ID()));

UNDROP TABLE DEPT_COPY;

SHOW TABLES HISTORY;
SELECT "name","retention_time","dropped_on" FROM TABLE(result_scan(LAST_QUERY_ID()));

SELECT * FROM DEPT_COPY;

-- The AT keyword allows you to capture historical data inclusive of all changes made by a statement or transaction up until that point.
TRUNCATE TABLE DEPT_COPY;
SET trunc_qid = (SELECT last_query_id())

SELECT * FROM DEPT_COPY;

--  Select table as it was 1 minute ago, expressed in difference in seconds between current time
SELECT * FROM DEPT_COPY
AT(OFFSET => -60*3);

-- Select rows from point in time of inserting records into table
SELECT * FROM DEPT_COPY
AT(STATEMENT => $trunc_qid);

SELECT * FROM DEPT_COPY
BEFORE(STATEMENT => $trunc_qid);

SELECT DATEADD(minute,-2, current_timestamp())

-- Select tables as it was 2 minutes ago using Timestamp
SELECT * FROM DEPT_COPY
AT(TIMESTAMP => DATEADD(minute,-2, current_timestamp()));

SELECT * FROM DEPT_COPY
AT(TIMESTAMP => DATEADD(minute,-3, current_timestamp()));



-- The BEFORE keyword allows you to select historical data from a table up to, but not including any changes made by a specified statement or transaction.


CREATE TABLE DEPT_COPY_RESTORED
AS 
SELECT * FROM DEPT_COPY
BEFORE(STATEMENT => $trunc_qid);

SELECT * FROM DEPT_COPY_RESTORED;

DROP TABLE dept_copy;

SHOW TABLES HISTORY;

DESC TABLE dept_copy;

UNDROP TABLE dept_copy;

SELECT *
FROM dept_copy;

DROP TABLE dept_copy;

SHOW TABLES HISTORY;

SELECT * FROM DEPT_COPY
BEFORE(STATEMENT => $trunc_qid); -- this fails as the table does not exist

UNDROP TABLE dept_copy;

SELECT * FROM DEPT_COPY
BEFORE(STATEMENT => $trunc_qid);

CREATE OR REPLACE TABLE dept_copy 
AS
SELECT * FROM DEPT_COPY
BEFORE(STATEMENT => $trunc_qid);

SHOW TABLES HISTORY;


-- Clear-down resources
--DROP DATABASE DEMO_DB;
ALTER ACCOUNT SET DATA_RETENTION_TIME_IN_DAYS=1;

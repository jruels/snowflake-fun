/*----------------Snowflake Fundamentals 3-day class Lab:---------------------------
1) User Defined Functions (UDFs)
2) External Functions
3) Stored Procedures
----------------------------------------------------------------------------------*/

USE ROLE ACCOUNTADMIN;
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE SYSADMIN;

-- Set context 
USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;

-- Create demo database and schema
CREATE DATABASE IF NOT EXISTS DEMO_DB;
CREATE SCHEMA IF NOT EXISTS DEMO_SCHEMA;

--Set context
USE DATABASE DEMO_DB;
USE SCHEMA DEMO_SCHEMA;

--User Defined Functions

-- SQL UDF to return the name of the day of the week on a date in the future
CREATE OR REPLACE FUNCTION DAY_NAME_ON(num_of_days int)
RETURNS STRING
  AS
  $$
    select 'In ' || CAST(num_of_days AS string) || ' days it will be a ' || dayname(dateadd(day,num_of_days, current_date()))
  $$; 
  -- single quote can be used instead of dollar sign to delimit function body
  
  
-- Use the SQL UDF as part of a query. 
SELECT DAY_NAME_ON(100);


SET days = 100;
SELECT dayname(dateadd(day, $days, current_date())) day_of_week;


SELECT *
FROM (VALUES (100), (200), (300)) AS t(days);

WITH x AS (
    SELECT *
    FROM (VALUES (100), (200), (300)) AS t(days)
)
SELECT dayname(dateadd(day, days, current_date())) day_of_week, DAY_NAME_ON(days) udf_dow
FROM x

SELECT dayname(dateadd(day, days, current_date())) day_of_week, DAY_NAME_ON(days) udf_dow
FROM (VALUES (100), (200), (300)) AS t(days);



-- JavaScript UDF to return the name of the day of the week on a date in the future
CREATE OR REPLACE FUNCTION JS_DAY_NAME_ON(num_of_days float)
RETURNS STRING
LANGUAGE JAVASCRIPT
  AS
  $$
    const weekday = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
    
    const date = new Date();
    date.setDate(date.getDate() + NUM_OF_DAYS);
    let day = weekday[date.getDay()];
    
    var result = 'In ' + NUM_OF_DAYS + ' days it will be a '+ day; 
   
    return result;
  $$;

-- Use the JavaScript UDF as part of a query. 
SELECT JS_DAY_NAME_ON(100);

SELECT dayname(dateadd(day, days, current_date())) day_of_week, JS_DAY_NAME_ON(days) js_udf_dow
FROM (VALUES (100), (200), (300)) AS t(days);


  
-- Overloading JavaScript UDF (all UDF languages can be overloaded)
CREATE OR REPLACE FUNCTION JS_DAY_NAME_ON(num_of_days float, is_abbr boolean)
RETURNS STRING
LANGUAGE JAVASCRIPT
  AS
  $$
    if (IS_ABBR === 1){
        var weekday = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
    } else {
        var weekday = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
    }    
    
    const date = new Date();
    date.setDate(date.getDate() + NUM_OF_DAYS);
    
    
    let day = weekday[date.getDay()];
    
    var result = 'In ' + NUM_OF_DAYS + ' days it will be a '+ day; 
   
    return result;
  $$;


-- Use the JavaScript UDF as part of a query. 
SELECT JS_DAY_NAME_ON(100,TRUE);
SELECT JS_DAY_NAME_ON(100,FALSE);


SELECT dayname(dateadd(day, days, current_date())) day_of_week, JS_DAY_NAME_ON(days, use_abbr) udf_dow
FROM (VALUES (100, TRUE), (200, TRUE), (300, TRUE)) AS t(days, use_abbr);


SET use_abbr = TRUE;

SELECT JS_DAY_NAME_ON(days, $use_abbr) js_udf_dow, JS_DAY_NAME_ON(days) udf_dow
FROM (VALUES (100), (200), (300)) AS t(days);


-- External Function (not going to work, but rather give you an idea how it may work)
/* 
    
CREATE OR REPLACE API INTEGRATION demonstration_external_api_integration_01
    API_PROVIDER=aws_api_gateway
    API_AWS_ROLE_ARN='arn:aws:iam::123456789012:role/my_cloud_account_role'
    API_ALLOWED_PREFIXES=('https://xyz.execute-api.us-west-2.amazonaws.com/production')
    ENABLED=true;

CREATE OR REPLACE EXTERNAL FUNCTION local_echo(string_col varchar)
    RETURNS variant
    API_INTEGRATION = demonstration_external_api_integration_01 -- API Integration object
    AS 'https://xyz.execute-api.us-west-2.amazonaws.com/production/remote_echo'; -- Proxy service URL

SELECT my_external_function(34, 56);
*/

-- Stored procedure JavaScript

-- Create demo tables and insert data to test procedure
CREATE TABLE DEMO_TABLE1 IF NOT EXISTS
(
NAME STRING, 
AGE INT
);

CREATE OR REPLACE TABLE DEMO_TABLE2 
(
NAME STRING, 
AGE INT
);

    
INSERT INTO DEMO_TABLE1 VALUES ('Joe',51),('Tom',33),('Clark',52),('Ruth',40),('Lora',23),('Ken',29);
INSERT INTO DEMO_TABLE2 VALUES ('Joe',51),('Tom',33),('Clark',52),('Ruth',40),('Lora',23),('Ken',29);

SELECT COUNT(*) FROM DEMO_TABLE1;
SELECT COUNT(*) FROM DEMO_TABLE2;

SHOW TABLES IN demo_schema;
SHOW TABLES IN demo_db.demo_schema;


CREATE OR REPLACE PROCEDURE TRUNCATE_ALL_TABLES_IN_SCHEMA(DATABASE_NAME STRING, SCHEMA_NAME STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
    EXECUTE AS OWNER -- can also be executed as 'caller'
    AS
    $$
    var result = [];
    var namespace = DATABASE_NAME + '.' + SCHEMA_NAME;
    var sql_command = 'SHOW TABLES in ' + namespace ; 
    var result_set = snowflake.execute({sqlText: sql_command});
    while (result_set.next()){
        var table_name = result_set.getColumnValue(2);
        var truncate_result = snowflake.execute({sqlText: 'TRUNCATE TABLE ' + table_name});
        result.push(namespace + '.' + table_name + ' has been sucessfully truncated.');
        
    }
    return result.join("\n"); 
    $$;


-- Calling a stored procedure cannot be used as part of a SQL statement, dissimilar to a UDF. 
CALL TRUNCATE_ALL_TABLES_IN_SCHEMA('DEMO_DB', 'DEMO_SCHEMA');

SELECT COUNT(*) FROM DEMO_TABLE1;
SELECT COUNT(*) FROM DEMO_TABLE2;


CREATE OR REPLACE FUNCTION PY_DAY_NAME_ON(num_of_days INT)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'calculate_day_name'
AS
$$
def calculate_day_name(num_of_days):
    import datetime
    from datetime import timedelta
    today = datetime.date.today()
    future_date = today + timedelta(days=num_of_days)
    day_name = future_date.strftime('%A')
    return f'In {num_of_days} days it will be a {day_name}'
$$;


SELECT PY_DAY_NAME_ON(100) PY_DOW;


SELECT dayname(dateadd(day, days, current_date())) day_of_week, JS_DAY_NAME_ON(days) js_udf_dow, PY_DAY_NAME_ON(days) py_udf_dow
FROM (VALUES (100), (200), (300)) AS t(days);


-- Clear objects
DROP DATABASE DEMO_DB;
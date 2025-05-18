/*----------------Snowflake Fundamentals 4-day class Lab:---------------------------
1) Create Warehouse
2) Create Stream
3) Create Task
4) Resumt Task
5) Check Task History
6) Suspend Task
----------------------------------------------------------------------------------*/

use role accountadmin;

-- 1. Create a Warehouse and Schema (if needed)

CREATE OR REPLACE WAREHOUSE demo_wh;

USE WAREHOUSE demo_wh;
USE SCHEMA demo_db.public;

-- 2. Create Source and Target Tables

CREATE OR REPLACE TABLE raw_sales (
  id INT,
  amount NUMBER,
  inserted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE processed_sales (
  id INT,
  amount NUMBER,
  processed_at TIMESTAMP
);

-- 3. Create a Stream on the Source Table

CREATE OR REPLACE STREAM sales_stream ON TABLE raw_sales;

-- 4. Create a Task to Process New Inserts

CREATE OR REPLACE TASK task_process_sales
  WAREHOUSE = demo_wh
  SCHEDULE = '1 MINUTE'
AS
  INSERT INTO processed_sales (id, amount, processed_at)
  SELECT id, amount, CURRENT_TIMESTAMP()
  FROM sales_stream
  WHERE METADATA$ACTION = 'INSERT';

-- 5. Activate the Task

ALTER TASK task_process_sales RESUME;

-- 6. Insert Sample Data

INSERT INTO raw_sales (id, amount) VALUES (1, 100), (2, 250);

-- Wait about a minute ⏳, then check:

SELECT * FROM processed_sales;

INSERT INTO raw_sales (id, amount) VALUES (3, 300), (4, 250);

-- Wait about a minute ⏳, then check:

SELECT * FROM processed_sales;

-- 7. Check the Task’s History

SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(TASK_NAME => 'TASK_PROCESS_SALES'))
ORDER BY SCHEDULED_TIME DESC
LIMIT 5;

SHOW TASKS;

--8. Suspend the task:

ALTER TASK task_process_sales SUSPEND;

SHOW TASKS; -- state=suspended

-- 9. Drop the task:

DROP TASK task_process_sales;


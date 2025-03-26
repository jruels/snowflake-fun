/*----------------Snowflake Fundamentals 4-day class Lab:---------------------------
1) Custom Role  
2) Streams
3) Dynamic SQL for role granting
4) Anonymous block
5) execute immediate statement
----------------------------------------------------------------------------------*/

use role accountadmin;

-- Create a dedicated role 

CREATE OR REPLACE ROLE stream_demo_role;

-- Grant privileges on a database/schema to the new role:

GRANT USAGE ON DATABASE demo_db TO ROLE stream_demo_role;

GRANT USAGE, CREATE TABLE, CREATE STREAM ON SCHEMA demo_db.public 
TO ROLE stream_demo_role;

-- For existing tables
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA demo_db.public
TO ROLE stream_demo_role;

-- For future tables
GRANT SELECT, INSERT, UPDATE, DELETE
ON FUTURE TABLES IN SCHEMA demo_db.public
TO ROLE stream_demo_role;

-- Grant privileges on the warehouse:
GRANT ALL ON WAREHOUSE compute_wh TO ROLE stream_demo_role;


--Grant newly created role to the current user:
DECLARE
    current_user_name STRING := CURRENT_USER();
BEGIN
    EXECUTE IMMEDIATE 'GRANT ROLE stream_demo_role TO USER "' || current_user_name || '"';
END;

--Verify if the new role has been granted to the current user:

-- ⚠️ This view can lag by up to 90 minutes, so not ideal for immediate feedback.
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE ROLE = 'STREAM_DEMO_ROLE';

-- This should show which user got the new role granted
SHOW GRANTS OF ROLE STREAM_DEMO_ROLE;


-- Switch to the role

USE ROLE stream_demo_role;
USE DATABASE demo_db;
USE SCHEMA public;

-------------------------------------------------------------------------------
-- Demo 1: Basic Stream on a Table

-- Step 1: Create Base Table

CREATE OR REPLACE TABLE products (
    id INT,
    name STRING,
    price NUMBER
);

-- Step 2: Make initial insert:
INSERT INTO products VALUES (1, 'Socks', 9.99), (2, 'Shirt', 19.99);

-- Step 3: Create a Stream
CREATE OR REPLACE STREAM product_stream ON TABLE products;

-- Step 4: Make Some Changes
UPDATE products SET price = 8.99 WHERE id = 1;

DELETE FROM products
WHERE id = 2;

-- Step 5: Query the Stream
SELECT * FROM product_stream;

-------------------------------------------------------------------------------
-- Demo 2: Using Stream in ETL (Insert-Only Table)

CREATE OR REPLACE TABLE sales_raw (
    id INT, amount NUMBER
);

CREATE OR REPLACE TABLE sales_cleaned (
    id INT, amount NUMBER
);

-- Create Append-Only Stream
CREATE OR REPLACE STREAM sales_stream ON TABLE sales_raw;


--Insert Raw Data
INSERT INTO sales_raw VALUES (1, 100), (2, 200), (3, 300);

-- Check the stream
SELECT *
FROM sales_stream;

--ETL Step Using Stream
INSERT INTO sales_cleaned
SELECT id, amount
FROM sales_stream;
WHERE METADATA$ACTION = 'INSERT';

-- Check the stream again
SELECT *
FROM sales_stream;

-------------------------------------------------------------------------------
-- Demo 3: Stream with MERGE (Upserts)

-- Base and Target
CREATE OR REPLACE TABLE customer_src (
    id INT, name STRING
);

CREATE OR REPLACE TABLE customer_dim (
    id INT, name STRING
);

-- Create a Stream
CREATE OR REPLACE STREAM customer_stream ON TABLE customer_src;

-- Insert + Update
INSERT INTO customer_src VALUES (1, 'Alice'), (2, 'Bob');
UPDATE customer_src SET name = 'Bobby' WHERE id = 2;

-- Check the stream:
SELECT *
FROM customer_stream;

-- Merge Using Stream:
MERGE INTO customer_dim t
USING customer_stream s
  ON t.id = s.id
WHEN MATCHED THEN UPDATE SET name = s.name
WHEN NOT MATCHED THEN INSERT (id, name) VALUES (s.id, s.name);

-- Check the target:
SELECT *
FROM customer_dim

-- Check the stream:
SELECT *
FROM customer_stream;

-------------------------------------
SHOW streams

use role accountadmin;

SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
WHERE ROLE = 'STREAM_DEMO_ROLE';



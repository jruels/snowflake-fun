/*----------------Snowflake Fundamentals 3-day class Lab:---------------------------
1) Stage types
2) Listing staged data files
3) PUT command
4) Querying staged data files
5) Removing staged data files
----------------------------------------------------------------------------------*/

--Set context
USE ROLE SYSADMIN;

CREATE DATABASE MOVIES_DB;
CREATE SCHEMA MOVIES_SCHEMA;

CREATE OR REPLACE TABLE MOVIES
(
ID INT, 
TITLE STRING, 
RELEASE_DATE DATE
);

-- INTERNAL STAGES
-- list contents of user stage (contains worksheet data)
ls @~;
list @~;

-- list contents of table stage 
ls @%MOVIES; 

-- Create internal named stage
CREATE STAGE MOVIES_STAGE;

-- list contents of internal named stage 
ls @MOVIES_STAGE;

  
-- PUT command (execute from within SnowSQL)
USE ROLE SYSADMIN;
USE DATABASE MOVIES_DB;
USE SCHEMA MOVIES_SCHEMA;

--Execute in snowsql: Make sure the path does not contain a space character
PUT file://C:\Personal\Training\movies.csv @~ auto_compress=false;
PUT file://C:\Personal\Training\movies.csv @%MOVIES auto_compress=false;
PUT file://C:\Personal\Training\movies.csv @MOVIES_STAGE auto_compress=false;


ls @~/movies.csv;

ls @%MOVIES; 

ls @MOVIES_STAGE;


-- Contents of a stage can be queried
SELECT $1, $2, $3 FROM @~/movies.csv;

-- Create csv file format to parse files in stage
CREATE FILE FORMAT CSV_FILE_FORMAT
  TYPE = CSV
  SKIP_HEADER = 1;

-- Metadata columns and file format
SELECT metadata$filename, metadata$file_row_number, $1, $2, $3 FROM @%MOVIES (file_format => 'CSV_FILE_FORMAT');
-- Pattern
SELECT metadata$filename, metadata$file_row_number, $1, $2, $3 FROM @MOVIES_STAGE (file_format => 'CSV_FILE_FORMAT', pattern=>'.*[.]csv') t;
-- Path
SELECT metadata$filename, metadata$file_row_number, $1, $2, $3 FROM @~/movies.csv (file_format => 'CSV_FILE_FORMAT') t;

-- Remove file from stage
rm @~/movies.csv;
rm @%MOVIES; 
rm @MOVIES_STAGE;
-- remove @~/movies.csv;
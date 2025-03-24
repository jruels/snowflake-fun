/*----------------Snowflake Fundamentals 3-day class Lab:---------------------------
1) Creating a Database
2) Schemas
3) Using External Stages
----------------------------------------------------------------------------------*/

use role sysadmin;

create database Citibike;

create or replace table trips  
(tripduration integer,
  starttime timestamp,
  stoptime timestamp,
  start_station_id integer,
  start_station_name string,
  start_station_latitude float,
  start_station_longitude float,
  end_station_id integer,
  end_station_name string,
  end_station_latitude float,
  end_station_longitude float,
  bikeid integer,
  membership_type string,
  usertype string,
  birth_year integer,
  gender integer);


use database citibike;
use schema public;

--CREATE STAGE citibike_trips URL = 's3://snowflake-workshop-lab/citibike-trips';

CREATE OR REPLACE STAGE citibike_trips URL = 's3://snowflake-workshop-lab/japan/citibike-trips';
list @CITIBIKE_TRIPS;

SET id = (SELECT last_query_id())

SELECT *
FROM table(result_scan($id))
WHERE "name" LIKE '%citibike%'
LIMIT 10


CREATE OR REPLACE FILE FORMAT csv
  TYPE = CSV
  FIELD_DELIMITER = ','
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
  EMPTY_FIELD_AS_NULL = TRUE
  SKIP_HEADER = 1;

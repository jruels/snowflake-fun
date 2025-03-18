/* *********************************************************************************** */
/* This SQL file is for testing and debugging external loads with failed Snowpipe                      */
/* *********************************************************************************** */
--drop database citibike;
--Set context
use role accountadmin;
create or replace warehouse pipe_wh with warehouse_size = 'medium' warehouse_type = 'standard' auto_suspend = 120 auto_resume = true;
use warehouse pipe_wh;
create database if not exists citibike;
use schema citibike.public;

--create trips table to load data from pipe
create or replace table trips_stream 
(tripduration integer,
  starttime timestamp,
  stoptime timestamp,
  start_station_id integer,
  end_station_id integer,
  bikeid integer,
  usertype string,
  birth_year integer,
  gender integer,
  program_id integer);

--create stage for trips
create or replace stage pipe_data_trips url = 's3://snowflake-workshop-lab/snowpipe/trips' file_format=(type=csv);

list @pipe_data_trips;

-- create the trips pipe using SNS topic
create or replace pipe trips_pipe auto_ingest=true 
aws_sns_topic='arn:aws:sns:us-east-1:484577546576:snowpipe_sns_lab' 
as copy into trips_stream from @pipe_data_trips;

show pipes;

--check trips pipe status
select system$pipe_status('trips_pipe');

-- show the files that have been processed
select *
from table(information_schema.copy_history(table_name=>'TRIPS_STREAM', start_time=>dateadd('hour', -1, CURRENT_TIMESTAMP())));

-- show the data landing in the table
select count(*) from trips_stream;

-- if we don't have entries we can debug trying to use the copy into directly from the external stage without the SNS Topic notifications

-- create the trips pipe using SNS topic
create or replace pipe trips_pipe auto_ingest=true 
as copy into trips_stream from @pipe_data_trips;

-- see if we have copy history now

select *
from table(information_schema.copy_history(table_name=>'TRIPS_STREAM', start_time=>dateadd('hour', -1, CURRENT_TIMESTAMP())));

-- show the data landing in the table on our revision for the pipe 
select count(*) from trips_stream;

-- if we still don't have entries we may have an issue with the access through the pipe to the stage without the required notifications
-- load the data without the pipe 

COPY INTO trips_stream from @pipe_data_trips;

== We'll see an error as noted here if we remap the folder to the wrong file by accident and this portion debugs loading from citibike-trips external stage to the wrong table definition
--Number of columns in file (16) does not match that of the corresponding table (10), use file format option error_on_column_count_mismatch=false to ignore this error
-- Add the option to ignore the error
--create stage for trips
--create or replace stage pipe_data_trips url = 's3://snowflake-workshop-lab/citibike-trips-csv/' file_format=(type=csv, error_on_column_count_mismatch=false);
--COPY INTO trips_stream from @pipe_data_trips ;

--create or replace stage pipe_data_trips url = 's3://snowflake-workshop-lab/citibike-trips-csv/' file_format=(type=csv, error_on_column_count_mismatch=false,FIELD_OPTIONALLY_ENCLOSED_BY='"');

--COPY INTO trips_stream from @pipe_data_trips ;

-- if we still have issues we may just want to skip misformatted data rows

--COPY INTO trips_stream from @pipe_data_trips ON_ERROR=CONTINUE;

select count(*) from trips_stream;
select * from trips_stream limit 5;

-- we can write complex SQL to analyze the data as new files
-- are getting loaded automatically via Snowpipe

-- what are the most popular cycle routes and how long do they take?
select start_station_id, end_station_id,
    count(1) num_trips,
    avg(datediff("minute", starttime, stoptime))::integer avg_duration_mins
  from trips_stream
  group by 1, 2
  order by 3 desc;
  
-- create some simple data masking policies to obscure PII data from developers
--only works on ENTERPRISE accounts & above
create or replace masking policy simple_mask_string as
  (val string) returns string ->
  case
    when current_role() in ('ACCOUNTADMIN') then val
      else '*** masked ***'
    end;

create or replace masking policy simple_mask_int as
  (val integer) returns integer ->
  case
    when current_role() in ('ACCOUNTADMIN') then val
      else -999
    end;


-- apply them to TRIPS table to protect our PII data
alter table trips_stream modify column bikeid set masking policy simple_mask_int;
alter table trips_stream modify column birth_year set masking policy simple_mask_int;
alter table trips_stream modify column gender set masking policy simple_mask_int;
alter table trips_stream modify column usertype set masking policy simple_mask_string;


-- data is now secure from developers but available to ACCOUNTADMIN
select * from trips_stream limit 200;

-- grant explicit permissions to SYSADMIN on the environment
grant all on warehouse pipe_wh to role sysadmin;
grant all on database citibike to role sysadmin;
grant all on all schemas in database citibike to role sysadmin;
grant all on all tables in database citibike to role sysadmin;

-- switch role to SYSADMIN now
use role sysadmin;

-- notice that for SYSADMIN role, the 4 columns(BIKEID, USERTYPE, BIRTH_YEAR, GENDER) are masked
select * from trips_stream limit 200;

use role accountadmin;

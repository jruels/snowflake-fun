/*----------------Snowflake Fundamentals 3-day class Lab:---------------------------
1) Copy Into Command
2) ON_ERROR attribute
3) PATTERN attribute
----------------------------------------------------------------------------------*/

use database citibike;
use schema public;

-- this will not work since there are JSON files mingled in with the CSV now in our stage
copy into trips from @citibike_trips
file_format=CSV;

--by adding a pattern we'll be able to load our CSV, ignoring the JSON (or other file formats) and skippin errors
copy into trips from @citibike_trips
file_format=CSV
ON_ERROR=CONTINUE
PATTERN='.*[.]csv.gz';

SET id = (SELECT last_query_id())

SELECT * FROM TABLE(VALIDATE(trips, JOB_ID => $id));

CREATE TABLE trips_load_errors AS
SELECT * FROM TABLE(VALIDATE(trips, JOB_ID => $id));

SELECT *
FROM trips_load_errors
LIMIT 10;

SELECT *
FROM trips
LIMIT 10;

copy into trips from @citibike_trips
file_format=CSV
ON_ERROR=CONTINUE
PATTERN='.*[.]csv.gz';

TRUNCATE TABLE trips;

CREATE OR REPLACE FILE FORMAT csv
  TYPE = CSV
  FIELD_DELIMITER = ','
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
  EMPTY_FIELD_AS_NULL = TRUE
  SKIP_HEADER = 1
  NULL_IF = (''); -- THIS ATTRIBUTE MADE THE DIFFERENCE!

copy into trips from @citibike_trips
file_format=CSV
ON_ERROR=CONTINUE
PATTERN='.*[.]csv.gz';

SET id = (SELECT last_query_id());

SELECT * FROM TABLE(VALIDATE(trips, JOB_ID => $id));



/*----------------Snowflake Fundamentals 4-day class Lab:---------------------------
1) Reading data files from external stages
2) Secure Views
3) Variant Column
4) External Table based on mutliple files in External Stage
5) Materialized View on External Table
----------------------------------------------------------------------------------*/

--We can review the data before importing it:

use role accountadmin;

create database if not exists weather;
use database weather;
use schema public;

-- We will have to use a file format object, inline definition only works with "COPY INTO" and "CREATE STAGE" commands
CREATE OR REPLACE FILE FORMAT json_format
TYPE = 'JSON';

SELECT metadata$filename, metadata$file_row_number, $1 as json_data
FROM @nyc_weather (file_format => 'json_format')
LIMIT 10;

SELECT metadata$filename as filename, metadata$file_row_number as rnum, TO_VARIANT($1) as json_data
FROM @nyc_weather (file_format => 'json_format')
LIMIT 10;

----------------------------------------------------------------------------------------
-- SECURE View Demo:
create or replace SECURE view vw_weather as
SELECT metadata$filename as filename, metadata$file_row_number as rnum, TO_VARIANT($1) as v
FROM @nyc_weather (file_format => 'json_format');

select
  v:time::timestamp as observation_time,  
  v:city.id::int as city_id,
  v:city.name::string as city_name,
  v:city.country::string as country,
  v:city.coord.lat::float as city_lat,
  v:city.coord.lon::float as city_lon,
  v:clouds.all::int as clouds,
  (v:main.temp::float)-273.15 as temp_avg,
  (v:main.temp_min::float)-273.15 as temp_min,
  (v:main.temp_max::float)-273.15 as temp_max,
  v:weather[0].main::string as weather,
  v:weather[0].description::string as weather_desc,
  v:weather[0].icon::string as weather_icon,
  v:wind.deg::float as wind_dir,
  v:wind.speed::float as wind_speed
from vw_weather
where city_id = 5128638
LIMIT 10;

DESC VIEW vw_weather;
SHOW VIEWS LIKE 'VW_WEATHER';

SELECT GET_DDL('VIEW', 'WEATHER.PUBLIC.VW_WEATHER');

GRANT SELECT ON VIEW vw_weather TO ROLE sysadmin;

use role sysadmin;

DESC VIEW vw_weather;
SHOW VIEWS LIKE 'VW_WEATHER';

SELECT GET_DDL('VIEW', 'WEATHER.PUBLIC.VW_WEATHER');

--------------------------------------------------------------------
CREATE OR REPLACE EXTERNAL TABLE ext_nyc_weather (
    v VARIANT AS ($1)  -- ← defining expression
)
WITH LOCATION = @nyc_weather
FILE_FORMAT = (FORMAT_NAME = 'json_format')
AUTO_REFRESH = TRUE;

ALTER TABLE ext_nyc_weather RENAME TO ext_weather;

select
  v:time::timestamp as observation_time,  
  v:city.id::int as city_id,
  v:city.name::string as city_name,
  v:city.country::string as country,
  v:city.coord.lat::float as city_lat,
  v:city.coord.lon::float as city_lon,
  v:clouds.all::int as clouds,
  (v:main.temp::float)-273.15 as temp_avg,
  (v:main.temp_min::float)-273.15 as temp_min,
  (v:main.temp_max::float)-273.15 as temp_max,
  v:weather[0].main::string as weather,
  v:weather[0].description::string as weather_desc,
  v:weather[0].icon::string as weather_icon,
  v:wind.deg::float as wind_dir,
  v:wind.speed::float as wind_speed
from ext_weather
where city_id = 5128638
LIMIT 10;


CREATE OR REPLACE MATERIALIZED VIEW mv_nyc_weather AS
select
  v:time::timestamp as observation_time,  
  v:city.id::int as city_id,
  v:city.name::string as city_name,
  v:city.country::string as country,
  v:city.coord.lat::float as city_lat,
  v:city.coord.lon::float as city_lon,
  v:clouds.all::int as clouds,
  (v:main.temp::float)-273.15 as temp_avg,
  (v:main.temp_min::float)-273.15 as temp_min,
  (v:main.temp_max::float)-273.15 as temp_max,
  v:weather[0].main::string as weather,
  v:weather[0].description::string as weather_desc,
  v:weather[0].icon::string as weather_icon,
  v:wind.deg::float as wind_dir,
  v:wind.speed::float as wind_speed
from ext_weather
where city_id = 5128638;


SELECT *
FROM mv_nyc_weather
LIMIT 10;

-- ALTER MATERIALIZED VIEW mv_nyc_weather REFRESH;

SHOW MATERIALIZED VIEWS LIKE 'MV_NYC_WEATHER';

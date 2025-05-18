/*----------------Snowflake Fundamentals 4-day class Lab:---------------------------
1) Data Wrangling
2) Storing JSON data
3) Querying JSON data
----------------------------------------------------------------------------------*/

use role accountadmin;
drop database if exists weather;

grant all on warehouse compute_wh to sysadmin;


use role sysadmin;
use warehouse compute_wh;


create database if not exists weather;
use database weather;
use schema public;


create table json_weather_data (v variant);


create stage nyc_weather
url = 's3://snowflake-workshop-lab/weather-nyc';



list @nyc_weather;



copy into json_weather_data 
from @nyc_weather 
file_format = (type=json);


select * from json_weather_data limit 10;


create view json_weather_data_view as
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
from json_weather_data
where city_id = 5128638;


select * from json_weather_data_view
where date_trunc('month',observation_time) = '2018-01-01' 
limit 20;


select weather as conditions
    ,count(*) as num_trips
from citibike.public.trips 
left outer join json_weather_data_view
    on date_trunc('hour', observation_time) = date_trunc('hour', starttime)
where conditions is not null
group by 1 order by 2 desc;

-- Cleanup (optional)
drop database if exists weather;

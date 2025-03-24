/*----------------Snowflake Fundamentals 3-day class Lab:---------------------------
1) STORED PROCEDURES with returned value
2) last_query_id function
3) result_scan function
4) TABLE function
----------------------------------------------------------------------------------*/

CREATE OR REPLACE PROCEDURE concat_strings(S1 STRING, S2 STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
    EXECUTE AS OWNER -- can also be executed as 'caller'
    AS
    $$
        var result = S1 + S2;
        return  result;
    $$;
    

CALL concat_strings('abc-', 'xyz');

SET qid = (SELECT last_query_id())

SELECT *
FROM TABLE(result_scan($qid))

SET result = (SELECT concat_strings FROM TABLE(result_scan($qid)))

SELECT $result

CALL concat_strings($result, '-ddd')


CALL concat_strings('abc-', 'xyz');
SET result = (SELECT concat_strings FROM TABLE(result_scan(last_query_id())));
CALL concat_strings($result, '-ddd');


SELECT $1
FROM TABLE(result_scan($qid))


CALL concat_strings('abc-', 'xyz');
SET result = (SELECT $1 FROM TABLE(result_scan(last_query_id())));
CALL concat_strings($result, '-ddd');



SELECT $1, $2
FROM CITIBIKE.PUBLIC.TRIPS
LIMIT 10


SELECT *
FROM CITIBIKE.PUBLIC.TRIPS
LIMIT 10
-- 19. Generate a list of integer values from 1 to 10


--Strategy #1:


SELECT ROW_NUMBER() OVER(ORDER BY 1) value, 1+seq1() value2
FROM TABLE(generator(ROWCOUNT=>10))


--Strategy #2:

SELECT LEVEL value
FROM dual
CONNECT BY NVL(PRIOR COLUMN1,0)=NVL(COLUMN1,0)
LIMIT 10


--Strategy #3:

WITH x (value) AS (
SELECT 1
UNION ALL
SELECT value + 1
FROM x
WHERE x.value < 10
)
SELECT *
FROM x


-- 21. Generate a list of 10 random Integers from the range between 20 and 50

--Strategy #1:


SELECT uniform(20::int, 50::int, random()) rnd
FROM TABLE(generator(ROWCOUNT=>10))


--Strategy #2:

SELECT uniform(20::int, 50::int, random()) rnd
FROM dual
CONNECT BY NVL(PRIOR COLUMN1,0)=NVL(COLUMN1,0)
LIMIT 10


--Strategy #3:


WITH x (value) AS (
SELECT 1
UNION ALL
SELECT value + 1
FROM x
WHERE x.value < 10
)
SELECT uniform(20::int, 50::int, random()) rnd
FROM x


WITH x (value, rnd) AS (
SELECT 1, uniform(20::int, 50::int, random())
UNION ALL
SELECT value + 1, uniform(20::int, 50::int, random())
FROM x
WHERE x.value < 10
)
SELECT rnd
FROM x


--22. Generate a list of 10 random character strings of 5 characters long each

--Strategy #1:

SELECT UPPER(randstr(5, random())) random_str
FROM TABLE(generator(ROWCOUNT=>10))


--Strategy #2:

SELECT UPPER(randstr(5, random())) random_str
FROM dual
CONNECT BY NVL(PRIOR COLUMN1,0)=NVL(COLUMN1,0)
LIMIT 10

--Strategy #3:

WITH x (value) AS (
SELECT 1
UNION ALL
SELECT value + 1
FROM x
WHERE x.value < 10
)
SELECT UPPER(randstr(5, random())) random_str
FROM x


WITH x (value, random_str) AS (
SELECT 1, UPPER(randstr(5, random()))
UNION ALL
SELECT value + 1, UPPER(randstr(5, random()))
FROM x
WHERE x.value < 10
)
SELECT random_str
FROM x


--25. Generate a list of dates from current day till the end of the week

--Strategy #1:

SELECT CURRENT_DATE() + ROW_NUMBER() OVER(ORDER BY 1) - 1 "date",
       TO_CHAR("date", 'Dy') "day"
FROM TABLE(generator(ROWCOUNT=>10))


SELECT LAST_DAY(CURRENT_DATE, WEEK) eow, 
       DAY(eow) lastday,
       DAY(CURRENT_DATE) today,
       lastday - today + 1 daysleft


SELECT CURRENT_DATE() + ROW_NUMBER() OVER(ORDER BY 1) - 1 "date",
       TO_CHAR("date", 'Dy') "day"
FROM TABLE(generator(ROWCOUNT=>DAY(LAST_DAY(CURRENT_DATE, WEEK)) - DAY(CURRENT_DATE) + 1))

WITH d AS (
SELECT CURRENT_DATE() + ROW_NUMBER() OVER(ORDER BY 1) - 1 "date",
       TO_CHAR("date", 'Dy') "day"
FROM TABLE(generator(ROWCOUNT=>7))
)
SELECT "date", "day"
FROM d
WHERE DATE_TRUNC(WEEK, "date") = DATE_TRUNC(WEEK, CURRENT_DATE)


--Strategy #2:

 
SELECT "date", TO_CHAR("date", 'Dy') "day"
FROM (
    SELECT DATEADD(DAY, LEVEL-1, CURRENT_DATE) "date"
    FROM dual
    CONNECT BY NVL(PRIOR COLUMN1,0)=NVL(COLUMN1,0)
    LIMIT 7
)
WHERE DATE_TRUNC(WEEK, "date") = DATE_TRUNC(WEEK, CURRENT_DATE)


--Strategy #3:

WITH x ("date") AS (
    SELECT CURRENT_DATE
    UNION ALL
    SELECT "date" + 1
    FROM x
    WHERE TRUNC("date" + 1, 'WEEK') = TRUNC(CURRENT_DATE, 'WEEK')
)
SELECT "date", TO_CHAR("date", 'Dy') "day"
FROM x


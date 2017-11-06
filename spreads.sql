SET work_mem='3GB';

WITH spreads AS (
    SELECT permno, date, 100*(ask-bid)/((bid+ask)/2) AS spread
    FROM crsp.dsf
    WHERE bid IS NOT NULL AND ask IS NOT NULL and date >= '1990-01-01')

SELECT permno, 
    extract(year FROM date)::integer AS year,
    extract(quarter FROM date)::integer AS quarter,
    avg(spread) AS spread
FROM spreads
GROUP BY 1, 2, 3;
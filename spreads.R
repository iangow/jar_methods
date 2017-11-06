sql <- "
    WITH spreads AS (
        SELECT permno, date, 100*(ask-bid)/((bid+ask)/2) AS spread
        FROM crsp.dsf
        WHERE bid IS NOT NULL AND ask IS NOT NULL and date >= '1990-01-01')
    
    SELECT permno, 
        extract(year FROM date)::integer AS year,
        extract(quarter FROM date)::integer AS quarter,
        avg(spread) AS spread
    FROM spreads
    GROUP BY 1, 2, 3"

library(dplyr)
pg <- src_postgres()

rs <- RPostgreSQL::dbGetQuery(pg$con, "SET work_mem='3GB'")

spreads <- tbl(pg, sql(sql)) %>%
    collect() # compute() 

spreads %>% 
    group_by(year, quarter) %>%
    summarize(mean(spread)) %>%
    collect() %>%
    arrange(year, desc(quarter))

spreads$treat <- FALSE
spreads$treat[sample.int(nrow(spreads), 100)] <- TRUE
table(spreads$treat)


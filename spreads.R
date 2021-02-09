library(dplyr, warn.conflicts = FALSE)
library(DBI)

pg <- dbConnect(RPostgres::Postgres())

rs <- dbExecute(pg, "SET work_mem='10GB'")
rs <- dbExecute(pg, "SET search_path TO crsp")

dsf <- tbl(pg, "dsf")

spreads <- 
    dsf %>%
    filter(!is.na(bid), !is.na(ask), date >= '1990-01-01') %>%
    mutate(spread =  100*(ask-bid)/((bid+ask)/2),
           year = as.integer(date_part('year', date)),
           quarter = as.integer(date_part('quarter', date))) %>%
    group_by(permno, year, quarter) %>%
    summarize(spread = mean(spread, na.rm = TRUE)) %>%
    collect()

spreads %>% 
    group_by(year, quarter) %>%
    summarize(mean(spread)) %>%
    collect() %>%
    arrange(year, desc(quarter))

spreads$treat <- FALSE
spreads$treat[sample.int(nrow(spreads), 100)] <- TRUE
table(spreads$treat)

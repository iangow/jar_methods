getSheetData = function(key, gid=NULL) {
    library(RCurl)
    url <- paste0("https://docs.google.com/spreadsheets/d/", key,
                  "/export?format=csv&id=", key, if (is.null(gid)) "" else paste0("&gid=", gid),
                  "&single=true")
    csv_file <- getURL(url, verbose=FALSE)
    the_data <- read.csv(textConnection(csv_file), as.is=TRUE)
    return( the_data )
}

key <- "1kegEFabLl5itVNCl-7SQyKxdKXfwLa9ZIs9LDEOjVWY"
gid <- 434924778

acct_2014 <- getSheetData(key, gid)
names(acct_2014) <- gsub("\\.", "", names(acct_2014))
acct_2014$causal_question_primary <- as.logical(acct_2014$causal_question_primary)
acct_2014$causal_question_secondary <- as.logical(acct_2014$causal_question_secondary)
acct_2014$causal_question <- 
    with(acct_2014, 
         ifelse(!causal_question_primary, causal_question_secondary, causal_question_primary))
with(subset(acct_2014, paper_type=="original" & category=="empirical"), 
     table(causal_question_primary, causal_question_secondary, useNA="ifany"))

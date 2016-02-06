
library(dplyr)

# Construct sample of people
n <- 10000L
type <- sample(c("A", "B", "C"), size = n, replace = TRUE)
base_salary <- runif(n=n, min=20000, max=50000)
id <- 1:n
people <- data_frame(type, base_salary, id)

# Construct educ table (maps type and age to degree indicator)
educ <- expand.grid(age = 21:30L, type=c("A", "B", "C"),
                    stringsAsFactors = FALSE)
educ <- as_data_frame(educ)
educ <- within(educ,
               degree <- ifelse(type=="A", TRUE, 
                      ifelse(type=="B" & age > 25, TRUE, FALSE))) 

# Make a data set with salaries and salary demeaned by ID
df <-
    people %>% 
    inner_join(educ) %>%
    mutate(salary = base_salary + 
               ifelse(type=="A" & degree, 20000,
                      ifelse(type=="B" & degree, 4000, 0))) %>%
    group_by(id) %>% 
    mutate(mean_sal = mean(salary), salary_alt = salary - mean_sal) %>%
    arrange(id, age)

summary(lm(salary_alt ~ degree, data=df))
summary(lm(salary_alt ~ degree, data=df, subset=type=="B"))

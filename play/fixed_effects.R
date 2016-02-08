
library(dplyr)

# Construct sample of people
n <- 10000L
types <- c("A", "B", "C")

type <- sample(types, size = n, replace = TRUE)
base_salary <- runif(n=n, min=20000, max=50000)
id <- 1:n
people <- data_frame(type, base_salary, id)

# Construct educ table (maps type and age to degree indicator)
educ <- expand.grid(age = 21:30L, type=types,
                    stringsAsFactors = FALSE)
educ <- as_data_frame(educ)
educ <- within(educ,
               degree <- ifelse(type=="A", TRUE, 
                      ifelse(type=="B" & age > 25, TRUE, FALSE))) 

# Make a data set with s0alaries and salary demeaned by ID
df <-
    people %>% 
    inner_join(educ) %>%
    mutate(salary = base_salary + 
               ifelse(type=="A" & degree, 20000,
                      ifelse(type=="B" & degree, 4000, 0))) %>%
    group_by(id) %>% 
    mutate(mean_sal = mean(salary), mean_deg = mean(degree),
           demean_salary = salary - mean_sal,
           demean_degree = degree - mean_deg) %>%
    arrange(id, age)

# summary(lm(salary ~ degree + factor(id), data=df))
summary(lm(demean_salary ~ demean_degree, data=df))
summary(lm(salary ~ degree, data=df))
summary(lm(salary ~ degree, data=df, subset=type!="A"))

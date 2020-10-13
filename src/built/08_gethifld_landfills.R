library(readr)
library(dplyr)


landfills = read_csv("Rivanna file path")
co_landfills = landfills %>% group_by(COUNTYFIPS) %>% count() %>% mutate(landfills = n) %>% select(-n)

# Then probably adjust per 10000 population
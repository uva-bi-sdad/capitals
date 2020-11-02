rm(list = ls())

library(tidyverse)
library(naniar)
library(readxl)
library(janitor)

# Get counties and geometries from acs
Sys.getenv("CENSUS_API_KEY")

acsdata <- get_acs(geography = "county", state = c(19, 41, 51),
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, NAME.x, ALAND, AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)

# water system violations 
water_IA <- read_csv("./rivanna_data/built/water-systems/water_system_summary_IA.csv") %>% clean_names()
water_VA <- read_csv("./rivanna_data/built/water-systems/water_system_summary_VA.csv") %>% clean_names()
water_OR <- read_csv("./rivanna_data/built/water-systems/water_system_summary_OR.csv") %>% clean_names()
water_quality <- read_csv("./rivanna_data/built/water-quality-data/water-quality-IAVAOR.csv") 

water_IA <- water_IA %>% mutate(STATEFP = 19) %>% 
  rename("NAME.x" = "counties_served") %>% group_by(NAME.x) %>% 
  summarize(water_pop_served = sum(population_served_count),
            water_facs_count = sum(number_of_facilities),
            water_violations_count = sum(number_of_violations),
            water_state_visits = sum(number_of_site_visits))
water_OR <- water_OR %>% mutate(STATEFP = 41) %>% 
  rename("NAME.x" = "counties_served") %>% group_by(NAME.x) %>% 
  summarize(water_pop_served = sum(population_served_count),
            water_facs_count = sum(number_of_facilities),
            water_violations_count = sum(number_of_violations),
            water_state_visits = sum(number_of_site_visits))
water_VA <- water_VA %>% mutate(STATEFP = 51) %>% 
  rename("NAME.x" = "counties_served") %>% group_by(NAME.x) %>% 
  summarize(water_pop_served = sum(population_served_count),
            water_facs_count = sum(number_of_facilities),
            water_violations_count = sum(number_of_violations),
            water_state_visits = sum(number_of_site_visits))

left_join(acsdata, water_IA, by = c("STATEFP", "NAME.x")) %>%
  left_join(., water_OR, by = c("GEOID")) %>%
  left_join(., water_VA, by = c("GEOID")) 


# this is not done yet 




# superfund sites 
# contaminant occurences 
# brownfield sites 
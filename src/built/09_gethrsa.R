rm(list = ls())

library(tidyverse)
library(janitor)
library(tidycensus)
library(readxl)

nhsc_sites <- read_excel("./rivanna_data/built/hrsa-data/HRSA_NHSCSites.xlsx") 
hrsa_mental_health <- read_csv("./rivanna_data/built/hrsa-data/HRSA_ShortageAreas_MentalHealth.csv") %>% select(-X66)
hrsa_dental_health <- read_csv("./rivanna_data/built/hrsa-data/HRSA_ShortageAreas_DentalHealth.csv") %>% select(-X66)
hrsa_pcps <- read_csv("./rivanna_data/built/hrsa-data/HRSA_ShortageAreas_PrimaryCare.csv") %>% select(-X66)
hrsa_med_underserved <- read_csv("./rivanna_data/built/hrsa-data/HRSA_ShortageAreas_MedicallyUnderserved.csv") %>% select(-X65)

# SKIP THIS FIRST SECTION 
# first step is to check for deduplicates across datasets 

check_mental <- hrsa_mental_health %>% 
  clean_names() %>%
  filter(common_state_abbreviation %in% c("IA", "OR", "VA")) %>% 
  select(hpsa_name, hpsa_id, hpsa_geography_identification_number, common_state_abbreviation) %>% 
  mutate(dataset = "mental_health")

check_dental <- hrsa_dental_health %>% 
  clean_names() %>%
  filter(common_state_abbreviation %in% c("IA", "OR", "VA")) %>% 
  select(hpsa_name, hpsa_id, hpsa_geography_identification_number, common_state_abbreviation) %>% 
  mutate(dataset = "dental_health")

check_pcps <- hrsa_pcps %>% 
  clean_names() %>% 
  filter(common_state_abbreviation %in% c("IA", "OR", "VA")) %>% 
  select(hpsa_name, hpsa_id, hpsa_geography_identification_number, common_state_abbreviation) %>% 
  mutate(dataset = "pcp_data")

check_all <- check_mental %>% 
  bind_rows(check_dental) %>% 
  bind_rows(check_pcps)  
  
check_all %>% 
  distinct(hpsa_name, hpsa_id, hpsa_geography_identification_number, dataset) %>% 
  janitor::get_dupes()
# this shows that there are no duplicates when you account for distinct hpsa_id & hpsa_geography_identification_number


# START HERE 
# Get counties and geometries from acs
Sys.getenv("CENSUS_API_KEY")

acsdata <- get_acs(geography = "county", state = c(19, 41, 51),
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, NAME.x, ALAND, AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)
acsdata <- acsdata %>% mutate(NAME.y = str_replace_all(NAME.y, "city,", "City,"))

# join geography to nhsc data 
nhsc_data <- nhsc_sites %>% 
  clean_names() %>%
  filter(state %in% c("IA", "OR", "VA") & county != "Not Determined") %>%
  mutate(state = str_replace_all(state, "IA", "Iowa"),
         state = str_replace_all(state, "OR", "Oregon"),
         state = str_replace_all(state, "VA", "Virginia"),
         NAME.y = paste0(county,", ",state)) %>% 
  left_join(acsdata, by = "NAME.y") %>% 
  arrange(STATEFP, COUNTYFP) %>% 
  group_by(STATEFP, COUNTYFP, NAME.y) %>% 
  count() %>% rename(nhsc_facs = n)

mental_health_data <- hrsa_mental_health %>%  
  clean_names() %>%
  filter(common_state_abbreviation %in% c("IA", "OR", "VA")) %>% 
  rename(NAME.y = common_county_name, 
         state = state_name, 
         STATEFP = state_fips_code,
         GEOID = common_state_county_fips_code) %>% 
  mutate(NAME.y = str_replace_all(NAME.y, ", IA", ", Iowa"),
         NAME.y = str_replace_all(NAME.y, ", OR", ", Oregon"),
         NAME.y = str_replace_all(NAME.y, ", VA", ", Virginia")) %>% 
  select(hpsa_name, state, NAME.y, STATEFP, GEOID, everything()) %>% 
  group_by(STATEFP, GEOID, NAME.y) %>% 
  count() %>% rename(mentalhealth_facs = n) %>% 
  mutate(STATEFP = as.character(STATEFP))


dental_health_data <- hrsa_dental_health %>%  
  clean_names() %>%
  filter(common_state_abbreviation %in% c("IA", "OR", "VA")) %>% 
  rename(NAME.y = common_county_name, 
         state = state_name, 
         STATEFP = state_fips_code,
         GEOID = common_state_county_fips_code) %>% 
  mutate(NAME.y = str_replace_all(NAME.y, ", IA", ", Iowa"),
         NAME.y = str_replace_all(NAME.y, ", OR", ", Oregon"),
         NAME.y = str_replace_all(NAME.y, ", VA", ", Virginia")) %>% 
  select(hpsa_name, state, NAME.y, STATEFP, GEOID, everything()) %>% 
  group_by(STATEFP, GEOID, NAME.y) %>% 
  count() %>% rename(dental_facs = n) %>% 
  mutate(STATEFP = as.character(STATEFP),
         GEOID = as.double(GEOID))


pcp_data <- hrsa_pcps %>% 
  clean_names() %>% 
  filter(common_state_abbreviation %in% c("IA", "OR", "VA")) %>% 
  rename(NAME.y = common_county_name, 
         state = state_name, 
         STATEFP = state_fips_code,
         GEOID = common_state_county_fips_code) %>% 
  mutate(NAME.y = str_replace_all(NAME.y, ", IA", ", Iowa"),
         NAME.y = str_replace_all(NAME.y, ", OR", ", Oregon"),
         NAME.y = str_replace_all(NAME.y, ", VA", ", Virginia")) %>% 
  select(hpsa_name, state, NAME.y, STATEFP, GEOID, everything()) %>% 
  group_by(STATEFP, GEOID, NAME.y) %>% 
  count() %>% rename(pcp_facs = n) %>% 
  mutate(STATEFP = as.character(STATEFP))


data <- mental_health_data %>% 
  left_join(nhsc_data, by = c("STATEFP", "NAME.y")) %>% 
  left_join(pcp_data, by = c("STATEFP", "GEOID", "NAME.y")) %>% 
  left_join(dental_health_data, by = c("STATEFP", "GEOID", "NAME.y")) %>% 
  select(STATEFP, GEOID, NAME.y, pcp_facs, nhsc_facs, dental_facs, mentalhealth_facs) %>% 
  mutate(nhsc_facs = replace_na(nhsc_facs, 0), 
         pcp_facs = replace_na(pcp_facs, 0),
         dental_facs = replace_na(dental_facs, 0),
         GEOID = as.character(GEOID))


# write this to the data folder 
write_rds(data, "./rivanna_data/built/built_hrsa_2019.Rds")









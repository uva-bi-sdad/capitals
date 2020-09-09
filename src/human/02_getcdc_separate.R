library(naniar)
library(dplyr)
library(readxl)
library(readr)
library(janitor)
library(sf)


# read in CDC Wonder data --------------------------

#alcohol1yr <- read_delim("./rivanna_data/human/human_cdc_alcohol 2018.txt", 
#                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
#alcohol5yr <- read_delim("./rivanna_data/human/human_cdc_alcohol 2014-18.txt", 
#                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
alcohol9yr <- read_delim("./rivanna_data/human/human_cdc_alcohol 2010-18.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% 
  clean_names() %>%
  select(-notes)

#suicide1yr <- read_delim("./rivanna_data/human/human_cdc_suicide 2018.txt", 
#                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
#suicide5yr <- read_delim("./rivanna_data/human/human_cdc_suicide 2014-18.txt", 
#                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
suicide9yr <- read_delim("./rivanna_data/human/human_cdc_suicide 2010-18.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% 
   clean_names() %>%
   select(-notes)

#overdose1yr <- read_delim("./rivanna_data/human/human_cdc_overdose 2018.txt", 
#                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
#overdose5yr <- read_delim("./rivanna_data/human/human_cdc_overdose 2014-18.txt", 
#                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
overdose9yr <- read_delim("./rivanna_data/human/human_cdc_overdose 2010-18.txt", 
                          col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% 
  clean_names() %>%
  select(-notes)

all1yr <- read_delim("./rivanna_data/human/human_cdc_all 2018.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% 
  clean_names() %>% select(-notes)
all5yr <- read_delim("./rivanna_data/human/human_cdc_all 2014-18.txt", 
                     col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% 
  clean_names() %>% select(-notes)
all9yr <- read_delim("./rivanna_data/human/human_cdc_all 2010-18.txt", 
                     col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% 
  clean_names() %>% select(-notes)


# rename columns so that we can merge cdc data into one dataframe --------------------------

alcohol9yr <- alcohol9yr %>%
  rename(hum_numalcdeaths = deaths, alc_pop = population, hum_cruderatealcdeaths = crude_rate, hum_ratealcdeaths = age_adjusted_rate)

overdose9yr <- overdose9yr %>%
  rename(hum_numoverdeaths = deaths, over_pop = population, hum_cruderateoverdeaths = crude_rate, hum_rateoverdeaths = age_adjusted_rate)

suicide9yr <- suicide9yr %>%
  rename(hum_numsuideaths = deaths, sui_pop = population, hum_cruderatesuideaths = crude_rate, hum_ratesuideaths = age_adjusted_rate)


# merge into one dataframe --------------------------------------

cdc <- left_join(alcohol9yr, overdose9yr, by = c("county", "county_code"))
cdc <- left_join(cdc, suicide9yr, by = c("county", "county_code"))


# check missingness --------------------------------

miss_var_summary(cdc) # none are NA, but there will be "missing" and "suppressed"


# organize dataframe --------------------------------------------

# all population columns are the same, so only keeping one of them
# only keeping age adjusted death rates for each cause

cdc <- cdc %>%
  select(county, county_code, alc_pop, hum_ratealcdeaths, hum_rateoverdeaths, hum_ratesuideaths) %>%
  rename(pop = alc_pop,
         GEOID = county_code)

# Clean column types
cdc <- cdc %>% mutate(pop = ifelse(pop == "Missing", NA_character_, pop))
cdc$pop <- as.numeric(cdc$pop)

cdc$hum_ratealcdeaths <- as.character(cdc$hum_ratealcdeaths)
cdc$hum_rateoverdeaths <- as.character(cdc$hum_rateoverdeaths)
cdc$hum_ratesuideaths <- as.character(cdc$hum_ratesuideaths)


# add geometry data from ACS ------------------------------------

cdc$STATEFP <- substr(cdc$GEOID, 1, 2)
cdc$COUNTYFP <- substr(cdc$GEOID, 3, 5)

acs <- readRDS("./rivanna_data/human/hum_acs_2018.rds")

acs <- acs %>%
  select(STATEFP, COUNTYFP, GEOID, geometry)

# The two cities Bedford City VA: reverted to town in 2013; Clifton Forge, VA: reverted back to town in 2001
setdiff(cdc$GEOID, acs$GEOID) # "51515" "51560"
setdiff(acs$GEOID, cdc$GEOID) # 0 

cdc_geo <- left_join(acs, cdc, by = c("STATEFP", "COUNTYFP", "GEOID"))


# check missingness ----------------------------------

miss_var_summary(cdc_geo) # nothing missing, but a lot of data is suppressed

table(cdc_geo$hum_ratealcdeaths) # 20 - "Suppressed", 63 - "Unreliable"
table(cdc_geo$hum_rateoverdeaths) # 90 - "Suppressed", 51 - "Unreliable"
table(cdc_geo$hum_ratesuideaths) # 20 - "Suppressed", 63 - "Unreliable"

# Sub-national data representing fewer than ten persons (0-9) are suppressed: SUPPRESSED IS 0-9 deaths
# Rates are marked as "unreliable" when the death count is less than 20:      UNRELIABLE IS 10-20 deaths
# Crude death rates in this dataset are calculated as (deaths / population) * 100,000, over a 9 year time period!

# Recode these values to NA. 

cdc_geo <- cdc_geo %>% mutate(hum_ratealcdeaths = ifelse(hum_ratealcdeaths == "Suppressed" | hum_ratealcdeaths == "Unreliable", NA_character_, hum_ratealcdeaths),
                              hum_rateoverdeaths = ifelse(hum_rateoverdeaths == "Suppressed" | hum_rateoverdeaths == "Unreliable", NA_character_, hum_rateoverdeaths),
                              hum_ratesuideaths = ifelse(hum_ratesuideaths == "Suppressed" | hum_ratesuideaths == "Unreliable", NA_character_, hum_ratesuideaths))

# Now can convert remaining values to numeric
cdc_geo$hum_ratealcdeaths <- as.numeric(cdc_geo$hum_ratealcdeaths)
cdc_geo$hum_rateoverdeaths <- as.numeric(cdc_geo$hum_rateoverdeaths)
cdc_geo$hum_ratesuideaths <- as.numeric(cdc_geo$hum_ratesuideaths)


# write ----------------------------------

write_rds(cdc_geo, "./rivanna_data/human/hum_cdc_2018.rds")


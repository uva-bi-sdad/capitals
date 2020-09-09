library(naniar)
library(dplyr)
library(readxl)
library(readr)
library(janitor)
library(sf)


# read in CDC Wonder data --------------------------

all9yr <- read_delim("./rivanna_data/human/human_cdc_all 2010-18.txt", 
                     col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% 
  clean_names() %>% select(-notes)


# rename columns --------------------------

cdc <- all9yr %>%
  rename(hum_deaths = deaths, hum_cruderatedeaths = crude_rate, hum_ageratedeaths = age_adjusted_rate)


# check missingness --------------------------------

miss_var_summary(cdc) # none are NA, but there will be "missing" and "suppressed"


# organize dataframe --------------------------------------------

cdc <- cdc %>% rename(GEOID = county_code)

# Clean column types
cdc <- cdc %>% mutate(population = ifelse(population == "Missing", NA_character_, population))
cdc$population <- as.numeric(cdc$population)


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

table(cdc_geo$hum_ageratedeaths) # 5 - "Suppressed", 11 - "Unreliable"
table(cdc_geo$hum_cruderatedeaths) # 5 - "Suppressed", 11 - "Unreliable"
table(cdc_geo$hum_deaths) # 5 - "Suppressed"


# Sub-national data representing fewer than ten persons (0-9) are suppressed: SUPPRESSED IS 0-9 deaths
# Rates are marked as "unreliable" when the death count is less than 20:      UNRELIABLE IS 10-20 deaths
# Crude death rates in this dataset are calculated as (deaths / population) * 100,000, over a 9 year time period

# Recode these values to NA. 

cdc_geo <- cdc_geo %>% mutate(hum_deaths = ifelse(hum_deaths == "Suppressed" | hum_deaths == "Unreliable", NA_character_, hum_deaths),
                              hum_cruderatedeaths = ifelse(hum_cruderatedeaths == "Suppressed" | hum_cruderatedeaths == "Unreliable", NA_character_, hum_cruderatedeaths),
                              hum_ageratedeaths = ifelse(hum_ageratedeaths == "Suppressed" | hum_ageratedeaths == "Unreliable", NA_character_, hum_ageratedeaths))

# Now can convert remaining values to numeric
cdc_geo$hum_deaths <- as.numeric(cdc_geo$hum_deaths)
cdc_geo$hum_cruderatedeaths <- as.numeric(cdc_geo$hum_cruderatedeaths)
cdc_geo$hum_ageratedeaths <- as.numeric(cdc_geo$hum_ageratedeaths)


# write ----------------------------------

write_rds(cdc_geo, "./rivanna_data/human/hum_cdc_2018.rds")


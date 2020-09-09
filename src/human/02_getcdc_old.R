library(naniar)
library(dplyr)
library(readxl)
library(readr)
library(janitor)
library(sf)

# read in CDC Wonder data --------------------------

alcohol <- read_xlsx("./rivanna_data/human/human_cdc_2018 - alcohol.xlsx", col_types = c("text", "text", "text", "text", "text")) %>% clean_names()
drug_unint <- read_xlsx("./rivanna_data/human/human_cdc_2018 - drugs1.xlsx", col_types = c("text", "text", "text", "text", "text")) %>% clean_names()
drug_und <- read_xlsx("./rivanna_data/human/human_cdc_2018 - drugs2.xlsx", col_types = c("text", "text", "text", "text", "text")) %>% clean_names()
drug_other <- read_xlsx("./rivanna_data/human/human_cdc_2018 - drugs3.xlsx", col_types = c("text", "text", "text", "text", "text")) %>% clean_names()
suicide <- read_xlsx("./rivanna_data/human/human_cdc_2018 - suicide.xlsx", col_types = c("text", "text", "text", "text", "text")) %>% clean_names()

# rename columns so that we can merge cdc data into one dataframe

alcohol <- alcohol %>%
  rename(hum_numalcdeaths = deaths, alc_pop = population, hum_ratealcdeaths = crude_rate)

drug_unint <- drug_unint %>%
  rename(hum_numdrguideaths = deaths, drg_ui_pop = population, hum_ratedrguideaths = crude_rate)

drug_und <- drug_und %>%
  rename(hum_numdrguddeaths = deaths, drg_ud_pop = population, hum_ratedrguddeaths = crude_rate)

drug_other <- drug_other %>%
  rename(hum_numdrgodeaths = deaths, drg_o_pop = population, hum_ratedrgodeaths = crude_rate)

suicide <- suicide %>%
  rename(hum_numsuideaths = deaths, sui_pop = population, hum_ratesuideaths = crude_rate)


# merge into one dataframe --------------------------------------

cdc <- merge(alcohol, drug_unint, by = c("county", "county_code"), all=TRUE) %>%
  merge(drug_und, by = c("county", "county_code"), all=TRUE) %>%
  merge(drug_other, by = c("county", "county_code"), all=TRUE) %>%
  merge(suicide, by = c("county", "county_code"), all=TRUE)


# check missingness --------------------------------

miss_var_summary(cdc) # none are NA, but there will be "missing" and "suppressed"

# noting "missing" and "suppressed" deaths data.  Out of 270 counties --------------------------------------

# CDC documentation (https://wonder.cdc.gov/wonder/help/ucd.html#):
# Sub-national data representing fewer than ten persons (0-9) are suppressed
# Rates are marked as "unreliable" when the death count is less than 20

table(cdc$hum_numalcdeaths) # missing - 2, suppressed - 221, --> 47 counties with numeric data      alcohol-induced 
table(cdc$hum_numdrguideaths) # missing - 2, suppressed - 222 --> 46 counties with numeric data     drug overdose unintentional   -- we discard this
table(cdc$hum_numdrguddeaths) # missing - 2, suppressed - 268 --> 0 counties with numeric data      drug overdose undetermined    -- we discard this
table(cdc$hum_numdrgodeaths) # missing - 2, suppressed - 263 --> 5 counties with numeric data       drug overdose other
table(cdc$hum_numsuideaths) # missing - 2, suppressed - 200 --> 68 counties with numeric data       suicide

# 2 missing counties are always 51515 & 51560:
# -- Bedford City VA: reverted to town in 2013; Clifton Forge, VA: reverted back to town in 2001


# organize dataframe --------------------------------------------

# all population columns are the same, so only keeping one of them
# keeping only unintentional drug overdoses (not drug-undetermined and drug-other)

cdc <- cdc %>%
  select(county, county_code, alc_pop, hum_ratealcdeaths, hum_ratedrguideaths, hum_ratesuideaths) %>%
  rename(pop = alc_pop,
         GEOID = county_code,
         hum_ratedrgdeaths = hum_ratedrguideaths)

# Clean column types
cdc <- cdc %>% mutate(pop = ifelse(pop == "Missing", NA_character_, pop))
cdc$pop <- as.numeric(cdc$pop)

cdc$hum_ratealcdeaths <- as.character(cdc$hum_ratealcdeaths)
cdc$hum_ratedrgdeaths <- as.character(cdc$hum_ratedrgdeaths)
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

table(cdc_geo$hum_ratealcdeaths) # 221 - "Suppressed", 22 - "Unreliable"
table(cdc_geo$hum_ratedrgdeaths) # 222 - "Suppressed", 24 - "Unreliable"
table(cdc_geo$hum_ratesuideaths) # 200 - "Suppressed", 38 - "Unreliable"

# Sub-national data representing fewer than ten persons (0-9) are suppressed: SUPPRESSED IS 0-9 deaths
# Rates are marked as "unreliable" when the death count is less than 20:      UNRELIABLE IS 10-20 deaths
# Crude death rates in this dataset are calculated as (deaths / population) * 100,000, so
# suppressed is ~ 4.5/population * 100,000
# unreliable is ~15/population * 100,000
# Problem with this soluton: 
# Even if coded as 4.5/pop * 100k, 15/pop * 100k and then binned, values for small geographies are absurd. 
# E.g. an area with 0-9 deaths but 19 people would have a crude death rate of 23684.211.

# Recode these values to NA. 

cdc_geo <- cdc_geo %>% mutate(hum_ratealcdeaths = ifelse(hum_ratealcdeaths == "Suppressed" | hum_ratealcdeaths == "Unreliable", NA_character_, hum_ratealcdeaths),
                              hum_ratedrgdeaths = ifelse(hum_ratedrgdeaths == "Suppressed" | hum_ratedrgdeaths == "Unreliable", NA_character_, hum_ratedrgdeaths),
                              hum_ratesuideaths = ifelse(hum_ratesuideaths == "Suppressed" | hum_ratesuideaths == "Unreliable", NA_character_, hum_ratesuideaths))

# Now can convert remaining values to numeric
cdc_geo$hum_ratealcdeaths <- as.numeric(cdc_geo$hum_ratealcdeaths)
cdc_geo$hum_ratedrgdeaths <- as.numeric(cdc_geo$hum_ratedrgdeaths)
cdc_geo$hum_ratesuideaths <- as.numeric(cdc_geo$hum_ratesuideaths)


# write -------------------------------------------

write_rds(cdc_geo, "./rivanna_data/human/hum_cdc_2018.rds")






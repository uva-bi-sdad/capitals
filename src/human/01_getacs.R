library(tidycensus)
library(tidyverse)
library(naniar)
library(sf)


#
# API key ------------------------------------------------------------------------
#

# installed census api key
census_api_key(CENSUS_API_KEY)


#
# Get data ------------------------------------------------------------------------
#

# Select variables
acsvars <- c(
  # Percent of population with at least a high school degree
  "B15003_017", "B15003_018", "B15003_019", "B15003_020", "B15003_021", "B15003_022", "B15003_023", 
  "B15003_024", "B15003_025", "B15003_001",
  # Percent of women who did not receive HS diploma or equivalent
  "B15002_020", "B15002_021", "B15002_022", "B15002_023", "B15002_024", "B15002_025", "B15002_026", 
  "B15002_027", "B15002_019", "B15002_001",
  # MEDIAN EARNINGS IN THE PAST 12 MONTHS (IN 2018 INFLATION-ADJUSTED DOLLARS) BY SEX BY EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER
  "B20004_007", "B20004_013",
  # white males with high school education or less"
  "C15002A_002", "C15002A_003", "C15002A_004",
  # employment status (unemployed in labor force)
  "B23025_003", "B23025_005"
)

# Select S table
acsvars_s <- c("S1201_C01_001", "S1201_C04_001", "S1201_C05_001") # marital status: percent divorced or separated


#
# Get data ------------------------------------------------------------------------
#

# Get data from 2014/18 5-year estimates for counties
data <- get_acs(geography = "county", state = c(19, 41, 51), 
                variables = acsvars,
                year = 2018, survey = "acs5",
                cache_table = TRUE, output = "wide", geometry = TRUE,
                keep_geo_vars = TRUE)

# Get data for the S table. NOTE THIS IS ALREADY IN %!
data_s <- get_acs(geography = "county", state = c(19, 41, 51), 
                  variables = acsvars_s,
                  year = 2018, survey = "acs5",
                  cache_table = TRUE, output = "wide", geometry = TRUE,
                  keep_geo_vars = TRUE)

#
# Calculate ------------------------------------------------------------------------
#

acsdata <- data %>% transmute(
  STATEFP = STATEFP, 
  COUNTYFP = COUNTYFP, 
  COUNTYNS = COUNTYNS, 
  AFFGEOID = AFFGEOID, 
  GEOID = GEOID, 
  LSAD = LSAD, 
  NAME.x = NAME.x, 
  NAME.y = NAME.y,
  geometry = geometry,
  hum_pcths = (B15003_017E + B15003_018E + B15003_019E + B15003_020E + B15003_021E + B15003_022E + B15003_023E + 
                 B15003_024E + B15003_025E) / B15003_001E * 100,
  hum_ratioFMpay = B20004_013E / B20004_007E,
  hum_pctFnohs = (B15002_020E + B15002_021E + B15002_022E + B15002_023E + B15002_024E + B15002_025E +
                    B15002_026E + B15002_027E) / B15002_019E * 100,
  hum_whitemhs = (C15002A_003E + C15002A_004E) / C15002A_002E * 100,
  hum_pctunemp = B23025_005E / B23025_003E * 100
)

# Note this is already in %!!!
acsdata_s <- data_s %>% transmute(
  STATEFP = STATEFP, 
  COUNTYFP = COUNTYFP, 
  COUNTYNS = COUNTYNS, 
  AFFGEOID = AFFGEOID, 
  GEOID = GEOID, 
  LSAD = LSAD, 
  NAME.x = NAME.x, 
  NAME.y = NAME.y,
  geometry = geometry,
  hum_pctdivorc = S1201_C04_001E + S1201_C05_001E
)

# Join
acsdata_s <- st_drop_geometry(acsdata_s)
acsdata <- left_join(acsdata, acsdata_s)

# Missingness
miss_var_summary(acsdata) # nothing missing


#
# Write ------------------------------------------------------------------------
#

write_rds(acsdata, "./rivanna_data/human/hum_acs_2018.rds")

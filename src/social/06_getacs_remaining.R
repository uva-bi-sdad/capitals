library(tidycensus)
library(tidyverse)
library(sf)


#
# API key ------------------------------------------------------------------------
#

# installed census api key
readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")


#
# Get data ------------------------------------------------------------------------
#

# B10002 GRANDCHILDREN UNDER 18 YEARS LIVING WITH A GRANDPARENT HOUSEHOLDER BY GRANDPARENT RESPONSIBILITY AND PRESENCE OF PARENT
# B25003 TENURE
# B07003 GEOGRAPHICAL MOBILITY IN THE PAST YEAR BY SEX FOR CURRENT RESIDENCE IN THE UNITED STATES
# B11015 HOUSEHOLDS BY PRESENCE OF NONRELATIVES
# B28010 COMPUTERS IN HOUSEHOLD
# B08134 MEANS OF TRANSPORTATION TO WORK BY TRAVEL TIME TO WORK
# C16002 HOUSEHOLD LANGUAGE BY HOUSEHOLD LIMITED ENGLISH SPEAKING STATUS
# B11010 NONFAMILY HOUSEHOLDS BY SEX OF HOUSEHOLDER BY LIVING ALONE BY AGE OF HOUSEHOLDER ------> from 2012/2016
# B15003 EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER
# B01003 TOTAL POPULATION -----> for 5 year period, so 2009/14 to 2014/18

# Select variables
acsvars18 <- c(
  # B10002 GRANDCHILDREN UNDER 18 YEARS LIVING WITH A GRANDPARENT HOUSEHOLDER BY GRANDPARENT RESPONSIBILITY AND PRESENCE OF PARENT
  "B10002_002", "B10002_001",
  # B25003 TENURE
  "B25003_002", "B25003_001",
  # B07003 GEOGRAPHICAL MOBILITY IN THE PAST YEAR BY SEX FOR CURRENT RESIDENCE IN THE UNITED STATES
  "B07003_004", "B07003_001",
  # B11015 HOUSEHOLDS BY PRESENCE OF NONRELATIVES
  "B28010_002", "B28010_001",
  # B28010 COMPUTERS IN HOUSEHOLD
  "B19056_002", "B19056_001",
  # B08134 MEANS OF TRANSPORTATION TO WORK BY TRAVEL TIME TO WORK
  "B08134_030", "B08134_001",
  # C16002 HOUSEHOLD LANGUAGE BY HOUSEHOLD LIMITED ENGLISH SPEAKING STATUS
  "C16002_004", "C16002_007", "C16002_010", "C16002_013", "C16002_001",
  # B15003 EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER (without hs diploma)
  "B15003_002", "B15003_003", "B15003_004", "B15003_005", "B15003_006", "B15003_007",
  "B15003_008", "B15003_009", "B15003_010", "B15003_011", "B15003_012", "B15003_013",
  "B15003_014", "B15003_015", "B15003_016", "B15003_001",
  # B01003 TOTAL POPULATION
  "B08303_001"
)

acsvars16 <- c(
  # NONFAMILY HOUSEHOLDS BY SEX OF HOUSEHOLDER BY LIVING ALONE BY AGE OF HOUSEHOLDER
  "B11010_005", "B11010_012", "B11010_001"
)

acsvars14 <- c(
  # B01003 TOTAL POPULATION
  "B08303_001"
)


#
# Get data ------------------------------------------------------------------------
#

# Get data from 2014/18 5-year estimates for counties
data18 <- get_acs(geography = "county", state = c(19, 41, 51), 
                variables = acsvars18,
                year = 2018, survey = "acs5",
                cache_table = TRUE, output = "wide", geometry = TRUE,
                keep_geo_vars = TRUE)

# Get data from 2012/16 5-year estimates for counties
data16 <- get_acs(geography = "county", state = c(19, 41, 51), 
                variables = acsvars16,
                year = 2016, survey = "acs5",
                cache_table = TRUE, output = "wide", geometry = TRUE,
                keep_geo_vars = TRUE)

# Get data from 2009/14 5-year estimates for counties
data14 <- get_acs(geography = "county", state = c(19, 41, 51), 
                variables = acsvars14,
                year = 2014, survey = "acs5",
                cache_table = TRUE, output = "wide", geometry = TRUE,
                keep_geo_vars = TRUE)

#
# Calculate ------------------------------------------------------------------------
#

acsdata18 <- data18 %>% transmute(
  STATEFP = STATEFP, 
  COUNTYFP = COUNTYFP, 
  COUNTYNS = COUNTYNS, 
  AFFGEOID = AFFGEOID, 
  GEOID = GEOID, 
  LSAD = LSAD, 
  NAME.x = NAME.x, 
  NAME.y = NAME.y,
  geometry = geometry,
  # Percent grandparent householders responsible for own grandchildren
  soc_grandp = B10002_002E / B10002_001E * 100,
  # Percent homeowners
  soc_homeown = B25003_002E / B25003_001E * 100,
  # Percent population living in the same house that they lived in one year prior
  soc_samehouse = B07003_004E / B07003_001E * 100,
  # Percent households with nonrelatives present
  soc_nonrelat = B28010_002E / B28010_001E * 100,
  # Percent households with a computing device (computer or smartphone)
  soc_computer = B19056_002E / B19056_001E * 100,
  # Percent workers with more than an hour of commute by themselves
  soc_commalone = B08134_030E / B08134_001E * 100,
  # Percent of residents that are not proficient in speaking English
  soc_limiteng = (C16002_004E + C16002_007E + C16002_010E + C16002_013E) / C16002_001E * 100,
  # Percent of population without a high school diploma
  soc_nohs = (B15003_002E + B15003_003E + B15003_004E + B15003_005E + B15003_006E + B15003_007E + 
              B15003_008E + B15003_009E + B15003_010E + B15003_011E + B15003_012E + B15003_013E + 
              B15003_014E + B15003_015E + B15003_016E) / B15003_001E * 100,
  # 5 year percentage change in population
  soc_totalpop18 = B08303_001E
)

acsdata16 <- data16 %>% transmute(
  STATEFP = STATEFP, 
  COUNTYFP = COUNTYFP, 
  COUNTYNS = COUNTYNS, 
  AFFGEOID = AFFGEOID, 
  GEOID = GEOID, 
  LSAD = LSAD, 
  NAME.x = NAME.x, 
  NAME.y = NAME.y,
  geometry = geometry,
  # Percent of all county residents who are both over 65 and live alone
  soc_65alone = (B11010_005E + B11010_012E) / B11010_001E * 100
)

acsdata14 <- data14 %>% transmute(
  STATEFP = STATEFP, 
  COUNTYFP = COUNTYFP, 
  COUNTYNS = COUNTYNS, 
  AFFGEOID = AFFGEOID, 
  GEOID = GEOID, 
  LSAD = LSAD, 
  NAME.x = NAME.x, 
  NAME.y = NAME.y,
  geometry = geometry,
  # 5 year percentage change in population
  soc_totalpop14 = B08303_001E
)


# Join
acsdata16 <- acsdata16 %>% st_drop_geometry()
acsdata14 <- acsdata14 %>% st_drop_geometry()

data <- left_join(acsdata18, acsdata16, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "AFFGEOID", "GEOID", "LSAD", "NAME.x", "NAME.y"))
data <- left_join(data, acsdata14, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "AFFGEOID", "GEOID", "LSAD", "NAME.x", "NAME.y"))

# Calculate population change
data <- data %>% mutate(soc_popchange = (1 - (soc_totalpop14 / soc_totalpop18)) * 100)


#
# Write ------------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/social/soc_acs_2018_remaining.Rds")

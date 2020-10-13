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

# Select variables
acsvars <- c(
  #Percent vacant properties
  "B25047_001", # Total housing units
  "B25047_002" # Housing units with complete plumbing
)


#
# Get data ------------------------------------------------------------------------
#

# Get data from 2014/18 5-year estimates for counties
data <- get_acs(geography = "county", state = c(19, 41, 51),
                variables = acsvars,
                year = 2018, survey = "acs5",
                cache_table = TRUE, output = "wide", geometry = TRUE,
                keep_geo_vars = TRUE)

#view(data)


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
  built_pctfullplumb = (B25047_002E / B25047_001E) * 100,
)

#view(acsdata)


#
# Write ------------------------------------------------------------------------
#

write_rds(acsdata, "Rivanna file path")

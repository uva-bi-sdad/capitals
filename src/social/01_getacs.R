library(tidyverse)
library(tidycensus)

#
# API key ------------------------------------------------------------------------
#

readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")

#
# Get data ------------------------------------------------------------------------
#

# Select variables
acsvars <- c(
  # total population
  "B01003_001E",
  # voter population
  "B29001_001E"
  
)

acs <- get_acs(geography = "county", state = c(19,41,51),
                  variables = acsvars,
                  year = 2018,
                  cache_table = TRUE, output = "wide", geometry = TRUE,
                  keep_geo_vars = TRUE)

#
# Calculate ------------------------------------------------------------------------
#

acs_county <- acs %>% transmute(
  STATEFP = STATEFP,
  COUNTYFP = COUNTYFP,
  GEOID = GEOID,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  ALAND = ALAND,
  AWATER = AWATER,
  geometry = geometry,
  total_pop = B01003_001E,
  voter_pop = B29001_001E
)
acs_county$NAME.x <- tolower(acs_county$NAME.x)
acs_county$county <- acs_county$NAME.x

#
# Write ------------------------------------------------------------------------
#

write_rds(acs_county, "./rivanna_data/social/soc_acs_2018.rds")

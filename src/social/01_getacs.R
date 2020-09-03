install.packages("tidycensus")
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
  "B01003_001"
)


acs <- get_acs(geography = "county", state = c(19,41,51),
                  variables = acsvars,
                  year = 2018,
                  cache_table = TRUE, output = "wide", geometry = TRUE,
                  keep_geo_vars = TRUE)

#
# Calculate ------------------------------------------------------------------------
#

acs_county <- acs_ny %>% transmute(
  STATEFP = STATEFP,
  COUNTYFP = COUNTYFP,
  GEOID = GEOID,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  ALAND = ALAND,
  AWATER = AWATER,
  geometry = geometry
)
acs_county$NAME.x <- tolower(acs_county$NAME.x)
acs_county$county <- acs_county$NAME.x
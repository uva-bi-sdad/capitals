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
  # voter population
  #"B29001_001"
  
)

acs <- get_acs(geography = "county", state = c(19,41,51),
                  variables = acsvars,
                  year = 2018,
                  cache_table = TRUE, output = "wide", geometry = TRUE,
                  keep_geo_vars = TRUE)

acs_2016 <- get_acs(geography = "county", state = c(19,41,51),
               variables = acsvars,
               year = 2016,
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
  soc_totalpop = B01003_001E
)
acs_county$NAME.x <- tolower(acs_county$NAME.x)
acs_county$county <- acs_county$NAME.x

acs_county_2016 <- acs_2016 %>% transmute(
  STATEFP = STATEFP,
  COUNTYFP = COUNTYFP,
  GEOID = GEOID,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  ALAND = ALAND,
  AWATER = AWATER,
  geometry = geometry,
  soc_totalpop = B01003_001E
)
acs_county_2016$NAME.x <- tolower(acs_county_2016$NAME.x)
acs_county_2016$county <- acs_county_2016$NAME.x

#
# Write ------------------------------------------------------------------------
#

write_rds(acs_county, "./rivanna_data/social/soc_acs_2018.rds")
write_rds(acs_county_2016, "./rivanna_data/social/soc_acs_2016.rds")

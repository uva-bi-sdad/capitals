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
  #Total population in county
  "B01003_001",
  #Percent vacant properties
  "B25002_003", #vacant properties
  "B25002_001", #total properties
  #Median property value
  "B25077_001",
  #Median Year Structure Built
  "B25035_001",
  #Percent detached single family housing
  "B25024_002", #single detatched
  "B25024_001", #total
  #Percent households with "Broadband such as cable, fiber optic, or DSL" subscription
  "B28011_004",
  "B28011_001",
  #Percent with complete plumbing 
  "B25047_001",
  "B25047_002",
  "B25047_003"
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
  ALAND = ALAND,
  AWATER = AWATER, 
  COUNTYPOP = B01003_001E,
  GEOID = GEOID,
  LSAD = LSAD,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  geometry = geometry,
  built_pctvacant = (B25002_003E / B25002_001E) * 100,
  built_medpropval = B25077_001E,
  built_medyrbuilt = B25035_001E,
  built_pctsinghaus = (B25024_002E / B25024_001E) * 100,
  built_pctbband = (B28011_004E / B28011_001E) *100,
  prc_complete_plumbing = (B25047_002E / B25047_001E) *100,
  prc_lacking_plumbing = (B25047_003E / B25047_001E) *100
)

#view(acsdata)


#
# Write ------------------------------------------------------------------------
#

write_rds(acsdata, "./rivanna_data/built/built_acs_2018.Rds")

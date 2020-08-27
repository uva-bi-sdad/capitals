library(tidycensus)
library(tidyverse)


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
  # Employed in agriculture, forestry, fishing and hunting, mining industry
  "C24050_001", "C24050_002",
  # Gini index of income inequality
  "B19083_001",
  # Income below poverty level
  "B17001_002", "B17001_001",
  # Public assistance or snap in past 12 months
  "B19058_002", "B19058_001",
  # Supplemental security income
  "B19056_002", "B19056_001",
  # Median household income
  "B19013_001",
  # Without BA
  "B15003_002", "B15003_003", "B15003_004", "B15003_005", "B15003_006", "B15003_007",
  "B15003_008", "B15003_009", "B15003_010", "B15003_011", "B15003_012", "B15003_013",
  "B15003_014", "B15003_015", "B15003_016", "B15003_017", "B15003_018", "B15003_019",
  "B15003_020", "B15003_021", "B15003_001",
  # In labor force
  "B23025_002", "B23025_001",
  # Travel time to work 30+
  "B08303_008", "B08303_009", "B08303_010", "B08303_011", "B08303_012", "B08303_013",
  "B08303_001"
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
  fin_pctemplagri = C24050_002E / C24050_001E * 100,
  fin_gini = B19083_001E,
  fin_pctinpov = B17001_002E / B17001_001E * 100,
  fin_pctassist = B19058_002E / B19058_001E * 100,
  fin_pctssi = B19056_002E / B19056_001E * 100,
  fin_medinc = B19013_001E,
  fin_pctlessba = (B15003_002E + B15003_003E + B15003_004E + B15003_005E + B15003_006E + B15003_007E +
                   B15003_008E + B15003_009E + B15003_010E + B15003_011E + B15003_012E + B15003_013E +
                   B15003_014E + B15003_015E + B15003_016E + B15003_017E + B15003_018E + B15003_019E +
                   B15003_020E + B15003_021E) / B15003_001E * 100,
  fin_pctcommute = (B08303_008E + B08303_009E + B08303_010E + B08303_011E + B08303_012E + B08303_013E) /
                    B08303_001E * 100,
  fin_pctlabforce = B23025_002E / B23025_001E * 100
)


#
# Write ------------------------------------------------------------------------
#

write_rds(acsdata, "./rivanna_data/financial/fin_acs_2018.Rds")

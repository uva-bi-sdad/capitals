library(readxl)
library(dplyr)
library(tidycensus)
library(readr)

# Read in -------------------------------------------------------------------
# Downloaded from https://www.huduser.gov/portal/datasets/assthsg.html#2009-2019_codebook
# under the data tab and "2019 - Based on Census 2010 geographies" drop down.  Then
# selected and downloaded "County"

data <- read_excel("./rivanna_data/built/COUNTY_2019.xlsx")

#
# Clean ------------------------------------------------------------------------
#
data <- data %>%
  filter(states == "VA Virginia" | states == "OR Oregon" | states == "IA Iowa") %>%
  filter(program_label == "Summary of All HUD Programs")

data <- data %>% transmute(
  state = state,
  county = name,
  code = code,
  total_units = total_units,
  pct_occupied = pct_occupied,
  people_per_unit = people_per_unit,
  people_total = people_total
)


# Get data from 2014/18 5-year estimates for counties
acsdata <- get_acs(geography = "county", state = c(19, 41, 51),
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)

acsdata$state_cnty <- paste(acsdata$STATEFP, acsdata$COUNTYFP, sep = "")

acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, -B01003_001M)

# Join
data <- left_join(acsdata, data, by = c("state_cnty" = "code"))


#Constructing Variables
huddata <- data %>% transmute(
  STATEFP = STATEFP,
  COUNTYFP = COUNTYFP,
  COUNTYNS = COUNTYNS,
  GEOID = GEOID,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  geometry = geometry,
  units_per_pop = total_units / B01003_001E,
  residents_per_pop = people_total / B01003_001E
)

#Write
write_rds(huddata, "./rivanna_data/built/built_hud_2019.Rds")

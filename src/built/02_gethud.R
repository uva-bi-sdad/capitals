library(readxl)
library(dplyr)
library(tidycensus)
library(readr)

# Read in -------------------------------------------------------------------
# Downloaded from https://www.huduser.gov/portal/datasets/assthsg.html#2009-2019_codebook
# under the data tab and "2019 - Based on Census 2010 geographies" drop down.  Then
# selected and downloaded "County"
# data dictionary: https://www.huduser.gov/portal/datasets/pictures/dictionary_2019.pdf

data <- read_excel("./rivanna_data/built/built_hud_2019_orig_COUNTY_2019.xlsx")


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
  total_units = total_units, # total number of affordable units
  pct_occupied = pct_occupied, # percent affordable units occupied - "Occupied units as the % of units available "
  people_per_unit = people_per_unit, # "Average size of household (with decimal point and place, e.g., 2.5, with -ve sign, decimal point for suppressed and non-reporting values, e.g., -4.0, -5.0) 
  people_total = people_total # total number of persons in affordable units - "Total number of people"
)

# Negative values: decimal point for suppressed and non-reporting values, e.g., -4.0, -5.0). Recode to NA.
data <- data %>% mutate(pct_occupied = ifelse(pct_occupied <0, NA, pct_occupied),
                        people_per_unit = ifelse(people_per_unit <0, NA, people_per_unit),
                        people_total = ifelse(people_total <0, NA, people_total))


# Get data from 2014/18 5-year estimates for counties
acsdata <- get_acs(geography = "county", state = c(19, 41, 51),
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)


acsdata <- acsdata %>% select(-LSAD, -COUNTYNS, -AFFGEOID, -B01003_001M)

# Join
data <- left_join(acsdata, data, by = c("GEOID" = "code"))

#Constructing Variables
huddata <- data %>% transmute(
  STATEFP = STATEFP,
  COUNTYFP = COUNTYFP,
  GEOID = GEOID,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  geometry = geometry,
  built_pctoccupied = pct_occupied, # Occupied units as the % of units available
  built_affunitsperpop = total_units / B01003_001E * 1000, # number of affordable units per 1,000 population
  built_pctinaffunits = people_total / B01003_001E * 100 # percent population in affordable units
)

#Write
write_rds(huddata, "./rivanna_data/built/built_hud_2019.Rds")

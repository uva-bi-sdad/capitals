library(readr)
library(dplyr)
library(magrittr)
library(janitor)
library(tidycensus)
library(stringr)

# Glossary: https://quickstats.nass.usda.gov/src/glossary.pdf. 
# (D): Withheld to avoid disclosing data for individual operations.
# (Z): Less than half the rounding unit.
# These are legitimate NAs and should be coded as such.

# Read in USDA-NASS data files
ag_land = read_csv("data/natural/nat_nass_2017_aglandtotal.csv") %>% clean_names()
agritourism = read_csv("data/natural/nat_nass_2017_agritourism.csv") %>% clean_names()
forestry = read_csv("data/natural/nat_nass_2017_forestry.csv") %>% clean_names()

# Create new columns with accurate names and select relevant columns
ag_land %<>% mutate(acres_operated = value) %>% select(state, state_ansi, county, county_ansi, acres_operated)
agritourism %<>% mutate(agritourism_revenue = value) %>% select(state, state_ansi, county, county_ansi, agritourism_revenue)
forestry %<>% mutate(forestry_revenue = value) %>% select(state, state_ansi, county, county_ansi, forestry_revenue)

# Fix column data types
agritourism$county_ansi %<>% as.character()
forestry$county_ansi %<>% as.character()
ag_land$county_ansi %<>% as.character()

agritourism$state_ansi %<>% as.character()
forestry$state_ansi %<>% as.character()
ag_land$state_ansi %<>% as.character()

# Pad
agritourism$county_ansi <- ifelse(nchar(agritourism$county_ansi) == 2, paste0("0", agritourism$county_ansi), agritourism$county_ansi)
agritourism$county_ansi <- ifelse(nchar(agritourism$county_ansi) == 1, paste0("00", agritourism$county_ansi), agritourism$county_ansi)

forestry$county_ansi <- ifelse(nchar(forestry$county_ansi) == 2, paste0("0", forestry$county_ansi), forestry$county_ansi)
forestry$county_ansi <- ifelse(nchar(forestry$county_ansi) == 1, paste0("00", forestry$county_ansi), forestry$county_ansi)

ag_land$county_ansi <- ifelse(nchar(ag_land$county_ansi) == 2, paste0("0", ag_land$county_ansi), ag_land$county_ansi)
ag_land$county_ansi <- ifelse(nchar(ag_land$county_ansi) == 1, paste0("00", ag_land$county_ansi), ag_land$county_ansi)

# GEOID
agritourism$GEOID <- paste0(agritourism$state_ansi, agritourism$county_ansi)
forestry$GEOID <- paste0(forestry$state_ansi, forestry$county_ansi)
ag_land$GEOID <- paste0(ag_land$state_ansi, ag_land$county_ansi)

# Join separate dataframes
nass_data = full_join(ag_land, agritourism, by = c("GEOID", "state", "state_ansi", "county", "county_ansi"))
nass_data = full_join(nass_data, forestry, by = c("GEOID", "state", "state_ansi", "county", "county_ansi"))

# Counties without data (NOT counties with (D) or (Z)) have 0 operations/revenue and should be recoded to 0 as a legitimate value.
nass_data <- nass_data %>% mutate(agritourism_revenue = ifelse(is.na(agritourism_revenue), 0, agritourism_revenue),
                                  forestry_revenue = ifelse(is.na(forestry_revenue), 0,  forestry_revenue))
  
# Read in County area data
counties = read_csv("data/natural/nat_census_2019_area.csv")
 
# Independent cities don't have data and should stay NA.

# Keep counties of interest
counties %<>% filter(STATEFP %in% c(19, 41, 51))

# Convert ALAND and AWATER to acres
counties %<>% mutate(ALAND_acres = ALAND * 0.00024711, AWATER_acres = AWATER * 0.00024711)

# Join nass_data to county data
nass_data = left_join(counties, nass_data, by = c("GEOID", "STATEFP" = "state_ansi", "COUNTYFP" = "county_ansi"))
nass_data = nass_data %>% select(STATEFP, COUNTYFP, GEOID, NAME, acres_operated, agritourism_revenue, forestry_revenue, ALAND_acres, AWATER_acres)

# Counties with "", (D), (Z) are true NAs and can now be recoded to NA.
nass_data <- nass_data %>% mutate(agritourism_revenue = ifelse(agritourism_revenue == "(D)", NA, agritourism_revenue),
                                  agritourism_revenue = ifelse(agritourism_revenue == "", NA, agritourism_revenue),
                                  forestry_revenue = ifelse(forestry_revenue == "(D)", NA, forestry_revenue),
                                  forestry_revenue = ifelse(forestry_revenue == "", NA, forestry_revenue),
                                  forestry_revenue = ifelse(forestry_revenue == "(Z)", NA, forestry_revenue))

nass_data$agritourism_revenue <- str_remove_all(nass_data$agritourism_revenue, ",")
nass_data$forestry_revenue <- str_remove_all(nass_data$forestry_revenue, ",")

nass_data$agritourism_revenue <- as.numeric(nass_data$agritourism_revenue)
nass_data$forestry_revenue <- as.numeric(nass_data$forestry_revenue)

# Create new columns accurately named and adjusted for area
nass_data %<>% mutate(total_area = ALAND_acres + AWATER_acres)
nass_data %<>% mutate(nat_pctagacres = acres_operated/total_area)
nass_data %<>% mutate(nat_pctwater = AWATER_acres/total_area)
nass_data %<>% mutate(nat_agritourrevper10kacres = (agritourism_revenue/total_area) * 10000)
nass_data %<>% mutate(nat_forestryrevper10kacres = (forestry_revenue/total_area) * 10000)

# Add geometries
Sys.getenv("CENSUS_API_KEY")

acsdata <- get_acs(geography = "county", state = c(19, 41, 51), 
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, NAME.x, ALAND, AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)

nass_data <- left_join(acsdata, nass_data, by = c("STATEFP", "COUNTYFP", "GEOID"))
  
# Write combined dataframe to rds file
write_rds(nass_data, "data/natural/nat_nass_2017.rds")
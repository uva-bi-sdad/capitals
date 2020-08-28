library(readr)
library(dplyr)
library(magrittr)
library(janitor)

# Read in USDA-NASS data files
ag_land = read_csv("data/natural/nat_nass_2017_aglandtotal.csv") %>% clean_names()
agritourism = read_csv("data/natural/nat_nass_2017_agritourism.csv", na = c("(D)", "")) %>% clean_names()
forestry = read_csv("data/natural/nat_nass_2017_forestry.csv", na = c("(D)", "", "(Z)")) %>% clean_names()

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

# Read in County area data
counties = read_csv("data/natural/nat_census_2019.csv")

# Keep counties of interest
counties %<>% filter(STATEFP %in% c(19, 41, 51))

# Convert ALAND and AWATER to acres
counties %<>% mutate(ALAND_acres = ALAND * 0.00024711, AWATER_acres = AWATER * 0.00024711)

# Join nass_data to county data
nass_data = left_join(counties, nass_data, by = c("GEOID", "STATEFP" = "state_ansi", "COUNTYFP" = "county_ansi"))
nass_data = nass_data %>% select(STATEFP, COUNTYFP, GEOID, NAME, acres_operated, agritourism_revenue, forestry_revenue, ALAND_acres, AWATER_acres)

# Create new columns accurately named and adjusted for area
nass_data %<>% mutate(total_area = ALAND_acres + AWATER_acres)
nass_data %<>% mutate(nat_pctagacres = acres_operated/total_area)
nass_data %<>% mutate(nat_pctwater = AWATER_acres/total_area)
nass_data %<>% mutate(nat_agritourrevper10kacres = (agritourism_revenue/total_area) * 10000)
nass_data %<>% mutate(nat_forestryrevper10kacres = (forestry_revenue/total_area) * 10000)

# Write combined dataframe to rds file
write_rds(nass_data, "data/natural/nat_nass_2017.rds")
library(readr)
library(dplyr)
library(magrittr)
library(stringr)

# Read in USDA-NASS data files
ag_land = read_csv("data/natural/nat_nass_2017_aglandtotal.csv")
agritourism = read_csv("data/natural/nat_nass_2017_agritourism.csv", na = c("(D)", ""))
forestry = read_csv("data/natural/nat_nass_2017_forestry.csv", na = c("(D)", ""))

# Create new columns with accurate names and select relevant columns
ag_land %<>% mutate(acres_operated = Value) %>% select(State, `State ANSI`, County, `County ANSI`, acres_operated)
agritourism %<>% mutate(agritourism_revenue = Value) %>% select(State, `State ANSI`, County, `County ANSI`, agritourism_revenue)
forestry %<>% mutate(forestry_revenue = Value) %>% select(State, `State ANSI`, County, `County ANSI`, forestry_revenue)

# Fix column data types
agritourism$`County ANSI` %<>% as.numeric()
forestry$`County ANSI` %<>% as.numeric()
forestry$forestry_revenue = as.numeric(str_remove_all(forestry$forestry_revenue, ","))

# Join separate dataframes
nass_data = full_join(ag_land, agritourism, by = c("State", "State ANSI", "County", "County ANSI"))
nass_data = full_join(nass_data, forestry, by = c("State", "State ANSI", "County", "County ANSI"))

# Read in County area data
counties = read_csv("data/natural/nat_census_2019.csv")

# Keep counties of interest
counties %<>% filter(STATEFP %in% c(19, 41, 51))

# Convert ALAND and AWATER to acres
counties %<>% mutate(ALAND_acres = ALAND * 0.00024711, AWATER_acres = AWATER * 0.00024711)

# Create new GEOID column for joining
nass_data$GEOID = paste0(str_pad(nass_data$`State ANSI`, 2, side = "left", "0"), str_pad(nass_data$`County ANSI`, 3, side = "left", "0"))

# Join nass_data to county data
nass_data = left_join(counties, nass_data %>% select(State, County, acres_operated, agritourism_revenue, forestry_revenue, GEOID))

# Create new columns accurately named and adjusted for area
nass_data %<>% mutate(total_area = ALAND_acres + AWATER_acres)
nass_data %<>% mutate(nat_pctagacres = acres_operated/total_area)
nass_data %<>% mutate(nat_pctwater = AWATER_acres/total_area)
nass_data %<>% mutate(nat_agritourrevper10kacres = (agritourism_revenue/total_area) * 10000)
nass_data %<>% mutate(nat_forestryrevper10kacres = (forestry_revenue/total_area) * 10000)

# Write combined dataframe to rds file
write_rds(nass_data, "data/natural/nat_nass_2017.rds")
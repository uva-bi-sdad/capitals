library(sf)
library(dplyr)
library(magrittr)
library(readr)
library(tidyr)
library(tigris)
library(naniar)

# Documentation for creating shapefile used here is found in data/natural/nat_usgs_2020_trails/nat_usgs_2020_trails_documentation.txt

# Read in segmented trail data (Previously exported from QGIS)
trails = st_read("data/natural/nat_usgs_2020_trails/nat_usgs_2020_trails.shp")
  
# Find length of each trail segment
trails$length = st_length(trails)

# Keep only trail segments in the three states of interest
trails %<>% filter(STATEFP %in% c("19", "41", "51"))

# Drop geometry
trails %<>% st_drop_geometry()

# Sum trail lengths by county (in meters)
county_trails = trails %>% group_by(GEOID) %>% summarise(total_trails = sum(length)) %>% ungroup()

# Get counties and geometries using tigris
counties = counties(state = c("19", "41", "51"), class = "sf")
counties %<>% select(STATEFP, COUNTYFP, GEOID, NAME, ALAND, AWATER)

# Get county populations
counties_pop = read_csv("data/natural/nat_census_2019_pop.csv")
counties_pop %<>% mutate(GEOID = paste0(STATE, COUNTY))
counties_pop %<>% filter(STATE %in% c("19", "41", "51")) %>% select(GEOID, POPESTIMATE2019)

# Join county populations with counties geometry
counties = left_join(counties, counties_pop, by = c("GEOID"))

# Join trails data to counties data
county_trails = left_join(counties, county_trails, by = c("GEOID"))

# Missingness analysis (All missing values are zeros)
pct_complete_case(county_trails) # 80.22
pct_complete_var(county_trails) # 88.89
pct_miss_var(county_trails) # 11.11

n_var_complete(county_trails) # 8 variables complete
n_var_miss(county_trails) # 1
miss_var_summary(county_trails)
# total_trails    53   19.8
# 53 counties do not have trails in the USGS data


# Replace NAs with zeros
county_trails$total_trails %<>% replace_na(0)

# Adjust for population
county_trails %<>% mutate(nat_trailsper1k = (total_trails/POPESTIMATE2019) * 1000)

write_rds(county_trails, "data/natural/nat_usgs_2020_trails/nat_usgs_2020_trails.rds")

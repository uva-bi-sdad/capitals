library(sf)
library(dplyr)
library(magrittr)
library(readr)
library(tidyr)
library(tidycensus)
library(naniar)

# Using HIFLD Cellular Towers, Aircraft Landing Facilities, EMS Stations, Electric Substations,
# and EPA FRS Wastewater Treatment Plants to investigate quality, and if viable,
# identify points in OR/VA/IA and tally by county.

# ** Unable to download Aircraft Landing Facilities right now "An error occurred fetching data." **

#cell_service = st_read("rivanna_data/built/Cellular_Service_Areas-shp/CellularServiceAreas.shp")
cell = st_read("rivanna_data/built/Cellular_Towers-shp/CellularTowers.shp")
electric = st_read("rivanna_data/built/Electric_Substations-shp/Substations.shp")
ems = st_read("rivanna_data/built/ems-shp/ems.shp")
waste_water = st_read("rivanna_data/built/epa-shp/epa.shp")
fire = st_read("rivanna_data/built/Fire_Stations-shp/Fire_Stations.shp")

# Get counties and geometries from acs
Sys.getenv("CENSUS_API_KEY")

acsdata <- get_acs(geography = "county", state = c(19, 41, 51),
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, NAME.x, ALAND, AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)

# Spatial join, adding acs data to each observation in each dataframe
cell = st_join(st_transform(cell, crs = st_crs(acsdata)), acsdata)
electric = st_join(st_transform(electric, crs = st_crs(acsdata)), acsdata)
ems = st_join(st_transform(ems, crs = st_crs(acsdata)), acsdata)
waste_water = st_join(st_transform(waste_water, crs = st_crs(acsdata)), acsdata)
fire = st_join(st_transform(fire, crs = st_crs(acsdata)), acsdata)


# Keep only observations that are in the three states
cell %<>% filter(STATEFP %in% c("19", "41", "51"))
electric %<>% filter(STATEFP %in% c("19", "41", "51"))
ems %<>% filter(STATEFP %in% c("19", "41", "51"))
waste_water %<>% filter(STATEFP %in% c("19", "41", "51"))
fire %<>% filter(STATEFP %in% c("19", "41", "51"))


# Count the number of each in each county and fix names/geometry
county_cell <- cell %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_cell) = c("GEOID", "cell_tower_count")
county_electric <- electric %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_electric) = c("GEOID", "electric_substations_count")
county_ems <- ems %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_ems) = c("GEOID", "ems_stations_count")
county_waste_water <- waste_water %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_waste_water) = c("GEOID", "waste_water_treatment_count")
county_fire <- fire %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_fire) = c("GEOID", "fire_station_count")


#combine them all
hifld_built <- left_join(county_cell, county_electric, by = c("GEOID")) %>%
  left_join(., county_ems, by = c("GEOID")) %>%
  left_join(., county_waste_water, by = c("GEOID")) %>%
  left_join(., county_fire, by = c("GEOID"))

# Missingness analysis (missing values are zeros)
pct_complete_case(hifld_built) # 92.09486
pct_complete_var(hifld_built) # 50
pct_miss_var(hifld_built) # 50

n_var_complete(hifld_built) # 3
n_var_miss(hifld_built) # 3
miss_var_summary(hifld_built)
# waste_water_treatment_count     16    6.32
# electric_substations_count       3    1.19
# ems_stations_count               2    0.791
# GEOID                            0    0
# cell_tower_count                 0    0
# fire_station_count               0    0

# Create whole DF linked back to ACS with geometry
data <- left_join(acsdata, hifld_built, by = "GEOID")

# Replace NAs with zeros
data$cell_tower_count %<>% replace_na(0)
data$electric_substations_count %<>% replace_na(0)
data$waste_water_treatment_count %<>% replace_na(0)
data$fire_station_count %<>% replace_na(0)
data$ems_stations_count %<>% replace_na(0)

# Write
write_rds(data, "rivanna_data/built/nat_hifldbuilt_2020.rds")

check <- read_rds("rivanna_data/built/nat_hifldbuilt_2020.rds")

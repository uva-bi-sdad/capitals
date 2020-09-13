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
county_cell <- cell %>% group_by(GEOID) %>% count() %<>% st_drop_geometry()
names(county_cell) = c("GEOID", "cell_tower_count")
county_electric <- electric %>% group_by(GEOID) %>% count() %<>% st_drop_geometry()
names(county_electric) = c("GEOID", "electric_substations_count")
county_ems <- ems %>% group_by(GEOID) %>% count() %<>% st_drop_geometry()
names(county_ems) = c("GEOID", "ems_stations_count")
county_waste_water <- waste_water %>% group_by(GEOID) %>% count() %<>% st_drop_geometry()
names(county_waste_water) = c("GEOID", "waste_water_treatment_count")
county_fire <- fire %>% group_by(GEOID) %>% count() %<>% st_drop_geometry()
names(county_fire) = c("GEOID", "fire_station_count")


#combine them all
hifld_built <- left_join(county_cell, county_electric, by = c("GEOID")) %>%
  left_join(., county_ems, by = c("GEOID")) %>%
  left_join(., county_waste_water, by = c("GEOID")) %>%
  left_join(., county_fire, by = c("GEOID"))


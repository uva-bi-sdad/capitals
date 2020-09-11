library(sf)
library(dplyr)
library(magrittr)
library(readr)
library(tidyr)
library(tidycensus)
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
county_trails = trails %>% group_by(GEOID) %>% summarise(total_trails = sum(length))


# Get counties and geometries from acs
Sys.getenv("CENSUS_API_KEY")

acsdata <- get_acs(geography = "county", state = c(19, 41, 51), 
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, NAME.x, ALAND, AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)


# Join trails data to acsdata
county_trails = left_join(acsdata, county_trails, by = c("GEOID"))


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

write_rds(county_trails, "data/natural/nat_usgs_2020_trails/nat_usgs_2020_trails.rds")

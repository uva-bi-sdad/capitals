library(sf)
library(dplyr)
library(magrittr)
library(readr)
library(tidyr)
library(tidycensus)
library(naniar)

# Using HIFLD Power Plants shapefile and oil and natural gas wells geojson 
# to find number of power plants, total power produced, and number of oil and natural gas wells in each county
# The wells file is very large, so I didn't push it
# Power Plants: https://hifld-geoplatform.opendata.arcgis.com/datasets/power-plants
# Wells: https://hifld-geoplatform.opendata.arcgis.com/datasets/oil-and-natural-gas-wells

# Neither dataset appears to have clear documentation online, only an issue for finding total power produced
# In the power plants data, SUMMER_CAP and WINTER_CAP appear to be the capacity of each plant in megawatts, but I'm not 100% certain on the units

# Ultimately, 97% of counties of interest don't have an oil or natural gas well, and about 26% of counties don't have a power plant


# Read in power plant shapefile
power = st_read("data/natural/nat_hifld_2020/Power_Plants.shp")

# Get counties and geometries from acs
Sys.getenv("CENSUS_API_KEY")

acsdata <- get_acs(geography = "county", state = c(19, 41, 51), 
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, NAME.x, ALAND, AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)


# Spatial join, adding acs data to each power plant observation
power = st_join(st_transform(power, crs = st_crs(acsdata)), acsdata)

# Keep only power plants that are in the three states
power %<>% filter(STATEFP %in% c("19", "41", "51"))

# Create column with the max cap between the summer cap and the winter cap
power$max_cap = pmax(as.numeric(power$SUMMER_CAP), as.numeric(power$WINTER_CAP))

# Count the number of electric power plants in each county and fix names/geometry
county_plants = power %>% group_by(GEOID) %>% count()
county_plants %<>% st_drop_geometry()
names(county_plants) = c("GEOID", "plant_count")
county_plants %<>% select(GEOID, plant_count)

# 14 observations have -999999 listed in both SUMMER_CAP and WINTER_CAP. Those plants were counted in the general plant count, but are assumed to be zeroes for this sum
total_power = power %>% filter(max_cap != -999999) %>% group_by(GEOID) %>% summarise(power = sum(max_cap))
total_power %<>% st_set_geometry(NULL)

# Join data
counties_power <- left_join(acsdata, county_plants, by = c("GEOID"))
counties_power = left_join(counties_power, total_power, by = c("GEOID"))



# Original oil and natural gas wells file is 1.2 GB, so not pushed to Github. 
# It can be downloaded here: https://hifld-geoplatform.opendata.arcgis.com/datasets/oil-and-natural-gas-wells/data?geometry=-117.557%2C29.775%2C-50.804%2C42.173
wells = st_read(file.choose())

# RDS file containing only three states of interest will be pushed
wells_3state = wells %>% filter(STATE %in% c("IA", "OR", "VA"))
write_rds(wells_3state, "data/natural/nat_hifld_2020/nat_hifld_2020_wells.rds")

# Count the number of wells in each county and clean up names and geometry
county_wells = wells_3state %>% group_by(COUNTYFIPS) %>% count()
county_wells %<>% st_drop_geometry()
names(county_wells) = c("GEOID", "well_count")

# Join data
hifld = left_join(counties_power, county_wells, by = c("GEOID"))




# Missingness analysis (missing values are zeros)
pct_complete_case(hifld) # 1.86
pct_complete_var(hifld) # 72.73
pct_miss_var(hifld) # 27.27

n_var_complete(hifld) # 8 variables complete
n_var_miss(hifld) # All 3 variables of note have missingness
miss_var_summary(hifld)
# well_count    260   97.0
# power         73    27.2
# plant_count   70    26.1



# Replace NAs with zeros
hifld$well_count %<>% replace_na(0)
hifld$plant_count %<>% replace_na(0)
hifld$power %<>% replace_na(0)

write_rds(hifld, "data/natural/nat_hifld_2020/nat_hifld_2020.rds")

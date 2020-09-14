library(sf)
library(dplyr)
library(magrittr)
library(readr)
library(tidyr)
library(naniar)
library(tigris)

# 43% of counties do not have a power plant fueled by renewables

# Read in power plant shapefile
power = st_read("data/natural/nat_hifld_2020/Power_Plants.shp")

# Subset to only renewables
# 221111: Hydroelectric, 221114: Solar, 221115: Wind, 221116: Geothermal, 221117: Biomass
ren_power = power %>% filter(NAICS_CODE %in% c("221111", "221114", "221115", "221116", "221117"))

# Get counties and geometries using tigris
counties = counties(state = c("19", "41", "51"))
counties %<>% select(STATEFP, COUNTYFP, GEOID, NAME, ALAND, AWATER)


# Spatial join, adding acs data to each ren_power plant observation
ren_power = st_join(st_transform(ren_power, crs = st_crs(counties)), counties)

# Keep only ren_power plants that are in the three states
ren_power %<>% filter(STATEFP %in% c("19", "41", "51"))

# Create column with the max cap between the summer cap and the winter cap
ren_power$max_cap = pmax(as.numeric(ren_power$SUMMER_CAP), as.numeric(ren_power$WINTER_CAP))

# Count the number of electric ren_power plants in each county and fix names/geometry
county_plants = ren_power %>% group_by(GEOID) %>% count()
county_plants %<>% st_drop_geometry()
names(county_plants) = c("GEOID", "plant_count")
county_plants %<>% select(GEOID, plant_count)

# 14 observations have -999999 listed in both SUMMER_CAP and WINTER_CAP. Those plants were counted in the general plant count, but are assumed to be zeroes for this sum
total_ren_power = ren_power %>% filter(max_cap != -999999) %>% group_by(GEOID) %>% summarise(ren_power = sum(max_cap))
total_ren_power %<>% st_drop_geometry()

# Join data
counties_ren_power <- left_join(counties, county_plants, by = c("GEOID"))
counties_ren_power = left_join(counties_ren_power, total_ren_power, by = c("GEOID"))


# Missingness analysis (missing values are zeros)
pct_complete_case(counties_ren_power) # 56.72
pct_complete_var(counties_ren_power) # 77.78
pct_miss_var(counties_ren_power) # 22.22

n_var_complete(counties_ren_power) # 7 variables complete
n_var_miss(counties_ren_power) # Both variables of note have missingness
miss_var_summary(counties_ren_power)
# ren_power     116    43.3
# plant_count   116    43.3



# Replace NAs with zeros
counties_ren_power$plant_count %<>% replace_na(0)
counties_ren_power$ren_power %<>% replace_na(0)

write_rds(counties_ren_power, "data/natural/nat_hifld_2020/nat_hifld_2020_renewables.rds")

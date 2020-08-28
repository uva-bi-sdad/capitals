library(dplyr)
library(magrittr)
library(readr)
library(tidycensus)

# Read in USGS wind turbine data
turbines = read_csv("data/natural/nat_usgs_2020.csv")

# Keep only wind turbines in the three states of interest
turbines %<>% filter(t_state %in% c("IA", "OR", "VA"))

# Find the total kW produced by turbines in each county
co_turbines = turbines %>% group_by(t_fips) %>% summarise(total_kw = sum(t_cap, na.rm = T)) %>% ungroup()

# Change names
names(co_turbines) = c("GEOID", "total_kw")

# Read in County population file
counties = read_csv("data/natural/nat_census_2019_pop.csv")

# Add GEOID column for joining
counties %<>% mutate(GEOID = paste0(STATE, COUNTY))

# Get rid of state totals
counties %<>% filter(COUNTY != "000")

# Keep states and columns of interest
counties %<>% filter(STATE %in% c("19", "41", "51")) %>% select(GEOID, POPESTIMATE2019)

# Join data
usgs_windpower = left_join(counties, co_turbines)

# Adjust total_kw for population
usgs_windpower %<>% mutate(nat_windkwper10k = (total_kw/POPESTIMATE2019) * 10000)

# Add geometries
Sys.getenv("CENSUS_API_KEY")

acsdata <- get_acs(geography = "county", state = c(19, 41, 51), 
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, NAME.x, ALAND, AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)

usgs_windpower <- left_join(acsdata, usgs_windpower, by = "GEOID")

# Write dataframe to rds file
write_rds(usgs_windpower, "data/natural/nat_usgs_2020.rds")

library(dplyr)
library(magrittr)
library(readr)

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

# Write dataframe to rds file
write_rds(usgs_windpower, "data/natural/nat_usgs_2020.rds")

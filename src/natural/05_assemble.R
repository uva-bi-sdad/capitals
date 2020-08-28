library(dplyr)
library(readr)
library(sf)
library(naniar)

# Read in each individual data file
nass = read_rds("data/natural/nat_nass_2017.rds")
rwj = read_rds("data/natural/nat_rwj_2020.rds")
fsa = read_rds("data/natural/nat_fsa_2020.rds")
usgs = read_rds("data/natural/nat_usgs_2020.rds")


# Join data files
nat_cap = left_join(nass %>% select(-State, -County), rwj %>% select(nat_particulatedensity, GEOID, State, County), by = "GEOID")
nat_cap = left_join(nat_cap, fsa %>% select(GEOID, nat_rarecrpper10kacres, nat_polcrpper10kacres, nat_wildlifecrpper10kacres), by = "GEOID")
nat_cap = left_join(nat_cap, usgs, by = "GEOID")


# Keep columns of interest
nat_cap %<>% mutate(state = State, county = County)
nat_cap %<>% select(STATEFP, state, COUNTYFP, county, GEOID, starts_with("nat_"))


#
# Missingness -----------------------------------------------------------------------
#

# This is for both cities and counties.
pct_complete_case(nat_cap) # 2.61
pct_complete_var(nat_cap) # 50
pct_miss_var(nat_cap) # 50

n_var_complete(nat_cap) # 7 variables complete
n_var_miss(nat_cap) # 7 have missingness
miss_var_summary(nat_cap)
# nat_windkwper10k              207    77.2 
# nat_rarecrpper10kacres        163    60.8 
# nat_wildlifecrpper10kacres    161    60.1 
# nat_polcrpper10kacres         154    57.5
# nat_agritourrevper10kacres    140    52.2
# nat_forestryrevper10kacres    134    50
# nat_pctagacres                35     13.1

# Only two actual variables of interest that are complete are nat_pctwater and nat_particulatedensity

write_rds(nat_cap, "data/natural/nat_final.rds")
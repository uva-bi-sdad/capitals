library(dplyr)
library(readr)
library(sf)
library(naniar)
library(magrittr)
library(sf)

# Read in each individual data file
nass = read_rds("data/natural/nat_nass_2017.rds")
rwj = read_rds("data/natural/nat_rwj_2020.rds") %>% st_drop_geometry()
fsa = read_rds("data/natural/nat_fsa_2020.rds") %>% st_drop_geometry()
usgs = read_rds("data/natural/nat_usgs_2020.rds") %>% st_drop_geometry()


# Join data files
nat_cap = left_join(nass, rwj, by = c("STATEFP", "COUNTYFP", "GEOID", "NAME.x", "ALAND", "AWATER", "NAME.y"))
nat_cap = left_join(nat_cap, fsa, by = c("STATEFP", "COUNTYFP", "GEOID", "NAME.x", "ALAND", "AWATER", "NAME.y", "ALAND_acres", "AWATER_acres", "total_area"))
nat_cap = left_join(nat_cap, usgs, by = c("STATEFP", "COUNTYFP", "GEOID", "NAME.x", "ALAND", "AWATER", "NAME.y"))


# Keep columns of interest
nat_cap %<>% select(STATEFP, State, COUNTYFP, County, GEOID, starts_with("nat_"))


#
# Missingness -----------------------------------------------------------------------
#

# This is for both cities and counties.
pct_complete_case(nat_cap) # 2.61
pct_complete_var(nat_cap) # 50
pct_miss_var(nat_cap) # 50

n_var_complete(nat_cap) # 8 variables complete
n_var_miss(nat_cap) # 8 have missingness
miss_var_summary(nat_cap)
# 1 nat_windkwper10k              207   77.2  
# 2 nat_rarecrpper10kacres        163   60.8  
# 3 nat_wildlifecrpper10kacres    161   60.1  
# 4 nat_polcrpper10kacres         154   57.5  
# 5 nat_agritourrevper10kacres    140   52.2  
# 6 nat_forestryrevper10kacres    134   50    
# 7 nat_pctagacres                 35   13.1  
# 8 nat_zparticulatedensity         1    0.373

# Only two actual variables of interest that are complete are nat_pctwater and nat_particulatedensity

write_rds(nat_cap, "data/natural/nat_final.rds")
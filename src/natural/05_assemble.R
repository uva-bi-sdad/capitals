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


#
# Quintiles -----------------------------------------------------------------------
#

# Code in the "asset" direction. Higher quintile = better.
# Preserve NAs -- end result should be NA if any index indicator is NA. 

# Define function
calcquint <- function(whichvar) {
  cut(whichvar, 
      quantile(whichvar, 
               prob = seq(0, 1, length = 6), na.rm = TRUE), 
      labels = FALSE, include.lowest = TRUE, right = FALSE)   
}

# Quantity of Resources Index: Percent of county area in farmland, Percent of county area in water, Forestry sales per 10,000 acres, Agri-tourism and recreational revenue per 10,000 acres
# nat_pctagacres, nat_pctwater, nat_forestryrevper10kacres, nat_agritourrevper10kacres
data <- data %>% group_by(STATEFP) %>%
  mutate(nat_pctagacres_q = calcquint(nat_pctagacres),
         nat_pctwater_q = calcquint(nat_pctwater),
         nat_forestryrevper10kacres_q = calcquint(nat_forestryrevper10kacres),
         nat_agritourrevper10kacres_q = calcquint(nat_agritourrevper10kacres),
         nat_index_quantres = (nat_pctagacres_q + nat_pctwater_q + nat_forestryrevper10kacres_q + nat_agritourrevper10kacres_q) / 4) %>%
  ungroup()

# Quality of Resources Index: Average daily density of fine particulate matter
# nat_particulatedensity
data <- data %>% group_by(STATEFP) %>%
  mutate(nat_particulatedensity_q = calcquint(nat_particulatedensity),
         nat_index_qualres = (nat_particulatedensity_q) / 1) %>%
  ungroup()

# Conservation Effort Index: Acres of pollinator habitat CRP per 10,000 total acres, Acres of wildlife habitat CRP per 10,000 total acres, Acres of rare and declining habitat CRP per 10,000 total acres, kW produced by wind turbines per 10,000 population
# nat_polcrpper10kacres, nat_wildlifecrpper10kacres, nat_rarecrpper10kacres, nat_windkwper10k
data <- data %>% group_by(STATEFP) %>%
  mutate(nat_polcrpper10kacres_q = calcquint(nat_polcrpper10kacres),
         nat_wildlifecrpper10kacres_q = calcquint(nat_wildlifecrpper10kacres),
         nat_rarecrpper10kacres_q = calcquint(nat_rarecrpper10kacres),
         nat_windkwper10k_q = calcquint(nat_windkwper10k),
         nat_index_conserv = (nat_polcrpper10kacres_q + nat_wildlifecrpper10kacres_q + nat_rarecrpper10kacres_q + nat_windkwper10k_q) / 4) %>%
  ungroup()


#
# Write -----------------------------------------------------------------------
#

write_rds(nat_cap, "data/natural/nat_final.rds")
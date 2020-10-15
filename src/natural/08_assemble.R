library(dplyr)
library(readr)
library(sf)
library(naniar)
library(magrittr)
library(sf)
library(readxl)
library(janitor)


# Read in each individual data file
nass = read_rds("rivanna_data/natural/nat_nass_2017.rds")
rwj = read_rds("rivanna_data/natural/nat_rwj_2020.rds") %>% st_drop_geometry()
fsa = read_rds("rivanna_data/natural/nat_fsa_2020.rds") %>% st_drop_geometry()
usgs = read_rds("rivanna_data/natural/nat_usgs_2020.rds") %>% st_drop_geometry()
# hifld = read_rds("rivanna_data/natural/nat_hifld_2020/nat_hifld_2020.rds") %>% st_drop_geometry()        power plants and wells
trails = read_rds("rivanna_data/natural/nat_usgs_2020_trails/nat_usgs_2020_trails.rds") %>% st_drop_geometry()  
renew = read_rds("rivanna_data/natural/nat_hifld_2020/nat_hifld_2020_renewables.rds") %>% st_drop_geometry()

rurality <- read_excel("./rivanna_data/rurality/IRR_2000_2010.xlsx", 
                       sheet = 2, range = cell_cols("A:C"), col_types = c("text", "text", "numeric")) %>% clean_names()
rurality$fips2010 <- ifelse(nchar(rurality$fips2010) == 4, paste0("0", rurality$fips2010), rurality$fips2010)


# Join data files
nat_cap = left_join(nass, rwj, by = c("STATEFP", "COUNTYFP", "GEOID", "NAME.x", "ALAND", "AWATER", "NAME.y"))
nat_cap = left_join(nat_cap, fsa, by = c("STATEFP", "COUNTYFP", "GEOID", "NAME.x", "ALAND", "AWATER", "NAME.y", "ALAND_acres", "AWATER_acres", "total_area"))
nat_cap = left_join(nat_cap, usgs, by = c("STATEFP", "COUNTYFP", "GEOID", "NAME.x", "ALAND", "AWATER", "NAME.y"))
nat_cap = left_join(nat_cap, trails, by = c("STATEFP", "COUNTYFP", "GEOID", "ALAND", "AWATER", "NAME", "POPESTIMATE2019"))
nat_cap = left_join(nat_cap, renew, by = c("STATEFP", "COUNTYFP", "GEOID", "ALAND", "AWATER", "NAME", "POPESTIMATE2019"))
nat_cap <- left_join(nat_cap, rurality, by = c("GEOID" = "fips2010", "NAME.y" = "county_name"))

# Keep columns of interest
nat_cap %<>% select(STATEFP, State, COUNTYFP, County, GEOID, NAME.y, starts_with("nat_"), irr2010, geometry)
nat_cap %<>% rename(state = State, county = County)

#
# Recode rurality  -----------------------------------------------------------------------
#


nat_cap <- nat_cap %>% mutate(irr2010_discretize = case_when(irr2010 < 0.15 ~ "Urban [0.12, 0.15)",
                                                       irr2010 >= 0.15 & irr2010 < 0.25 ~ "Urban [0.15, 0.25)",
                                                       irr2010 >= 0.25 & irr2010 < 0.35 ~ "Urban [0.25, 0.35)",
                                                       irr2010 >= 0.35 & irr2010 < 0.45 ~ "Urban [0.35, 0.45)",
                                                       irr2010 >= 0.45 & irr2010 < 0.55 ~ "In-between [0.45, 0.55)",
                                                       irr2010 >= 0.55 & irr2010 < 0.65 ~ "Rural [0.55, 0.65)",
                                                       irr2010 >= 0.65 ~ "Rural [0.65, 0.68]"
))
nat_cap$irr2010_discretize <- factor(nat_cap$irr2010_discretize,
                                  levels = c("Urban [0.12, 0.15)", "Urban [0.15, 0.25)", "Urban [0.25, 0.35)",
                                             "Urban [0.35, 0.45)", "In-between [0.45, 0.55)", "Rural [0.55, 0.65)",
                                             "Rural [0.65, 0.68]"))


#
# Missingness -----------------------------------------------------------------------
#

# This is for both cities and counties.
pct_complete_case(nat_cap) # 2.61
pct_complete_var(nat_cap) # 56.25
pct_miss_var(nat_cap) # 43.75

n_var_complete(nat_cap) # 9 variables complete
n_var_miss(nat_cap) # 7 have missingness
miss_var_summary(nat_cap)
# 1 nat_agritourrevper10kacres    116   43.3  
# 2 nat_forestryrevper10kacres    105   39.2  
# 3 nat_rarecrpper10kacres         45   16.8  
# 4 nat_polcrpper10kacres          45   16.8  
# 5 nat_wildlifecrpper10kacres     45   16.8  
# 6 nat_pctagacres                 35   13.1  
# 7 nat_zparticulatedensity         1    0.373

# Only three actual variables of interest that are complete are nat_pctwater, nat_windkwper10k, nat_particulatedensity


#
# Quintiles -----------------------------------------------------------------------
#

# Code in the "asset" direction. Higher quintile = better.
# Preserve NAs -- end result should be NA if any index indicator is NA. 

# Define function: Quintiles
calcquint <- function(whichvar) {
  cut(whichvar, 
      quantile(whichvar, 
               prob = seq(0, 1, length = 6), na.rm = TRUE), 
      labels = FALSE, include.lowest = TRUE, right = FALSE)   
}

# Define function: Terciles
calcterc <- function(whichvar) {
  cut(whichvar, 
      quantile(whichvar, 
               prob = seq(0, 1, length = 4), na.rm = TRUE), 
      labels = FALSE, include.lowest = TRUE, right = FALSE)   
}

# Recode 0s to LOWEST quintile.

# QUINTILE, QUARTILE, TERCILE BREAKS ARE NOT UNIQUE            
# Quantity of Resources Index: Percent of county area in farmland, Percent of county area in water, Forestry sales per 10,000 acres, Agri-tourism and recreational revenue per 10,000 acres
# nat_pctagacres, nat_pctwater, nat_forestryrevper10kacres, nat_agritourrevper10kacres
nat_cap <- nat_cap %>% group_by(STATEFP) %>%
  mutate(nat_pctagacres_q = ifelse(nat_pctagacres != 0, calcquint(nat_pctagacres[nat_pctagacres != 0]), 1),
         nat_pctwater_q = ifelse(nat_pctwater != 0, calcquint(nat_pctwater[nat_pctagacres != 0]), 1),
         nat_forestryrevper10kacres_q = ifelse(nat_forestryrevper10kacres != 0, calcquint(nat_forestryrevper10kacres[nat_forestryrevper10kacres != 0]), 1),
         nat_agritourrevper10kacres_q = ifelse(nat_agritourrevper10kacres != 0, calcquint(nat_agritourrevper10kacres[nat_agritourrevper10kacres != 0]), 1),
         nat_index_quantres = (nat_pctagacres_q + nat_pctwater_q + nat_forestryrevper10kacres_q + nat_agritourrevper10kacres_q) / 4) %>%
  ungroup()

# Quality of Resources Index: Average daily density of fine particulate matter
# nat_particulatedensity
# ! NEED TO REVERSE CODE nat_particulatedensity
nat_cap <- nat_cap %>% group_by(STATEFP) %>%
  mutate(nat_particulatedensity_q = calcquint(nat_particulatedensity),
         nat_particulatedensity_q = case_when(nat_particulatedensity_q == 5 ~ 1,
                                              nat_particulatedensity_q == 4 ~ 2,
                                              nat_particulatedensity_q == 3 ~ 3,
                                              nat_particulatedensity_q == 2 ~ 4,
                                              nat_particulatedensity_q == 1 ~ 5,
                                              is.na(nat_particulatedensity_q) ~ NA_real_),
         nat_index_qualres = (nat_particulatedensity_q) / 1) %>%
  ungroup()

# BREAKS ARE NOT UNIQUE
# Conservation Effort Index: Acres of pollinator habitat CRP per 10,000 total acres, Acres of wildlife habitat CRP per 10,000 total acres, Acres of rare and declining habitat CRP per 10,000 total acres, kW produced by wind turbines per 10,000 population
# # nat_polcrpper10kacres, nat_wildlifecrpper10kacres, nat_rarecrpper10kacres, nat_windkwper10k
# nat_cap <- nat_cap %>% group_by(STATEFP) %>%
#   mutate(nat_polcrpper10kacres_q = ifelse(nat_polcrpper10kacres != 0, calcquint(nat_polcrpper10kacres[nat_polcrpper10kacres != 0]), 1), 
#          nat_wildlifecrpper10kacres_q = ifelse(nat_wildlifecrpper10kacres != 0, calcquint(nat_wildlifecrpper10kacres[nat_wildlifecrpper10kacres != 0]), 1),
#          nat_rarecrpper10kacres_q = ifelse(nat_rarecrpper10kacres != 0, calcquint(nat_rarecrpper10kacres[nat_rarecrpper10kacres != 0]), 1),
#          nat_windkwper10k_q = ifelse(nat_windkwper10k != 0, calcterc(nat_windkwper10k[nat_windkwper10k != 0]), 1), 
#          nat_index_conserv = (nat_polcrpper10kacres_q + nat_wildlifecrpper10kacres_q + nat_rarecrpper10kacres_q + nat_windkwper10k_q) / 4) %>%
#   ungroup()

# Instead, could sum habitat types and treat as one variable
nat_cap <- nat_cap %>% mutate(nat_habitat = nat_polcrpper10kacres + nat_wildlifecrpper10kacres + nat_rarecrpper10kacres)

nat_cap <- nat_cap %>% group_by(STATEFP) %>%
  mutate(nat_habitat_q = ifelse(nat_habitat != 0, calcquint(nat_habitat[nat_habitat != 0]), 1),
         nat_windkwper10k_q = ifelse(nat_windkwper10k != 0, calcquint(nat_windkwper10k[nat_windkwper10k != 0]), 1),
         nat_index_conserv = (nat_habitat_q + nat_windkwper10k_q) / 2) %>%
  ungroup()


# Note: "nat_windkwper10k"          "nat_trailsper1k"            "nat_renpowerper1k"          "nat_renplantsper1k"
# These variables are not in use yet.


#
# Write -----------------------------------------------------------------------
#

write_rds(nat_cap, "rivanna_data/natural/nat_final.Rds")

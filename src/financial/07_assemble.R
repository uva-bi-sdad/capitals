library(dplyr)
library(readr)
library(sf)
library(naniar)


#
# Read in -----------------------------------------------------------------------
#

data_acs <- read_rds("./rivanna_data/financial/fin_acs_2018.Rds")
data_cbp <- read_rds("./rivanna_data/financial/fin_cbp_2018.Rds") %>% st_drop_geometry()
data_laus <- read_rds("./rivanna_data/financial/fin_laus_2020.Rds") %>% st_drop_geometry()
data_nass <- read_rds("./rivanna_data/financial/fin_nass_2017.Rds") %>% st_drop_geometry()
data_urban <- read_rds("./rivanna_data/financial/fin_urban_2018.Rds") %>% st_drop_geometry()


#
# Join -----------------------------------------------------------------------
#

data <- left_join(data_acs, data_cbp, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "AFFGEOID", "GEOID", "LSAD", "NAME.x", "NAME.y"))
data <- left_join(data, data_laus, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "GEOID", "NAME.x", "NAME.y"))
data <- left_join(data, data_nass, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "GEOID", "NAME.x", "NAME.y", "ALAND", "AWATER")) %>% select(-county, -state)
data <- left_join(data, data_urban, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "GEOID", "NAME.x", "NAME.y", "ALAND", "AWATER"))


#
# Clean -----------------------------------------------------------------------
#

# What do to with independent cities?
data <- data %>% select(STATEFP, state, COUNTYFP, county, GEOID, NAME.x, NAME.y, area_name, starts_with("fin_"), geometry)


#
# Missingness -----------------------------------------------------------------------
#

# This is for both cities and counties.
pct_complete_case(data) # 83.95
pct_complete_var(data) # 85.71
pct_miss_var(data) # 14.28

n_var_complete(data) # 24 variables complete
n_var_miss(data) # 4 have missingness
miss_var_summary(data)
# fin_netincperfarm     37    13.8 
# fin_landvalacre       35    13.1 
# fin_pctagacres        35    13.1 
# fin_pctdebtcol        6     2.24


#
# Write -----------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/financial/fin_final.Rds")

library(dplyr)
library(readr)
library(sf)


#
# Read in -----------------------------------------------------------------------
#

data_acs <- read_rds("./data/financial/fin_acs_2018.Rds")
data_cbp <- read_rds("./data/financial/fin_cbp_2018.Rds") %>% st_drop_geometry()
data_laus <- read_rds("./data/financial/fin_laus_2020.Rds") %>% st_drop_geometry()
data_nass <- read_rds("./data/financial/fin_nass_2017.Rds") %>% st_drop_geometry()
data_urban <- read_rds("./data/financial/fin_urban_2018.Rds") %>% st_drop_geometry()


#
# Join -----------------------------------------------------------------------
#

data <- left_join(data_acs, data_cbp, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "AFFGEOID", "GEOID", "LSAD", "NAME.x", "NAME.y"))
data <- left_join(data, data_laus, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "GEOID", "NAME.x", "NAME.y"))
data <- left_join(data, data_nass, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "GEOID", "NAME.x", "NAME.y", "ALAND", "AWATER"))
data <- left_join(data, data_urban, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "GEOID", "NAME.x", "NAME.y", "ALAND", "AWATER", "state", "county"))


#
# Clean -----------------------------------------------------------------------
#

data <- data %>% select(STATEFP, state, COUNTYFP, county, GEOID, NAME.x, NAME.y, area_name, starts_with("fin_"), geometry)

# What do to with independent cities?




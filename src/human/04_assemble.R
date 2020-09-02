library(dplyr)
library(readr)
library(sf)
library(naniar)


#
# Read in -----------------------------------------------------------------------
#

data_acs <- read_rds("./rivanna_data/human/hum_acs_2018.rds")
data_cdc <- read_rds("./rivanna_data/human/hum_cdc_2018.rds") %>% st_drop_geometry()
data_rwj <- read_rds("./rivanna_data/human/hum_rwj_2020.rds") %>% st_drop_geometry()


#
# Join -----------------------------------------------------------------------
#

data <- left_join(data_acs, data_cdc, by = c("STATEFP", "COUNTYFP", "GEOID"))
data <- left_join(data, data_rwj, by = c("STATEFP", "COUNTYFP", "GEOID"))


#
# De-select columns -----------------------------------------------------------------------
#

data <- data %>%
  select(-County.x, -pop, -State, -County.y)


#
# Missingness -----------------------------------------------------------------------
#

# This is for both cities and counties.
pct_complete_case(data) # 92.91
pct_complete_var(data) # 90.48
pct_miss_var(data) # 9.52

n_var_complete(data) # 19 variables complete
n_var_miss(data) # 2 have missingness
miss_var_summary(data)
# hum_ratementalhp     14     5.22
# hum_ratepcp           6     2.24


#
# Write -----------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/human/hum_final.Rds")





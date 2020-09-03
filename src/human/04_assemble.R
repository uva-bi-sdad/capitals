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
  select(-County, -county, -pop, -State, -AFFGEOID, -COUNTYNS, -LSAD)


#
# Missingness -----------------------------------------------------------------------
#

# This is for both cities and counties.
pct_complete_case(data) # 5.59
pct_complete_var(data) # 72.2
pct_miss_var(data) # 27.7

n_var_complete(data) # 13 variables complete
n_var_miss(data) # 5 have missingness
miss_var_summary(data)
# 1 hum_ratedrgdeaths    246    91.8 
# 2 hum_ratealcdeaths    243    90.7 
# 3 hum_ratesuideaths    238    88.8 
# 4 hum_ratementalhp      14     5.22
# 5 hum_ratepcp            6     2.24


#
# Composites -----------------------------------------------------------------------
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

# Health index
# Average number of reported poor physical health days in a month, Average number of reported poor mental health days in a month, Percentage of adults that report no leisure-time physical activity
# Primary care physicians per 100,000 population, Mental health providers per 100,000 population
# hum_numpoorphys, hum_numpoormental, hum_pctnophys, hum_ratepcp, hum_ratementalhp

# Child care index
# Women to men pay ratio, Percent of children living in a single-parent household, Percent of women who did not receive HS diploma or equivalent
# hum_ratioFMpay, hum_pctsngparent, hum_pctFnohs

# Despair index
# Number of alcohol deaths per 100,000 population, Number of drug dreaths per 100,000 population, Number of suicide deaths per 100,000 population
# hum_ratealcdeaths, hum_ratedrgdeaths, hum_ratesuideaths



#
# Write -----------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/human/hum_final.Rds")





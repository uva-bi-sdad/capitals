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

# Commerce index: Number of businesses per 10,000 people, Number of new businesses per 10,000 people
# fin_estper10k, fin_newestper10k
data <- data %>% group_by(STATEFP) %>%
                 mutate(fin_estper10k_q = calcquint(fin_estper10k),
                        fin_newestper10k_q = calcquint(fin_newestper10k),
                        fin_index_commerce = (fin_estper10k_q + fin_newestper10k_q) / 2) %>%
                 ungroup()

# Agriculture Index
# Percent county in agriculture acres, Land value per acre, Net income per farm operation, Percent employed in agriculture, forestry, fishing and hunting, mining industry
# fin_pctagacres, fin_landvalacre, fin_netincperfarm, fin_pctemplagri
data <- data %>% group_by(STATEFP) %>%
                 mutate(fin_pctagacres_q = calcquint(fin_pctagacres), 
                        fin_landvalacre_q = calcquint(fin_landvalacre),
                        fin_netincperfarm_q = calcquint(fin_netincperfarm),
                        fin_pctemplagri_q = calcquint(fin_pctemplagri),
                        fin_index_agri = (fin_pctagacres_q + fin_landvalacre_q + fin_netincperfarm_q + fin_pctemplagri_q) / 4) %>%
                 ungroup()

# Economic Diversification Index
# HHI of employment by industry, HHI of payroll by industry
# fin_emphhi, fin_aphhi
data <- data %>% group_by(STATEFP) %>%
                 mutate(fin_emphhi_q = calcquint(fin_emphhi), 
                        fin_aphhi_q = calcquint(fin_aphhi),
                        fin_index_divers = (fin_emphhi_q + fin_aphhi_q) / 2) %>%
                 ungroup()

# Employment Index
# Unemployment rate before COVID, Unemployment rate during COVID, Percent commuting 30min+, Percent of working age population in labor force
# fin_unempcovid, fin_unempprecovid, fin_pctcommute, fin_pctlabforce

# create fin_index_empl

# Financial Well-Being Index
# Gini Index of income inequality, Percent with income below poverty level in last 12 months, Percent households receiving public assistance or SNAP, Percent households receiving suplemental security income
# Median household income, Percent of people older than 25 with less than a four year degree, Share of people with a credit bureau record who have any debt in collections
# fin_gini, fin_pctinpov, fin_pctassist, fin_pctssi, fin_medinc, fin_pctlessba, fin_pctdebtcol

# create fin_index_well

#
# Write -----------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/financial/fin_final.Rds")

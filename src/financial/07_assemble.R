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
# ! NEED REVERSE CODE QUINTILE PLACEMENTS FOR: fin_unempcovid, fin_unempprecovid, fin_pctcommute
data <- data %>% group_by(STATEFP) %>%
  mutate(fin_unempcovid_q = calcquint(fin_unempcovid), 
         fin_unempcovid_q = case_when(fin_unempcovid_q == 5 ~ 1,
                                      fin_unempcovid_q == 4 ~ 2,
                                      fin_unempcovid_q == 3 ~ 3,
                                      fin_unempcovid_q == 2 ~ 4,
                                      fin_unempcovid_q == 1 ~ 5,
                                      is.na(fin_unempcovid_q) ~ NA_real_),
         fin_unempprecovid_q = calcquint(fin_unempprecovid),
         fin_unempprecovid_q = case_when(fin_unempprecovid_q == 5 ~ 1,
                                         fin_unempprecovid_q == 4 ~ 2,
                                         fin_unempprecovid_q == 3 ~ 3,
                                         fin_unempprecovid_q == 2 ~ 4,
                                         fin_unempprecovid_q == 1 ~ 5,
                                         is.na(fin_unempprecovid_q) ~ NA_real_),
         fin_pctcommute_q = calcquint(fin_pctcommute),
         fin_pctcommute_q = case_when(fin_pctcommute_q == 5 ~ 1,
                                      fin_pctcommute_q == 4 ~ 2,
                                      fin_pctcommute_q == 3 ~ 3,
                                      fin_pctcommute_q == 2 ~ 4,
                                      fin_pctcommute_q == 1 ~ 5,
                                      is.na(fin_pctcommute_q) ~ NA_real_),
         fin_pctlabforce_q = calcquint(fin_pctlabforce),
         fin_index_empl = (fin_unempcovid_q + fin_unempprecovid_q + fin_pctcommute_q + fin_pctlabforce_q) / 4) %>%
  ungroup()

# Financial Well-Being Index
# Gini Index of income inequality, Percent with income below poverty level in last 12 months, Percent households receiving public assistance or SNAP, Percent households receiving suplemental security income
# Median household income, Percent of people older than 25 with less than a four year degree, Share of people with a credit bureau record who have any debt in collections
# fin_gini, fin_pctinpov, fin_pctassist, fin_pctssi, fin_medinc, fin_pctlessba, fin_pctdebtcol
# ! NEED REVERSE CODE QUINTILE PLACEMENTS FOR: fin_gini, fin_pctinpov, fin_pctassist, fin_pctssi, fin_pctlessba, fin_pctdebtcol

data <- data %>% group_by(STATEFP) %>%
  mutate(fin_gini_q = calcquint(fin_gini), 
         fin_gini_q = case_when(fin_gini_q == 5 ~ 1,
                                fin_gini_q == 4 ~ 2,
                                fin_gini_q == 3 ~ 3,
                                fin_gini_q == 2 ~ 4,
                                fin_gini_q == 1 ~ 5,
                                is.na(fin_gini_q) ~ NA_real_),
         fin_pctinpov_q = calcquint(fin_pctinpov),
         fin_pctinpov_q = case_when(fin_pctinpov_q == 5 ~ 1,
                                    fin_pctinpov_q == 4 ~ 2,
                                    fin_pctinpov_q == 3 ~ 3,
                                    fin_pctinpov_q == 2 ~ 4,
                                    fin_pctinpov_q == 1 ~ 5,
                                    is.na(fin_pctinpov_q) ~ NA_real_),
         fin_pctassist_q = calcquint(fin_pctassist),
         fin_pctassist_q = case_when(fin_pctassist_q == 5 ~ 1,
                                     fin_pctassist_q == 4 ~ 2,
                                     fin_pctassist_q == 3 ~ 3,
                                     fin_pctassist_q == 2 ~ 4,
                                     fin_pctassist_q == 1 ~ 5,
                                      is.na(fin_pctassist_q) ~ NA_real_),
         fin_medinc_q = calcquint(fin_medinc),
         fin_pctssi_q = calcquint(fin_pctssi),
         fin_pctssi_q = case_when(fin_pctssi_q == 5 ~ 1,
                                  fin_pctssi_q == 4 ~ 2,
                                  fin_pctssi_q == 3 ~ 3,
                                  fin_pctssi_q == 2 ~ 4,
                                  fin_pctssi_q == 1 ~ 5,
                                  is.na(fin_pctssi_q) ~ NA_real_),
         fin_pctlessba_q = calcquint(fin_pctlessba),
         fin_pctlessba_q = case_when(fin_pctlessba_q == 5 ~ 1,
                                     fin_pctlessba_q == 4 ~ 2,
                                     fin_pctlessba_q == 3 ~ 3,
                                     fin_pctlessba_q == 2 ~ 4,
                                     fin_pctlessba_q == 1 ~ 5,
                                     is.na(fin_pctlessba_q) ~ NA_real_),
         fin_pctdebtcol_q = calcquint(fin_pctdebtcol),
         fin_pctdebtcol_q = case_when(fin_pctdebtcol_q == 5 ~ 1,
                                      fin_pctdebtcol_q == 4 ~ 2,
                                      fin_pctdebtcol_q == 3 ~ 3,
                                      fin_pctdebtcol_q == 2 ~ 4,
                                      fin_pctdebtcol_q == 1 ~ 5,
                                     is.na(fin_pctdebtcol_q) ~ NA_real_),
         fin_index_well = (fin_gini_q + fin_pctinpov_q + fin_pctassist_q + fin_medinc_q + fin_pctssi_q + fin_pctlessba_q + fin_pctdebtcol_q) / 7) %>%
  ungroup()


#
# Write -----------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/financial/fin_final.Rds")

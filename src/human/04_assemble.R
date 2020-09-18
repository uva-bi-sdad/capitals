library(dplyr)
library(readr)
library(sf)
library(naniar)
library(readxl)
library(janitor)
library(stringr)


#
# Read in -----------------------------------------------------------------------
#

data_acs <- read_rds("./rivanna_data/human/hum_acs_2018.rds")
data_cdc <- read_rds("./rivanna_data/human/hum_cdc_2018.rds") %>% st_drop_geometry()
data_rwj <- read_rds("./rivanna_data/human/hum_rwj_2020.rds") %>% st_drop_geometry()

rurality <- read_excel("./rivanna_data/rurality/IRR_2000_2010.xlsx", 
                       sheet = 2, range = cell_cols("A:C"), col_types = c("text", "text", "numeric")) %>% clean_names()
rurality$fips2010 <- ifelse(nchar(rurality$fips2010) == 4, paste0("0", rurality$fips2010), rurality$fips2010)


#
# Join -----------------------------------------------------------------------
#

data <- left_join(data_acs, data_cdc, by = c("STATEFP", "COUNTYFP", "GEOID"))
data <- left_join(data, data_rwj, by = c("STATEFP", "COUNTYFP", "GEOID"))
data <- left_join(data, rurality, by = c("GEOID" = "fips2010", "NAME.y" = "county_name"))


#
# De-select columns -----------------------------------------------------------------------
#

data <- data %>%
  select(-County, -county, -population, -State, -AFFGEOID, -COUNTYNS, -LSAD)


#
# Recode rurality  -----------------------------------------------------------------------
#

data <- data %>% mutate(irr2010_discretize = case_when(irr2010 < 0.15 ~ "[0.12, 0.15)",
                                                       irr2010 >= 0.15 & irr2010 < 0.25 ~ "[0.15, 0.25)",
                                                       irr2010 >= 0.25 & irr2010 < 0.35 ~ "[0.25, 0.35)",
                                                       irr2010 >= 0.35 & irr2010 < 0.45 ~ "[0.35, 0.45)",
                                                       irr2010 >= 0.45 & irr2010 < 0.55 ~ "[0.45, 0.55)",
                                                       irr2010 >= 0.55 & irr2010 < 0.65 ~ "[0.55, 0.65)",
                                                       irr2010 >= 0.65 ~ "[0.65, 0.68]"
                                                       ))

data$irr2010_discretize <- factor(data$irr2010_discretize,
                                  levels = c("[0.12, 0.15)", "[0.15, 0.25)", "[0.25, 0.35)", "[0.35, 0.45)",
                                             "[0.45, 0.55)", "[0.55, 0.65)", "[0.65, 0.68]"))

#
# Missingness -----------------------------------------------------------------------
#

# This is for both cities and counties.
pct_complete_case(data) # 79.85075
pct_complete_var(data) # 70.83333
pct_miss_var(data) # 29.16667

n_var_complete(data) # 17 variables complete
n_var_miss(data) # 7 have missingness
miss_var_summary(data)

# 1 hum_reading             28    10.4 
# 2 hum_math                26     9.70
# 3 hum_cruderatedeaths     16     5.97
# 4 hum_ageratedeaths       16     5.97
# 5 hum_ratementalhp        14     5.22
# 6 hum_ratepcp              6     2.24
# 7 hum_deaths               5     1.87


#
# Composites -----------------------------------------------------------------------
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

# Education index
# Percent of population with at least a high school degree, Reading proficiency, Math proficiency
# hum_pcths, hum_reading, hum_math
data <- data %>% group_by(STATEFP) %>%
  mutate(hum_pcths_q = calcquint(hum_pcths), 
         hum_reading_q = calcquint(hum_reading),
         hum_math_q = calcquint(hum_math),
         hum_index_edu = (hum_pcths_q + hum_reading_q + hum_math_q) / 3) %>%
  ungroup()

# Health index
# Average number of reported poor physical health days in a month, Average number of reported poor mental health days in a month, Percentage of adults that report no leisure-time physical activity
# Primary care physicians per 100,000 population, Mental health providers per 100,000 population
# hum_numpoorphys, hum_numpoormental, hum_pctnophys, hum_ratepcp, hum_ratementalhp
# ! NEED TO REVERSE CODE QUINTILE PLACEMENTS FOR: hum_numpoorphys, hum_numpoormental, hum_pctnophys
data <- data %>% group_by(STATEFP) %>%
  mutate(hum_numpoorphys_q = calcquint(hum_numpoorphys), 
         hum_numpoorphys_q = case_when(hum_numpoorphys_q == 5 ~ 1,
                                       hum_numpoorphys_q == 4 ~ 2,
                                       hum_numpoorphys_q == 3 ~ 3,
                                       hum_numpoorphys_q == 2 ~ 4,
                                       hum_numpoorphys_q == 1 ~ 5,
                                      is.na(hum_numpoorphys_q) ~ NA_real_),
         hum_numpoormental_q = calcquint(hum_numpoormental),
         hum_numpoormental_q = case_when(hum_numpoormental_q == 5 ~ 1,
                                         hum_numpoormental_q == 4 ~ 2,
                                         hum_numpoormental_q == 3 ~ 3,
                                         hum_numpoormental_q == 2 ~ 4,
                                         hum_numpoormental_q == 1 ~ 5,
                                         is.na(hum_numpoormental_q) ~ NA_real_),
         hum_pctnophys_q = calcquint(hum_pctnophys),
         hum_pctnophys_q = case_when(hum_pctnophys_q == 5 ~ 1,
                                     hum_pctnophys_q == 4 ~ 2,
                                     hum_pctnophys_q == 3 ~ 3,
                                     hum_pctnophys_q == 2 ~ 4,
                                     hum_pctnophys_q == 1 ~ 5,
                                     is.na(hum_pctnophys_q) ~ NA_real_),
         hum_numpoormental_q = calcquint(hum_numpoormental),
         hum_ratementalhp_q = calcquint(hum_ratementalhp),
         hum_index_health = (hum_numpoorphys_q + hum_numpoormental_q + hum_pctnophys_q + hum_numpoormental_q + hum_ratementalhp_q) / 5) %>%
  ungroup()

# Child care index
# Women to men pay ratio, Percent of children living in a single-parent household, Percent of women who did not receive HS diploma or equivalent
# hum_ratioFMpay, hum_pctsngparent, hum_pctFnohs
# ! NEED TO REVERSE CODE QUINTILE PLACEMENT FOR: hum_pctsngparent, hum_pctFnohs
data <- data %>% group_by(STATEFP) %>%
  mutate(hum_ratioFMpay_q = calcquint(hum_ratioFMpay), 
         hum_pctsngparent_q = calcquint(hum_pctsngparent),
         hum_pctsngparent_q = case_when(hum_pctsngparent_q == 5 ~ 1,
                                         hum_pctsngparent_q == 4 ~ 2,
                                         hum_pctsngparent_q == 3 ~ 3,
                                         hum_pctsngparent_q == 2 ~ 4,
                                         hum_pctsngparent_q == 1 ~ 5,
                                         is.na(hum_pctsngparent_q) ~ NA_real_),
         hum_pctFnohs_q = calcquint(hum_pctFnohs),
         hum_pctFnohs_q = case_when(hum_pctFnohs_q == 5 ~ 1,
                                    hum_pctFnohs_q == 4 ~ 2,
                                    hum_pctFnohs_q == 3 ~ 3,
                                    hum_pctFnohs_q == 2 ~ 4,
                                    hum_pctFnohs_q == 1 ~ 5,
                                    is.na(hum_pctFnohs_q) ~ NA_real_),
         hum_index_child = (hum_ratioFMpay_q + hum_pctsngparent_q + hum_pctFnohs_q) / 3) %>%
  ungroup()

# Despair index
# WARNING -- THIS IS A DEFICIT COMPOSITE, NOT AN ASSET!!!!! WE PRESERVE CODING IN THE NEGATIVE DIRECTION.
# Percent divorced or separated, Percent population in labor force unemployed, Percent white men with high school education or lower,
# Age-adjusted rate of alcohol, overdose, and suicide deaths per 100,000 population between 2010-2018
# hum_pctdivorc, hum_pctunemp,  hum_whitemhs, hum_ageratedeaths
# WARNING -- THIS IS A DEFICIT COMPOSITE, NOT AN ASSET!!!!! WE PRESERVE CODING IN THE NEGATIVE DIRECTION.
data <- data %>% group_by(STATEFP) %>%
  mutate(hum_pctdivorc_q = calcquint(hum_pctdivorc),
         hum_pctunemp_q = calcquint(hum_pctunemp),
         hum_whitemhs_q = calcquint(hum_whitemhs),
         hum_ageratedeaths_q = calcquint(hum_ageratedeaths),
         hum_index_despair = (hum_pctdivorc_q + hum_pctunemp_q + hum_whitemhs_q + hum_ageratedeaths_q) / 4) %>%
  ungroup()

# Make state and county columns
data$state <- ifelse(data$STATEFP == "19", "Iowa", ifelse(data$STATEFP == "41", "Oregon", "Virginia"))
data$county <- str_remove_all(pattern = c(", Virginia|, Oregon|, Iowa"), data$NAME.y)


#
# Write -----------------------------------------------------------------------
#

# Write
write_rds(data, "./rivanna_data/human/hum_final.Rds")












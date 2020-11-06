rm(list = ls())

library(tidyverse)
library(readr)
library(readxl)
library(naniar)
library(janitor)
library(sf)

# county level data -----------------------------------------------------------------------

acs_data <- read_rds("./rivanna_data/built/built_acs_2018.Rds")
hud_data <- read_rds("./rivanna_data/built/built_hud_2019.Rds") %>% st_drop_geometry()
fcc_data <- read_rds("./rivanna_data/built/built_fcc_2019.Rds") %>% st_drop_geometry()
dot_data <- read_rds("./rivanna_data/built/built_dot_2020.Rds") 
imls_data <- read_rds("./rivanna_data/built/built_imls_2018.rds")
hifld_data <- read_rds("./rivanna_data/built/built_hifld_2020.rds") %>% st_drop_geometry()
hrsa_data <- read_rds("./rivanna_data/built/built_hrsa_2019.Rds")
#irs_data <- read_rds("./rivanna_data/built/built_acs_2018.Rds")
#epa_data <- read_rds("./rivanna_data/built/built_acs_2018.Rds")


# pull in rurality data -----------------------------------------------------------------------

rurality <- read_excel("./rivanna_data/rurality/IRR_2000_2010.xlsx", 
                       sheet = 2, range = cell_cols("A:C"), col_types = c("text", "text", "numeric")) %>% clean_names()
rurality$fips2010 <- ifelse(nchar(rurality$fips2010) == 4, paste0("0", rurality$fips2010), rurality$fips2010)

# join all the data together -----------------------------------------------------------------------

data <- left_join(acs_data, hud_data, by = c("STATEFP", "COUNTYFP", "GEOID", "NAME.x", "NAME.y"))
data <- left_join(data, fcc_data, by = c("STATEFP", "COUNTYFP", "COUNTYNS", "GEOID", "NAME.x", "NAME.y"))
data <- left_join(data, dot_data, by = "GEOID")
data <- left_join(data, imls_data, by = "GEOID")
data <- left_join(data, hifld_data, by = c("STATEFP", "COUNTYFP", "GEOID", "NAME.x", "NAME.y"))
data <- left_join(data, hrsa_data, by = c("STATEFP", "GEOID", "NAME.y")) 
data <- left_join(data, rurality, by = c("GEOID" = "fips2010", "NAME.y" = "county_name"))


#
# De-select columns -----------------------------------------------------------------------
#

#data <- data %>%
#  select(-AFFGEOID, -COUNTYNS, -LSAD) # others later 

#
# Recode rurality  -----------------------------------------------------------------------
#

data <- data %>% mutate(irr2010_discretize = case_when(irr2010 < 0.15 ~ "Most Urban [0.12, 0.15)",
                                                       irr2010 >= 0.15 & irr2010 < 0.25 ~ "More Urban [0.15, 0.25)",
                                                       irr2010 >= 0.25 & irr2010 < 0.35 ~ "Urban [0.25, 0.35)",
                                                       irr2010 >= 0.35 & irr2010 < 0.45 ~ "In-Between [0.35, 0.45)",
                                                       irr2010 >= 0.45 & irr2010 < 0.55 ~ "Rural [0.45, 0.55)",
                                                       irr2010 >= 0.55 & irr2010 < 0.65 ~ "More Rural [0.55, 0.65)",
                                                       irr2010 >= 0.65 ~ "Most Rural [0.65, 0.68]"
))
data$irr2010_discretize <- factor(data$irr2010_discretize,
                                  levels = c("Most Urban [0.12, 0.15)", "More Urban [0.15, 0.25)", "Urban [0.25, 0.35)",
                                             "In-Between [0.35, 0.45)", "Rural [0.45, 0.55)", "More Rural [0.55, 0.65)",
                                             "Most Rural [0.65, 0.68]"))

#
# Missingness -----------------------------------------------------------------------
#

# This is for both cities and counties.
pct_complete_case(data) 
pct_complete_var(data) 
pct_miss_var(data) 

# calculate composites here 
# see https://github.com/uva-bi-sdad/capitals/blob/master/src/human/04_assemble.R


#
# Composite Creation 
#

data <- data %>% # telecom 
  mutate(ALAND_acres = ALAND * 0.00024711, 
         AWATER_acres = AWATER * 0.00024711,
         total_area = ALAND_acres + AWATER_acres,
         pcp_facs = replace_na(pcp_facs, 0),
         nhsc_facs = replace_na(nhsc_facs, 0),
         dental_facs = replace_na(dental_facs, 0),
         mentalhealth_facs = replace_na(mentalhealth_facs, 0),
         built_publibs = replace_na(built_publibs, 0),
         #built_lib_avcomputers= replace_na(built_lib_avcomputers, 0),
         #built_lib_computeruse = replace_na(built_lib_computeruse, 0),
         built_comm_airports = replace_na(built_comm_airports, 0),
         built_noncomm_airports = replace_na(built_noncomm_airports, 0),
         cell_tower_adj = (cell_tower_count / ALAND_acres),
         publibs_adj = (built_publibs / COUNTYPOP),
         lib_avcomputers_adj = (built_lib_avcomputers / COUNTYPOP * 10000) * 100,
         lib_computeruse_adj = (built_lib_computeruse / COUNTYPOP * 10000) * 100,
         #transportation
         bridge_count_adj = (built_bridges / total_area * 10000),
         built_perc_poor_bridges = built_perc_poor_bridges, 
         road_count_adj = (road_count / total_area),
         miles_of_road_adj = (miles_of_road / total_area),
         # educational facilities
         publicschool_adj = (publicschool_count / COUNTYPOP * 10000), 
         privateschool_adj = (privateschool_count / COUNTYPOP * 10000),
         university_adj = (university_count / COUNTYPOP * 10000 * 10000),
         suppcollege_adj = (suppcollege_count / COUNTYPOP * 10000 * 10000),
         built_educ_facs = ((publicschool_count + privateschool_count + university_count + suppcollege_count) / COUNTYPOP * 10000), 
         # emergency facilities 
         hospitals_adj = (hospital_count / COUNTYPOP * 10000),
         urgentcares_count = (urgentcare_count / COUNTYPOP * 10000),
         mentalhealthfacs_adj = (mentalhealth_facs / COUNTYPOP * 10000),
         fire_stations_adj = (fire_station_count / COUNTYPOP * 10000),
         localpolice_adj = (localpolice_count / COUNTYPOP * 10000),
         built_emergency_facs = ((hospital_count + psap_count + urgentcare_count + vahealth_count + ems_stations_count +
                      nhsc_facs + mentalhealth_facs + dental_facs + pcp_facs +  fire_station_count + localpolice_count) / COUNTYPOP * 10000),
         # convention facilities 
         placesofworship_adj = (placesofworship_count / COUNTYPOP * 10000),
         fairgrounds_adj = (fairgrounds_count / COUNTYPOP * 10000),
         sportvenues_adj =(sportvenues_count / COUNTYPOP * 10000),
         built_convention_facs = ((placesofworship_count + fairgrounds_count + sportvenues_count) / COUNTYPOP * 10000),
         built_energy_facs = ((electric_substations_count + power_plant_count +  ethanol_plant_count + ethanol_loading_count +
           petro_plant_count + petro_terminal_count + biodiesel_plant_count) / COUNTYPOP  * 10000)) 

data %>% 
  select(NAME.y, COUNTYPOP, built_bridges, bridge_count_adj, built_perc_poor_bridges, road_count, road_count_adj, miles_of_road, miles_of_road_adj) %>% 
  arrange(-bridge_count_adj)

# LEFT OFF HERE ---> THE ROUND COUNTS DON'T MAKE SENSE IN THE CITIES, NEED TO GO BACK AND CHECK ALL THE VARS THAT WERE INCLUDED


#
# Write -----------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/built/built_final.Rds")
check <- read_rds("./rivanna_data/built/built_final.Rds")
write_rds(check, "./src/ccdash/data/built_final.Rds")


rm(list = ls())

library(tidyverse)
library(readr)
library(readxl)
library(naniar)
library(janitor)

# county level data -----------------------------------------------------------------------

acs_data <- read_rds("./rivanna_data/built/built_acs_2018.Rds")
hud_data <- read_rds("./rivanna_data/built/built_hud_2019.Rds") %>% st_drop_geometry()
fcc_data <- read_rds("./rivanna_data/built/built_fcc_2019.Rds") %>% st_drop_geometry()
dot_data <- read_rds("./rivanna_data/built/built_dot_2020.Rds") 
imls_data <- read_rds("./rivanna_data/built/built_imls_2018.rds")
hifld_data <- read_rds("./rivanna_data/built/built_hifld_2020.rds") %>% st_drop_geometry()

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
data <- left_join(data, rurality, by = c("GEOID" = "fips2010", "NAME.y" = "county_name"))

#
# De-select columns -----------------------------------------------------------------------
#

data <- data %>%
  select(-AFFGEOID, -COUNTYNS, -LSAD) # others later 

#
# Recode rurality  -----------------------------------------------------------------------
#

data <- data %>% mutate(irr2010_discretize = case_when(irr2010 < 0.15 ~ "Urban [0.12, 0.15)",
                                                       irr2010 >= 0.15 & irr2010 < 0.25 ~ "Urban [0.15, 0.25)",
                                                       irr2010 >= 0.25 & irr2010 < 0.35 ~ "Urban [0.25, 0.35)",
                                                       irr2010 >= 0.35 & irr2010 < 0.45 ~ "Urban [0.35, 0.45)",
                                                       irr2010 >= 0.45 & irr2010 < 0.55 ~ "In-between [0.45, 0.55)",
                                                       irr2010 >= 0.55 & irr2010 < 0.65 ~ "Rural [0.55, 0.65)",
                                                       irr2010 >= 0.65 ~ "Rural [0.65, 0.68]"
))
data$irr2010_discretize <- factor(data$irr2010_discretize,
                                  levels = c("Urban [0.12, 0.15)", "Urban [0.15, 0.25)", "Urban [0.25, 0.35)",
                                             "Urban [0.35, 0.45)", "In-between [0.45, 0.55)", "Rural [0.55, 0.65)",
                                             "Rural [0.65, 0.68]"))

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

data



#
# Write -----------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/built/built_final.Rds")

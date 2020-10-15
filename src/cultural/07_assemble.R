library(readr)
library(tidycensus)
library(sf)
library(dplyr)
library(stringr)

# Read in
cult_rel <- read.csv("./rivanna_data/cultural/CulturalREL.csv")
cult_anc <- read.csv("./rivanna_data/cultural/CulturalANC.csv")

# Get geometry
geo <- get_acs(geography="county", 
               state=c(19, 41, 51), 
               variables="C02003_001", # we have to define a variable for the function to work, will be removed since we don't need this data
               year=2018, 
               survey="acs5", 
               cache_table=TRUE, 
               output="wide", 
               geometry=TRUE, 
               keep_geo_vars=TRUE)


# Clean and join
cult_rel$GEOID <- as.character(cult_rel$GEOID)
cult_anc$GEOID <- as.character(cult_anc$GEOID)

cult_rel <- left_join(geo, cult_rel, by = "GEOID")

cult_anc <- cult_anc %>% rename("anc_gsi" = "GSI", "anc_rich" = "Richness")

data <- left_join(cult_rel, cult_anc[, c("GEOID", "State", "Location", "anc_rich", "anc_gsi")], by = c("GEOID", "State", "Location"))

# Prepare
data <- data %>% select("STATEFP", "State", "COUNTYFP", "GEOID", "NAME.x", "NAME.y", "IRR", "Richness", "GSI", "anc_rich", "anc_gsi") %>%
  rename("irr2010" = "IRR", "state" = "State", "cult_rich" = "Richness", "cult_gsi" = "GSI") %>%
  mutate(area_name = ifelse(state == "Iowa", str_replace(NAME.y, ", Iowa", ", IA"), 
                            ifelse(state == "Virginia", str_replace(NAME.y, ", Virginia", ", VA"), 
                                   ifelse(state == "Oregon", str_replace(NAME.y, ", Oregon", ", OR"), NA))),
         county = str_remove_all(NAME.y, ", Virginia|, Oregon|, Iowa"), 
         irr2010_discretize = case_when(irr2010 < 0.15 ~ "Urban [0.12, 0.15)",
                                        irr2010 >= 0.15 & irr2010 < 0.25 ~ "Urban [0.15, 0.25)",
                                        irr2010 >= 0.25 & irr2010 < 0.35 ~ "Urban [0.25, 0.35)",
                                        irr2010 >= 0.35 & irr2010 < 0.45 ~ "Urban [0.35, 0.45)",
                                        irr2010 >= 0.45 & irr2010 < 0.55 ~ "In-between [0.45, 0.55)",
                                        irr2010 >= 0.55 & irr2010 < 0.65 ~ "Rural [0.55, 0.65)",
                                        irr2010 >= 0.65 ~ "Rural [0.65, 0.68]"
         )
         )

data$irr2010_discretize <- factor(data$irr2010_discretize,
                                  levels = c("Urban [0.12, 0.15)", "Urban [0.15, 0.25)", "Urban [0.25, 0.35)",
                                             "Urban [0.35, 0.45)", "In-between [0.45, 0.55)", "Rural [0.55, 0.65)",
                                             "Rural [0.65, 0.68]"))

# Write out
write_rds(data, "./rivanna_data/cultural/cult_final.Rds")




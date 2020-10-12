library(tidycensus)
library(tidyverse)
library(sf)
library(readxl)
library(janitor)


#
# Read in data -------------------------------------------------------------------------------
#

data <- read_rds("./rivanna_data/political/pol_final_1_orig.Rds")


#
# Clean --------------------------------------------------------------------------------------

# Remove redundant columns
data$state <- NULL
data$IRR2010 <- NULL

# Rename variables
# participation (votepart), organization (assn2014) and, contribution (num100)
data <- data %>% rename(pol_voterturnout = votepart,
                        pol_voterturnout_q = votepartQuint,
                        pol_orgs = assn2014,
                        pol_orgs_q = assn2014Quint,
                        pol_contrib = num1000,
                        pol_contrib_q = num1000Quint,
                        pol_index = indexQuint,
                        state = State)

# Remove whitespace
data$state <- sub(" ", "", data$state)

#
# Add rurality --------------------------------------------------------------------------------------
#

rurality <- read_excel("./rivanna_data/rurality/IRR_2000_2010.xlsx", 
                       sheet = 2, range = cell_cols("A:C"), col_types = c("text", "text", "numeric")) %>% clean_names()
rurality$fips2010 <- ifelse(nchar(rurality$fips2010) == 4, paste0("0", rurality$fips2010), rurality$fips2010)

data <- left_join(data, rurality, by = c("GEOID" = "fips2010", "name" = "county_name"))

data <- data %>% mutate(irr2010_discretize = 
                          case_when(irr2010 < 0.15 ~ "Most Urban [0.12, 0.15)",
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
# Write out --------------------------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/political/pol_final_1.Rds")

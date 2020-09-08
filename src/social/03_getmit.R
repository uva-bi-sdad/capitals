library(tidyverse)
library(naniar)
library(readr)
library(janitor)
library(sf)

#
# Get data ------------------------------------------------------------------------
#
data <- read.csv("rivanna_data/social/soc_mit_2018.csv")

data <- data %>%
  # filter(year == 2016, state %in% c("Iowa", "Oregon", "Virginia")) %>%
  transmute(state = state,
            county = county,
            GEOID = fips,
            totalvotes = trump16 + clinton16 + otherpres16,
            totalvoters = cvap) %>%
  mutate(voter_rate = (totalvotes/totalvoters)*100)
# %>%
# distinct()

# add geometry data from ACS ------------------------------------

data$STATEFP <- substr(data$GEOID, 1, 2)
data$COUNTYFP <- substr(data$GEOID, 3, 5)

acs <- readRDS("./rivanna_data/social/soc_acs_2018.rds")

acs <- acs %>%
  select(STATEFP, COUNTYFP, GEOID, geometry)
  
data$GEOID <- as.character(data$GEOID)

# The two cities Bedford City VA: reverted to town in 2013; Clifton Forge, VA: reverted back to town in 2001
setdiff(data$GEOID, acs$GEOID) # NULL
setdiff(acs$GEOID, data$GEOID) # 268 values

data_geo <- left_join(acs, data, by = c("STATEFP", "COUNTYFP", "GEOID"))


# check missingness ----------------------------------

miss_var_summary(data_geo) # nothing missing

#
# Write ------------------------------------------------------------------------
#

write_rds(data_geo, "./rivanna_data/social/soc_mit_2018.rds")

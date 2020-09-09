library(tidyverse)
library(naniar)
library(readr)
library(janitor)
library(sf)

#
# Get data ------------------------------------------------------------------------
#

data <- read.csv("./rivanna_data/social/soc_census_2020.csv")

# CRRALL - cummulative self response rate, CAVG - cummulative average overall response rate

data <- data %>%
  transmute(GEOID = GEO_ID,
            soc_overallcensusrate = CRRALL,
            soc_overallavgcensusrate = CAVG) %>%
  separate(GEOID, c("place", "GEOID"), "US")

# add geometry data from ACS ------------------------------------

acs <- readRDS("./rivanna_data/social/soc_acs_2018.rds")

acs <- acs %>%
  select(STATEFP, COUNTYFP, GEOID, geometry)

data$GEOID <- as.character(data$GEOID)

data_geo <- left_join(acs, data, by = c("GEOID"))

data_geo$STATEFP <- substr(data_geo$GEOID,1,2)
data_geo$COUNTYFP <-substr(data_geo$GEOID,3,5)

data_geo$STATEFP <- as.character(data_geo$STATEFP)
data_geo$COUNTYFP <- as.character(data_geo$COUNTYFP)


# check missingness ----------------------------------

miss_var_summary(data_geo)

#
# Write ------------------------------------------------------------------------
#

write_rds(data_geo, "./rivanna_data/social/soc_census_2020.rds")

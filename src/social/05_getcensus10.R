library(tidyverse)
library(naniar)
library(data.table)
library(sf)

#
# Get data ------------------------------------------------------------------------
#

data_pre <- read.table("./rivanna_data/social/soc_census_2010.txt", sep = "|", header = F)

data_1 <- data_pre %>%
  transmute(GEOID = V1,
            name = V3,
            type = V5,
            participation_rate = V9) %>%
  filter(type == "County ")

data_1 <- data_1[-1,]

data_2 <- data_1 %>%
  separate(name, c("county", "state"), ", ") 

data_3 <- data_2 %>%
  filter(state %in% c("VA ", "IA ","OR "))
data <- data_3 

data$STATEFP <- substr(data$GEOID,1,2)
data$COUNTYFP <- substr(data$GEOID,3,5)

data$STATEFP <- as.character(data$STATEFP)
data$COUNTYFP <- as.character(data$COUNTYFP)

data$GEOID <- as.character(data$GEOID)
# missing quite a few counties with the census 2010 data
# only have 145 counties v 268 from acs.... oh maybe because i'm using 2018 acs data LOL


# add geometry data from ACS ------------------------------------
#maybe make an acs with 2010 acs data...

acs <- readRDS("./rivanna_data/social/soc_acs_2018.rds")

acs <- acs %>%
  select(STATEFP, COUNTYFP, GEOID, geometry)

data_geo <- left_join(acs, data, by = c("STATEFP", "COUNTYFP", "GEOID"))

# check missingness ----------------------------------

miss_var_summary(data_geo) # there's a lot missing with this data set.

#
# Write ------------------------------------------------------------------------
#

write_rds(data_geo, "./rivanna_data/social/soc_census_2010.rds")
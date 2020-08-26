library(readxl)
library(dplyr)
library(tidycensus)
library(readr)


#
# Read in -------------------------------------------------------------------
#

data <- read_excel("./data/financial/fin_urban_2018_orig.xlsx")


#
# Clean ------------------------------------------------------------------------
#

# Filter to three states
data <- data %>% filter(state == "Virginia" |
                          state == "Oregon" |
                          state == "Iowa")

# "n/a*" = unavailable due to insufficient sample size, recode to NA
data <- data %>% mutate(share_anydebtcollections = ifelse(share_anydebtcollections == "n/a*", NA, share_anydebtcollections))
data$share_anydebtcollections <- as.numeric(data$share_anydebtcollections)

# Convert to percent and rename
data$share_anydebtcollections <- data$share_anydebtcollections * 100
data <- data %>% rename(fin_pctdebtcol = share_anydebtcollections)

# Prepare name for linking
data$fullname <- paste0(data$county, ", ", data$state)


#
# Add geography ------------------------------------------------------------------------
#

readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")

# Get data from 2014/18 5-year estimates for counties
acsdata <- get_acs(geography = "county", state = c(19, 41, 51), 
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, -B01003_001E, -B01003_001M)

# Join
data <- left_join(acsdata, data, by = c("NAME.y" = "fullname"))
# Note: In the Urban dataset and thus here, 3 counties missing data in Oregon and 3 in Virginia.


#
# Write ------------------------------------------------------------------------
#

write_rds(data, "./data/financial/fin_urban_2018.Rds")


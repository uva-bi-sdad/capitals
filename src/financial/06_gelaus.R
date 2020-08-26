library(readxl)
library(dplyr)
library(tidyr)
library(tidycensus)
library(readr)


#
# Read in and clean up -------------------------------------------------------------------
#

# Read
data <- read_excel("./data/financial/fin_laus_2020_orig.xlsx", 
                   col_types = c("text", "text", "text", "text", "date", "numeric", "numeric", "numeric", "numeric"))

# Prepare GEOID
data$county <- ifelse(nchar(data$county) == 2, paste0("0", data$county), data$county)
data$county <- ifelse(nchar(data$county) == 1, paste0("00", data$county), data$county)
data$GEOID <- paste0(data$state, data$county)

# Change date to text
data$period <- as.character(data$period)
data <- data %>% mutate(period = case_when(period == "2020-01-20" ~ "jan", 
                                           period == "2020-02-20" ~ "feb",
                                           period == "2020-03-20" ~ "mar",
                                           period == "2020-04-20" ~ "apr",
                                           period == "2020-05-20" ~ "may",
                                           period == "2020-06-20" ~ "jun"))
data$period <- ordered(data$period, levels = c("jan", "feb", "mar", "apr", "may", "jun"))

# Unemployment rate = Number of Unemployed Persons / Labor Force, multiplied by 100; already calculated here and is in the data.

# Select
data <- data %>% select(-laus_area_code, -civilian_labor_force, -employed, -unemp_level)


#
# Reshape data -------------------------------------------------------------------
#

data <- data %>% pivot_wider(id_cols = c("GEOID", "state", "county", "area_name"), names_from = "period", values_from = "unemp_rate")


#
# Calculate -------------------------------------------------------------------
#

# Unemployment rate pre-covid = Mean of Jan, Feb, Mar 2020 LAUS seasonally adjusted unemployment rates.
# Unemployment rate during covid = Mean of Apr, May, Jun 2020 LAUS seasonally adjusted unemployment rates 
data <- data %>% mutate(fin_unempprecovid = (jan + feb + mar)/3,
                        fin_unempcovid = (apr + may + jun)/3)


#
# Add geography -------------------------------------------------------------------
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


#
# Join -------------------------------------------------------------------
#

data <- left_join(acsdata, data, by = c("GEOID", "STATEFP" = "state", "COUNTYFP" = "county"))


#
# Write out -------------------------------------------------------------------
#

write_rds(data, "./data/financial/fin_laus_2020.Rds")
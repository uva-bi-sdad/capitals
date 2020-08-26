library(readr)
library(dplyr)
library(tidycensus)
library(janitor)


#
# Get geographies and area from ACS ---------------------------------------------------
#

# Key
readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")

# Get data from 2014/18 5-year estimates for counties
acsdata <- get_acs(geography = "county", state = c(19, 41, 51), 
                variables = "B01003_001",
                year = 2018, survey = "acs5",
                cache_table = TRUE, output = "wide", geometry = TRUE,
                keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, -B01003_001E, -B01003_001M)

# Land area in acres (convert from square meters)
acsdata$acres <- acsdata$ALAND * 0.00024710538146717


#
# Read in NASS files ---------------------------------------------------
#

# FARM OPERATIONS - ACRES OPERATED total
aglandtotal <- read_csv("./data/financial/fin_nass_2017_aglandtotal.csv") %>% clean_names()

# LAND AREA, INCL NON-AG - ACRES total
landareatotal <- read_csv("./data/financial/fin_nass_2017_landareatotal.csv") %>% clean_names()

# AG LAND, INCL BUILDINGS - ASSET VALUE, MEASURED IN $ / ACRE total
landvalueperacre <- read_csv("./data/financial/fin_nass_2017_landvalueperacre.csv") %>% clean_names()

# INCOME, NET CASH FARM, OF OPERATIONS - NET INCOME, MEASURED IN $ / OPERATION total
netincome <- read_csv("./data/financial/fin_nass_2017_netincome.csv") %>% clean_names()


#
# Join NASS files ---------------------------------------------------
#

# Prepare names
aglandtotal <- aglandtotal %>% rename(aglandtotal = value) %>%
                 select(-commodity, -data_item, -domain, -domain_category)

landareatotal <- landareatotal %>% rename(landareatotal = value) %>%
                  select(-commodity, -data_item, -domain, -domain_category)

landvalueperacre <- landvalueperacre %>% rename(fin_landvalacre = value) %>%
                      select(-commodity, -data_item, -domain, -domain_category)

netincome <- netincome %>% rename(fin_netincperfarm = value) %>%
                select(-commodity, -data_item, -domain, -domain_category)

# Join
nassdata <- left_join(aglandtotal, landareatotal, by = c("year", "geo_level", "state", "state_ansi", "county", "county_ansi"))
nassdata <- left_join(nassdata, landvalueperacre, by = c("year", "geo_level", "state", "state_ansi", "county", "county_ansi"))
nassdata <- left_join(nassdata, netincome, by = c("year", "geo_level", "state", "state_ansi", "county", "county_ansi"))


#
# Join NASS and ACS/geography ---------------------------------------------------
#

# Prepare NASS GEOID
nassdata$county_ansi <- ifelse(nchar(nassdata$county_ansi) == 2, paste0("0", nassdata$county_ansi), nassdata$county_ansi)
nassdata$county_ansi <- ifelse(nchar(nassdata$county_ansi) == 1, paste0("00", nassdata$county_ansi), nassdata$county_ansi)
nassdata$state_ansi <- as.character(nassdata$state_ansi)

nassdata$GEOID <- paste0(nassdata$state_ansi, nassdata$county_ansi)

# Join
data <- left_join(acsdata, nassdata, by = "GEOID")


#
# Rename and calculate percent county in agriculture acres ---------------------------------------------------
#

# Calculate using ACS total acreage vs. using NASS total acreage; result is the same 
data <- data %>% mutate(fin_pctagacres1 = aglandtotal / acres * 100,
                        fin_pctagacres2 = aglandtotal / landareatotal * 100)
data <- data %>% rename(fin_pctagacres = fin_pctagacres1) %>% select(-fin_pctagacres2)


#
# Write out ---------------------------------------------------
#

write_rds(data, "./data/financial/fin_nass_2017.Rds")


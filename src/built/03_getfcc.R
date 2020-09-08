library(readxl)
library(dplyr)
library(tidycensus)
library(readr)

# Read in -------------------------------------------------------------------
# Downloaded from https://opendata.fcc.gov/Wireless/Area-Table-June-2019/tun5-dwjh/data.
# Used their filtering function to filter type column down to county, id down to
# only start with 51, 41, or 19, speed to equal 25, and tech to equal acfosw.

data <- read_csv("./src/built/Area_Table_June_2019.csv",
                 col_types = cols(id = col_character()))

#
# Clean ------------------------------------------------------------------------
#
data <- data %>%
  select(-type, -tech, -urban_rural, -tribal_non) %>%
  group_by(id) %>%
  summarise_each(funs(sum))


# Get data from 2014/18 5-year estimates for counties
acsdata <- get_acs(geography = "county", state = c(19, 41, 51),
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)

acsdata$state_cnty <- paste(acsdata$STATEFP, acsdata$COUNTYFP, sep = "")

acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, -B01003_001M)


# Join
data <- left_join(acsdata, data, by = c("state_cnty" = "id"))


#Constructing Variables
fccdata <- data %>% transmute(
  STATEFP = STATEFP,
  COUNTYFP = COUNTYFP,
  COUNTYNS = COUNTYNS,
  GEOID = GEOID,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  geometry = geometry,
  pct_has_0 = (has_0 / B01003_001E) * 100,
  pct_has_1 = (has_1 / B01003_001E) * 100,
  pct_has_2 = (has_2 / B01003_001E) * 100,
  pct_has_3more = (has_3more / B01003_001E) * 100
)
View(fccdata)

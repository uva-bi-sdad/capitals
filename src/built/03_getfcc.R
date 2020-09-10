library(readxl)
library(dplyr)
library(tidycensus)
library(readr)

# Read in -------------------------------------------------------------------
# Downloaded from https://opendata.fcc.gov/Wireless/Area-Table-June-2019/tun5-dwjh/data.
# Used their filtering function to filter type column down to county, id down to
# only start with 51, 41, or 19, speed to equal 25, and tech to equal acfosw.

data <- read_csv("./rivanna_data/built/built_fcc_2019_orig_Area_Table_June19.csv",
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

acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, -B01003_001M)


# Join
data <- left_join(acsdata, data, by = c("GEOID" = "id"))


#Constructing Variables
fccdata <- data %>% transmute(
  STATEFP = STATEFP,
  COUNTYFP = COUNTYFP,
  COUNTYNS = COUNTYNS,
  GEOID = GEOID,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  geometry = geometry,
  built_pct0bbandprov = (has_0 / B01003_001E) * 100,
  built_pcd1bbandprov = (has_1 / B01003_001E) * 100,
  built_pct2bbandprov = (has_2 / B01003_001E) * 100,
  built_pct3bbandprov = (has_3more / B01003_001E) * 100,
  test = built_pct0bbandprov + built_pcd1bbandprov + built_pct2bbandprov + built_pct3bbandprov
  )

write_rds(fccdata, "./rivanna_data/built/built_fcc_2019.Rds")

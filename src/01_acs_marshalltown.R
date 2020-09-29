library(tidyverse)
library(tidycensus)
library(sf)


#
# API key ------------------------------------------------------------------------
#

readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")


#
# TABLE 1 ------------------------------------------------------------
#

acsvars1 <- c(
  # total population
  "B01003_001",
  # hispanic origin
  "B03003_003")

acs_city_18_1 <- get_acs(geography = "place", state = 19,
                         variables = acsvars1,
                         year = 2018,
                         cache_table = TRUE, output = "wide", geometry = TRUE,
                         keep_geo_vars = TRUE)
acs_city_18_1 <- acs_city_18_1 %>% filter(PLACEFP == 49755)

# Total population: 27275
# Hispanic: 8142 (29.85%)


#
# TABLE 2 ------------------------------------------------------------
#

acsvars2 <- c(
  # total Hispanic population
  "B01001I_001",
  # males and females under age 18
  "B01001I_003", "B01001I_004", "B01001I_005", "B01001I_006",
  "B01001I_018", "B01001I_019", "B01001I_020", "B01001I_021",
  # employed in armed forces or civilian male and female two age groups
  "C23002I_001", 
  "C23002I_005", "C23002I_007", "C23002I_012", 
  "C23002I_018", "C23002I_020", "C23002I_025")

acs_city_18_2 <- get_acs(geography = "place", state = 19,
                         variables = acsvars2,
                         year = 2018,
                         cache_table = TRUE, output = "wide", geometry = TRUE,
                         keep_geo_vars = TRUE)
acs_city_18_2 <- acs_city_18_2 %>% filter(PLACEFP == 49755)

acs_city_18_2 <- acs_city_18_2 %>% mutate(
  under18 = (B01001I_003E + B01001I_004E + B01001I_005E + B01001I_006E + 
               B01001I_018E + B01001I_019E + B01001I_020E + B01001I_021E) / B01001I_001E * 100,
  employed = (C23002I_005E + C23002I_007E + C23002I_012E + 
                C23002I_018E + C23002I_020E + C23002I_025E) / C23002I_001E * 100
)


#
# TABLE 3 ------------------------------------------------------------
#

acsvars3 <- c(
  # males and females <5
  "B01001I_003", "B01001I_018",
  # males and females 6-17
  "B01001I_004", "B01001I_005", "B01001I_006", "B01001I_019", "B01001I_020", "B01001I_021",
  # males and females 18-29
  "B01001I_007", "B01001I_008", "B01001I_009", "B01001I_022", "B01001I_023", "B01001I_024",
  # males and females 30-64
  "B01001I_010", "B01001I_011", "B01001I_012", "B01001I_013", "B01001I_025", "B01001I_026", "B01001I_027", "B01001I_028",
  # males and females >65
  "B01001I_014", "B01001I_015", "B01001I_016", "B01001I_029", "B01001I_030", "B01001I_031"
)

acs_city_18_3 <- get_acs(geography = "place", state = 19,
                         variables = acsvars3,
                         year = 2018,
                         cache_table = TRUE, output = "wide", geometry = TRUE,
                         keep_geo_vars = TRUE)
acs_city_18_3 <- acs_city_18_3 %>% filter(PLACEFP == 49755)

acs_city_18_3 <- acs_city_18_3 %>% mutate(
  age5M = B01001I_003E,
  age5F = B01001I_018E,
  age6_17M = (B01001I_004E + B01001I_005E + B01001I_006E),
  age6_17F = (B01001I_019E + B01001I_020E + B01001I_021E),
  age18_29M = (B01001I_007E + B01001I_008E + B01001I_009E),
  age18_29F = (B01001I_022E + B01001I_023E + B01001I_024E),
  age30_64M = (B01001I_010E + B01001I_011E + B01001I_012E + B01001I_013E),
  age30_64F = (B01001I_025E + B01001I_026E + B01001I_027E + B01001I_028E),
  age65M = (B01001I_014E + B01001I_015E + B01001I_016E),
  age65F = (B01001I_029E + B01001I_030E + B01001I_031E)
)
library(tidyverse)
library(tidycensus)

#
# API key ------------------------------------------------------------------------
#

readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")

#
# Get data ------------------------------------------------------------------------
#

# Select variables
acsvars <- c(
  # total population
  "B01003_001",
  # hispanic origin
  "B03003_003",
  # sex by age (hispanic or latino)
  "B01001I_003", 
  "B01001I_004", "B01001I_005", "B01001I_006",
  "B01001I_007", "B01001I_008", "B01001I_009", "B01001I_010", 
  "B01001I_011", "B01001I_012", "B01001I_013", 
  "B01001I_014", "B01001I_015", "B01001I_016", 
  "B01001I_018", 
  "B01001I_019", "B01001I_020", "B01001I_021",
  "B01001I_022", "B01001I_023", "B01001I_024", "B01001I_025", 
  "B01001I_026", "B01001I_027", "B01001I_028", 
  "B01001I_029", "B01001I_030", "B01001I_031", 
  # sex by age (all ethnicities and races) - under 5, 5-17, 18-29, 30-64, 65+ : Female and Male Hispanic as Percentage
  "B01001_003",
  "B01001_004", "B01001_005", "B01001_006", 
  "B01001_007", "B01001_008", "B01001_009", "B01001_010", "B01001_011", 
  "B01001_012",
  "B01001_013","B01001_014","B01001_015","B01001_016","B01001_017","B01001_018","B01001_019",
  "B01001_020","B01001_021","B01001_022","B01001_023","B01001_024","B01001_025",
  "B01001_027",
  "B01001_028","B01001_029","B01001_030",
  "B01001_031","B01001_032","B01001_033","B01001_034","B01001_035",
  "B01001_036",
  "B01001_037","B01001_038","B01001_039","B01001_040","B01001_041","B01001_042","B01001_043",
  "B01001_044","B01001_045","B01001_046","B01001_047","B01001_048","B01001_049"
)
# marshalltown county 019127
# acs_cty_00 <- get_acs(geography = "county", state = 19,
#                variables = acsvars,
#                year = 2000,
#                cache_table = TRUE, output = "wide", geometry = TRUE,
#                keep_geo_vars = TRUE)
# 
# acs_cty_02 <- get_acs(geography = "county", state = 19, county = 127,
#                       variables = acsvars,
#                       year = 2002,
#                       cache_table = TRUE, output = "wide", geometry = TRUE,
#                       keep_geo_vars = TRUE)

acs_cty_10 <- get_acs(geography = "county", state = 19, county = 127,
                      variables = acsvars,
                      year = 2010,
                      cache_table = TRUE, output = "wide", geometry = TRUE,
                      keep_geo_vars = TRUE)

acs_cty_18 <- get_acs(geography = "county", state = 19, county = 127,
                      variables = acsvars,
                      year = 2018,
                      cache_table = TRUE, output = "wide", geometry = TRUE,
                      keep_geo_vars = TRUE)

# marshalltown city 49755
acs_city_18 <- get_acs(geography = "place", state = 19,
               variables = acsvars,
               year = 2018,
               cache_table = TRUE, output = "wide", geometry = TRUE,
               keep_geo_vars = TRUE)
acs_city_18 <- acs_city_18 %>%
  filter(PLACEFP == 49755)

# acs_city_10 <- get_acs(geography = "place", state = 19,
#                        variables = acsvars,
#                        year = 2015,
#                        cache_table = TRUE, output = "wide", geometry = TRUE,
#                        keep_geo_vars = TRUE)
# acs_city_10 <- acs_city_15 %>%
#   filter(PLACEFP == 49755)

# acs_city_10 <- get_acs(geography = "place", state = 19,
#                     variables = acsvars,
#                     year = 2010,
#                     cache_table = TRUE, output = "wide", geometry = TRUE,
#                     keep_geo_vars = TRUE)
# acs_city_10 <- acs_city_10 %>%
#   filter(PLACEFP == 49755)

# acs_city_02 <- get_acs(geography = "place", state = 19,
#                     variables = acsvars,
#                     year = 2002,
#                     cache_table = TRUE, output = "wide", geometry = TRUE,
#                     keep_geo_vars = TRUE)
# acs_city_02 <- acs_city_02 %>%
#   filter(PLACEFP == 49755)

# acs_city_00 <- get_acs(geography = "place", state = 19,
#                     variables = acsvars,
#                     year = 2000,
#                     cache_table = TRUE, output = "wide", geometry = TRUE,
#                     keep_geo_vars = TRUE)
# acs_city_18 <- acs_city_18 %>%
#   filter(PLACEFP == 49755)


#
# Calculate ------------------------------------------------------------------------
#

acs_cty_18 <- acs_cty_18 %>% transmute(
  STATEFP = STATEFP,
  COUNTYFP = COUNTYFP,
  GEOID = GEOID,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  ALAND = ALAND,
  AWATER = AWATER,
  geometry = geometry,
  total_pop = B01003_001E,
  hispanic_pop = (B03003_003E/B01003_001E)*100,
  hisp_5_m = (B01001I_003E/B01001_003E)*100,
  hisp_5_f = (B01001I_018E/B01001_027E)*100,
  hisp_18_m = ((B01001I_004E + B01001I_005E + B01001I_006E)/(B01001_004E + B01001_005E + B01001_006E))*100,
  hisp_18_f = ((B01001I_019E + B01001I_020E + B01001I_021E)/(B01001_028E + B01001_029E + B01001_030E))*100,
  hisp_30_m = ((B01001I_007E + B01001I_008E + B01001I_009E)/(B01001_007E + B01001_008E + B01001_009E + B01001_010E + B01001_011E))*100,
  hip_30_f = ((B01001I_022E + B01001I_023E + B01001I_024E)/(B01001_031E + B01001_032E + B01001_033E + B01001_034E + B01001_035E))*100,
  hisp_65_m = ((B01001I_010E + B01001I_011E + B01001I_012E + B01001I_013E)/(B01001_012E + B01001_013E + B01001_014E + B01001_015E + B01001_016E + B01001_017E + B01001_018E + B01001_019E))*100,
  hisp_65_f = ((B01001I_025E + B01001I_026E + B01001I_027E + B01001I_028E)/(B01001_036E + B01001_037E + B01001_038E + B01001_039E + B01001_040E + B01001_041E + B01001_042E + B01001_043E))*100,
  hisp_plus_m = ((B01001I_014E + B01001I_015E + B01001I_016E)/(B01001_020E + B01001_021E + B01001_022E + B01001_023E + B01001_024E + B01001_025E))*100,
  hisp_plus_f = ((B01001I_029E + B01001I_030E + B01001I_031E)/(B01001_044E + B01001_045E + B01001_046E + B01001_047E + B01001_048E + B01001_049E))*100,
  year = 2018
)

acs_cty_18$NAME.x <- tolower(acs_cty_18$NAME.x)
acs_cty_18$county <- acs_cty_18$NAME.x

acs_cty_10 <- acs_cty_10 %>% transmute(
  STATEFP = STATEFP,
  COUNTYFP = COUNTYFP,
  GEOID = GEOID,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  geometry = geometry,
  total_pop = B01003_001E,
  hispanic_pop = (B03003_003E/B01003_001E)*100,
  hisp_5_m = (B01001I_003E/B01001_003E)*100,
  hisp_5_f = (B01001I_018E/B01001_027E)*100,
  hisp_18_m = ((B01001I_004E + B01001I_005E + B01001I_006E)/(B01001_004E + B01001_005E + B01001_006E))*100,
  hisp_18_f = ((B01001I_019E + B01001I_020E + B01001I_021E)/(B01001_028E + B01001_029E + B01001_030E))*100,
  hisp_30_m = ((B01001I_007E + B01001I_008E + B01001I_009E)/(B01001_007E + B01001_008E + B01001_009E + B01001_010E + B01001_011E))*100,
  hip_30_f = ((B01001I_022E + B01001I_023E + B01001I_024E)/(B01001_031E + B01001_032E + B01001_033E + B01001_034E + B01001_035E))*100,
  hisp_65_m = ((B01001I_010E + B01001I_011E + B01001I_012E + B01001I_013E)/(B01001_012E + B01001_013E + B01001_014E + B01001_015E + B01001_016E + B01001_017E + B01001_018E + B01001_019E))*100,
  hisp_65_f = ((B01001I_025E + B01001I_026E + B01001I_027E + B01001I_028E)/(B01001_036E + B01001_037E + B01001_038E + B01001_039E + B01001_040E + B01001_041E + B01001_042E + B01001_043E))*100,
  hisp_plus_m = ((B01001I_014E + B01001I_015E + B01001I_016E)/(B01001_020E + B01001_021E + B01001_022E + B01001_023E + B01001_024E + B01001_025E))*100,
  hisp_plus_f = ((B01001I_029E + B01001I_030E + B01001I_031E)/(B01001_044E + B01001_045E + B01001_046E + B01001_047E + B01001_048E + B01001_049E))*100,
  year = 2010
)

acs_cty_10$NAME.x <- tolower(acs_cty_10$NAME.x)
acs_cty_10$county <- acs_cty_10$NAME.x

acs_city_18 <- acs_city_18 %>% transmute(
  STATEFP = STATEFP,
  PLACEFP = PLACEFP,
  GEOID = GEOID,
  NAME.x = NAME.x,
  NAME.y = NAME.y,
  geometry = geometry,
  total_pop = B01003_001E,
  hispanic_pop = (B03003_003E/B01003_001E)*100,
  hisp_5_m = (B01001I_003E/B01001_003E)*100,
  hisp_5_f = (B01001I_018E/B01001_027E)*100,
  hisp_18_m = ((B01001I_004E + B01001I_005E + B01001I_006E)/(B01001_004E + B01001_005E + B01001_006E))*100,
  hisp_18_f = ((B01001I_019E + B01001I_020E + B01001I_021E)/(B01001_028E + B01001_029E + B01001_030E))*100,
  hisp_30_m = ((B01001I_007E + B01001I_008E + B01001I_009E)/(B01001_007E + B01001_008E + B01001_009E + B01001_010E + B01001_011E))*100,
  hip_30_f = ((B01001I_022E + B01001I_023E + B01001I_024E)/(B01001_031E + B01001_032E + B01001_033E + B01001_034E + B01001_035E))*100,
  hisp_65_m = ((B01001I_010E + B01001I_011E + B01001I_012E + B01001I_013E)/(B01001_012E + B01001_013E + B01001_014E + B01001_015E + B01001_016E + B01001_017E + B01001_018E + B01001_019E))*100,
  hisp_65_f = ((B01001I_025E + B01001I_026E + B01001I_027E + B01001I_028E)/(B01001_036E + B01001_037E + B01001_038E + B01001_039E + B01001_040E + B01001_041E + B01001_042E + B01001_043E))*100,
  hisp_plus_m = ((B01001I_014E + B01001I_015E + B01001I_016E)/(B01001_020E + B01001_021E + B01001_022E + B01001_023E + B01001_024E + B01001_025E))*100,
  hisp_plus_f = ((B01001I_029E + B01001I_030E + B01001I_031E)/(B01001_044E + B01001_045E + B01001_046E + B01001_047E + B01001_048E + B01001_049E))*100,
  year = 2018
)

acs_city_18$NAME.x <- tolower(acs_city_18$NAME.x)
acs_city_18$county <- acs_city_18$NAME.x

#
# Write ------------------------------------------------------------------------
#

write_rds(acs_marshall_cty, "./rivanna_data/acs_marshall_cty.rds")
write_rds(acs_marshall_city, "./rivanna_data/acs_marshall_city.rds")
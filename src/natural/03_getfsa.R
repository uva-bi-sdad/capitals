library(dplyr)
library(magrittr)
library(readxl)
library(readr)
library(tidycensus)

# Read in USDA-FSA Conservation Reserve Program data
fsa = read_xlsx("data/natural/nat_fsa_2020.xlsx", skip = 3)

# Get rid of first row, which has secondary column names
fsa = fsa[-1,]

# Keep only data for the three states of interest
fsa %<>% filter(STATE %in% c("IOWA", "OREGON", "VIRGINIA"))

# Select only the columns of interest
fsa %<>% select(FIPS, STATE, COUNTY, `RARE AND\r\nDECLINING\r\nHABITAT\r\n(CP25)`, `POLLINATOR\r\nHABITAT 8/\r\n(CP42)`, `STATE\r\nACRES FOR\r\nWILDLIFE\r\nENHANCEMENT\r\n(CP38)`)

# Change column names to make them less unwieldy
names(fsa) = c("GEOID", "STATE", "COUNTY", "rare_hab", "pol_hab", "wildlife")

fsa$GEOID %<>% as.character()

# Read in County area data
counties = read_csv("data/natural/nat_census_2019_area.csv")

# Keep counties of interest
counties %<>% filter(STATEFP %in% c(19, 41, 51))

# Convert ALAND and AWATER to acres
counties %<>% mutate(ALAND_acres = ALAND * 0.00024711, AWATER_acres = AWATER * 0.00024711)
counties %<>% mutate(total_area = ALAND_acres + AWATER_acres)

# Join fsa data to counties dataset
fsa = left_join(counties, fsa)

# Create new columns with correct names and transformed data
fsa %<>% mutate(nat_rarecrpper10kacres = (rare_hab/total_area) * 10000)
fsa %<>% mutate(nat_polcrpper10kacres = (pol_hab/total_area) * 10000)
fsa %<>% mutate(nat_wildlifecrpper10kacres = (wildlife/total_area) * 10000)

# Clean up
fsa <- fsa %>% select(-AFFGEOID, -LSAD, -ALAND, -AWATER, -STATE, -COUNTY, -COUNTYNS, -NAME)

# Add geometries
Sys.getenv("CENSUS_API_KEY")

acsdata <- get_acs(geography = "county", state = c(19, 41, 51), 
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, NAME.x, ALAND, AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)

fsa <- left_join(acsdata, fsa, by = c("GEOID", "STATEFP", "COUNTYFP"))

# Write dataframe to rds file
write_rds(fsa, "data/natural/nat_fsa_2020.rds")

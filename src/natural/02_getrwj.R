library(dplyr)
library(magrittr)
library(readxl)
library(readr)
library(tidycensus)

# Read in Robert Wood Johnson County Health Ranking files sheet with all measures
rwj_ia = read_xlsx("data/natural/nat_rwj_2020_iowa.xlsx", sheet = "Ranked Measure Data", skip = 1)
rwj_or = read_xlsx("data/natural/nat_rwj_2020_oregon.xlsx", sheet = "Ranked Measure Data", skip = 1)
rwj_va = read_xlsx("data/natural/nat_rwj_2020_virginia.xlsx", sheet = "Ranked Measure Data", skip = 1)

# Get rid of statewide data row
rwj_ia = rwj_ia[-1,]
rwj_or = rwj_or[-1,]
rwj_va = rwj_va[-1,]

# Select only useful columns
rwj_ia %<>% select(FIPS, State, County, `Average Daily PM2.5`, `Z-Score...201`)
rwj_or %<>% select(FIPS, State, County, `Average Daily PM2.5`, `Z-Score...201`)
rwj_va %<>% select(FIPS, State, County, `Average Daily PM2.5`, `Z-Score...201`)

# Bind the individual state dataframes into a single dataframe
rwj = rbind(rwj_ia, rwj_or, rwj_va)

# Change names of columns
names(rwj) = c("GEOID", "State", "County", "nat_particulatedensity", "nat_zparticulatedensity")

# Add geometries
Sys.getenv("CENSUS_API_KEY")

acsdata <- get_acs(geography = "county", state = c(19, 41, 51), 
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, NAME.x, ALAND, AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)

rwj <- left_join(acsdata, rwj, by = "GEOID")
  
# Save combined dataframe to an RDS file
write_rds(rwj, "data/natural/nat_rwj_2020.rds")
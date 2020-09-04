library(naniar)
library(dplyr)
library(readxl)
library(readr)
library(janitor)
library(tidycensus)
library(sf)


#
# Read in RWJ County Health Rankings data ----------------------------------
#

# Variables to get:
# Number of juvenile arrests per 1000 juveniles --> Juvenile Arrest Rate (additional measures sheet)
# Number of violent crimes per 100,000 population --> Violent Crime Rate
# Percent of people who indicated that they have more than 14 poor mental health days per month --> % Frequent Mental Distress (additional measures sheet)
# Number of suicides per 1,000 population --> Suicide Rate (Age-Adjusted) (additional measures sheet)
# Number of social associations per 10,000 population ---> Social Association Rate

ia1 <- read_excel("./rivanna_data/social/soc_chr_2020_iowa.xlsx", sheet = "Ranked Measure Data", skip = 1) %>% 
  clean_names() %>% select(fips, state, county, violent_crime_rate, social_association_rate)
or1 <- read_excel("./rivanna_data/social/soc_chr_2020_oregon.xlsx", sheet = "Ranked Measure Data", skip = 1) %>% 
  clean_names() %>% select(fips, state, county, violent_crime_rate, social_association_rate) 
va1 <- read_excel("./rivanna_data/social/soc_chr_2020_virginia.xlsx", sheet = "Ranked Measure Data", skip = 1) %>% 
  clean_names() %>% select(fips, state, county, violent_crime_rate, social_association_rate)

ia2 <- read_excel("./rivanna_data/social/soc_chr_2020_iowa.xlsx", sheet = "Additional Measure Data", skip = 1) %>% 
  clean_names() %>% select(fips, state, county, percent_frequent_mental_distress, juvenile_arrest_rate, suicide_rate_age_adjusted)
or2 <- read_excel("./rivanna_data/social/soc_chr_2020_oregon.xlsx", sheet = "Additional Measure Data", skip = 1) %>% 
  clean_names() %>% select(fips, state, county, percent_frequent_mental_distress, juvenile_arrest_rate, suicide_rate_age_adjusted)
va2 <- read_excel("./rivanna_data/social/soc_chr_2020_virginia.xlsx", sheet = "Additional Measure Data", skip = 1) %>% 
  clean_names() %>% select(fips, state, county, percent_frequent_mental_distress, juvenile_arrest_rate, suicide_rate_age_adjusted)


#
# Join ----------------------------------
#

iowa <- left_join(ia1, ia2, by = c("fips", "state", "county"))
oregon <- left_join(or1, or2, by = c("fips", "state", "county"))
virginia <- left_join(va1, va2, by = c("fips", "state", "county"))

data <- rbind(iowa, oregon)
data <- rbind(data, virginia)

# Remove state totals
data <- data %>% filter(!is.na(county))


#
# Add geometry ----------------------------------
#

readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")

# Get data from 2014/18 5-year estimates for counties
acsdata <- get_acs(geography = "county", state = c(19, 41, 51), 
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, -ALAND, -AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)

# Join
data <- left_join(acsdata, data, by = c("GEOID" = "fips", "NAME.x" = "county"))


#
# Rename variables for composites ----------------------------------
#

data <- data %>% rename(soc_violcrime = violent_crime_rate,
                        soc_assoc = social_association_rate,
                        soc_freqmental = percent_frequent_mental_distress,
                        soc_juvarrest = juvenile_arrest_rate,
                        soc_suicrate = suicide_rate_age_adjusted)


#
# Write out ----------------------------------
#


write_rds(data, "./rivanna_data/social/soc_chr_2020.Rds")
write_rds(data, "./rivanna_data/financial/fin_laus_2020.Rds")
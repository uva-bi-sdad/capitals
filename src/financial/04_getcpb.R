library(readr)
library(dplyr)
library(tidycensus)
library(sf)
library(stringr)


#
# Read in --------------------------------------------------------------------------------
#

# Note: Original file too large for version control. Start with data file for all counties from
# https://www.census.gov/data/datasets/2018/econ/cbp/2018-cbp.html and 
# https://www.census.gov/data/datasets/2014/econ/cbp/2014-cbp.html if replicating entire workflow.
# Layout explanations at 
# https://www2.census.gov/programs-surveys/cbp/technical-documentation/records-layouts/2018_record_layouts/county-layout-2018.txt

cbpdata14 <- read_csv("./rivanna_data/financial/fin_cbp_2014_orig.txt")
cbpdata18 <- read_csv("./rivanna_data/financial/fin_cbp_2018_orig.txt")


#
# Get ACS --------------------------------------------------------------------------------
#

# Key
readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")

# Pull and transform
acsvars <- c("B01003_001")

acsdata14 <- get_acs(geography = "county", state = c(19, 41, 51), 
                     variables = acsvars,
                     year = 2014, survey = "acs5",
                     cache_table = TRUE, output = "wide", geometry = TRUE,
                     keep_geo_vars = TRUE)

acsdata18 <- get_acs(geography = "county", state = c(19, 41, 51), 
                variables = acsvars,
                year = 2018, survey = "acs5",
                cache_table = TRUE, output = "wide", geometry = TRUE,
                keep_geo_vars = TRUE)

acsdata14 <- acsdata14 %>% transmute(
  STATEFP = STATEFP, 
  COUNTYFP = COUNTYFP, 
  COUNTYNS = COUNTYNS, 
  AFFGEOID = AFFGEOID, 
  GEOID = GEOID, 
  LSAD = LSAD, 
  NAME.x = NAME.x, 
  NAME.y = NAME.y,
  geometry = geometry,
  totalpop14 = B01003_001E
)

acsdata18 <- acsdata18 %>% transmute(
  STATEFP = STATEFP, 
  COUNTYFP = COUNTYFP, 
  COUNTYNS = COUNTYNS, 
  AFFGEOID = AFFGEOID, 
  GEOID = GEOID, 
  LSAD = LSAD, 
  NAME.x = NAME.x, 
  NAME.y = NAME.y,
  geometry = geometry,
  totalpop18 = B01003_001E
)


#
# Calculate businesses per 10k --------------------------------------------------------------------------------
#

# Prepare CBP 
# NAICS = industry code, ------ is top level
# est = Total Number of Establishments
cbpdata18$GEOID <- paste0(cbpdata18$fipstate, cbpdata18$fipscty)
cbpdata18 <- cbpdata18 %>% filter(fipstate == 41 | fipstate == 51 | fipstate == 19)
cbpdata18 <- cbpdata18 %>% filter(naics == "------")

cbpdata14$GEOID <- paste0(cbpdata14$fipstate, cbpdata14$fipscty)
cbpdata14 <- cbpdata14 %>% filter(fipstate == 41 | fipstate == 51 | fipstate == 19)
cbpdata14 <- cbpdata14 %>% filter(naics == "------")
cbpdata14 <- cbpdata14 %>% rename(est14 = est)
cbpdata14 <- cbpdata14 %>% select(GEOID, est14)

# Join
data14 <- left_join(acsdata14, cbpdata14, by = "GEOID")
data18 <- left_join(acsdata18, cbpdata18, by = "GEOID")

data14 <- data14 %>% select(GEOID, totalpop14, est14) %>% st_set_geometry(NULL)
data <- left_join(data18, data14, by = "GEOID")


#
# Calculate --------------------------------------------------------------------------------
#

# Number of businesses per 10,000 people
data <- data %>% mutate(fin_estper10k = est/totalpop18 * 10000)

# Number of new businesses 2014-18 per 10,000 people
data <- data %>% mutate(fin_newestper10k = fin_estper10k - (est14/totalpop14 * 10000))


#
# Calculate HHIs --------------------------------------------------------------------------------
#

# HHI of employment within that county
# fin_emphhi: Square the share of employment for each industry (naics: ----) within a county, then sum those squared values to receive the HHI for that county. 
# HHI of payroll within that county
# fin_aphhi: Square the share of payroll (ap_share) for each industry within a county, then sum those squared values to receive the HHI for that county. 

# Prepare
cbpforindex <- read_csv("./data/financial/fin_cbp_2018_orig.txt")
cbpforindex <- cbpforindex %>% filter(fipstate == 41 | fipstate == 51 | fipstate == 19)
cbpforindex$GEOID <- paste0(cbpforindex$fipstate, cbpforindex$fipscty)

# Filter to major industries
cbpforindex <- cbpforindex %>% filter(naics != "------")
cbpforindex <- cbpforindex %>% filter(str_detect(naics, "----"))
cbpforindex$naics <- as.factor(cbpforindex$naics)
cbpforindex <- data.frame(cbpforindex)

# Prepare totals dataframe (denominator)
cbpforindex_totals <- data.frame(cbpdata18)
cbpforindex_totals <- cbpforindex_totals %>% select(GEOID, emp, ap)
cbpforindex_totals <- cbpforindex_totals %>% rename(emp_total = emp, ap_total = ap)

# Calculate industry shares, then total index
cbpforindex <- left_join(cbpforindex, cbpforindex_totals, by = "GEOID")
cbpforindex <- cbpforindex %>% mutate(share_emp = emp/emp_total * 100, 
                                      share_ap = ap/ap_total * 100,
                                      share_emp_sq = share_emp^2,
                                      share_ap_sq = share_ap^2)
cbpforindex <- cbpforindex %>% group_by(GEOID) %>%
  mutate(fin_emphhi = sum(share_emp_sq),
         fin_aphhi = sum(share_ap_sq)) %>%
  ungroup()

# Get one row
cbpforindex <- cbpforindex %>% select(GEOID, fin_emphhi, fin_aphhi)
cbpforindex <- cbpforindex %>% group_by(GEOID) %>% slice(1) %>% ungroup()
cbpforindex <- data.frame(cbpforindex)


#
# Join to other data --------------------------------------------------------------------------------
#

data <- left_join(data, cbpforindex, by = "GEOID")


#
# Write out --------------------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/financial/fin_cbp_2018.Rds")

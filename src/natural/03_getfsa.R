library(dplyr)
library(magrittr)
library(readxl)
library(readr)

# Read in USDA-FSA Conservation Reserve Program data
fsa = read_xlsx("data/natural/nat_fsa_2020.xlsx", skip = 3)

# Get rid of first row, which has secondary column names
fsa = fsa[-1,]

# Keep only data for the three states of interest
fsa %<>% filter(STATE %in% c("IOWA", "OREGON", "VIRGINIA"))

# Select only the columns of interest
fsa %<>% select(FIPS, STATE, COUNTY, `RARE AND\r\nDECLINING\r\nHABITAT\r\n(CP25)`, `POLLINATOR\r\nHABITAT 8/\r\n(CP42)`, `STATE\r\nACRES FOR\r\nWILDLIFE\r\nENHANCEMENT\r\n(CP38)`)

# Change column names to make them less unwieldy
names(fsa) = c("FIPS", "STATE", "COUNTY", "rare_hab", "pol_hab", "wildlife")

# Write dataframe to rds file
write_rds(fsa, "data/natural/nat_fsa_2020.rds")

library(dplyr)
library(magrittr)
library(readxl)
library(readr)

fsa = read_xlsx("data/natural/nat_fsa_2020.xlsx", skip = 3)

names(fsa)

fsa = fsa[-1,]

fsa %<>% filter(STATE %in% c("IOWA", "OREGON", "VIRGINIA"))

fsa %<>% select(FIPS, STATE, COUNTY, `RARE AND\r\nDECLINING\r\nHABITAT\r\n(CP25)`, `POLLINATOR\r\nHABITAT 8/\r\n(CP42)`, `STATE\r\nACRES FOR\r\nWILDLIFE\r\nENHANCEMENT\r\n(CP38)`)

names(fsa) = c("FIPS", "STATE", "COUNTY", "rare_hab", "pol_hab", "wildlife")


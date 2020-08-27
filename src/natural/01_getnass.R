library(readr)
library(dplyr)
library(magrittr)
library(stringr)

# Read in USDA-NASS data files
ag_land = read_csv("data/natural/nat_nass_2017_aglandtotal.csv")
agritourism = read_csv("data/natural/nat_nass_2017_agritourism.csv", na = c("(D)", ""))
forestry = read_csv("data/natural/nat_nass_2017_forestry.csv", na = c("(D)", ""))

# Create new columns with accurate names and select relevant columns
ag_land %<>% mutate(acres_operated = Value) %>% select(State, `State ANSI`, County, `County ANSI`, acres_operated)
agritourism %<>% mutate(agritourism_revenue = Value) %>% select(State, `State ANSI`, County, `County ANSI`, agritourism_revenue)
forestry %<>% mutate(forestry_revenue = Value) %>% select(State, `State ANSI`, County, `County ANSI`, forestry_revenue)

# Fix column data types
agritourism$`County ANSI` %<>% as.numeric()
forestry$`County ANSI` %<>% as.numeric()
forestry$forestry_revenue = as.numeric(str_remove_all(forestry$forestry_revenue, ","))

# Join separate dataframes
nass_data = full_join(ag_land, agritourism, by = c("State", "State ANSI", "County", "County ANSI"))
nass_data = full_join(nass_data, forestry, by = c("State", "State ANSI", "County", "County ANSI"))

# Write combined dataframe to rds file
write_rds(nass_data, "data/natural/nat_nass_2017.rds")
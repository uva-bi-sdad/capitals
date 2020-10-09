
library(tidyverse)
library(janitor)
library(naniar)

data <- read_csv("./rivanna_data/built/County_Transportation_Profiles.csv") %>% 
  clean_names()


data <- data %>% 
  filter(state_name %in% c("Iowa", "Oregon", "Virginia")) %>% 
  transmute(GEOID = county_fips,
            #county_name = county_name,
            #state_fips = state_fips, 
            #state_name = state_name,
            built_comm_airports = primary_and_commercial_airports,
            built_noncomm_airports = non_commercial_civil_public_use_airports_and_seaplane_base,
            built_bridges = number_of_bridges,
            built_perc_fair_bridges = percent_of_medium_to_fair_condition_bridges,
            built_perc_poor_bridges = percent_of_poor_condition_bridges,
            built_businesses = number_of_business_establishments,
            #built_docks = total_docks,
            #built_marinas = total_marinas, 
            no_residents = number_of_residents,
            no_res_workers = number_of_resident_workers,
            work_athome = number_of_resident_workers_who_work_at_home,
            work_withincounty = number_of_resident_workers_who_commute_within_county,
            work_outsidecounty = number_of_workers_from_other_counties_who_commute_to_work_in_the_county,
            work_fromothercounty = number_of_workers_from_other_counties_who_commute_to_work_in_the_county,
            commute_bytransit = percent_of_resident_workers_who_commute_by_transit
  )

# not too much missing on rows, but the missingness in 
pct_complete_case(data) # 92.53731
pct_complete_var(data) # 70.58824
pct_miss_var(data) # 29.41176

# write this to the data folder 
write_rds(data, "./rivanna_data/built/built_dot_2020.Rds")

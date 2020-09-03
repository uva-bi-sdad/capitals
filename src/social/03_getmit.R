library(tidyverse)

#
# Get data ------------------------------------------------------------------------
#
data <- read.csv("rivanna_data/social/soc_mit_2016.csv")

data <- data %>%
  filter(year == 2016, state %in% c("Iowa", "Oregon", "Virginia")) %>%
  transmute(state = state,
            county = county,
            FIPS = FIPS,
            totalvotes = totalvotes) %>%
  distinct()

#
# Write ------------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/social/soc_mit_2016.rds")
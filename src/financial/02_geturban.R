library(readxl)
library(dplyr)


#
# Read in -------------------------------------------------------------------
#

data <- read_excel("./data/financial/fin_urban_2018_orig.xlsx")


#
# Clean ------------------------------------------------------------------------
#

# Filter to three states
data <- data %>% filter(state == "Virginia" |
                          state == "Oregon" |
                          state == "Iowa")

# "n/a*" = unavailable due to insufficient sample size, recode to NA
data <- data %>% mutate(share_anydebtcollections = ifelse(share_anydebtcollections == "n/a*", NA, share_anydebtcollections))
data$share_anydebtcollections <- as.numeric(data$share_anydebtcollections)

# Convert to percent and rename
data$share_anydebtcollections <- data$share_anydebtcollections * 100
data <- data %>% rename(fin_pctdebtcol = share_anydebtcollections)

# Prepare name for linking
data$fullname <- paste0(data$county, ", ", data$state)


#
# Write ------------------------------------------------------------------------
#

write_rds(data, "./data/financial/fin_urban_2018.Rds")


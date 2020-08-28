library(naniar)
library(dplyr)
library(readxl)
library(readr)

# read in RWJ County Health Rankings data ----------------------------------

ia <- read_excel("./data/human/human_rwj_2020 - Iowa.xlsx", sheet = "Ranked Measure Data", skip=1)
or <- read_excel("./data/human/human_rwj_2020 - Oregon.xlsx", sheet = "Ranked Measure Data", skip=1)
va <- read_excel("./data/human/human_rwj_2020 - Virginia.xlsx", sheet = "Ranked Measure Data", skip=1)

# select only the indicators we want -----------------------------

ia <- ia %>%
  select(FIPS, State, County, 
         `Average Number of Physically Unhealthy Days`,
         `Average Number of Mentally Unhealthy Days`,
         `% Physically Inactive`,
         `Primary Care Physicians Rate`,
         `Mental Health Provider Rate`,
         `% Single-Parent Households`
         )

or <- or %>%
  select(FIPS, State, County, 
         `Average Number of Physically Unhealthy Days`,
         `Average Number of Mentally Unhealthy Days`,
         `% Physically Inactive`,
         `Primary Care Physicians Rate`,
         `Mental Health Provider Rate`,
         `% Single-Parent Households`
  )

va <- va %>%
  select(FIPS, State, County, 
         `Average Number of Physically Unhealthy Days`,
         `Average Number of Mentally Unhealthy Days`,
         `% Physically Inactive`,
         `Primary Care Physicians Rate`,
         `Mental Health Provider Rate`,
         `% Single-Parent Households`
  )

# create one dataframe for the 3 states --------------------------

rwj <- rbind(ia, or, va)

# missingness check --------------------------------------

miss_var_summary(rwj)

# write ----------------------------------

write_rds(rwj, "./data/human/hum_rwj_2020.rds")

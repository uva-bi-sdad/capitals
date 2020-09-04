library(naniar)
library(dplyr)
library(readxl)
library(readr)

# also get math and reading scores from here! it's on the additional measures tab. Reading scores: ER, Math scores: EW


# read in RWJ County Health Rankings data ----------------------------------

ia <- read_excel("./rivanna_data/human/human_rwj_2020 - Iowa.xlsx", sheet = "Ranked Measure Data", skip=1)
or <- read_excel("./rivanna_data/human/human_rwj_2020 - Oregon.xlsx", sheet = "Ranked Measure Data", skip=1)
va <- read_excel("./rivanna_data/human/human_rwj_2020 - Virginia.xlsx", sheet = "Ranked Measure Data", skip=1)

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

# add geometry data from ACS ------------------------------------

rwj$STATEFP <- substr(rwj$FIPS, 1, 2)
rwj$COUNTYFP <- substr(rwj$FIPS, 3, 5)
rwj <- rwj %>%
  rename(GEOID = FIPS)

acs <- readRDS("./rivanna_data/human/hum_acs_2018.rds")

acs <- acs %>%
  select(STATEFP, COUNTYFP, GEOID, geometry)

rwj_geo <- merge(acs, rwj, by=c("STATEFP", "COUNTYFP", "GEOID"), all.x = TRUE)

# rename columns -------------------------------------

rwj_geo <- rwj_geo %>%
  rename(hum_numpoorphys = `Average Number of Physically Unhealthy Days`,
         hum_numpoormental = `Average Number of Mentally Unhealthy Days`,
         hum_pctnophys = `% Physically Inactive`,
         hum_ratepcp = `Primary Care Physicians Rate`,
         hum_ratementalhp = `Mental Health Provider Rate`,
         hum_pctsngparent = `% Single-Parent Households`)


# missingness check --------------------------------------

miss_var_summary(rwj_geo)  # Out of 268, 6 missing in hum_ratepcp, 14 missing in hum_ratementalhp

# write ----------------------------------

write_rds(rwj_geo, "./rivanna_data/human/hum_rwj_2020.rds")

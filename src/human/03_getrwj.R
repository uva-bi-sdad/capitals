library(naniar)
library(dplyr)
library(readxl)
library(readr)
library(sf)
library(tidycensus)

# also get math and reading scores from here! it's on the additional measures tab. Reading scores: ER, Math scores: EW


# read in RWJ County Health Rankings data ----------------------------------

ia1 <- read_excel("./rivanna_data/human/human_rwj_2020 - Iowa.xlsx", sheet = "Ranked Measure Data", skip = 1)
or1 <- read_excel("./rivanna_data/human/human_rwj_2020 - Oregon.xlsx", sheet = "Ranked Measure Data", skip = 1)
va1 <- read_excel("./rivanna_data/human/human_rwj_2020 - Virginia.xlsx", sheet = "Ranked Measure Data", skip = 1)

ia2 <- read_excel("./rivanna_data/human/human_rwj_2020 - Iowa.xlsx", sheet = "Additional Measure Data", skip = 1)
or2 <- read_excel("./rivanna_data/human/human_rwj_2020 - Oregon.xlsx", sheet = "Additional Measure Data", skip = 1)
va2 <- read_excel("./rivanna_data/human/human_rwj_2020 - Virginia.xlsx", sheet = "Additional Measure Data", skip = 1)


# select only the indicators we want -----------------------------

ia1 <- ia1 %>%
  select(FIPS, State, County, 
         `Average Number of Physically Unhealthy Days`,
         `Average Number of Mentally Unhealthy Days`,
         `% Physically Inactive`,
         `Primary Care Physicians Rate`,
         `Mental Health Provider Rate`,
         `% Single-Parent Households`
         )

ia2 <- ia2 %>%
  select(FIPS, State, County, 
         `Average Grade Performance...148`, #reading
         `Average Grade Performance...153`  #math
  )

or1 <- or1 %>%
  select(FIPS, State, County, 
         `Average Number of Physically Unhealthy Days`,
         `Average Number of Mentally Unhealthy Days`,
         `% Physically Inactive`,
         `Primary Care Physicians Rate`,
         `Mental Health Provider Rate`,
         `% Single-Parent Households`
  )

or2 <- or2 %>%
  select(FIPS, State, County, 
         `Average Grade Performance...148`,  #reading
         `Average Grade Performance...153`   #math
  )

va1 <- va1 %>%
  select(FIPS, State, County, 
         `Average Number of Physically Unhealthy Days`,
         `Average Number of Mentally Unhealthy Days`,
         `% Physically Inactive`,
         `Primary Care Physicians Rate`,
         `Mental Health Provider Rate`,
         `% Single-Parent Households`
  )

va2 <- va2 %>%
  select(FIPS, State, County, 
         `Average Grade Performance...148`, #reading
         `Average Grade Performance...153`  #math
  )

# create one dataframe for the 3 states --------------------------

iowa <- left_join(ia1, ia2, by = c("FIPS", "State", "County"))
oregon <- left_join(or1, or2, by = c("FIPS", "State", "County"))
virginia <- left_join(va1, va2, by = c("FIPS", "State", "County"))

rwj <- rbind(iowa, oregon, virginia)

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
         hum_pctsngparent = `% Single-Parent Households`,
         hum_reading = `Average Grade Performance...148`,
         hum_math = `Average Grade Performance...153`)


# missingness check --------------------------------------

miss_var_summary(rwj_geo)  # Out of 268, 6 missing in hum_ratepcp, 14 missing in hum_ratementalhp

# 1 hum_reading           28    10.4 
# 2 hum_math              26     9.70
# 3 hum_ratementalhp      14     5.22
# 4 hum_ratepcp            6     2.24

# write ----------------------------------

write_rds(rwj_geo, "./rivanna_data/human/hum_rwj_2020.rds")

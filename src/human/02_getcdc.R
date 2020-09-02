library(naniar)
library(dplyr)
library(readr)

# read in CDC Wonder data --------------------------

alcohol <- read.delim("./rivanna_data/human/human_cdc_2018 - alcohol.txt", header = TRUE, sep = "\t")
drug_unint <- read.delim("./rivanna_data/human/human_cdc_2018 - drugs1.txt", header = TRUE, sep = "\t")
drug_und <- read.delim("./rivanna_data/human/human_cdc_2018 - drugs2.txt", header = TRUE, sep = "\t")
drug_other <- read.delim("./rivanna_data/human/human_cdc_2018 - drugs3.txt", header = TRUE, sep = "\t")
suicide <- read.delim("./rivanna_data/human/human_cdc_2018 - suicide.txt", header = TRUE, sep = "\t")

# only keep table data, cut off notes - each dataset has 270 rows

alcohol <- alcohol[1:270, ]
drug_unint <- drug_unint[1:270, ]
drug_und <- drug_und[1:270, ]
drug_other <- drug_other[1:270, ]
suicide <- suicide[1:270, ]

# rename columns so that we can merge cdc data into one dataframe

alcohol <- alcohol %>%
  rename(hum_numalcdeaths = Deaths, alc_pop = Population, hum_ratealcdeaths = Crude.Rate)

drug_unint <- drug_unint %>%
  rename(hum_numdrguideaths = Deaths, drg_ui_pop = Population, hum_ratedrguideaths = Crude.Rate)

drug_und <- drug_und %>%
  rename(hum_numdrguddeaths = Deaths, drg_ud_pop = Population, hum_ratedrguddeaths = Crude.Rate)

drug_other <- drug_other %>%
  rename(hum_numdrgodeaths = Deaths, drg_o_pop = Population, hum_ratedrgodeaths = Crude.Rate)

suicide <- suicide %>%
  rename(hum_numsuideaths = Deaths, sui_pop = Population, hum_ratesuideaths = Crude.Rate)


# merge into one dataframe --------------------------------------

cdc <- merge(alcohol, drug_unint, by = c("Notes", "County", "County.Code"), all=TRUE) %>%
  merge(drug_und, by = c("Notes", "County", "County.Code"), all=TRUE) %>%
  merge(drug_other, by = c("Notes", "County", "County.Code"), all=TRUE) %>%
  merge(suicide, by = c("Notes", "County", "County.Code"), all=TRUE)


# check missingness --------------------------------

miss_var_summary(cdc) # none

# noting "missing" and "suppressed" deaths data.  Out of 270 counties --------------------------------------

table(cdc$hum_numalcdeaths) # missing - 2, suppressed - 221, --> 47 counties with numeric data 
table(cdc$hum_numdrguideaths) # missing - 2, suppressed - 222 --> 46 counties with numeric data
table(cdc$hum_numdrguddeaths) # missing - 2, suppressed - 268 --> 0 counties with numeric data
table(cdc$hum_numdrgodeaths) # missing - 2, suppressed - 263 --> 5 counties with numeric data
table(cdc$hum_numsuideaths) # missing - 2, suppressed - 200 --> 68 counties with numeric data

# 2 missing counties are always 51515 & 51560:
# -- Bedford City VA: reverted to town in 2013; Clifton Forge, VA: reverted back to town in 2001


# organize dataframe --------------------------------------------

# all population columns are the same, so only keeping one of them

cdc <- cdc %>%
  select(County, County.Code, alc_pop, hum_ratealcdeaths, hum_ratedrguideaths, hum_ratesuideaths) %>%
  rename(pop = alc_pop,
         GEOID = County.Code,
         hum_ratedrgdeaths = hum_ratedrguideaths)

# add geometry data from ACS ------------------------------------

cdc$STATEFP <- substr(cdc$GEOID, 1, 2)
cdc$COUNTYFP <- substr(cdc$GEOID, 3, 5)

acs <- readRDS("./rivanna_data/human/hum_acs_2018.rds")

acs <- acs %>%
  select(STATEFP, COUNTYFP, GEOID, geometry)

cdc_geo <- merge(acs, cdc, by=c("STATEFP", "COUNTYFP", "GEOID"), all.x = TRUE)


# check missingness ----------------------------------

miss_var_summary(cdc_geo) # nothing missing, but a lot of data is suppressed

table(cdc_geo$hum_ratealcdeaths) # 221 - "Suppressed", 22 - "Unreliable"
table(cdc_geo$hum_ratedrgdeaths) # 222 - "Suppressed", 24 - "Unreliable"
table(cdc_geo$hum_ratesuideaths) # 200 - "Suppressed", 38 - "Unreliable"


# write -------------------------------------------

write_rds(cdc_geo, "./rivanna_data/human/hum_cdc_2018.rds")






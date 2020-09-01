library(naniar)
library(dplyr)
library(readr)

# read in CDC Wonder data --------------------------

alcohol <- read.delim("./data/human/human_cdc_2018 - alcohol.txt", header = TRUE, sep = "\t")
drug_unint <- read.delim("./data/human/human_cdc_2018 - drugs1.txt", header = TRUE, sep = "\t")
drug_und <- read.delim("./data/human/human_cdc_2018 - drugs2.txt", header = TRUE, sep = "\t")
drug_other <- read.delim("./data/human/human_cdc_2018 - drugs3.txt", header = TRUE, sep = "\t")
suicide <- read.delim("./data/human/human_cdc_2018 - suicide.txt", header = TRUE, sep = "\t")

# only keep table data, cut off notes - each dataset has 270 rows

alcohol <- alcohol[1:270, ]       # alcohol-induced causes
drug_unint <- drug_unint[1:270, ] # drug overdoses unintentional
drug_und <- drug_und[1:270, ]     # drug overdoses undetermined
drug_other <- drug_other[1:270, ] # drug overdoses other
suicide <- suicide[1:270, ]       # suicide

# rename columns so that we can merge cdc data into one dataframe

alcohol <- alcohol %>%
  rename(alc_deaths = Deaths, alc_pop = Population, alc_rate = Crude.Rate)

drug_unint <- drug_unint %>%
  rename(drg_ui_deaths = Deaths, drg_ui_pop = Population, drg_ui_rate = Crude.Rate)

drug_und <- drug_und %>%
  rename(drg_ud_deaths = Deaths, drg_ud_pop = Population, drg_ud_rate = Crude.Rate)

drug_other <- drug_other %>%
  rename(drg_o_deaths = Deaths, drg_o_pop = Population, drg_o_rate = Crude.Rate)

suicide <- suicide %>%
  rename(sui_deaths = Deaths, sui_pop = Population, sui_rate = Crude.Rate)


# merge into one dataframe --------------------------------------

cdc <- merge(alcohol, drug_unint, by = c("Notes", "County", "County.Code"), all=TRUE) %>%
  merge(drug_und, by = c("Notes", "County", "County.Code"), all=TRUE) %>%
  merge(drug_other, by = c("Notes", "County", "County.Code"), all=TRUE) %>%
  merge(suicide, by = c("Notes", "County", "County.Code"), all=TRUE)

# organize dataframe --------------------------------------------

# all population columns are the same, so only keeping one of them

cdc <- cdc %>%
  select(County, County.Code, alc_pop, alc_deaths, alc_rate, drg_ui_deaths, drg_ui_rate,
         drg_ud_deaths, drg_ud_rate, drg_o_deaths, drg_o_rate, sui_deaths, sui_rate) %>%
  rename(pop = alc_pop)

# write -------------------------------------------

write_rds(cdc, "./data/human/hum_cdc_2018.rds")


# check missingness --------------------------------

miss_var_summary(cdc) # none

# noting "missing" and "suppressed" deaths data.  Out of 270 counties --------------------------------------

table(cdc$alc_deaths) # missing - 2, suppressed - 221, --> 47 counties with numeric data 
table(cdc$drg_ui_deaths) # missing - 2, suppressed - 222 --> 46 counties with numeric data
table(cdc$drg_ud_deaths) # missing - 2, suppressed - 268 --> 0 counties with numeric data
table(cdc$drg_o_deaths) # missing - 2, suppressed - 263 --> 5 counties with numeric data
table(cdc$sui_deaths) # missing - 2, suppressed - 200 --> 68 counties with numeric data

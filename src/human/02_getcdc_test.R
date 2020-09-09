library(naniar)
library(dplyr)
library(readxl)
library(readr)
library(janitor)
library(sf)

# read in CDC Wonder data --------------------------

alcohol1yr <- read_delim("./rivanna_data/human/human_cdc_alcohol 2018.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
alcohol5yr <- read_delim("./rivanna_data/human/human_cdc_alcohol 2014-18.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
alcohol9yr <- read_delim("./rivanna_data/human/human_cdc_alcohol 2010-18.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()

suicide1yr <- read_delim("./rivanna_data/human/human_cdc_suicide 2018.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
suicide5yr <- read_delim("./rivanna_data/human/human_cdc_suicide 2014-18.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
suicide9yr <- read_delim("./rivanna_data/human/human_cdc_suicide 2010-18.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()

overdose1yr <- read_delim("./rivanna_data/human/human_cdc_overdose 2018.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
overdose5yr <- read_delim("./rivanna_data/human/human_cdc_overdose 2014-18.txt", 
                         col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()
overdose9yr <- read_delim("./rivanna_data/human/human_cdc_overdose 2010-18.txt", 
                          col_types = cols(`County Code` = col_character()), delim = "\t", n_max = 270) %>% clean_names()


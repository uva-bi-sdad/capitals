library(naniar)
library(dplyr)
library(readr)
library(readxl)
library(sf)
library(tidycensus)
library(janitor)


#
# Read in data ----------------------------------
#


# Two-level headers in program files (A, B, C). Skip the first (descriptive) header and retain only variable reference number. 
# The number can be matched to description using the program details sheet.
pir19a <- read_excel("./rivanna_data/human/human_hses_2019/pir_export_2019.xlsx", sheet = "Section A", 
                     col_names = TRUE, skip = 1, trim_ws = TRUE, progress = TRUE) %>% clean_names()

pir19b <- read_excel("./rivanna_data/human/human_hses_2019/pir_export_2019.xlsx", sheet = "Section B", 
                     col_names = TRUE, skip = 1, trim_ws = TRUE, guess_max = 3400, progress = TRUE) %>% clean_names()

pir19c <- read_excel("./rivanna_data/human/human_hses_2019/pir_export_2019.xlsx", sheet = "Section C", 
                     col_names = TRUE, skip = 1, trim_ws = TRUE, guess_max = 3400, progress = TRUE) %>% clean_names()

pir19prog <- read_excel("./rivanna_data/human/human_hses_2019/pir_export_2019.xlsx", sheet = "Program Details", 
                        col_names = TRUE, trim_ws = TRUE, progress = TRUE) %>% clean_names()

pir19ref <- read_excel("./rivanna_data/human/human_hses_2019/pir_export_2019.xlsx", sheet = "Reference", 
                       col_names = TRUE,  trim_ws = TRUE, progress = TRUE) %>% clean_names()
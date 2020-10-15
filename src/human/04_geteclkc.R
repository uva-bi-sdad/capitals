library(naniar)
library(dplyr)
library(readr)
library(sf)
library(tidycensus)


#
# Read in data ----------------------------------
#

ia <- read_csv("./rivanna_data/human/human_eclkc_2020-iowa.csv")
or <- read_csv("./rivanna_data/human/human_eclkc_2020-oregon.csv")
va <- read_csv("./rivanna_data/human/human_eclkc_2020-virginia.csv")

# programCounty = county (or address, ZIP,...) of the grantee/program
# county = county (or address, ZIP,...) of the site
# There are program reports available for grantees (pdf file) with information about number of funded enrollment spots. 
# No easy way to retrieve this. We would have to download a couple hundred pdfs and transcribe from tables?



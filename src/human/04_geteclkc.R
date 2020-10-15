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
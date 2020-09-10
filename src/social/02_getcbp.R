library(tidyverse)
library(naniar)
library(readr)
library(janitor)
library(sf)

#
# Get data ------------------------------------------------------------------------
#

# fipsstate is the state
# est is the number of establishments
# 19 is Iowa, 41 is Oregon, 51 is Virginia
# 813110 is religious, 813410 is civic, 813910 is business, 813940 is political, 813920 is professional, 813930 is labor
# 713950 is bowling, 713940 is fitness, 713910 is golf, 711211 is sports teams
# "81321/", "81331/", "81341/" are non profit codes

data <- read.table("rivanna_data/social/soc_cbp_2016.txt", sep = ",", header = T, colClasses = c("fipstate" = "character", "fipscty" = "character"))
data_state <- data %>%
  filter(naics %in% c("813110", "813410", "813910", "813940", "813920", "813930", "713950", "713940", "713910","711211", "81321/", "81331/", "81341/"), fipstate %in% c("19", "41", "51"))

nonprofit_1 <- data_state[which(data_state$naics == "81321/"),]
nonprofit_1 <- nonprofit_1 %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(nonprofit_1_est = est) %>%
  select(-naics)

nonprofit_2 <- data_state[which(data_state$naics == "81331/"),]
nonprofit_2 <- nonprofit_2 %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(nonprofit_2_est = est) %>%
  select(-naics)

nonprofit_3 <- data_state[which(data_state$naics == "81341/"),]
nonprofit_3 <- nonprofit_3 %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(nonprofit_3_est = est) %>%
  select(-naics)

religious <- data_state[which(data_state$naics == "813110"),]
religious <- religious %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(soc_religiousest = est) %>%
  select(-naics)

civic <- data_state[which(data_state$naics == "813410"),]
civic <- civic %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(soc_civicest = est) %>%
  select(-naics)

business <- data_state[which(data_state$naics == "813910"),]
business <- business %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(soc_businessest = est) %>%
  select(-naics)

political <- data_state[which(data_state$naics == "813940"),]
political <- political %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(soc_politicalest = est) %>%
  select(-naics)

professional <- data_state[which(data_state$naics == "813920"),]
professional <- professional %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(soc_professionalest = est) %>%
  select(-naics)

labor <- data_state[which(data_state$naics == "813930"),]
labor <- labor %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(soc_laborest = est) %>%
  select(-naics)

bowling <- data_state[which(data_state$naics == "713950"),]
bowling <- bowling %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(soc_bowlingest = est) %>%
  select(-naics)

fitness <- data_state[which(data_state$naics == "713940"),]
fitness <- fitness %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(soc_fitnessest = est) %>%
  select(-naics)

golf <- data_state[which(data_state$naics == "713910"),]
golf <- golf %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(soc_golfest = est) %>%
  select(-naics)

sports <- data_state[which(data_state$naics == "711211"),]
sports <- sports %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(soc_sportsest = est) %>%
  select(-naics)

cbp_data <- left_join(religious, civic)
cbp_data <- left_join(cbp_data, business)
cbp_data <- left_join(cbp_data, political)
cbp_data <- left_join(cbp_data, professional)
cbp_data <- left_join(cbp_data, labor)
cbp_data <- left_join(cbp_data, bowling)
cbp_data <- left_join(cbp_data, fitness)
cbp_data <- left_join(cbp_data, golf)
cbp_data <- left_join(cbp_data, sports)
cbp_data <- left_join(cbp_data, nonprofit_1)
cbp_data <- left_join(cbp_data, nonprofit_2)
cbp_data <- left_join(cbp_data, nonprofit_3)
cbp_data[is.na(cbp_data)] = 0
cbp_data$soc_nonprofit <- (cbp_data$nonprofit_1_est + cbp_data$nonprofit_2_est + cbp_data$nonprofit_3_est)

# add geometry data from ACS ------------------------------------

acs <- readRDS("./rivanna_data/social/soc_acs_2016.rds")

acs <- acs %>%
  select(STATEFP, COUNTYFP, GEOID, soc_totalpop, geometry)

cbp_geo <- left_join(acs, cbp_data, by = c("STATEFP" = "fipstate", "COUNTYFP" = "fipscty"))
nrow(cbp_geo)

cbp_geo <- cbp_geo %>%
  select(-nonprofit_1_est, -nonprofit_2_est, -nonprofit_3_est)

cbp_geo$perthousand <- cbp_geo$soc_totalpop/1000

cbp_geo$soc_religiouspop <- cbp_geo$soc_religiousest / cbp_geo$perthousand
cbp_geo$soc_civicspop <- cbp_geo$soc_civicest / cbp_geo$perthousand
cbp_geo$soc_businesspop <- cbp_geo$soc_businessest / cbp_geo$perthousand
cbp_geo$soc_politicalpop <- cbp_geo$soc_politicalest / cbp_geo$perthousand
cbp_geo$soc_professionalpop <- cbp_geo$soc_professionalest / cbp_geo$perthousand
cbp_geo$soc_laborpop <- cbp_geo$soc_laborest / cbp_geo$perthousand
cbp_geo$soc_bowlingpop <- cbp_geo$soc_bowlingest / cbp_geo$perthousand
cbp_geo$soc_fitnesspop <- cbp_geo$soc_fitnessest / cbp_geo$perthousand
cbp_geo$soc_golfpop <- cbp_geo$soc_golfest / cbp_geo$perthousand
cbp_geo$soc_sportspop <- cbp_geo$soc_sportsest / cbp_geo$perthousand
cbp_geo$soc_nonprofitpop <- cbp_geo$soc_nonprofit / cbp_geo$perthousand

cbp_data[is.na(cbp_data)] = 0

# Total
cbp_geo <- cbp_geo %>% mutate(soc_assoctotal = soc_religiouspop + soc_civicspop + soc_businesspop + soc_politicalpop + 
                              soc_professionalpop + soc_laborpop + soc_bowlingpop + soc_fitnesspop + soc_golfpop + soc_sportspop)

# check missingness ----------------------------------

miss_var_summary(cbp_geo) # there is one place missing and it's in oregon, county fips code 69

#
# Write ------------------------------------------------------------------------
#

write_rds(cbp_geo, "./rivanna_data/social/soc_cbp_2016.rds")

library(tidyverse)

#
# Get data ------------------------------------------------------------------------
#

# fipsstate is the state
# est is the number of establishments
# 19 is Iowa, 41 is Oregon, 51 is Virginia
# 813110 is religious, 813410 is civic, 813910 is business, 813940 is political, 813920 is professional, 813930 is labor
# 713950 is bowling, 713940 is fitness, 713910 is golf, 711211 is sports teams

data <- read.table("rivanna_data/social/soc_cbp_2016.txt", sep = ",", header = T)
data_state <- data %>%
  filter(naics %in% c("813110", "813410", "813910", "813940", "813920", "813930", "713950", "713940", "713910","711211"), fipstate %in% c("19", "41", "51"))

religious <- data_state[which(data_state$naics == "813110"),]
religious <- religious %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(religious_est = est) %>%
  select(-naics)

civic <- data_state[which(data_state$naics == "813410"),]
civic <- civic %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(civic_est = est) %>%
  select(-naics)

business <- data_state[which(data_state$naics == "813910"),]
business <- business %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(business_est = est) %>%
  select(-naics)

political <- data_state[which(data_state$naics == "813940"),]
political <- political %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(political_est = est) %>%
  select(-naics)

professional <- data_state[which(data_state$naics == "813920"),]
professional <- professional %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(professional_est = est) %>%
  select(-naics)

labor <- data_state[which(data_state$naics == "813930"),]
labor <- labor %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(labor_est = est) %>%
  select(-naics)

bowling <- data_state[which(data_state$naics == "713950"),]
bowling <- bowling %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(bowling_est = est) %>%
  select(-naics)

fitness <- data_state[which(data_state$naics == "713940"),]
fitness <- fitness %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(fitness_est = est) %>%
  select(-naics)

golf <- data_state[which(data_state$naics == "713910"),]
golf <- golf %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(golf_est = est) %>%
  select(-naics)

sports <- data_state[which(data_state$naics == "711211"),]
sports <- sports %>% transmute(
  fipstate = fipstate,
  fipscty = fipscty,
  naics = naics,
  est = est) %>%
  rename(sports_est = est) %>%
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

cbp_data[is.na(cbp_data)] = 0
  
#
# Write ------------------------------------------------------------------------
#

write_rds(cbp_data, "./rivanna_data/social/soc_cbp_2016.rds")

library(dplyr)
library(readr)
library(sf)
library(naniar)
library(readxl)
library(janitor)


#
# Read in -----------------------------------------------------------------------
#

# Teja's part
data_acs <- read_rds("./rivanna_data/social/soc_acs_2018_remaining.Rds")
data_chr <- read_rds("./rivanna_data/social/soc_chr_2020.Rds") %>% st_drop_geometry()

# Morgan's part
data_acsm18 <- read_rds("./rivanna_data/social/soc_acs_2018.rds")
data_acsm16 <- read_rds("./rivanna_data/social/soc_acs_2016.rds")
data_cbp <- read_rds("./rivanna_data/social/soc_cbp_2016.rds")
data_mit <- read_rds("./rivanna_data/social/soc_mit_2018.rds") %>% st_drop_geometry()
data_census20 <- read_rds("./rivanna_data/social/soc_census_2020.rds") %>% st_drop_geometry()

# Rurality
rurality <- read_excel("./rivanna_data/rurality/IRR_2000_2010.xlsx", 
                       sheet = 2, range = cell_cols("A:C"), col_types = c("text", "text", "numeric")) %>% clean_names()
rurality$fips2010 <- ifelse(nchar(rurality$fips2010) == 4, paste0("0", rurality$fips2010), rurality$fips2010)


#
# Join -----------------------------------------------------------------------
#

data <- left_join(data_acs, data_chr, by = c("STATEFP", "COUNTYFP", "GEOID", "NAME.x", "NAME.y"))
data <- left_join(data, rurality, by = c("GEOID" = "fips2010", "NAME.y" = "county_name"))

data <- data %>% select(-COUNTYNS, -AFFGEOID, -LSAD, -state)


#
# Missingness -----------------------------------------------------------------------
#

pct_complete_case(data) # 55.9
pct_complete_var(data) # 78.3

n_var_complete(data) # 18 variables complete
n_var_miss(data) # 5 have missingness
miss_var_summary(data)
# 1 soc_suicrate      103     38.4
# 2 soc_juvarrest      76     28.4
# 3 soc_violcrime      44     16.4
# 4 soc_assoc          38     14.2
# 5 soc_freqmental     38     14.2


#
# Composites -----------------------------------------------------------------------
#

# Code in the "asset" direction. Higher quintile = better.
# Preserve NAs -- end result should be NA if any index indicator is NA. 

# Define function: Quintiles
calcquint <- function(whichvar) {
  cut(whichvar, 
      quantile(whichvar, 
               prob = seq(0, 1, length = 6), na.rm = TRUE), 
      labels = FALSE, include.lowest = TRUE, right = FALSE)   
}

# Social relationships index
# Number of juvenile arrests per 1000 juveniles, Number of violent crimes per 100,000 population, Percent grandparent householders responsible for own grandchildren
# Percent homeowners, Percent population living in the same house that they lived in one year prior, Percent households with nonrelatives present
# soc_juvarrest, soc_violcrime, soc_grandp, soc_homeown, soc_samehouse, soc_nonrelat
# ! NEED TO REVERSE CODE QUINTILE PLACEMENT FOR: soc_juvarrest, soc_violcrime, soc_grandp, soc_nonrelat
data <- data %>% group_by(STATEFP) %>%
  mutate(soc_homeown_q = calcquint(soc_homeown), 
         soc_juvarrest_q = calcquint(soc_juvarrest), 
         soc_juvarrest_q = case_when(soc_juvarrest_q == 5 ~ 1,
                                     soc_juvarrest_q == 4 ~ 2,
                                     soc_juvarrest_q == 3 ~ 3,
                                     soc_juvarrest_q == 2 ~ 4,
                                     soc_juvarrest_q == 1 ~ 5,
                                     is.na(soc_juvarrest_q) ~ NA_real_),
         soc_violcrime_q = calcquint(soc_violcrime),
         soc_violcrime_q = case_when(soc_violcrime_q == 5 ~ 1,
                                     soc_violcrime_q == 4 ~ 2,
                                     soc_violcrime_q == 3 ~ 3,
                                     soc_violcrime_q == 2 ~ 4,
                                     soc_violcrime_q == 1 ~ 5,
                                     is.na(soc_violcrime_q) ~ NA_real_),
         soc_grandp_q = calcquint(soc_grandp),
         soc_grandp_q = case_when(soc_grandp_q == 5 ~ 1,
                                  soc_grandp_q == 4 ~ 2,
                                  soc_grandp_q == 3 ~ 3,
                                  soc_grandp_q == 2 ~ 4,
                                  soc_grandp_q == 1 ~ 5,
                                  is.na(soc_grandp_q) ~ NA_real_),
         soc_nonrelat_q = calcquint(soc_nonrelat),
         soc_nonrelat_q = case_when(soc_nonrelat_q == 5 ~ 1,
                                    soc_nonrelat_q == 4 ~ 2,
                                    soc_nonrelat_q == 3 ~ 3,
                                    soc_nonrelat_q == 2 ~ 4,
                                    soc_nonrelat_q == 1 ~ 5,
                                    is.na(soc_nonrelat_q) ~ NA_real_),
         soc_index_relat = (soc_homeown_q + soc_juvarrest_q + soc_violcrime_q + soc_grandp_q + soc_nonrelat_q) / 5) %>%
  ungroup()

# Social isolation index
# Percent households with a computing device (computer or smartphone), Percent workers with more than an hour of commute by themselves
# Percent of residents that are not proficient in speaking English, Percent of all county residents who are both over 65 and live alone
# Percent of people who indicated that they have more than 14 poor mental health days per month (frequent mental distress), Number of suicides per 1,000 population
# soc_computer, soc_commalone, soc_limiteng, soc_65alone, soc_freqmental, soc_suicrate
# ! NEED TO REVERSE CODE QUINTILE PLACEMENT FOR: soc_commalone, soc_limiteng, soc_65alone, soc_freqmental, soc_suicrate
data <- data %>% group_by(STATEFP) %>%
  mutate(soc_computer_q = calcquint(soc_computer), 
         soc_commalone_q = calcquint(soc_commalone), 
         soc_commalone_q = case_when(soc_commalone_q == 5 ~ 1,
                                     soc_commalone_q == 4 ~ 2,
                                     soc_commalone_q == 3 ~ 3,
                                     soc_commalone_q == 2 ~ 4,
                                     soc_commalone_q == 1 ~ 5,
                                     is.na(soc_commalone_q) ~ NA_real_),
         soc_limiteng_q = calcquint(soc_limiteng),
         soc_limiteng_q = case_when(soc_limiteng_q == 5 ~ 1,
                                     soc_limiteng_q == 4 ~ 2,
                                     soc_limiteng_q == 3 ~ 3,
                                     soc_limiteng_q == 2 ~ 4,
                                     soc_limiteng_q == 1 ~ 5,
                                     is.na(soc_limiteng_q) ~ NA_real_),
         soc_65alone_q = calcquint(soc_65alone),
         soc_65alone_q = case_when(soc_65alone_q == 5 ~ 1,
                                  soc_65alone_q == 4 ~ 2,
                                  soc_65alone_q == 3 ~ 3,
                                  soc_65alone_q == 2 ~ 4,
                                  soc_65alone_q == 1 ~ 5,
                                  is.na(soc_65alone_q) ~ NA_real_),
         soc_freqmental_q = calcquint(soc_freqmental),
         soc_freqmental_q = case_when(soc_freqmental_q == 5 ~ 1,
                                    soc_freqmental_q == 4 ~ 2,
                                    soc_freqmental_q == 3 ~ 3,
                                    soc_freqmental_q == 2 ~ 4,
                                    soc_freqmental_q == 1 ~ 5,
                                    is.na(soc_freqmental_q) ~ NA_real_),
         soc_suicrate_q = calcquint(soc_suicrate),
         soc_suicrate_q = case_when(soc_suicrate_q == 5 ~ 1,
                                      soc_suicrate_q == 4 ~ 2,
                                      soc_suicrate_q == 3 ~ 3,
                                      soc_suicrate_q == 2 ~ 4,
                                      soc_suicrate_q == 1 ~ 5,
                                      is.na(soc_suicrate_q) ~ NA_real_),
         soc_index_isol = (soc_computer_q + soc_commalone_q + soc_limiteng_q + soc_65alone_q + soc_freqmental_q + soc_suicrate_q) / 6) %>%
  ungroup()

# Community Engagement Index	
# Number of social associations per 10,000 population
# soc_assoc
data <- data %>% group_by(STATEFP) %>%
  mutate(soc_assoc_q = calcquint(soc_assoc),
         soc_index_assoc = (soc_assoc_q) / 1) %>%
  ungroup()


#
# Social capital index ------------------------------------------------------
#

# First factor: The aggregate for all of above variables (all the org variables) divided by population per 1,000
# Second factor: Voter turnout
# Third factor: Census response rate
# Fourth factor: Number of non-profit organizations without including those with an international approach 

# Establishments: soc_assoctotal (soc_religiouspop, soc_civicpop, soc_businesspop, soc_politicalpop, soc_professionalpop, soc_laborpop, soc_bowlingpop, soc_fitnesspop, soc_golfpop, soc_sportspop)
# Voter turnout: soc_voterrate
# Census response rate: soc_overallcensusrate
# Nonprofits: soc_nonprofitpop

# data_cbp: soc_assoctotal, soc_nonprofitpop
# data_mit: soc_voterrate
# data_census20: soc_overallcensusrate

# No reverse coding here. 
data_sci <- left_join(data_cbp, data_mit, by = c("STATEFP", "COUNTYFP", "GEOID"))
data_sci <- left_join(data_sci, data_census20, by = c("STATEFP", "COUNTYFP", "GEOID"))

data_sci <- data_sci %>% group_by(STATEFP) %>%
  mutate(soc_assoctotal_q = calcquint(soc_assoctotal),
         soc_voterrate_q = calcquint(soc_voterrate),
         soc_overallcensusrate_q = calcquint(soc_overallcensusrate),
         soc_nonprofitpop_q = calcquint(soc_nonprofitpop),
         soc_index_eng = (soc_assoctotal_q + soc_voterrate_q + soc_overallcensusrate_q + soc_nonprofitpop_q) / 4) %>%
  ungroup()

data_sci <- st_drop_geometry(data_sci)


#
# Join both ------------------------------------------------------
#


data <- left_join(data, data_sci, by = c("STATEFP", "COUNTYFP", "GEOID"))
miss_var_summary(data)

#
# Discretize Rurality ----------------------------------------------
#

#Create a variable to assign colors to ranges of the IRR
IRR <- data.frame()
IRR <- data %>%
  select(GEOID, county, state, irr2010) %>% 
  st_drop_geometry()

IRR$group[which(IRR$irr2010>=0.45 & IRR$irr2010<0.55)]="[0.45, 0.55)"
IRR$group[which(IRR$irr2010<0.15)]="[0.12, 0.15)"
IRR$group[which(IRR$irr2010>=0.15 & IRR$irr2010<0.25)]="[0.15, 0.25)"
IRR$group[which(IRR$irr2010>=0.25 & IRR$irr2010<0.35)]="[0.25, 0.35)"
IRR$group[which(IRR$irr2010>=0.35 & IRR$irr2010<0.45)]="[0.35, 0.45)"
IRR$group[which(IRR$irr2010>=0.55 & IRR$irr2010<0.65)]="[0.55, 0.65)"
IRR$group[which(IRR$irr2010>=0.65)]="[0.65, 0.68]"
IRR$group<-factor(IRR$group,
                  levels=c("[0.12, 0.15)","[0.15, 0.25)","[0.25, 0.35)","[0.35, 0.45)",
                           "[0.45, 0.55)","[0.55, 0.65)","[0.65, 0.68]"))
names(IRR)<-c("GEOID","county","state","irr2010","irr2010_discretize")

#Divergent Palette color for the IRR box plots points
# DIV<-c("#B2521A","#D47417","#EB8E38","#C0C0C4","#C3B144","#7F842C","#4E5827")
# DIVwarm<-colorRampPalette(DIV[1:3])(4)
# DIVcool<-colorRampPalette(DIV[5:7])(4)
# DIV.P1<-c(DIVwarm,"#F9F1CB",DIVcool)
# show_col(DIV.P1)
# GATES.EM2<-DIV.P1[c(9,8,7,6,5,4,2)]; show_col(GATES.EM2)

data_discretize <- left_join(data, IRR, by = c("GEOID", "state", "county"))
data_discretize <- data_discretize %>%
  select(-irr2010.y) %>%
  rename(irr2010 = irr2010.x)


#
# Write -----------------------------------------------------------------------
#

write_rds(data_discretize, "./rivanna_data/social/soc_final.Rds")






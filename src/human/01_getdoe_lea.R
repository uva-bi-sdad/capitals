library(naniar)
library(dplyr)
library(readxl)
library(readr)

# read in Dept of Education data ---------------------

math_1718 <- read_csv("./rivanna_data/human/human_doe_LEAmath2017-18.csv", 
                      col_types = cols_only(
                        STNAM = "c",
                        FIPST = "c",
                        LEAID = "c",
                        ST_LEAID = "c",
                        LEANM = "c",
                        #SCHNAM = "c",
                        #NCESSCH = "c",
                        #ST_SCHID = "c",
                        ALL_MTH00NUMVALID_1718 = "c",
                        ALL_MTH00PCTPROF_1718 = "c"
                      ))

math_1617 <- read_csv("./rivanna_data/human/human_doe_LEAmath2016-17.csv",
                      col_types = cols_only(
                        STNAM = "c",
                        FIPST = "c",
                        LEAID = "c",
                        ST_LEAID = "c",
                        LEANM = "c",
                        #SCHNAM = "c",
                        #NCESSCH = "c",
                        #ST_SCHID = "c",
                        ALL_MTH00NUMVALID_1617 = "c",
                        ALL_MTH00PCTPROF_1617 = "c"
                      ))


rla <- read_csv("./rivanna_data/human/human_doe_LEArla2017-18.csv",
                col_types = cols_only(
                  STNAM = "c",
                  FIPST = "c",
                  LEAID = "c",
                  ST_LEAID = "c",
                  LEANM = "c",
                  #SCHNAM = "c",
                  #NCESSCH = "c",
                  #ST_SCHID = "c",
                  ALL_RLA00NUMVALID_1718 = "c",
                  ALL_RLA00PCTPROF_1718 = "c"
                )
)


# filter for IA, OR, VA --------------------------

math_1718 <- math_1718 %>%
  filter(FIPST == "19" | FIPST == "41") %>%   # IA and OR
  rename(mth_n = ALL_MTH00NUMVALID_1718,
         mth_pctprof = ALL_MTH00PCTPROF_1718)

math_1617 <- math_1617 %>%
  filter(FIPST == "51") %>%   # VA only
  rename(mth_n = ALL_MTH00NUMVALID_1617,
         mth_pctprof = ALL_MTH00PCTPROF_1617)

rla <- rla %>%
  filter(FIPST == "19" | FIPST == "41" | FIPST == "51") %>%
  rename(rla_n = ALL_RLA00NUMVALID_1718,
         rla_pctprof = ALL_RLA00PCTPROF_1718)

# bind math scores -----------------------------------

math <- rbind(math_1718, math_1617)

#
# merge math and reading scores ----------------------------------------
#

setdiff(math$LEAID, rla$LEAID)  # empty set
setdiff(rla$LEAID, math$LEAID)  # empty set

ed <- merge(math, rla, by = c("STNAM", "FIPST", "LEAID", "ST_LEAID", "LEANM"), all = TRUE)  

miss_var_summary(ed)  # nothing missing


#
# read in geography information to map school district to county -------------------------------
#

geo <- read_excel("./rivanna_data/human/human_edge_LEA1819.xlsx")

# filter for only IA, OR, VA 

geo <- geo %>% 
  filter(STFIP == 19 | STFIP == 41 | STFIP == 51) %>%
  select(LEAID, STFIP, CNTY, NMCNTY)

# merge geography information and assessment scores so that we can aggregate by county ---------------

ed_bycnty <- merge(ed, geo, by="LEAID", all.x = TRUE)


#
# aggregate math and rla scores by county --------------------------------
#

# ??? what to do with score ranges



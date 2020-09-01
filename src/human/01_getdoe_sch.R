library(naniar)
library(dplyr)
library(readxl)
library(readr)

# read in Dept of Education data ---------------------

math_1718 <- read_csv("./rivanna_data/human/human_doe_math2017-18.csv", 
                      col_types = cols_only(
                        STNAM = "c",
                        FIPST = "c",
                        LEAID = "c",
                        ST_LEAID = "c",
                        LEANM = "c",
                        SCHNAM = "c",
                        NCESSCH = "c",
                        ST_SCHID = "c",
                        ALL_MTH00NUMVALID_1718 = "c",
                        ALL_MTH00PCTPROF_1718 = "c"
                        ))
                      
math_1617 <- read_csv("./rivanna_data/human/human_doe_math2016-17.csv",
                      col_types = cols_only(
                        STNAM = "c",
                        FIPST = "c",
                        LEAID = "c",
                        ST_LEAID = "c",
                        LEANM = "c",
                        SCHNAM = "c",
                        NCESSCH = "c",
                        ST_SCHID = "c",
                        ALL_MTH00NUMVALID_1617 = "c",
                        ALL_MTH00PCTPROF_1617 = "c"
                      ))
                      
                      
rla <- read_csv("./rivanna_data/human/human_doe_rla2017-18.csv",
                col_types = cols_only(
                  STNAM = "c",
                  FIPST = "c",
                  LEAID = "c",
                  ST_LEAID = "c",
                  LEANM = "c",
                  SCHNAM = "c",
                  NCESSCH = "c",
                  ST_SCHID = "c",
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

setdiff(math$NCESSCH, rla$NCESSCH)  
# "510004202386" "510004202390" "510009000016" "510021000074" "510030000116" "510030000135"
# "510111002750" "510387001734" "510408001783"

setdiff(rla$NCESSCH, math$NCESSCH)  
# "191269000768" "193093000483" "510186003043" "510225003036" "510236003034" "510313003044"
# "510387003038" "510387003039" "510405003042"

ed <- merge(math, rla, by = c("STNAM", "FIPST", "LEAID", "ST_LEAID", "LEANM", 
                              "NCESSCH", "ST_SCHID", "SCHNAM"), all = TRUE)   # length 4288 (12 extra)

# find out where these 12 extra schools came from

temp <- table(ed$NCESSCH)
temp[temp > 1]
# 510004202382 510051001897 510126000497 510126001099 510291002794 510313003025 510324002307 
# 510402001776 510405001777 510405001780 510408001793 510408002050

# Note: these 12 extra schools come from not exact matches on SCHNAM.  Most were just slight changes
# in words/punctuation used, but a few were from schools that changed names.  All of the name changes
# checked out, and we will use the more recent names from rla. (VA math scores came from 16-17.)

ed <- merge(math, rla, by = c("STNAM", "FIPST", "LEAID", "ST_LEAID", "LEANM", 
                              "NCESSCH", "ST_SCHID"), all = TRUE)   # length 4276 

miss_var_summary(ed)  # 9 missing rla and math scores - to be expected from the setdiff commands above


#
# read in geography information to map school to county -------------------------------
#

geo <- read_excel("./rivanna_data/human/human_edge_1819.xlsx")

# filter for only IA, OR, VA 

geo <- geo %>% 
  filter(STFIP == 19 | STFIP == 41 | STFIP == 51) %>%
  select(NCESSCH, STFIP, CNTY, NMCNTY)

# merge geography information and assessment scores so that we can aggregate by county ---------------

ed_bycnty <- merge(ed, geo, by="NCESSCH", all.x = TRUE)


#
# aggregate math and rla scores by county --------------------------------
#

# ??? what to do with score ranges


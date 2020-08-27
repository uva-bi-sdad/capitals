library(readxl)
library(dplyr)
library(janitor)
library(tidygeocoder)
library(readr)


#
# Read in ------------------------------------------------------------------------------
#

# Read in. Warnings are OK - coercion was correct.
data <- read_excel("./rivanna_data/financial/fin_cdfi_2020_orig.xlsx", 
                   col_types = c("text", "date", "text", "text", "text", "text", "text", "text", "text")) %>% clean_names()


#
# Filter to three states and geocode ------------------------------------------------------------------------------
#

# Filter
data <- data %>% filter(state == "VA" | state == "IA" | state == "OR")

# Prepare full address
data$zip <- substr(data$zipcode, 1, 5)
data$fulladdress <- paste0(data$address1, ", ", data$city, ", ", data$state, " ", data$zip)
data <- data.frame(data)

# Geocode
data <- data %>% geocode(fulladdress, lat = latitude, long = longitude, method = "census")

# Manual
# Affiliated Tribes of Northwest Indians Financial Services - geocode physical not mailing address (9836 E. Burnside Street, Portland, OR 97216)
data$latitude[1] <- 45.522707
data$longitude[1] <- -122.562577

# Business Seed Capital, Inc. - geocode physical not mailing address (302 2nd St SW, Roanoke, VA 24011, USA)
data$latitude[4] <- 37.271747
data$longitude[4] <- -79.944047

# Consolidated Federal Credit Union - manual
data$latitude[12] <- 45.530741
data$longitude[12] <- -122.659916

# Habitat for Humanity of Oregon - geocode physical not mailing address (5825 N Greeley Ave, Portland, OR 97217)
data$latitude[21] <- 45.565730
data$longitude[21] <- -122.695977

# HDC Community Fund LLC 847 NE 19th Avenue, Suite 150, Portland, OR 97232 - manual
data$latitude[22] <- 45.529400
data$longitude[22] <- -122.648016

# MID OREGON FEDERAL CREDIT UNION - geocode main branch not mailing (28 1386 NE Cushing Drive Bend, OR 97701)
data$latitude[28] <- 44.065146
data$longitude[28] <- -121.264172

# Network for Oregon Affordable Housing (1020 SW Taylor Street Suite #585, Portland, OR 97205)
data$latitude[31] <- 45.519326
data$longitude[31] <- -122.683412

# Newport News Shipbuilding Employees Credit Union (1 BayPort Way Ste 350, Newport News, VA 23606)
data$latitude[32] <- 37.105059
data$longitude[32] <- -76.481623

# Peoples Advantage Federal Credit Union - geocode physical not mailing (110 Wagner Rd., Petersburg, VA 23805)
data$latitude[34] <- 37.189609
data$longitude[34] <- -77.367049

# Point West Credit Union (main branch not mailing, 1107 NE 9th Ave #108, Portland, OR 97232)
data$latitude[36] <- 45.531585
data$longitude[36] <- -122.657321

# Portland Housing Center,  3233 NE Sandy Blvd, Portland, OR 97232
data$latitude[37] <- 45.532155
data$longitude[37] <- -122.631251

# RVA Financial Federal Credit Union, 1700 Robin Hood Road, Richmond, VA 23220
data$latitude[38] <- 37.574443
data$longitude[38] <- -77.461763

# Trailhead Federal Credit Union, 221 NW Second Ave, Portland, OR 97209
data$latitude[41] <- 45.525837
data$longitude[41] <- -122.672549
  
#
# Write out ------------------------------------------------------------------------------
#

write_rds(data, "./rivanna_data/financial/fin_cdfi_2020.Rds")
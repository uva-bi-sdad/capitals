
library(tidyverse)



data <- read_csv("./rivanna_data/built/imls-raw/pls_fy18_ae_pud18i.csv")

data <- data %>% 
  rename(state = STABR, 
         built_libname = LIBNAME, 
         built_libaddress = ADDRESS, built_libcity = CITY, built_zip = ZIP, library_phone = PHONE, lat = LATITUDE, lon = LONGITUD, 
         built_lib_avcomputers = GPTERMS, 
         built_lib_computeruse = PITUSR) %>% 
  select(state, library_name, address, city, zipcode, library_phone, lat, lon, available_computers, uses_of_computers) %>% 
  filter(state %in% c("IA", "OR", "VA"))

# data$GPTERMS = Internet computers used by general public 
# PITUSR = Uses of public Internet computers per year 

# https://www.imls.gov/sites/default/files/2018_pls_data_file_documentation.pdf

write_csv(data, "./rivanna_data/built/built_imls_2018.csv")
write_rds(data, "./rivanna_data/built/built_imls_2018.rds")


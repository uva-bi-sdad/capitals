
library(tidyverse)
library(naniar)


data <- read_csv("./rivanna_data/built/imls-raw/pls_fy18_ae_pud18i.csv")

data <- data %>% 
  rename(state = STABR, 
         built_libname = LIBNAME, 
         built_libaddress = ADDRESS, built_libcity = CITY, built_libzip = ZIP, 
         built_libphone = PHONE, built_liblat = LATITUDE, built_liblon = LONGITUD, 
         # data$GPTERMS = Internet computers used by general public 
         # PITUSR = Uses of public Internet computers per year 
         built_lib_avcomputers = GPTERMS, built_lib_computeruse = PITUSR) %>% 
  select(state, built_libname, built_libaddress, built_libcity, built_libzip, built_libphone, built_liblat, built_liblon, 
         built_lib_avcomputers, built_lib_computeruse) %>% 
  filter(state %in% c("IA", "OR", "VA")) %>%  
  mutate(city_state = paste0(built_libcity, ", ", state),
         city_state = stringr::str_to_title(city_state),
         city_state = str_replace_all(city_state, ", Ia", ", IA"),
         city_state = str_replace_all(city_state, ", Or", ", OR"),
         city_state = str_replace_all(city_state, ", Va", ", VA")) 
  
cities_data <- read_csv("./rivanna_data/built/uscities.csv") %>% 
  filter(state_id %in% c("IA", "OR", "VA")) %>% 
  mutate(city_state = paste0(city, ", ", state_id)) %>% 
  select(city_state, county_fips, county_name) %>% 
  mutate(city_state = str_replace_all(city_state, "McGregor, IA", "Mcgregor, IA"),
         city_state = str_replace_all(city_state, "DeWitt, IA", "De Witt, IA"),
         city_state = str_replace_all(city_state, "Charlotte Court House, VA", "Charlotte Court Hous, VA"),
         city_state = str_replace_all(city_state, "McMinnville, OR", "Mcminnville, OR"),
         city_state = str_replace_all(city_state, "Amelia, VA", "Amelia Court House, VA")) %>% 
  add_row(city_state = "Jewell, IA", county_fips = "19079", county_name = "Hamilton") %>% 
  add_row(city_state = "Luverne, IA", county_fips = "19081", county_name = "Hancock") %>% 
  add_row(city_state = "Agness, OR", county_fips = "41015", county_name = "Curry") %>% 
  add_row(city_state = "Chesterfield, VA", county_fips = "51041", county_name = "Chesterfield") %>% 
  add_row(city_state = "Gloucester, VA", county_fips = "51073", county_name = "Gloucester") %>%
  add_row(city_state = "Henrico, VA", county_fips = "51087", county_name = "Henrico") %>% 
  add_row(city_state = "Amelia, VA", county_fips = "51007", county_name = "Amelia") %>% 
  add_row(city_state = "Prince William, VA", county_fips = "51153", county_name = "Prince William") 


library_count <- data %>% 
  left_join(cities_data, by = "city_state") %>% 
  group_by(county_fips) %>%
  count()

lib_data <- data %>% 
  left_join(cities_data, by = "city_state") %>% 
  group_by(county_fips) %>% 
  summarize(built_lib_avcomputers = sum(built_lib_avcomputers),
            built_lib_computeruse = sum(built_lib_computeruse)) %>% 
  full_join(library_count, by = "county_fips") %>% 
  rename(GEOID = county_fips, built_publibs = n) %>% 
  select(GEOID, built_publibs, everything())


pct_complete_case(lib_data)
pct_complete_var(lib_data) 
pct_miss_var(lib_data) 


# https://www.imls.gov/sites/default/files/2018_pls_data_file_documentation.pdf

# write the data 
write_rds(lib_data, "./rivanna_data/built/built_imls_2018.rds")


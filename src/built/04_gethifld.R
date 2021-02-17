rm(list = ls())

library(sf)
library(dplyr)
library(magrittr)
library(readr)
library(tidyr)
library(tidycensus)
library(naniar)

# https://hifld-geoplatform.opendata.arcgis.com/search

# Using HIFLD Cellular Towers, Aircraft Landing Facilities, EMS Stations, Electric Substations,
# and EPA FRS Wastewater Treatment Plants to investigate quality, and if viable,
# identify points in OR/VA/IA and tally by county.

# ** Unable to download Aircraft Landing Facilities right now "An error occurred fetching data." **

#cell_service = st_read("rivanna_data/built/Cellular_Service_Areas-shp/CellularServiceAreas.shp")
cell = st_read("rivanna_data/built/Cellular_Towers-shp/CellularTowers.shp")
electric = st_read("rivanna_data/built/Electric_Substations-shp/Substations.shp")
ems = st_read("rivanna_data/built/ems-shp/ems.shp")
waste_water = st_read("rivanna_data/built/epa-wastewater-shp/epa.shp")
fire = st_read("rivanna_data/built/Fire_Stations-shp/Fire_Stations.shp")

# Brandon adding (first round)
universities = st_read("rivanna_data/built/Colleges_and_Universities-shp/Colleges_and_Universities.shp")
supp_colleges = st_read("rivanna_data/built/SupplementalColleges-shp/SupplementalColleges.shp")
public_schools = st_read("rivanna_data/built/PublicSchools-shp/PublicSchools.shp")
private_schools = st_read("rivanna_data/built/Private_Schools-shp/Private_Schools.shp")
places_of_worship = st_read("rivanna_data/built/All_Places_Of_Worship-shp/All_Places_Of_Worship.shp")
fairgrounds = st_read("rivanna_data/built/ConventionCentersFairgrounds-shp/ConventionCentersFairgrounds.shp")
sports_venues = st_read("rivanna_data/built/MajorSportVenues-shp/MajorSportVenues.shp")
hospitals = st_read("rivanna_data/built/Hospitals-shp/Hospitals.shp")
psap_areas = st_read("rivanna_data/built/PSAP_911_Service_Areas-shp/PSAP_911_Service_Area_Boundaries.shp")
urgent_care = st_read("rivanna_data/built/UrgentCareFacs-shp/UrgentCareFacs.shp")
va_health = st_read("rivanna_data/built/Veterans_Health_Medical_Facilities-shp/Veterans_Health_Administration_Medical_Facilities.shp")
local_police = st_read("rivanna_data/built/Local_Law_Enforcement-shp/Local_Law_Enforcement.shp")
roads = st_read("rivanna_data/built/National_Highway_Inventory-shp/National_Highway_Planning_Network.shp")
power_plants = st_read("rivanna_data/built/epa-power-plants-shp/Environmental_Protection_Agency__EPA__Facility_Registry_Service__FRS__Power_Plants.shp")
ethanol_plants = st_read("rivanna_data/built/ethanol-plants-shp/Ethanol_Plants.shp")
ethanol_transloading_sites = st_read("rivanna_data/built/ethanol-transloading-facs-shp/EthanolTransloading_Facilities.shp")
petroleum_plants = st_read("rivanna_data/built/petroleum-ports-shp/Petroleum_Ports.shp")
petroleum_terminals = st_read("rivanna_data/built/petroleum-terminals-shp/POL_Terminals.shp")
biodiesel_plants = st_read("rivanna_data/built/biodiesel-plants-shp/BiodieselPlants.shp")
solid_waste_sites = st_read("rivanna_data/built/solid-waste-shp/SolidWasteLandfillFacilities.shp")
prisons = st_read("rivanna_data/built/Prison_Boundaries-shp/Prison_Boundaries.shp")
fdic_banks = st_read("rivanna_data/built/fdic-insured-banks-shp/FDIC_Insured_Banks.shp")
ups_facilties = st_read("rivanna_data/built/ups-facilities-shp/UPS_Facilities.shp")
fedex_facilities = st_read("rivanna_data/built/fedex-facilities-shp/FedEx_Facilities.shp")
dhl_facilities = st_read("rivanna_data/built/dhl-facilities-shp/DHL_Facilities.shp")
#private_shipping_facilities = st_read("rivanna_data/built/pirvate-shipping-facilities-shp/PrivateShippingFacilities.shp")
truck_driving_schools = st_read("rivanna_data/built/truck-driving-schools-shp/TruckDrivingSchools.shp")
crushed_stone_operations = st_read("rivanna_data/built/crushed-stone-operations-shp/Crushed_Stone_Operations.shp")


# Get counties and geometries from acs
Sys.getenv("CENSUS_API_KEY")

acsdata <- get_acs(geography = "county", state = c(19, 41, 51),
                   variables = "B01003_001",
                   year = 2018, survey = "acs5",
                   cache_table = TRUE, output = "wide", geometry = TRUE,
                   keep_geo_vars = TRUE)
acsdata <- acsdata %>% select(-LSAD, -AFFGEOID, NAME.x, ALAND, AWATER, -COUNTYNS, -B01003_001E, -B01003_001M)

# Spatial join, adding acs data to each observation in each dataframe
cell = st_join(st_transform(cell, crs = st_crs(acsdata)), acsdata)
electric = st_join(st_transform(electric, crs = st_crs(acsdata)), acsdata)
ems = st_join(st_transform(ems, crs = st_crs(acsdata)), acsdata)
waste_water = st_join(st_transform(waste_water, crs = st_crs(acsdata)), acsdata)
fire = st_join(st_transform(fire, crs = st_crs(acsdata)), acsdata)
# Brandon adding 
universities = st_join(st_transform(universities, crs = st_crs(acsdata)), acsdata) # could get enrollment, etc from IPEDS 
supp_colleges = st_join(st_transform(supp_colleges, crs = st_crs(acsdata)), acsdata)
public_schools = st_join(st_transform(public_schools, crs = st_crs(acsdata)), acsdata)
private_schools = st_join(st_transform(private_schools, crs = st_crs(acsdata)), acsdata)
places_of_worship = st_join(st_transform(places_of_worship, crs = st_crs(acsdata)), acsdata)
fairgrounds = st_join(st_transform(fairgrounds, crs = st_crs(acsdata)), acsdata)
sports_venues = st_join(st_transform(sports_venues, crs = st_crs(acsdata)), acsdata)
hospitals = st_join(st_transform(hospitals, crs = st_crs(acsdata)), acsdata)
psap_areas = st_join(st_transform(psap_areas, crs = st_crs(acsdata)), acsdata)
urgent_care = st_join(st_transform(urgent_care, crs = st_crs(acsdata)), acsdata)
va_health = st_join(st_transform(va_health, crs = st_crs(acsdata)), acsdata)
local_police = st_join(st_transform(local_police, crs = st_crs(acsdata)), acsdata)
roads = st_join(st_transform(roads, crs = st_crs(acsdata)), acsdata)
power_plants = st_join(st_transform(power_plants, crs = st_crs(acsdata)), acsdata)
ethanol_plants = st_join(st_transform(ethanol_plants, crs = st_crs(acsdata)), acsdata)
ethanol_transloading_sites = st_join(st_transform(ethanol_transloading_sites, crs = st_crs(acsdata)), acsdata)
petroleum_plants = st_join(st_transform(petroleum_plants, crs = st_crs(acsdata)), acsdata)
petroleum_terminals = st_join(st_transform(petroleum_terminals, crs = st_crs(acsdata)), acsdata)
biodiesel_plants = st_join(st_transform(biodiesel_plants, crs = st_crs(acsdata)), acsdata)
solid_waste_sites = st_join(st_transform(solid_waste_sites, crs = st_crs(acsdata)), acsdata)
prisons = st_join(st_transform(prisons, crs = st_crs(acsdata)), acsdata)
fdic_banks = st_join(st_transform(fdic_banks, crs = st_crs(acsdata)), acsdata)
ups_facilties = st_join(st_transform(ups_facilties, crs = st_crs(acsdata)), acsdata)
fedex_facilities = st_join(st_transform(fedex_facilities, crs = st_crs(acsdata)), acsdata)
dhl_facilities = st_join(st_transform(dhl_facilities, crs = st_crs(acsdata)), acsdata)
#private_shipping_facilities = st_join(st_transform(private_shipping_facilities, crs = st_crs(acsdata)), acsdata)
truck_driving_schools = st_join(st_transform(truck_driving_schools, crs = st_crs(acsdata)), acsdata)
crushed_stone_operations = st_join(st_transform(crushed_stone_operations, crs = st_crs(acsdata)), acsdata)


# Keep only observations that are in the three states
cell %<>% filter(STATEFP %in% c("19", "41", "51"))
electric %<>% filter(STATEFP %in% c("19", "41", "51"))
ems %<>% filter(STATEFP %in% c("19", "41", "51"))
waste_water %<>% filter(STATEFP %in% c("19", "41", "51"))
fire %<>% filter(STATEFP %in% c("19", "41", "51"))
# Brandon adding 
universities %<>% filter(STATEFP %in% c("19", "41", "51"))
supp_colleges %<>% filter(STATEFP %in% c("19", "41", "51"))
public_schools %<>% filter(STATEFP %in% c("19", "41", "51"))
private_schools %<>% filter(STATEFP %in% c("19", "41", "51"))
places_of_worship %<>% filter(STATEFP %in% c("19", "41", "51"))
fairgrounds %<>% filter(STATEFP %in% c("19", "41", "51"))
sports_venues %<>% filter(STATEFP %in% c("19", "41", "51"))
hospitals %<>% filter(STATEFP %in% c("19", "41", "51"))
psap_areas %<>% filter(STATEFP %in% c("19", "41", "51"))
urgent_care %<>% filter(STATEFP %in% c("19", "41", "51"))
va_health %<>% filter(STATEFP %in% c("19", "41", "51"))
local_police %<>% filter(STATEFP %in% c("19", "41", "51"))
roads %<>% filter(STATEFP %in% c("19", "41", "51"))
power_plants %<>% filter(STATEFP %in% c("19", "41", "51"))
ethanol_plants %<>% filter(STATEFP %in% c("19", "41", "51"))
ethanol_transloading_sites %<>% filter(STATEFP %in% c("19", "41", "51"))
petroleum_plants %<>% filter(STATEFP %in% c("19", "41", "51"))
petroleum_terminals %<>% filter(STATEFP %in% c("19", "41", "51"))
biodiesel_plants %<>% filter(STATEFP %in% c("19", "41", "51"))
solid_waste_sites %<>% filter(STATEFP %in% c("19", "41", "51"))
prisons %<>% filter(STATEFP %in% c("19", "41", "51"))
fdic_banks %<>% filter(STATEFP %in% c("19", "41", "51"))
ups_facilties %<>% filter(STATEFP %in% c("19", "41", "51"))
fedex_facilities %<>% filter(STATEFP %in% c("19", "41", "51"))
dhl_facilities %<>% filter(STATEFP %in% c("19", "41", "51"))
#private_shipping_facilities %<>% filter(STATEFP %in% c("19", "41", "51"))
truck_driving_schools %<>% filter(STATEFP %in% c("19", "41", "51"))
crushed_stone_operations %<>% filter(STATEFP %in% c("19", "41", "51"))


# Count the number of each in each county and fix names/geometry
county_cell <- cell %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_cell) = c("GEOID", "cell_tower_count")
county_electric <- electric %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_electric) = c("GEOID", "electric_substations_count")
county_ems <- ems %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_ems) = c("GEOID", "ems_stations_count")
county_waste_water <- waste_water %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_waste_water) = c("GEOID", "waste_water_treatment_count")
county_fire <- fire %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_fire) = c("GEOID", "fire_station_count")
# brandon adding 
county_university <- universities %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_university) = c("GEOID", "university_count")
county_supp_colleges <- supp_colleges %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_supp_colleges) = c("GEOID", "suppcollege_count")
county_public_schools <- public_schools %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_public_schools) = c("GEOID", "publicschool_count")
county_private_schools <- private_schools %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_private_schools) = c("GEOID", "privateschool_count")
county_places_of_worship <- places_of_worship %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_places_of_worship) = c("GEOID", "placesofworship_count")
county_fairgrounds <- fairgrounds %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_fairgrounds) = c("GEOID", "fairgrounds_count")
county_sports_venues <- sports_venues %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_sports_venues) = c("GEOID", "sportvenues_count")
county_hospitals <- hospitals %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_hospitals) = c("GEOID", "hospital_count")
county_psap <- psap_areas %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_psap) = c("GEOID", "psap_count")
county_urgent_care <- urgent_care %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_urgent_care) = c("GEOID", "urgentcare_count")
county_vahealth <- va_health %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_vahealth) = c("GEOID", "vahealth_count")
county_local_police <- local_police %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_local_police) = c("GEOID", "localpolice_count")
county_prisons <- prisons %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_prisons) = c("GEOID", "prison_count")
county_roads <- roads %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_roads) = c("GEOID", "road_count")
county_roads <- roads %>% 
  group_by(GEOID) %>% summarize(miles_of_road = sum(MILES)) %<>% 
  st_drop_geometry() %>% ungroup() %>% full_join(county_roads, by = "GEOID") %>% select(GEOID, road_count, miles_of_road)
county_power_plants <- power_plants %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_power_plants) = c("GEOID", "power_plant_count")
county_ethanol_plants <- ethanol_plants %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_ethanol_plants) = c("GEOID", "ethanol_plant_count")
county_ethanol_loading <- ethanol_transloading_sites %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_ethanol_loading) = c("GEOID", "ethanol_loading_count")
county_petro_plants <- petroleum_plants %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_petro_plants) = c("GEOID", "petro_plant_count")
county_petro_terminals <- petroleum_terminals %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_petro_terminals) = c("GEOID", "petro_terminal_count")
county_biodiesel_plants <- biodiesel_plants %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_biodiesel_plants) = c("GEOID", "biodiesel_plant_count")
county_solid_waste <- solid_waste_sites %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_solid_waste) = c("GEOID", "solidwaste_fac_count")
county_fdic_banks <- fdic_banks %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_fdic_banks) = c("GEOID", "fdic_bank_count")
county_ups_facs <- ups_facilties %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_ups_facs) = c("GEOID", "ups_facility_count")
county_fedex_facs <- fedex_facilities %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_fedex_facs) = c("GEOID", "fedex_facility_count")
county_dhl_facs <- dhl_facilities %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_dhl_facs) = c("GEOID", "dhl_facility_count")
#county_priv_shipping_facs <- private_shipping_facilities %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
#names(county_priv_shipping_facs) = c("GEOID", "priv_ship_facs_count")
county_trucking_schools <- truck_driving_schools %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_trucking_schools) = c("GEOID", "trucking_school_count")
county_stone_ops <- crushed_stone_operations %>% group_by(GEOID) %>% count() %<>% st_drop_geometry() %>% ungroup()
names(county_stone_ops) = c("GEOID", "stone_ops_count")

# add in students totals, teachers totals, student:teacher ratio for both public private (make sure recode -999 and account for missings)
# do this for both public and private 
#public_schools$ENROLLMENT[public_schools$ENROLLMENT==-999] <- 0
#public_schools$FT_TEACHER[public_schools$FT_TEACHER==-999] <- 0
# could calculate capacity and % filled in prisons 
# number of beds in medical 


#combine them all
hifld_built <- left_join(county_cell, county_electric, by = c("GEOID")) %>%
  left_join(., county_ems, by = c("GEOID")) %>%
  left_join(., county_waste_water, by = c("GEOID")) %>%
  left_join(., county_fire, by = c("GEOID")) %>% 
  # brandon adding 
  left_join(., county_university, by = c("GEOID")) %>%
  left_join(., county_supp_colleges, by = c("GEOID")) %>%
  left_join(., county_public_schools, by = c("GEOID")) %>% 
  left_join(., county_private_schools, by = c("GEOID")) %>%
  left_join(., county_places_of_worship, by = c("GEOID")) %>%
  left_join(., county_fairgrounds, by = c("GEOID")) %>% 
  left_join(., county_sports_venues, by = c("GEOID")) %>%
  left_join(., county_hospitals, by = c("GEOID")) %>%
  left_join(., county_psap, by = c("GEOID")) %>% 
  left_join(., county_urgent_care, by = c("GEOID")) %>%
  left_join(., county_vahealth, by = c("GEOID")) %>%
  left_join(., county_local_police, by = c("GEOID")) %>% 
  left_join(., county_prisons, by = c("GEOID")) %>% 
  left_join(., county_roads, by = c("GEOID")) %>% 
  left_join(., county_power_plants, by = c("GEOID")) %>% 
  left_join(., county_ethanol_plants, by = c("GEOID")) %>% 
  left_join(., county_ethanol_loading, by = c("GEOID")) %>% 
  left_join(., county_petro_plants, by = c("GEOID")) %>% 
  left_join(., county_petro_terminals, by = c("GEOID")) %>% 
  left_join(., county_biodiesel_plants, by = c("GEOID")) %>% 
  left_join(., county_solid_waste, by = c("GEOID")) %>% 
  left_join(., county_fdic_banks, by = c("GEOID")) %>% 
  left_join(., county_ups_facs, by = c("GEOID")) %>% 
  left_join(., county_fedex_facs, by = c("GEOID")) %>% 
  left_join(., county_dhl_facs, by = c("GEOID")) %>% 
  #left_join(., county_priv_shipping_facs, by = c("GEOID")) %>% 
  left_join(., county_trucking_schools, by = c("GEOID")) %>% 
  left_join(., county_stone_ops, by = c("GEOID")) 

hifld_built

# Missingness analysis (missing values are zeros)
pct_complete_case(hifld_built) #
pct_complete_var(hifld_built) # 
pct_miss_var(hifld_built) # 


n_var_complete(hifld_built) # 3
n_var_miss(hifld_built) # 3
miss_var_summary(hifld_built)
# waste_water_treatment_count     16    6.32
# electric_substations_count       3    1.19
# ems_stations_count               2    0.791
# GEOID                            0    0
# cell_tower_count                 0    0
# fire_station_count               0    0

# Create whole DF linked back to ACS with geometry
data <- left_join(acsdata, hifld_built, by = "GEOID")

# Replace NAs with zeros
data$cell_tower_count %<>% replace_na(0)
data$electric_substations_count %<>% replace_na(0)
data$waste_water_treatment_count %<>% replace_na(0)
data$fire_station_count %<>% replace_na(0)
data$ems_stations_count %<>% replace_na(0)
# brandon adding 
data$university_count %<>% replace_na(0)
data$suppcollege_count %<>% replace_na(0)
data$publicschool_count %<>% replace_na(0)
data$privateschool_count %<>% replace_na(0)
data$placesofworship_count %<>% replace_na(0)
data$fairgrounds_count %<>% replace_na(0)
data$sportvenues_count %<>% replace_na(0)
data$hospital_count %<>% replace_na(0)
data$psap_count %<>% replace_na(0)
data$urgentcare_count %<>% replace_na(0)
data$vahealth_count %<>% replace_na(0)
data$localpolice_count %<>% replace_na(0)
data$prison_count %<>% replace_na(0)
data$road_count %<>% replace_na(0)
data$miles_of_road %<>% replace_na(0)
data$power_plant_count %<>% replace_na(0)
data$ethanol_plant_count %<>% replace_na(0)
data$ethanol_loading_count %<>% replace_na(0)
data$petro_plant_count %<>% replace_na(0)
data$petro_terminal_count %<>% replace_na(0)
data$biodiesel_plant_count %<>% replace_na(0)
data$solidwaste_fac_count %<>% replace_na(0)
data$fdic_bank_count %<>% replace_na(0)
data$ups_facility_count %<>% replace_na(0)
data$fedex_facility_count %<>% replace_na(0)
data$dhl_facility_count %<>% replace_na(0)
#data$priv_ship_facs_count %<>% replace_na(0)
data$trucking_school_count %<>% replace_na(0)
data$stone_ops_count %<>% replace_na(0)

#
# Select certain features to cut out all the missingness
#

data <- data %>% 
  select(STATEFP, COUNTYFP, GEOID, NAME.x, NAME.y, 
         university_count, suppcollege_count, publicschool_count, privateschool_count, 
         placesofworship_count, fairgrounds_count, sportvenues_count,  
         hospital_count, psap_count, urgentcare_count, vahealth_count, fire_station_count, ems_stations_count, localpolice_count, 
         electric_substations_count, power_plant_count,  ethanol_plant_count, ethanol_loading_count, petro_plant_count, 
         petro_terminal_count, biodiesel_plant_count, waste_water_treatment_count, solidwaste_fac_count, 
         prison_count, fdic_bank_count, ups_facility_count, fedex_facility_count, dhl_facility_count, #priv_ship_facs_count,
         trucking_school_count, stone_ops_count, cell_tower_count, road_count, miles_of_road, geometry)
         # removing these composites because i'll create them in the 10_assemble file 
         #built_educ_facs, built_convention_facs, built_emergency_facs, built_energy_facs, geometry)

# Missingness analysis (missing values are zeros)
pct_complete_case(data) #94.02985
pct_complete_var(data) # 96.55172
pct_miss_var(data) # 3.448276

# Write
write_rds(data, "rivanna_data/built/built_hifld_2020.rds")

# Check 
check <- read_rds("rivanna_data/built/built_hifld_2020.rds")



















# Code from class sides
# load libraries
library(tidyverse)
library(sf)
library(jsonlite)

# function to convert json
json_to_tibble <- function(x){
    if(is.na(x))  return(x)
    parse_json(x) %>%
    enframe() %>%
    unnest(value)
}

# Read file
bat <- read_csv("C:/code/p3_AshLee/data/SafeGraph - Patterns and Core Data - Chipotle - July 2021/SafeGraph - Patterns and Core Data - Chipotle - July 2021/Core Places and Patterns Data/chipotle_core_poi_and_patterns.csv")

#Freehand code
bat %>%
    slice(5:10) %>%
    #pull(related_same_day_brand) #related in the fact they went from chipolte and the listed store 50 times same day
    pull(popularity_by_day)

# format somehow
datNest <- dat %>%
    slice(1:25) %>% # for the example
    mutate(
        visitor_country_of_origin = map(visitor_country_of_origin, ~json_to_tibble(.x)),
        bucketed_dwell_times = map(bucketed_dwell_times, ~json_to_tibble(.x)),
        related_same_day_brand = map(related_same_day_brand, ~json_to_tibble(.x)),
        related_same_month_brand = map(related_same_month_brand, ~json_to_tibble(.x)),
        popularity_by_hour = map(popularity_by_hour, ~json_to_tibble(.x)),
        popularity_by_day = map(popularity_by_day, ~json_to_tibble(.x)),
        device_type = map(device_type, ~json_to_tibble(.x)),
        visitor_home_cbgs = map(visitor_home_cbgs, ~json_to_tibble(.x)),
        visitor_home_aggregation = map(visitor_home_aggregation, ~json_to_tibble(.x)),
        visitor_daytime_cbgs = map(visitor_daytime_cbgs, ~json_to_tibble(.x))
        ) 

# Exploring
datNest %>% 
    slice(1:5) %>% 
    select(popularity_by_day, device_type) %>% 
    unnest(popularity_by_day) %>% 
    filter(!is.na(name)) %>% 
    pivot_wider(names_from = name, values_from = value) # note that the rows b/c col headers

# Exploring
datNest %>% 
    slice(1:5) %>% 
    select(placekey, location_name, latitude, longitude, city , region, popularity_by_day) %>% 
    unnest(popularity_by_day) %>% 
    filter(!is.na(name)) %>% 
    pivot_wider(names_from = name, values_from = value) # note that the rows b/c col headers




dat %>% slice(1:5) %>% select(placekey, location_name, latitude, longitude, city 
    , region, device_type)

# 10/11 data

# install.packages("USAboundaries")
# install.packages("USAboundariesData", repos = "http://packages.ropensci.org", type = "source")
# install.packages("leaflet")

library(tidyverse)
library(sf)
library(USAboundaries)
library(leaflet)

httpgd::hgd()
httpgd::hgd_browse()

# pulls in rds file (copy some stuff)
dat$latitude[1] # change this in other code
dat <- read_rds("C:/code/p3_AshLee/data/chipotle_nested.rds")

dat <- dat %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

select(dat, street_address, region, geometry)

cal <- USAboundaries::us_counties(states = 'California')

cal 
# map cali counties
ggplot() +
    geom_sf(data = cal) +
    geom_sf(data = filter(dat, region == 'CA'))

# map cali counties (for us)
ggplot() +
    geom_sf(data = cal) +
    geom_sf(data = cal, aes(fill = awater)) +
    geom_sf_text(data = cal, aes(label = name), color = "grey")

#had to remove double data
cal %>%
    select(-9) %>%
    mutate(sf_area = st_area(geometry),
    sf_middle = st_centroid(geometry)
    )

# blend/join together
chipolte_in_county <- st_join(dat, cal, join = st_within)


# create object w/ count by county
chipolte_in_county %>%
    as_tibble() %>%
    count(geoid, name)

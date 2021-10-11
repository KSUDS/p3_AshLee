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

dat <- read_csv("User/ashleyrabanales/Projects_ST/p3_AshLeeSafeGraph - Patterns and Core Data - Chipotle - July 2021/Core Places and Patterns Data/chipotle_core_poi_and_patterns.csv")

#Freehand code
dat %>%
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
    select(placekey, location_name, latitude, longitude, city , region, device_type) %>% 
    unnest(device_type) %>% 
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


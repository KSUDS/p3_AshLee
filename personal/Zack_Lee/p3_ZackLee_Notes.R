library(tidyverse)
install.packages("sf")
library(sf)
install.packages("jsonlite")
library(jsonlite)

json_to_tibble <- function(x){
    if(is.na(x))  return(x)
    parse_json(x) %>%
    enframe() %>%
    unnest(value)
}

dat <- read_csv("~/Downloads/Data_Science/p3_AshLee/data/SafeGraph - Patterns and Core Data - Chipotle - July 2021/SafeGraph - Patterns and Core Data - Chipotle - July 2021/Core Places and Patterns Data/chipotle_core_poi_and_patterns.csv")

dat %>%
    slice(5:10) %>%
    pull(popularity_by_day)

datNest <- dat %>%
    slice(1:50) %>% # for the example in class.
    mutate(
        open_hours = map(open_hours, ~json_to_tibble(.x)),
        visits_by_day = map(visits_by_day, ~bracket_to_tibble(.x)),
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

datNest <- datNest %>%
    select(placekey, latitude, longitude, street_address,
        city, region, postal_code,  
        raw_visit_counts:visitor_daytime_cbgs, parent_placekey, open_hours)




datNest <- dat %>%
    slice(1:25) %>% 
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

datNest %>% 
    slice(1:5) %>% 
    select(placekey, location_name, latitude, longitude, city , region, device_type) %>% 
    unnest(device_type) %>% 
    filter(!is.na(name)) %>% 
    pivot_wider(names_from = name, values_from = value)

datNest %>% 
    slice(1:5) %>% 
    select(placekey, location_name, latitude, longitude, city , region, popularity_by_day) %>% 
    unnest(popularity_by_day) %>% 
    filter(!is.na(name)) %>% 
    pivot_wider(names_from = name, values_from = value)




dat %>% slice(1:5) %>% select(placekey, location_name, latitude, longitude, city 
    , region, device_type)





    ######          p3 datasets         #######

    v1_base_b4_census <- read_csv("~/Downloads/Data_Science/p3_AshLee-1/data/v1_base_b4_census.csv")

    v1_base_with_census_metrics <- read_csv("~/Downloads/Data_Science/p3_AshLee-1/data/v1_base_with_census_metrics.csv")



#############       10/11 notes      ##############

#boundaries

install.packages("USAboundaries")
install.packages("USAboundariesData", repos = "http://packages.ropensci.org", type = "source")
install.packages("leaflet")

library(tidyverse)
library(sf)
library(USAboundaries)
library(leaflet)

dat <- read_rds("~/Downloads/Data_Science/p3_AshLee-1/data/chipotle_nested.rds")


dat <- dat %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

select(dat, street_address, region, geometry)

cal <- USAboundaries :: us_counties(states = "California")

ggplot()+
    geom_sf(data = cal)+
    geom_sf(data = filter(dat, region == "CA"))

ggplot()+
    geom_sf(data = cal, aes(fill = awater))+
    geom_sf_text(data = cal, aes(label = name), color = "white")

cal %>%
    select(-9) %>%
    mutate(sf_area = st_area(geometry),
    sf_middle = st_centroid(geometry))


chipotle_in_county <- st_join(dat, cal, join = st_within)


chipotle_in_county %>%
    count(geoid, name)


# 10/13 Notes


dat <- read_rds("chipotle_nested.rds") %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

cal <- us_counties(states = "California") %>%
    select(countyfp, countyns, name, aland, awater, state_abbr, geometry)

cal %>%
    mutate(
        states_area = aland + awater,
        sf_area = st_area(geometry)) %>%
    select(name, states_area, aland, sf_area, awater) %>%
    filter(name == "Santa Barbara")

ksu <- tibble(latitude = 34.037876, longitude = -84.58102) %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 3310)

# https://epsg.io/4326 units are degrees
calw <- cal %>%
    st_transform(3310) %>% # search https://spatialreference.org/ref/?search=california&srtext=Search. Units are in meters for buffer.
    filter(name != "San Francisco") %>%
    mutate(
        aland_acres = aland * 0.000247105,
        awater_acres = awater * 0.000247105,
        percent_water = 100 * (awater / aland),
        sf_area = st_area(geometry),
        sf_center = st_centroid(geometry),
        sf_length = st_length(geometry),
        sf_distance = st_distance(sf_center, ksu),
        sf_buffer = st_buffer(sf_center, 24140.2), # 24140.2 is 15 miles
        sf_intersects = st_intersects(., filter(., name == "Los Angeles"), sparse = FALSE)
        )


ggplot(data = calw) +
    geom_sf(aes(fill = sf_intersects)) + 
    geom_sf(aes(geometry = sf_buffer), fill = "white") +
    geom_sf(aes(geometry = sf_center), color = "darkgrey") +
    geom_sf_text(aes(label = name), color = "lightgrey") +
    geom_sf(data = filter(dat, region == "CA"), color = "black") + # our chipotle locations
    theme_bw() 


#join chart build process
store_in_county <- st_join(dat, cal, join = st_within) %>%
    select(placekey, city, region, geometry, countyfp, name)

store_in_county_count <- store_in_county %>%
    as_tibble() %>% 
    count(countyfp, name) %>%
    filter(!is.na(countyfp)) # drop the NA counts.


calw <- calw %>%
    left_join(store_in_county_count, fill = 0) %>%
    replace_na(list(n = 0)) 


calw %>%
    ggplot() +
    geom_sf(aes(fill = n)) + 
    scale_fill_continuous(trans = "sqrt") +
    geom_sf(data = filter(dat, region == "CA"), color = "white", shape = "x") +
    theme_bw() +
    theme(legend.position = "bottom") +
    labs(fill = "Number of Chipotle\nstores")



dat_wc <- st_join(dat, cal, join = st_within) 


#unnest and pivot
days_week_long <- dat_wc %>%
    filter(region == "CA") %>%
    as_tibble() %>% # notice this line to break the sf object rules.
    rename(name_county = name) %>%
    unnest(popularity_by_day) %>%
    select(placekey, city, region, contains("raw"),
        name, value, geometry, countyfp, name_county)

days_week <-  days_week_long %>%
    pivot_wider(names_from = name, values_from = value)


# average visits per day over the n stores by county.
visits_day_join <- days_week %>%
    group_by(countyfp, name_county) %>%
    summarise(
        count = n(),
        Monday = sum(Monday, na.rm = TRUE) / count,
        Tuesday = sum(Tuesday, na.rm = TRUE) / count,
        Wednesday = sum(Wednesday, na.rm = TRUE) / count,
        Thursday = sum(Thursday, na.rm = TRUE) / count,
        Friday = sum(Friday, na.rm = TRUE) / count,
        Saturday = sum(Saturday, na.rm = TRUE) / count,
        Sunday = sum(Sunday, na.rm = TRUE) / count,
    ) %>%
    ungroup()


calw <- calw %>%
    left_join(visits_day_join %>% select(-name_county)) %>%
    replace_na(list(Monday = 0, Tuesday = 0, Wednesday = 0,
      Thursday = 0, Friday = 0, Saturday = 0, Sunday = 0)) 

calw %>%
ggplot() +
    geom_sf(aes(fill = Saturday)) + 
    geom_sf(data = filter(dat, region == "CA"), color = "white", shape = "x") +
    theme_bw() +
    theme(legend.position = "bottom") +
    labs(fill = "Average store traffic", 
      title = "Saturday traffic for Chipotle")

calw %>%
ggplot() +
    geom_sf(aes(fill = Saturday)) + 
    geom_sf(aes(geometry = sf_center, size = count), color = "grey") +
    theme_bw() +
    scale_size_continuous(breaks = c(1, 5, 10, 25, 50, 75),
      trans = "sqrt", range = c(2, 15)) +
    labs(
        fill = "Average store traffic",
        size = "Number of stores",
        title = "Saturday traffic for Chipotle")


calw_4326 <- st_transform(calw, 4326) # will need in 4326 for leaflet 

bins <- c(0, 10, 20, 30, 50, 70, 90, 110)
pal <- colorBin("YlOrRd", domain = calw_4326$n)

m <- leaflet(calw_4326) %>%
    addPolygons(
        data = calw_4326,
        fillColor = ~pal(n),
        fillOpacity = .5,
        color = "darkgrey",
        weight = 2) %>%
    addCircleMarkers(
        data = filter(dat, region == "CA"),
        radius = 3,
        color = "grey") %>%
    addProviderTiles(providers$CartoDB.Positron)



    #10/18 Notes 
library(tidyverse)
library(sf)
library(USAboundaries)
library(leaflet)
install.packages("geofacet")
library(geofacet)


    dat <- read_rds("chipotle_nested.rds") %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

states <- us_states() %>%
    filter(!state_name %in% c("Alaska", "Hawaii", "Puerto Rico")) %>%
    st_transform(4326)

    dat_space <- dat %>%
    select(placekey, street_address, city, stusps = region, raw_visitor_counts) %>%
    filter(!is.na(raw_visitor_counts)) %>%
    group_by(stusps) %>%
    summarise(
        total_visitors = sum(raw_visitor_counts, na.rm = TRUE),
        per_store = mean(raw_visitor_counts, na.rm = TRUE),
        n_stores = n(),
        across(geometry, ~ sf::st_combine(.)),
    ) %>%
    rename(locations = geometry) %>%
    as_tibble()

states <- states %>%
    left_join(dat_space)

dat_time <- dat %>%
    as_tibble() %>%
    select(placekey, street_address, city, region, raw_visitor_counts, visits_by_day) %>%
    filter(!is.na(raw_visitor_counts)) %>%
    unnest(visits_by_day) %>%
    rename(dayMonth = name, dayCount = value) %>%
    group_by(region, dayMonth) %>%
    summarize(
        dayAverage = mean(dayCount),
        dayCount = sum(dayCount),
        stores = length(unique(placekey))) %>%
    mutate(
        stores_label = c(stores[1], rep(NA, length(stores) - 1))
    )

    dat_time %>%
    ggplot(aes(x = dayMonth, y = dayAverage)) +
    geom_point() +
    geom_smooth() +
    geom_text(
        aes(label = stores_label),
            x = -Inf, y = Inf,
            hjust = "left", vjust = "top") +
    facet_geo(~region, grid = "us_state_grid2", label = "name")

summary(dat_time)

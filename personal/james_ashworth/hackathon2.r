# Initiate libraries

library(tidyverse)
library(sf)
library(USAboundaries)
library(leaflet)
 
# function to help shift to tibble

json_to_tibble <- function(x) {
    if(is.na(x))  return(x)
    parse_json(x) %>%
    enframe() %>%
    unnest(value)
}

# Import the data and set up with initial geometry

dat <- read_csv("C:/code/p3_AshLee/hackathon_data/202107/core_poi-patterns.csv") %>%
    select(c('street_address','poi_cbg','latitude', 'longitude','raw_visit_counts','visitor_home_cbgs'))

# Flip to tibble (Only on visitor home cbgs, keeping other just in case)

datNest <- dat %>%
    mutate(
        visitor_cbg = map(visitor_home_cbgs, ~json_to_tibble(.x))
        )

# Verticle breakage

datNest2 <- datNest %>%
    select(street_address, poi_cbg, , latitude, longitude, visitor_cbg) %>%
    unnest(visitor_cbg) 

# Pull in census tables needed for calculations

def2 <- read_csv("C:/code/p3_AshLee/hackathon_data/safegraph_open_census_data_2019/data/cbg_b03.csv")
def4 <- read_csv("C:/code/p3_AshLee/hackathon_data/safegraph_open_census_data_2019/data/cbg_b01.csv")
def5 <- read_csv("C:/code/p3_AshLee/hackathon_data/safegraph_open_census_data_2019/data/cbg_b19.csv")

# Create other race column
def2 <- def2 %>%
    mutate(other = (B03002e5+B03002e7+B03002e8+B03002e9))

# create subset of just race counts
def3 <- def2 %>%
    select(census_block_group, B03002e1, B03002e3, B03002e4, B03002e6, B03002e12, other)

def4 = subset(def4, select = c(census_block_group,B01002e1))
def5 = subset(def5, select = c(census_block_group,B19013e1))

# merge race data with main data
datNest3 <- merge(datNest2, def3, by.x = c('name'), by.y = c('census_block_group'))
datNest3 <- merge(datNest3, def4, by.x = c('name'), by.y = c('census_block_group'))
datNest3 <- merge(datNest3, def5, by.x = c('name'), by.y = c('census_block_group'))

#pull down to one level head(datNest3)

datNest4 <- datNest3 %>%
        group_by(street_address, poi_cbg, latitude, longitude) %>%
        summarise(wam_age = weighted.mean(B01002e1,value,na.rm = TRUE)
                ,wam_income = weighted.mean(B19013e1,value,na.rm = TRUE)
                ,ttl_value = sum(value)
                ,ttl_population = sum(B03002e1)
                ,ttl_white = sum(B03002e3)
                ,ttl_black = sum(B03002e4)
                ,ttl_asian = sum(B03002e6)
                ,ttl_hispanic = sum(B03002e12)
                ,ttl_other = sum(other)
                ) %>%
        ungroup()

# Format the geometry
datNest4 <- datNest4 %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# Pull in initial boundries

ga <- us_counties(states = "Georgia") %>%
    select(countyfp, countyns, name, aland, awater, state_abbr, geometry)

# Calculations in GA file

gaw <- ga %>%
    mutate(
        aland_acres = aland * 0.000247105,
        awater_acres = awater * 0.000247105,
        percent_water = 100 * (awater / aland),
        sf_area = st_area(geometry),
        sf_center = st_centroid(geometry),
        sf_length = st_length(geometry)
        )

# Combine data with initial boundries

dat2 <- st_join(datNest4, ga, join = st_within) %>%
    select(street_address, countyfp, name, wam_age, wam_income, ttl_value, ttl_population, ttl_white, ttl_black, ttl_asian, ttl_hispanic, ttl_other)

# Summarize by county (wam will work...need to work on totals)

dat3 <- dat2 %>%
        group_by(countyfp, name) %>%
        summarise(wam_age = weighted.mean(wam_age,ttl_value,na.rm = TRUE)
                ,wam_income = weighted.mean(wam_income,ttl_value,na.rm = TRUE)
                ,ttl_value = sum(ttl_value)
                ,ttl_population = sum(ttl_population)
                ,ttl_white = sum(ttl_white)
                ,ttl_black = sum(ttl_black)
                ,ttl_asian = sum(ttl_asian)
                ,ttl_hispanic = sum(ttl_hispanic)
                ,ttl_other = sum(ttl_other)
                ) %>%
        ungroup()

# Write out safegraph data to get on with it.  Work on mapping later
dat3 <- dat3 %>% as_tibble %>% select(-geometry)
write.csv('C:/code/p3_AshLee/data/202107_formatted_county_data.csv', x = datNest)


#####################################################  End


# Set up tibble to link over
ga_count <- dat2 %>%
    select(countyfp, name, wam_age, wam_income, ttl_value, ttl_population, ttl_white, ttl_black, ttl_asian, ttl_hispanic, ttl_other) %>%
    as_tibble()

# Final combination
gaw <- gaw %>%
    left_join(ga_count, by = 'countyfp') %>%
    replace_na(list(n = 0)) 

write.csv('C:/code/p3_AshLee/data/garbage2chk.csv', x = dat2)

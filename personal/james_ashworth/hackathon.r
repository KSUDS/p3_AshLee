# importing libraries for file access
library(tidyverse)
library(sf)
library(jsonlite)
library(USAboundaries)
library(leaflet)
library(tmap)

json_to_tibble <- function(x) {
    if(is.na(x))  return(x)
    parse_json(x) %>%
    enframe() %>%
    unnest(value)
}

bracket_to_tibble <- function(x){
    value <- str_replace_all(x, "\\[|\\]", "") %>%
        str_split(",", simplify = TRUE) %>%
        as.numeric()

    name <- seq_len(length(value))

    tibble::tibble(name = name, value = value)
}

# Read in original file
dat <- read_csv("C:/code/p3_AshLee/hackathon_data/202107/core_poi-patterns.csv")

# Create version with filtered columns

dat2 <- dat %>%
    select(c('street_address','latitude', 'longitude','raw_visit_counts','visitor_home_cbgs'))

# Flip to tibble (Only on visitor home cbgs, keeping other just in case)

datNest <- dat2 %>%
    #slice(1:50) %>% # for the example in class.
    mutate(
        visitor_cbg = map(visitor_home_cbgs, ~json_to_tibble(.x))
        ) 

# Verticle breakage

datNest2 <- datNest %>%
    select(street_address, latitude, longitude, visitor_cbg) %>%
    unnest(visitor_cbg) 

# Write csv file for base.
write.csv('C:/code/p3_AshLee/data/2021_base_b4_census.csv', x = datNest2)

# Import definition files for lat/long
#def1 <- read_csv("C:/code/p3_AshLee/hackathon_data/safegraph_open_census_data_2019/metadata/cbg_geographic_data2.csv", col_types = "cddcc")

#dat_w_geo <- merge(datNest2, def1, by = xxxxxxxx)

# If need to read in material after blowing up pc again

def2 <- read_csv("C:/code/p3_AshLee/hackathon_data/safegraph_open_census_data_2019/data/cbg_b03.csv")
def4 <- read_csv("C:/code/p3_AshLee/hackathon_data/safegraph_open_census_data_2019/data/cbg_b01.csv")
def5 <- read_csv("C:/code/p3_AshLee/hackathon_data/safegraph_open_census_data_2019/data/cbg_b19.csv")

# CReate df with unique data
# made no change
#datNest2_stripped = subset(datNest2, select = -c(placekey, brands, city, visitor_cbg))

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

#pull down to one level

datNest4 <- datNest3 %>%
        group_by(street_address, latitude, longitude) %>%
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
     
    
# checking
filter(datNest4, street_address == "2009 W Hill Ave")

# Write data with census data metrics
write.csv('C:/code/p3_AshLee/data/2021_base_with_census_metrics.csv', x = datNest4)
#write.csv('C:/code/p3_AshLee/data/garbage.csv', x = datNest3)

# Code in case break in work
datNest4 <- read_csv("C:/code/p3_AshLee/data/v1_base_with_census_metrics.csv")


# Getting mapping data
datNest4 <- datNest4 %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

ga <- USAboundaries::us_counties(states = 'Georgia')


# Showing options middle and area
#ga %>%
#    select(-9) %>%
#    mutate(sf_area = st_area(geometry),
#    sf_middle = st_centroid(geometry)
#    )


# Join data
gas_in_ga2 <- st_join(datNest4, ga, join = st_within)
# remove duplicate state
gas_in_ga2 <- gas_in_ga2 %>% select(-20)

# Write the joined mapping data
write.csv('C:/code/p3_AshLee/data/2021_base_with_census_mapping_metrics2.csv', x = gas_in_ga)


# Graph?
ggplot() +
    geom_sf(data = ga) +
    geom_sf(data = gas_in_ga2, aes(fill = wam_income)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")
    #geom_sf_text(data = ga, aes(label = name), color = "grey")

tmap_mode("view")
tm_shape(gas_in_ga) +
    tm_fill(
        col = "wam_income",
        palette = 'Greens',
        style = 'cont',
        contrast = c(.1,1),
        title = 'Median Income By County',
        id = ,
        showNA = FALSE,
        alpha = 0.8,
        popup.vars = c("Total Visits" = 'value',
        'Median Income' = 'wam_income'),
        popup.format = list( value = list(format = "f", digits = 0),
        wam_income = list(format = "f", disgits = 0)
        )
    ) +
tm_borders(col = 'darkgray', lwd = 0.7) 

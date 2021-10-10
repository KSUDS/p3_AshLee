# importing libraries for file access
library(tidyverse)
library(sf)
library(jsonlite)

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
dat <- read_csv("C:/code/p3_AshLee/hackathon_data/201907/core_poi-patterns.csv")

# Create version with filtered columns

dat2 <- dat %>%
    select(c('placekey','brands','latitude','longitude','city','raw_visit_counts','raw_visitor_counts','visitor_home_cbgs','poi_cbg','visitor_home_aggregation'))

# Flip to tibble (Only on visitor home cbgs, keeping other just in case)

datNest <- dat2 %>%
    slice(1:50) %>% # for the example in class.
    mutate(
        visitor_cbg = map(visitor_home_cbgs, ~json_to_tibble(.x))
        ) 

# Verticle breakage

datNest2 <- datNest %>%
    select(placekey,brands,latitude,longitude,city,poi_cbg, visitor_cbg) %>%
    unnest(visitor_cbg)

# Write csv file for base.
write.csv('C:/code/p3_AshLee/data/v1_base_b4_census.csv', x = datNest2)

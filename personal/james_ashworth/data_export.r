# install.packages("sfarrow")
library(tidyverse)
library(USAboundaries)
library(sf)
library(sfarrow)

# usa <- USAboundaries::usa_boundaries() %>%
#    st_transform(4326)

usa_counties <- USAboundaries::us_counties() %>%
    select(-state_name) %>%
    st_transform(4326)

usa_cities <- USAboundaries::us_cities() %>%
    st_transform(4326)


# sfarrow::st_write_feather(usa, "personal/usa.feather")
# sfarrow::st_write_parquet(usa, "personal/usa.parquet")

sfarrow::st_write_feather(usa_counties, "C:/code/p3_AshLee/personal/james_ashworth/usa_counties.feather")
sfarrow::st_write_parquet(usa_counties, "C:/code/p3_AshLee/personal/james_ashworth/usa_counties.parquet")

sfarrow::st_write_feather(usa_cities, "C:/code/p3_AshLee/personal/james_ashworth/usa_cities.feather")
sfarrow::st_write_parquet(usa_cities, "C:/code/p3_AshLee/personal/james_ashworth/usa_cities.parquet")
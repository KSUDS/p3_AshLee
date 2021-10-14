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

ga <- USAboundaries::us_counties(states = 'Georgia')
gas_in_ga <- st_join(Nest, ga, join = st_within)
# remove duplicate state
gas_in_ga <- gas_in_ga %>% select(-24)

Nest <- read.csv("/Users/ashleyrabanales/Projects_ST/p3_AshLee/safeguard/201907/brand_info.csv")

guac <- read.csv("/Users/ashleyrabanales/Projects_ST/p3_AshLee/data/v1_base_with_census_metrics.csv")



#comparing the years to county in the census gov
#aggerating county
#median age by county year over year. 
#seeing the change from 19 / 20 

#create an age group
#seperate and combine those near to cobb county. 


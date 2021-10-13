
datNest4 <- read_csv("~/Downloads/Data_Science/p3_AshLee-1/data/v1_base_with_census_metrics.csv")


datNest4 <- datNest4 %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326)  # i omitted lat/long...needed?

ga <- USAboundaries::us_counties(states = 'Georgia')

# Join data
gas_in_ga <- st_join(datNest4, ga, join = st_within)
# remove duplicate state
gas_in_ga <- gas_in_ga %>% select(-24)

# Write the joined mapping data
write.csv('~/Downloads/Data_Science/p3_AshLee/data/v1_base_with_census_mapping_metrics.csv', x = gas_in_ga)

#Income, Total Pop
ggplot(data = gas_in_ga) +
    geom_sf(aes(color = wam_income, size = ttl_population)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt") 
    #geom_sf(data = filter(gas_in_ga, region == "GA"))
    #geom_sf_text(data = ga, aes(label = name), color = "#da0a0a")

#Income, white
ggplot()+
    geom_sf(data = ga) +
    geom_sf(data = gas_in_ga, aes(color = wam_income, size = ttl_white)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")
#Income, black
ggplot()+
    geom_sf(data = ga) +
    geom_sf(data = gas_in_ga, aes(color = wam_income, size = ttl_black)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")
#Income, asian
ggplot()+
    geom_sf(data = ga) +
    geom_sf(data = gas_in_ga, aes(color = wam_income, size = ttl_asian)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")

#Age difference thru state
ggplot(data = gas_in_ga) +
    geom_sf(aes(color = wam_age))


ggplot()+
    geom_sf(data = ga) +
    geom_sf(data = gas_in_ga, aes(color = wam_income, size = ttl_asian)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")

#trying to filter top counties
top_counties <- gas_in_ga %>%
    filter(namelsad == c("Gwinnett", "Fulton", "DeKalb"))


ggplot()+
    geom_sf(data = ga) +
    geom_sf(data = gas_in_ga, aes(color = wam_income, size = ttl_value)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")

#continue for 2021 data


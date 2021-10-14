
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


#2019

year19 <- read_csv("~/Downloads/Data_Science/p3_AshLee-1/data/201907_formatted_county_data.csv")
View(year19)

testest19 <- year19 %>%
    mutate(year = 2019)


Gwinnett1 <- testest19 %>%
    filter(name == "Gwinnett")

Fulton1 <- testest19 %>%
    filter(name == "Fulton")

Forsyth1 <- testest19 %>%
    filter(name == "Forsyth")

Cherokee1 <- testest19 %>%
    filter(name == "Cherokee")

Fayette1 <- testest19 %>%
    filter(name == "Fayette")

Cobb1 <- testest19 %>%
    filter(name == "Cobb")

Columbia1 <- testest19 %>%
    filter(name == "Columbia")

Oconee1 <- testest19 %>%
    filter(name == "Oconee")

Dawson1 <- testest19 %>%
    filter(name == "Dawson")

DeKalb1 <- testest19 %>%
    filter(name == "DeKalb")


counties19 <- rbind(Gwinnett1, Fulton1, Forsyth1, Cherokee1, Fayette1, Cobb1, Columbia1, Oconee1, Dawson1, DeKalb1)


#2021

testest <- read_csv("~/Downloads/Data_Science/p3_AshLee-1/data/202107_formatted_county_data.csv")
View(testest)

testest21 <- testest %>%
    mutate(year = 2021)

View(testest21)
#filtering top counties

Gwinnett <- testest21 %>%
    filter(name == "Gwinnett")

Fulton <- testest21 %>%
    filter(name == "Fulton")

Forsyth <- testest21 %>%
    filter(name == "Forsyth")

Cherokee <- testest21 %>%
    filter(name == "Cherokee")

Fayette <- testest21 %>%
    filter(name == "Fayette")

Cobb <- testest21 %>%
    filter(name == "Cobb")

Columbia <- testest21 %>%
    filter(name == "Columbia")

Oconee <- testest21 %>%
    filter(name == "Oconee")

Dawson <- testest21 %>%
    filter(name == "Dawson")

DeKalb <- testest21 %>%
    filter(name == "DeKalb")

counties21 <- rbind(Gwinnett, Fulton, Forsyth, Cherokee, Fayette, Cobb, Columbia, Oconee, Dawson, DeKalb)



#combining 2019 and 2021


 counties_total<- rbind(counties19,counties21)


ggplot(counties_total, aes(x=name, y=wam_income, size = 2,
color = year, c("2019","2021"))) + 
theme_bw() +
geom_point()+
labs(y = "Average Income", x = "County", title = "Change in Average Income by Highest Income Counties (2019 to 2021)")+
guides(size=FALSE)


library(tidyverse)
install.packages("jsonlite")
library(jsonlite)
library(ggplot2)
library(dbplyr)

#2019
year19 <- read.csv("/Users/ashleyrabanales/Projects_ST/p3_AshLee/data/201907_formatted_county_data.csv")

dat19 <- dat19 %>%
  mutate(year = "2019") %>%

  Gwinnett1 <- dat19 %>%
  filter(name == "Gwinnett")

Fulton1 <- dat19 %>%
  filter(name == "Fulton")

Forsyth1 <- dat19 %>%
  filter(name == "Forsyth")

Cherokee1 <- dat19 %>%
  filter(name == "Cherokee")

Fayette1 <- dat19 %>%
  filter(name == "Fayette")

Cobb1 <- dat19 %>%
  filter(name == "Cobb")

Columbia1 <- dat19 %>%
  filter(name == "Columbia")

Oconee1 <- dat19 %>%
  filter(name == "Oconee")

Dawson1 <- dat19 %>%
  filter(name == "Dawson")

DeKalb1 <- dat19 %>%
  filter(name == "DeKalb")


counties19 <- rbind(Gwinnett1, Fulton1, Forsyth1, Cherokee1, Fayette1, Cobb1, Columbia1, Oconee1, Dawson1, DeKalb1)


#2021

year21 <- read.csv("/Users/ashleyrabanales/Projects_ST/p3_AshLee/data/202107_formatted_county_data.csv")

dat21 <- year21 %>%
  mutate(year = "2021")

Gwinnett <- dat21 %>%
  filter(name == "Gwinnett")

Fulton <- dat21 %>%
  filter(name == "Fulton")

Forsyth <- dat21 %>%
  filter(name == "Forsyth")

Cherokee <- dat21 %>%
  filter(name == "Cherokee")

Fayette <- dat21 %>%
  filter(name == "Fayette")

Cobb <- dat21 %>%
  filter(name == "Cobb")

Columbia <- dat21 %>%
  filter(name == "Columbia")

Oconee <- dat21 %>%
  filter(name == "Oconee")

Dawson <- dat21 %>%
  filter(name == "Dawson")

DeKalb <- dat21 %>%
  filter(name == "DeKalb")

counties21 <- rbind(Gwinnett, Fulton, Forsyth, Cherokee, Fayette, Cobb, Columbia, Oconee, Dawson, DeKalb)

#interference with columns not matching - find the common col
common_cols <- intersect(colnames(counties19), colnames(counties21))

total_counties =rbind(subset(counties19, select = common_cols), 
                 subset(counties21, select = common_cols))



#comparing the years to county in the census gov
#aggerating county
#median age by county year over year. 
#seeing the change from 19 / 20 

#create an age group
#seperate and combine those near to cobb county. 


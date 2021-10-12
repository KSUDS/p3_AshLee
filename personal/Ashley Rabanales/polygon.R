    ###10/11/2021 - Polygons###

install.packages("USAboundaries")
install.packages("USAboundariesData", repos = "http://packages.ropensci.org", type = "source")
install.packages("leaflet")

library(tidyverse)
library(sf) #sf and stars packages operate on simple feature obj. 
library(USAboundaries)
library(leaflet)

httpgd::hgd()
httpgd::hgd_browse()


dat <- read_rds("/Users/ashleyrabanales/Projects_ST/p3_AshLee/data/chipotle_nested.rds")


m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=37.768, lat=-86.852, popup="The birthplace of R")
m

library(maps)
mapStates = map("state", fill = TRUE, plot = FALSE)
leaflet(data = gas_in_ga2$geometry) %>% addTiles() %>%
  addPolygons(fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)


#testing work with other file

install.packages("sf")
library(sf)

df <- sf::st_read("C:/code/p3_AshLee/hackathon_data/safegraph_open_census_data_2010_to_2019_geometry/cbg.geojson")

head(df)

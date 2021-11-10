# %%
import pandas as pd
import numpy as np
import geopandas as gpd

import folium
import rtree

from plotnine import *

# %%

county = gpd.read_parquet("C:/code/p3_AshLee/personal/james_ashworth/usa_counties.parquet")
cities = gpd.read_parquet("C:/code/p3_AshLee/personal/james_ashworth/usa_cities.parquet")

# %%
dat = pd.read_csv("C:/code/p3_AshLee/data/SafeGraph - Patterns and Core Data - Chipotle - July 2021/SafeGraph - Patterns and Core Data - Chipotle - July 2021/Core Places and Patterns Data/chipotle_core_poi_and_patterns.csv")

# %%
# relative position of folder
import os
os.getcwd() # get current working directory
# ../ means go down one working folder
# Right click relative path for files when reading

# %%
dat_cal = dat.query("region=='GA'")
dat_cal = gpd.GeoDataFrame(
    dat_cal.filter(["placekey", "latitude", "longitude", "median_dwell", "region"]),
        geometry=gpd.points_from_xy(dat_cal.longitude, dat_cal.latitude),
    crs='EPSG:4326')
# %%
from shapely.geometry import Point
ksu_df = pd.DataFrame({"lat":[34.037876],
        "long":[-84.58102]})
ksu = gpd.GeoDataFrame(ksu_df,
    geometry=gpd.points_from_xy(ksu_df.long, ksu_df.lat),
    crs='EPSG:4326')
# Had to convert to point function from dataframe
point = Point(
    ksu.geometry.to_crs(epsg = 3310).x,
    ksu.geometry.to_crs(epsg = 3310).y)
# %%
cal = county.query("stusps =='GA'")
# %%
# buffer for distance "w/in 10 miles example" have to convert to eqsg units
calw = (cal
    .assign(
        gp_area = lambda x: x.geometry.to_crs(epsg = 3310).area,
        gp_acres = lambda x: x.gp_area * 0.000247105,
        aland_acres = lambda x: x.aland * 0.000247105,
        percent_water = lambda x: x.awater / x.aland,
        gp_center = lambda x: x.geometry.to_crs(epsg = 3310).centroid,
        gp_length = lambda x: x.geometry.to_crs(epsg = 3310).length,
        gp_distance = lambda x: x.gp_center.distance(point),
        gp_buffer = lambda x: x.geometry.to_crs(epsg = 3310).buffer(24140.2)      
))
# %%
calw.gp_buffer.plot()
calw.gp_center.plot(color= "black")
# %%
base = calw.plot(color="white", edgecolor="darkgrey")
dat_cal.plot(ax=base, color="red", markersize=5)
# %%
# dat_cal is list of stores, calw is polygons county data
dat_join_s1 = gpd.sjoin(dat_cal, calw)

# Size is some type of method?
# reset index fixes the group by calc b/c it groups and creates index
dat_join_merge = (dat_join_s1
    .groupby("name")
    .agg(counts = ('percent_water', 'size'))
    .reset_index())

calw_join = (calw
    .merge(dat_join_merge, on="name", how="left")
    .fillna(value={"counts":0}))
# %%
base = calw_join.plot(
    edgecolor="darkgrey",
    column = "counts",
    legend = True)
dat_cal.plot(ax=base, color="red", markersize=4)

# %%
# javascript leafleft plot
base_inter = calw_join.explore(
    column = 'counts',
    style_kwds = { 
        "color":"darkgrey",
        "weight":.4}
)

theplot=dat_cal.explore(
    m=base_inter,
    # column='median_dwell',
    # cmap="Set1",
    marker_kwds={"radius":2, "fill":True},
    style_kwds={"fillOpacity":1})

# %%
# Use folium or add fetures
folium.TileLayer('Stamen Toner', control=True).add_to(base_inter)  # use folium to add alternative tiles
folium.LayerControl().add_to(base_inter)  

# %%
# Save File as interactive html

base_inter.save("C:/code/p3_AshLee/documents/ga_chipoltemap.html")
theplot.save("C:/code/p3_AshLee/documents/ga_chipoltemap2.html")

# %%

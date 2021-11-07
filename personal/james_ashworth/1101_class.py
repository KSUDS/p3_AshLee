# %%
# import sys
# !{sys.executable} -m pip install geopandas
# !{sys.executable} -m pip install pyarrow
# !{sys.executable} -mpip install pygeos
# !{sys.executable} -m pip install wheel
# !{sys.executable} -m pip install folium
# !{sys.executable} -m pip install matplotlib mapclassify

# %%
# Keep in case I need to uninstall all these versions in future
# !{sys.executable} -m pip install pipwin
# !{sys.executable} -m pip uninstall numpy
# !{sys.executable} -m pip uninstall pandas
# !{sys.executable} -m pip uninstall shapely
# !{sys.executable} -m pip uninstall gdal
# !{sys.executable} -m pip uninstall fiona
# !{sys.executable} -m pip uninstall pyproj
# !{sys.executable} -m pip uninstall six
# !{sys.executable} -m pip uninstall rtree
# !{sys.executable} -m pip uninstall geopandas
# %%
import pandas as pd
import numpy as np
import geopandas as gpd
import pyarrow as pyarrow
import rtree as rtree
# %%
census_url  = "https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip"
county_shp = gpd.read_file(census_url)

# county_shp = gpd.read_file("data/cb_2018_us_county_500k.zip")
# %%
county = gpd.read_parquet("C:/code/p3_AshLee/personal/james_ashworth/usa_counties.parquet")
cities = gpd.read_parquet("C:/code/p3_AshLee/personal/james_ashworth/usa_cities.parquet")
# %%
county = gpd.read_feather("C:/code/p3_AshLee/personal/james_ashworth/usa_counties.feather")
cities = gpd.read_feather("C:/code/p3_AshLee/personal/james_ashworth/usa_cities.feather")
# %%
# Get the chipolte safegraph data
dat = pd.read_csv("C:/code/p3_AshLee/data/SafeGraph - Patterns and Core Data - Chipotle - July 2021/SafeGraph - Patterns and Core Data - Chipotle - July 2021/Core Places and Patterns Data/chipotle_core_poi_and_patterns.csv")

dat_sp = gpd.GeoDataFrame(
    dat.filter(["placekey", "latitude", "longitude", "median_dwell"]), 
    geometry=gpd.points_from_xy(
        dat.longitude,
        dat.latitude))

# %%
# import graphing packages
import folium
import matplotlib
import mapclassify
from plotnine import *

# %%
# county = gpd.read_parquet("C:/code/p3_AshLee/personal/james_ashworth/usa_counties.parquet")
c48 = county.query('stusps not in ["HI", "AK", "PR"]')

base = c48.plot(color="white", edgecolor="darkgrey")
dat_sp.plot(ax=base, color="red", markersize=5)
# %%
dat_sp_lt100 = dat_sp.query("median_dwell < 100")
c48 = county.query('statusps not in ["HI", "AK", "PR"]')

# %%
# interactive map
base_inter = c48.explore(
    style_kwds = {"fill":False, 
        "color":"darkgrey",
        "weight":.4}
)

theplot=dat_sp.explore(
    m=base_inter,
    column='median_dwell',
    cmap="Set1",
    marker_kwds={"radius":2, "fill":True},
    style_kwds={"fillOpacity":1})

folium.TileLayer('Stamen Toner', control=True).add_to(base_inter)  # use folium to add alternative tiles
folium.LayerControl().add_to(base_inter)  

theplot
# %%
# Save as html
theplot.save("C:/code/p3_AshLee/personal/james_ashworth/map.html")
# %%
# Calculate land/water info
c48 = c48.assign(
    aland_calc = c48.geometry.to_crs(epsg = 3310).area
)
# %%
(ggplot(c48, aes(
    x="aland_calc/aland",
    fill="awater")) + 
geom_histogram())
# %%


# %%

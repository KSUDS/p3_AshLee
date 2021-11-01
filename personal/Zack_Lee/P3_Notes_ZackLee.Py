# %%
from os import access
import pandas as pd
import numpy as np
import altair as alt
from plotnine import theme
from plotnine import *
import sys
#%%
!{sys.executable} -m pip install geopandas
import geopandas as gpd

#%%
import sys
!{sys.executable} -mpip install pygeos

#%%
!{sys.executable} -m pip install wheel
!{sys.executable} -m pip install pipwin
!{sys.executable} -m pipwin install numpy
!{sys.executable} -m pipwin install pandas
!{sys.executable} -m pipwin install shapely
!{sys.executable} -m pipwin install gdal
!{sys.executable} -m pipwin install fiona
!{sys.executable} -m pipwin install pyproj
!{sys.executable} -m pipwin install six
!{sys.executable} -m pipwin install rtree
!{sys.executable} -m pipwin install geopandas
#%%
census_url  = "https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip"
#%%
county_shp = gpd.read_file(census_url)
#county_shp = gpd.read_file("data/cb_2018_us_county_500k.zip")

# %%
cobb_url = "https://github.com/johan/world.geo.json/raw/master/countries/USA/GA/Cobb.geo.json"
#%%
cobb_gj = gpd.read_file(cobb_url)
# cobb_gj = gpd.read_file("data/Cobb.geo.json")

#%%
import os
os.getcwd()
#%%
usa = gpd.read_parquet("data/usa.parquet")
county = gpd.read_parquet("data/usa_counties.parquet")
cities = gpd.read_parquet("data/usa_cities.parquet")
# %%

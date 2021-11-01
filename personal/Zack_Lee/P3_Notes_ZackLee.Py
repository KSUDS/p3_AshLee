# %%
from os import access
import pandas as pd
import numpy as np
import altair as alt
from plotnine import theme
from plotnine import *
import sys
!{sys.executable} -m pip install geopandas
import geopandas as gpd

#%%
import sys
!{sys.executable} -mpip install pygeos
#%%
census_url  = "https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip"
county_shp = gpd.read_file(census_url)
# county_shp = gpd.read_file("data/cb_2018_us_county_500k.zip")

# %%
cobb_url = "https://github.com/johan/world.geo.json/raw/master/countries/USA/GA/Cobb.geo.json"
cobb_gj = gpd.read_file(cobb_url)
# cobb_gj = gpd.read_file("data/Cobb.geo.json")

#%%
usa = gpd.read_parquet("data/usa.parquet")
county = gpd.read_parquet("data/usa_counties.parquet")
cities = gpd.read_parquet("data/usa_cities.parquet")
# %%

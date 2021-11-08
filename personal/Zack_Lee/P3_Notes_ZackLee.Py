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
sfarrow::st_write_feather(usa, "Downloads/Data_Science/p3_AshLee/data/usa.feather")
sfarrow::st_write_parquet(usa, "Downloads/Data_Science/p3_AshLee/data/usa.parquet")

sfarrow::st_write_feather(usa_counties, "Downloads/Data_Science/p3_AshLee/data/usa_counties.feather")
sfarrow::st_write_parquet(usa_counties, "Downloads/Data_Science/p3_AshLee/data/usa_counties.parquet")

sfarrow::st_write_feather(usa_cities, "Downloads/Data_Science/p3_AshLee/data/usa_cities.feather")
sfarrow::st_write_parquet(usa_cities, "Downloads/Data_Science/p3_AshLee/data/usa_cities.parquet")

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

import sys
!{sys.executable} -m pip install rtree
# %%
import folium
import rtree
from plotnine import *

# %%
url_loc = "https://github.com/KSUDS/p3_spatial/raw/main/SafeGraph%20-%20Patterns%20and%20Core%20Data%20-%20Chipotle%20-%20July%202021/Core%20Places%20and%20Patterns%20Data/chipotle_core_poi_and_patterns.csv"

dat = pd.read_csv(url_loc)

#%%
dat_cal = dat.query("region=='CA'")
dat_cal = gpd.GeoDataFrame(
    dat_cal.filter(["placekey", "latitude", "longitude", "median_dwell", "region"]),
        geometry=gpd.points_from_xy(dat_cal.longitude, dat_cal.latitude),
    crs='EPSG:4326')
# %%
county = gpd.read_parquet("personal/usa_counties.parquet")
#%%
from shapely.geometry import Point
ksu_df = pd.DataFrame({"lat":[34.037876],
        "long":[-84.58102]})
ksu = gpd.GeoDataFrame(ksu_df,
    geometry=gpd.points_from_xy(ksu_df.long, ksu_df.lat),
    crs='EPSG:4326')
point = Point(
    ksu.geometry.to_crs(epsg = 3310).x,
    ksu.geometry.to_crs(epsg = 3310).y)
# %%
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

#%%
calw.gp_buffer.plot()
calw.gp_center.plot(color= "black")

#%%
base = calw.plot(color="white", edgecolor="darkgrey")
dat_cal.plot(ax=base, color="red", markersize=5)

#%%
dat_join_s1 = gpd.sjoin(dat_cal, calw)

dat_join_merge = (dat_join_count
    .groupby("name")
    .agg(counts = ('percent_water', 'size'))
    .reset_index())

calw_join = (calw
    .merge(dat_join_merge, on="name", how="left")
    .fillna(value={"counts":0}))

#%%
base = calw_join.plot(
    edgecolor="darkgrey",
    column = "counts")
dat_cal.plot(ax=base, color="red", markersize=4)




#11/8 Notes

#%%

import requests 

your_location = "safegraph_functions.py"

url = "https://gist.githubusercontent.com/hathawayj/ddb41bb308aaf4e95cede353311fb4f5/raw/02184ca131c0b145931a028feba5c38f8c7e4b52/safegraph_functions.py"

response = requests.get(url)

print(response.headers.get('content-type'))

open(your_location, "wb").write(response.content)
# %%
#https://towardsdatascience.com/cleaning-and-extracting-json-from-pandas-dataframes-f0c15f93cb38
#https://packaging.python.org/tutorials/packaging-projects/

#%%

import pandas as pd
import json
import re

def jsonloads(x):
    if pd.isna(x):
        return None
    else:
        return json.loads(x)

def createlist(x):
    try:
        return x.str.strip('][').str.split(',')
    except:
        return None

def rangenumbers(x):
    if x.size == 1:
        return 0
    else:
        return range(1, x.size + 1)

def expand_json(var, dat):

    rowid = dat.placekey

    parsedat = dat[var]
    loadsdat = parsedat.apply(jsonloads)
    df_wide = pd.json_normalize(loadsdat)

    # clean up store names so they work as column names
    col_names = df_wide.columns
    col_names = [re.sub(r'[^\w\s]','', x) for x in col_names] # remove non-alphanumeric characters
    col_names = [str(col).lower().replace(" ", "_") for col in col_names] # replace spaces with dashes
    col_names_long = [var + '-' + col for col in col_names] 
    
    # rename the columns
    df_wide.columns = col_names_long # add variable name to column names

    df_wide = df_wide.assign(placekey = rowid)

    out = df_wide.loc[:, ["placekey"] + col_names_long]

    return out

def expand_list(var, dat):

    dat_expand = (dat
        .assign(lvar = createlist(dat[var]))
        .filter(["placekey", "lvar"])
        .explode("lvar")
        .reset_index(drop=True)
        .rename(columns={"lvar":var})
    )

    dat_label = (dat_expand
        .groupby('placekey')
        .transform(lambda x: rangenumbers(x))
        .reset_index(drop=True)
    )
    
    if var.find("hour") !=-1:
        dat_label.columns = ['hour']
    elif var.find("day") !=-1:
        dat_label.columns = ['day']
    else :
        dat_label.columns = ['sequence']

    out = pd.concat([dat_expand, dat_label], axis=1)
    out[var] = out[var].astype(float)
    return out
# %%

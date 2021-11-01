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

# %%
gas_in_ga = pd.read_csv('~/Downloads/Data_Science/p3_AshLee/data/v1_base_with_census_mapping_metrics.csv')

#%%
ga = pd.read_csv("/Users/Zack/Downloads/Data_Science/p3_AshLee-1/data/ga.csv")

#%%
ga <- USAboundaries::us_counties(states = 'Georgia')
# %%
#Income, white
ggplot()+
    geom_sf(data = ga) +
    geom_sf(data = gas_in_ga, aes(color = wam_income, size = ttl_white)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")

#%%
#Income, black
ggplot()+
    geom_sf(data = ga) +
    geom_sf(data = gas_in_ga, aes(color = wam_income, size = ttl_black)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")

#%%
#Income, asian
ggplot()+
    geom_sf(data = ga) +
    geom_sf(data = gas_in_ga, aes(color = wam_income, size = ttl_asian)) +
    scale_fill_viridis_c(option = "plasma", trans = "sqrt")



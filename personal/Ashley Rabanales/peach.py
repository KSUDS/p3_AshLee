import pandas as pd
import altair as alt
import numpy as py
import plotnine as plt
import matplotlib as mat
import geopandas as gpd

import sfarrow as sf

import sys
!{sys.executable} -m pip install geopandas

#ga <- USAboundaries::us_counties(states = 'Georgia')

#%% 
datNest4 = pd.read_csv("/Users/ashleyrabanales/Projects_ST/p3_AshLee/data/v1_base_with_census_metrics.csv")
print (datNest4) #tell if import correctly

ga = pd.read_csv("/Users/ashleyrabanales/Projects_ST/p3_AshLee/data/ga.csv")

#%%

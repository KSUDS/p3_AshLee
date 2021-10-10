# %%
from os import access
import pandas as pd
import numpy as np
import altair as alt
from plotnine import theme
from plotnine import *
# %%
# Read my dataset from exported R code
datNest2 = pd.read_csv("C:/code/p3_AshLee/data/v1_base_b4_census.csv")
datNest2 = datNest2.drop('visitor_cbg', 1)
datNest2['poi_cbg'] = datNest2.poi_cbg.astype(str)
datNest2['poi_cbg'] = datNest2['poi_cbg'].str[:12]
datNest2['poi_cbg'] = datNest2.poi_cbg.astype(object)

# %%
# bring in data from R vertical breakage

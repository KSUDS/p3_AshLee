# %%
from os import access
import pandas as pd
import numpy as np
import altair as alt
from plotnine import theme
from plotnine import *
# %%
# Read my dataset from exported R code
datNest3 = pd.read_csv("C:/code/p3_AshLee/data/v1_base_with_census_metrics.csv")
datNest3 = datNest3.drop('visitor_cbg', 1)
#datNest3['poi_cbg'] = datNest3.poi_cbg.astype(str)
#datNest3['poi_cbg'] = datNest3['poi_cbg'].str[:12]
#datNest3['poi_cbg'] = datNest3.poi_cbg.astype(object)

# %%
# bring in data from R vertical breakage

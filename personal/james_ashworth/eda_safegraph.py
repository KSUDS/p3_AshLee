# %%
import requests 

# %%
your_location = "c:/code/p3_AshLee/personal/james_ashworth/safegraph_functions.py"

url = "https://gist.githubusercontent.com/hathawayj/ddb41bb308aaf4e95cede353311fb4f5/raw/017a2512a4da5f0c25c69465327e938f43f41b9a/safegraph_functions.py"

response = requests.get(url)

print(response.headers.get('content-type'))

open(your_location, "wb").write(response.content)

# %%
import pandas as pd
import numpy as np
import geopandas as gpd
import folium
from plotnine import *
import safegraph_functions as sgf

# %%
url_loc = "https://github.com/KSUDS/p3_spatial/raw/main/SafeGraph%20-%20Patterns%20and%20Core%20Data%20-%20Chipotle%20-%20July%202021/Core%20Places%20and%20Patterns%20Data/chipotle_core_poi_and_patterns.csv"
dat = pd.read_csv(url_loc)

# %%
datl = dat.iloc[:10,:]

# %%
list_cols = ['visits_by_day', 'popularity_by_hour']
json_cols = ['open_hours','visitor_home_cbgs', 'visitor_country_of_orgin', 'bucketed_dwell_times', 'related_same_day_brand', 'related_same_month_brand', 'popularity_by_day', 'device_type', 'visitor_home_aggregation', 'visitor_daytime_cbgs']

dat_pbd = sgf.expand_json('popularity_by_day', datl)
dat_rsdb = sgf.expand_json('related_same_day_brand', datl)
dat_vbd = sgf.expand_list("visits_by_day", datl)
dat_pbh = sgf.expand_list("popularity_by_hour", datl)
# %%
# find top 3 related stores customers visit same day
# bar chart of top 10
dat_rsdb = sgf.expand_json('related_same_day_brand', dat)
# %%
graph = (dat_rsdb
.drop(columns = ['placekey'])
.sum()
.reset_index()
.rename(columns = {"index": "brand", 0: "visits"})
.sort_values(by = 'visits', ascending = False)
.assign(brand = lambda x: x.brand.str.replace
("related_same_day_brand-", ""))
.head(20))

# %%

brand_list = ['mcdonalds','walmart','starbucks','target','chickfila','shell_oil','dunkin','walgreens','taco_bell','simon_mall','7eleven','wendys','cvs','chevron','speedway','the_home_depot','subway','bp','quiktrip','wawa']
brand_cat = pd.Categorical(graph['brand'], categories = brand_list, ordered = True)
graph = graph.assign(brand_cat = brand_cat)

(ggplot(graph, aes( x = 'brand_cat', y = 'visits')) +
geom_col() +
coord_flip())
# %%
## box plot of hours in day
dat_pbh = sgf.expand_list("popularity_by_hour", dat)

# %%
(ggplot(dat_pbh, aes(x = 'hour.astype(str).str.zfill(2)', y= 'popularity_by_hour')) +
geom_boxplot() +
scale_y_continuous(limits = [0, 100]))
# %%

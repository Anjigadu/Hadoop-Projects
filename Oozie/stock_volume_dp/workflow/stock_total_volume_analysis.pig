## HDFS cli
   hdfs dfs -mkdir -p /user/cloudera/rawdata/hadoop/nasdaq_daily_prices
   hdfs dfs -put Downloads/NASDAQ_daily_prices_subset.csv /user/cloudera/rawdata/hadoop/nasdaq_daily_prices
   
## Read the column structure of data  
## [Content]
head Downloads/NASDAQ_daily_prices_subset.csv
# NASDAQ,DELL,1997-08-26,83.87,84.75,82.50,82.81,48736000,10.35

## Load the data storage directory
data = LOAD '/user/cloudera/rawdata/hadoop/nasdaq_daily_prices' USING PigStorage(',')
AS (exchange:chararray,stock_symbol:chararray,date:chararray,stock_price_open:float,stock_price_high:float,
stock_price_low:float,stock_price_close:float,stock_volume:int,stock_price_adj_close:float);

# In case the data from sqoop still contains the header, it is important to filter it out
filtered = FILTER data BY exchange != 'exchange';

# Project only the stock_symbol and the volumn
proj = FOREACH filtered GENERATE stock_symbol, stock_volume;

# Group the available records by the symbol
grouped = GROUP proj BY stock_symbol;

# Reduce the grouped data by summing the groups
agg = FOREACH grouped GENERATE group as symbol,sum(proj.stock_volume) AS total_vol;

# store records in the ouput location
STORE agg INTO '/user/cloudera/output/hadoop/pig/nasdaq_stock_volume';


# describe 
# explain 
# illustrate

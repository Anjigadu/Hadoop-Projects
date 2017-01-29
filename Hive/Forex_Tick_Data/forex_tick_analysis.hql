Scenario 1: Create a hive table from the all_price_data.txt dataset and run sample select queries.

(Objective) Read and/or create a table in the Hive metastore in a given schema
==================================================================================

hdfs dfs -mkdir -p /user/yuanhsin/rawdata/forex_tick/price_data
hdfs dfs -copyFromLocal price_data.txt /user/yuanhsin/rawdata/forex_tick/price_data

create external table raw_price_data(
datetimestamp string, 
open float, 
high float, 
low float, 
close float, 
volume int, 
symbol string)
row format delimited
fields terminated by '\;'      # ';' is reserved character
location '/user/yuanhsin/rawdata/forex_tick/price_data';

#sample queries
-- (1) return all datatimestamp, open, close and sym for all instances of XUAUSD traded.
select datetimestamp, open, close, symbol from raw_price_data where symbol = 'XUAUSD';
-- (2) return all trading instrument symbols in this dataset
select distinct symbol from raw_price_data;
-- (3) return the avg open and close prices for all trading pairs
select symbol, avg(open) avg_open, avg(close) avg_close from raw_price_data group by symbol;


Scenario 2: Using the raw_price_data, dataset create a wider table called price_data_wide that splits the datatimestamp column into year, month, day, hour, min integer columns. The new table must be stored in parquet format

(Objective) Read and/or create a table in the Hive metastore in a given schema
==============================================================================
-- Create hive table
create external table price_data_wide (year int, month int, day int, hour int, min int, open float, high float, low float, close float, volume int, symbol string)
stored as parquet
location '/user/yuanhsin/rawdata/forex_tick/price_data_wide';

-- Load data from raw_price_data
insert overwrite table price_data_wide
select cast(substr(datetimestamp, 0, 4) as int) year, cast(substr(datetimestamp, 5, 2) as int) month, 
cast(substr(datetimestamp, 7, 2) as int) day, cast(substr(datetimestamp, 10, 2) as int) hour, cast(substr(datetimestamp, 12, 2) as int) min 
, open, high, low, close, volume, symbol
from raw_price_data;

#sample query
-- return the monthly average volatility (differnce between high and low) for all dollar pairs in the year 2010 
select year, month, symbol, avg(high-low) avg_volatility 
from price_data_wide 
where year = 2010 and symbol like '%USD%' 
group by year, month, symbol; 


Scenario 3: Using the raw_price_data, dataset create a wider table called price_data_avro that splits the datatimestamp column into year, month, day, hour, min integer columns. 
The new table must be stored in avro format using a /user/yuanhsin/rawdata/forex_tick/schema/price_data.avsc schema file provide to you. 
All records in the raw_price_data must be successfully migrated to price_data_avro.

(Objective) Create a table in the Hive metastore using the Avro file format and an external schema file
==============================================================================
create external table price_data_avro 
(year int, month int, day int, hour int, min int, open float, high float, low float, close float, symbol string)
stored as avro
location '/user/yuanhsin/rawdata/forex_tick/price_data_avro'
tblproperties('avro.schema.url'='hdfs://quickstart.cloudera:8020/user/cloudera/rawdata/forex_tick/schema/price_data.avsc');

-- Load data from raw_price_data
insert overwrite table price_data_avro
select cast(substr(datetimestamp, 0, 4) as int) year, cast(substr(datetimestamp, 5, 2) as int) month, 
cast(substr(datetimestamp, 7, 2) as int) day, cast(substr(datetimestamp, 10, 2) as int) hour, cast(substr(datetimestamp, 12, 2) as int) min 
, open, high, low, close, symbol
from raw_price_data;

#sample query
-- return the monthly average volatility (differnce between high and low) for all dollar pairs in the year 2010 
select year, month, symbol, avg(high-low) avg_volatility from price_data_wide where year = 2010 and symbol like '%USD%' 
group by year, month, symbol;

Scenario 4: Assume that quant analysis do their analysis mainly on data in a year window. 
You are asked to partition all sales data by year and sym and load all dataset from the data_price_wide table into it. 
The new table should be named data_price_part. 
Also because analyst discovered that the volume column is always null, you have been asked to remove it from the new table.

(Objective): Improve query performance by creating partitioned tables in the Hive metastore
=====================================================================================================
create external table price_data_part (month int, day int, hour int, min int, open float, high float, low float, close float)
partitioned by (year int, symbol string)
stored as parquet
location '/user/cloudera/rawdata/hist_forex/price_data_part';

--load data from price_data_wide
--first enable dynamic partitioning
set hive.exec.dynamic.partition=enable;
--set the mode of dynamic partition to nonstrict
set hive.exec.dynamic.partition.mode=nonstrict;

insert overwrite table price_data_part 
partition (year, symbol)
select month, day, hour, min, open, high, low, close, year, symbol
from price_data_wide;



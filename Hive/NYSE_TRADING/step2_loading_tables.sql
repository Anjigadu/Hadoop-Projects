use nyse_db;

--load data into the managed table mng_daily_prices
load data inpath '/user/yuanhsin/rawdata/nasdaq_daily_price/NASDAQ_daily_prices_subset.csv' 
overwrite into table mng_daily_prices;

select * from mng_daily_prices limit 3;

exchange	stock_symbol	date	NULL	NULL	NULL	NULL	NULL	NULL
NASDAQ	DELL	1997-08-26	83.87	84.75	82.5	82.81	48736000	10.35
NASDAQ	DITC	2002-10-24	1.56	1.69	1.53	1.6	133600	1.6

select count(1) from mng_daily_prices;    -- how many records in the table?

load data local inpath '/home/cloudera/NASDAQ_daily_prices_subset.csv'  -- wget https://raw.githubusercontent.com/thebigjc/HackReduce/master/datasets/nasdaq/daily_prices/NASDAQ_daily_prices_subset.csv
into table mng_daily_prices;

-- List files and directories in alphabetic order
hdfs dfs -ls -R .

-- Put data into the folder
hdfs dfs -put NASDAQ_daily_prices_subset.csv /user/yuanhsin/rawdata/hive/ext_daily_prices

-- Insert data into Hive Table
insert into mng_daily_prices 
select * from ext_daily_prices where exchange_name != 'exchange';


--load data into the managed parquet table tbl_nasdaq_daily_prices into table mng_daily_prices;


insert overwrite table tbl_nasdaq_daily_prices_parquet
select * from tbl_nasdaq_daily_prices;

---- to load data into our new avro table from another previous table or the same column specification
insert overwrite table nasdaq_dividends_avro select * from nasdaq_dividends;

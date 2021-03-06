-- To log into Hive
-- >hive
-- >beeline
-- >history | grep beeline
-- beeline> !connect jdbc:hive2://localhost:10000/ cloudera cloudera
-- > beeline -u jdbc:hive2://localhost:10000/ -n cloudera
-- beeline> !quit

-- HDFS commands
--1. create directory
hdfs dfs -mkdir -p hive/warehouse
hdfs dfs -mkdir -p /user/hive/warehouse/nyse_db
hdfs dfs -mkdir -p /user/yuanhsin/rawdata/nasdaq_daily_price/
--2. search iteratively 
hdfs dfs -ls -R hive/warehouse/
--3. move data to directory
hdfs dfs -moveFromLocal NASDAQ_daily_prices_subset.csv  /user/yuanhsin/rawdata/nasdaq_daily_price/
--4.(optional)
hdfs dfs -put NASDAQ_daily_prices_subset.csv /user/yuanhsin/rawdata/hive/nasdaq_daily_prices

-- create a database for this project
-- when creating a database, hive creates a folder
create database nyse_db location '/user/yuanhsin/hive/warehouse/nyse_db';

show databases;
show schemas;

use nyse_db;
show tables;
drop database nyse_db;
desc table_name;

-- Hive Data Types
-- Create Hive Tables
-- 1. Managed: has table and data totally controlled by Hive
-- 2. External: has table but not data totally controlled by Hive
-- Queries

use nyse_db;
alter database nyse_db set dbproperties('author'='YuanHsin Huang');
alter database nyse_db set dbproperties('comment'='This is the sample comment.');

--List out the last n rows
hdfs dfs -tail /user/yuanhsin/rawdata/nasdaq_daily_price/NASDAQ_daily_prices_subset.csv

NASDAQ,DORM,1995-07-10,7.75,8.50,7.75,8.50,10800,4.25
NASDAQ,DGAS,2004-01-09,24.65,24.65,24.28,24.28,1100,18.17
NASDAQ,DEPO,2007-07-12,2.39,2.53,2.35,2.37,2195500,2.37
NASDAQ,DNDN,2007-10-10,7.95,8.50,7.94,8.42,9718200,8.42
NASDAQ,DGIT,2001-11-20,1.42,1.49,1.36,1.36,14000,13.60
NASDAQ,DECK,2009-08-20,69.09,71.43,69.09,69.76,379100,69.76
NASDAQ,DYNT,2003-12-12,1.69,1.73,1.46,1.65,43200,1.65
NASDAQ,DLTR,2007-11-05,36.03,36.17,34.06,34.06,2144900,34.06

--(1) Create a Managed Table for NASDAQ daily prices data set
create table mng_daily_prices(
	exchange_name string, stock_symbol string, date string, price_open float,price_high float, price_low float,
	price_close float, volume int, price_adj_close float)
ROW format delimited
fields terminated by ','
stored as textfile
location '/user/yuanhsin/hive/warehouse/nyse_db/mng_daily_prices';

show tables;

--(2) Create a Managed Table for data set with parquet data format
-- Parquet: columnar storage format 
create table mng_daily_prices_parquet (
	exchange_name string, stock_symbol string, date string, price_open float,price_high float, price_low float,
	price_close float, volume int, price_adj_close float)
stored as parquet;

--(3) Create an External Table for NASDAQ daily prices data set.
create external table ext_daily_prices(
	exchange_name string, stock_symbol string, date string, price_open float,price_high float, price_low float,
	price_close float, volume int, price_adj_close float)
row format delimited
fields terminated by ','
location '/user/yuanhsin/rawdata/hive/nasdaq_daily_prices';

--(4) Alternative method to create Table
create table zb_result
row format delimited
fields terminated by '\t'   -- DEFAULT '\001','\u001'
location '/user/yuanhsin/hive_result/stock_volume'
as select stock_symbol, sum(volume) total_stock_volume from mng_daily_prices group by stock_symbol order by stock_symbol;

-- Open text editor
nano stock_vol.hql

insert overwrite directory '/user/yuanhsin/hive_result/stock_volume_dir1'
row format delimited
fields terminated by '-'
select symbol, sum(volume) total_stock_volume from mng_daily_prices group by symbol order by symbol;

hive -f stock_vol.hql

-- Create an external table for NASDAQ dividends data set.
create external table ext_daily_prices_pq (
	exchange_name string,stock_symbol string, date string, price_open float, price_high float, price_low float,
	price_close float, volume int, price_adj_close float
)
stored as parquet
location '/user/yuanhsin/rawdata/parquet_result/daily_prices';

insert overwrite table ext_daily_prices_pq 
select * from ext_daily_prices where exchange_name != 'exchange';

create table ext_daily_prices_avro
stored as avro
as
select * from ext_daily_prices where exchange_name != 'exchange';

hdfs dfs -ls -R .
hdfs dfs -ls -R /user/yuanhsin/

-- To recreate the sql statement used to create a table
-- Also use the output to view the real details for building a hive table
show create table ext_daily_prices;

-- View details of avro table
show create table ext_daily_prices_avro;  

-- Alter table to add the schema location
alter table ext_daily_prices_avro
set location '/user/yuanhsin/rawdata/hive_result/ext_daily_prices_avro';

-- Alter a table to add a table property
alter table ext_daily_prices_avro
set tblproperties('author'='YuanHsin');

-- Alter table to rename the table
alter table ext_daily_prices_avro 
rename to avro_prices;



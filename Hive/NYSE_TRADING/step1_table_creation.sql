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
--2. search iteratively 
hdfs dfs -ls -R hive/warehouse/

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

--(1) Create a Managed Table for NASDAQ daily prices data set
create table mng_daily_prices(
	exchange_name string, stock_symbol string, date string, price_open float,price_high float, price_low float,
	price_close float, volume int, price_adj_close float)
ROW format delimited
fields terminated by ','
stored as TEXTFILE
location '/user/yuanhsin/hive/warehouse/nyse_db/mng_daily_prices';

show tables;

--(2) Create a Managed Table for data set with parquet data format
-- Parquet: columnar storage format 
create table mng_daily_prices_parquet (
	exchange_name string, stock_symbol string, date string, price_open float,price_high float, price_low float,
	price_close float, volume int, price_adj_close float)
stored as parquet;

--(3) Create an External Table for NASDAQ daily prices data set.

hdfs dfs -mkdir -p /user/yuanhsin/rawdata/hive/nasdaq_daily_prices
hdfs dfs -put NASDAQ_daily_prices_subset.csv /user/yuanhsin/rawdata/hive/nasdaq_daily_prices

create external table ext_daily_prices(
	exchange_name string, stock_symbol string, date string, price_open float,price_high float, price_low float,
	price_close float, volume int, price_adj_close float)
row format delimited
fields terminated by ','
location '/user/yuanhsin/rawdata/hive/nasdaq_daily_prices';





-- Create an external table for NASDAQ dividends data set.
create external table nasdaq_dividends (
	exchange_name string,stock_symbol string, date string, dividends float
)
row format delimited
fields terminated by ','
location '/user/cloudera/rawdata/hadoop_class/nasdaq_dividend';

-- create a managed avro table
create table nasdaq_dividends_avro (
	exchange_name string,stock_symbol string, date string, dividends float
)
stored as avro;

--alter table to add the schema location
alter table nasdaq_dividends_avro
set location '/user/cloudera/rawdata/hadoop_class/nasdaq_dividend_avro';

-- alter a table to add a table property
alter table nasdaq_dividends_avro set tblproperties('author'='michael enudi')

-- alter table to rename the table
alter table nasdaq_dividends_avro rename to avro_dividend	

-- to recreate the sql statement used to create a table
-- also use the output to view the real details for building a hive table
show create table nasdaq_daily_prices;

-- view details of our new avro table
show create table nasdaq_dividends_avro;
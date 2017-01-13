-- To log into Hive
>hive
>beeline
>history | grep beeline
beeline> !connect jdbc:hive2://localhost:10000/ cloudera cloudera
> beeline -u jdbc:hive2://localhost:10000/ -n cloudera
beeline> !quit

-- HDFS commands
1. create directory
hdfs dfs -mkdir -p hive/warehouse
hdfs dfs -mkdir -p /user/hive/warehouse/nyse_db
2. search iteratively 
hdfs dfs -ls -R hive/warehouse/

-- create a database for this project
create database nyse_db location '/user/yuanhsin/hive/warehouse/nyse_db';

show databases;
show schemas;

use nyse_db;
show tables;
drop database nyse_db;
desc table_name;

-- Hive Data Types
-- Create Hive Tables
   1. Managed 
   2. External
-- Queries

--Create a managed table for NASDAQ daily prices data set.
create table tbl_nasdaq_daily_prices (
	exchange_name string,stock_symbol string,date string,stock_price_open float,
	stock_price_high float,stock_price_low float,stock_price_close float,
	stock_volume int, stock_price_adj_close float
)
row format delimited
fields terminated by ',';

--Create a managed table for NASDAQ daily prices data set with parquet data format
create table tbl_nasdaq_daily_prices_parquet (
	exchange_name string,stock_symbol string,date string,stock_price_open float,
	stock_price_high float,stock_price_low float,stock_price_close float,
	stock_volume int, stock_price_adj_close float
)
stored as parquet;

--Create an external table for NASDAQ daily prices data set.
create external table nasdaq_daily_prices (
	exchange_name string,stock_symbol string,date string,stock_price_open float,
	stock_price_high float,stock_price_low float,stock_price_close float,
	stock_volume int, stock_price_adj_close float
)
row format delimited
fields terminated by ','
location '/user/cloudera/rawdata/hadoop_class/nasdaq_prices';


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

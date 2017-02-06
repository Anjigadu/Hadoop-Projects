-- create a database schema with an empty table

create database hadoop_sqoop;

use hadoop_sqoop;

create table nyse_dividends(exchange varchar(20), stock_symbol varchar(5), datestring varchar(20), value float(10,2));


create database yh_airline location '/user/cloudera/hive/warehouse/airline.db';

use yh_airline;

## 2007, 12     ,15         ,6        ,1646   ,1645      ,1827    ,1836       ,DL            ,49       ,N394DA  ,221             
## year month    dayofmonth dayofweek deptime crsdeptime arrtime  crsarrtime  uniquecarrier  flightnum tailnum   actualelapsedtime   
   
## ,231             ,202      ,-9         ,1        ,CVG    ,SLC   ,1449     ,6          ,13            ,0        ,          
##  crselapsedtime   airtime   arrdelay    depdelay  origin  dest   distance  taxiin      taxiout     cancelled    cancellationcode

## ,0               ,0            ,0             ,0         ,0             ,0
##  diverted         carrierdelay  weatherdelay   nasdelay   securitydelay  lateaircraftdelay

# create a managed table on airline timing
create table airline_timing 
(year smallint,month tinyint,dayofmonth tinyint,dayofweek tinyint,
 deptime smallint, crsdeptime smallint, arrtime smallint, crsarrtime smallint, 
 uniquecarrier string, flightnum string, tailnum string, actualelapsedtime smallint, 
 crselapsedtime smallint, airtime smallint, arrdelay smallint, depdelay smallint,  
 origin string, dest string, distance smallint, taxiin string, taxiout string,
 cancelled string, cancellationcode string, diverted string, carrierdelay smallint,
 weatherdelay smallint, nasdelay smallint, securitydelay smallint, lateaircraftdelay smallint)
row format delimited
fields terminated by ',';

# creates an external table table on airline timing
create external table ext_airline_timing 
(year smallint,month tinyint,dayofmonth tinyint,dayofweek tinyint,
 deptime smallint, crsdeptime smallint, arrtime smallint, crsarrtime smallint, 
 uniquecarrier string, flightnum string, tailnum string, actualelapsedtime smallint,
 crselapsedtime smallint, airtime smallint, arrdelay smallint, depdelay smallint, 
 origin string, dest string, distance smallint, taxiin string, taxiout string,
 cancelled string, cancellationcode string, diverted string, carrierdelay smallint,
 weatherdelay smallint, nasdelay smallint, securitydelay smallint, lateaircraftdelay smallint)
row format delimited
fields terminated by ','
location '/user/cloudera/output/hadoop/hive/airline_time_performance/refactored';

# creates an external avro table with partition (by year) on airline timing
create external table airline_timing_part
	(month tinyint,dayofmonth tinyint,dayofweek tinyint,
	deptime smallint, crsdeptime smallint, arrtime smallint, crsarrtime smallint, 
	uniquecarrier string, flightnum string, tailnum string, actualelapsedtime smallint,
	crselapsedtime smallint, airtime smallint, arrdelay smallint, depdelay smallint, 
	origin string, dest string, distance smallint, taxiin string, taxiout string,
	cancelled string, cancellationcode string, diverted string, carrierdelay smallint,
	weatherdelay smallint, nasdelay smallint, securitydelay smallint, lateaircraftdelay smallint)
partitioned by (year smallint)
stored as avro
location '/user/cloudera/output/hadoop/hive/airline_time_performance/flight_partitioned_avro';

## STATIC PARTITIONING
# manual add a partition to the partitoned table
alter table airline_timing_part 
add partition (year=2007);

# insert data into a table partition using static partitioning
insert overwrite table airline_timing_part 
partition(year=2007)
select 
	month,   
	dayofmonth,         
	dayofweek,          
	deptime,            
	crsdeptime ,        
	arrtime,            
	crsarrtime ,        
	uniquecarrier  ,,    
	flightnum ,         
	tailnum ,           
	actualelapsedtime  ,
	crselapsedtime  ,   
	airtime  ,          
	arrdelay ,          
	depdelay ,          
	origin  ,           
	dest ,              
	distance   ,        
	taxiin ,            
	taxiout   ,         
	cancelled ,         
	cancellationcode  , 
	diverted   ,        
	carrierdelay   ,    
	weatherdelay  ,     
	nasdelay ,          
	securitydelay    ,  

lateaircraftdelay 
from airline_timing 
where year = 2007;

# droping a partition
# not that since this is an external table ,
# the partition will be dropped from the hive metastore but will still be available on the distributed file system
# so there will have to a hdfs command to drop the file as well

alter table airline_timing_part drop partition(year=2007);
hdfs dfs -rm -R /user/cloudera/output/handson_train/pig/airline_time_performance/flight_partitioned_avro/year=2007

## DYNAMIC PARTITIONING
# enabling dynamic partition in a hive database
# setting the dynamic partition mode to non-strict

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;

# inserting data into a hive table using dynamic nonstrict partition mode
insert into airline_timing_part 
partition(year)
select 
	month,   
	dayofmonth,         
	dayofweek,          
	deptime,            
	crsdeptime ,        
	arrtime,            
	crsarrtime ,        
	uniquecarrier  ,    
	flightnum ,         
	tailnum ,           
	actualelapsedtime  ,
	crselapsedtime  ,   
	airtime  ,          
	arrdelay ,          
	depdelay ,          
	origin  ,           
	dest ,              
	distance   ,        
	taxiin ,            
	taxiout   ,         
	cancelled ,         
	cancellationcode  , 
	diverted   ,        
	carrierdelay   ,    
	weatherdelay  ,     
	nasdelay ,          
	securitydelay    ,  
	lateaircraftdelay,
	year
from airline_timing ;


# create external table for airports
# contents:
  hdfs dfs -tail /user/yuanhsin/rawdata/hadoop/airline_performance/airports/airports.csv
# "Z08","Ofu","Ofu Village","AS","USA",14.18435056,-169.6700236
# "Z09","Kasigluk","Kasigluk","AK","USA",60.87202194,-162.5248094

create external table airports (
    iata string, 
    airport string, 
    city string,
    state string, 
    country string, 
    geolat float, 
    geolong float
)
row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
with serdeproperties (
   "separatorChar" = ",",
   "quoteChar"     = "\"",
   "escapeChar"    = "\\"
)  
stored as textfile
location '/user/yuanhsin/rawdata/hadoop/airline_performance/airports';

# This SerDe works for most CSV data, but does not handle embedded newlines. 
# To use the SerDe, specify the fully qualified class name org.apache.hadoop.hive.serde2.OpenCSVSerde.  
# This SerDe treats all columns to be of type String. 
# Even if you create a table with non-string column types using this SerDe, the DESCRIBE TABLE output would show string column type. 
# The type information is retrieved from the SerDe. 
# To convert columns to the desired type in a table, you can create a view over the table that does the CAST to the desired type.



# create external table for carriers
create external table carriers (
    cdde varchar(4), 
    description varchar(30)
)
row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
with serdeproperties (
   "separatorChar" = ",",
   "quoteChar"     = "\"",
   "escapeChar"    = "\\"
)  
stored as textfile
location '/user/cloudera/rawdata/hadoop/airline_performance/carriers';

# create external table for plane information
# content:
# N999CA,Foreign Corporation,CANADAIR,07/09/2008,CL-600-2B19,Valid,Fixed Wing Multi-Engine,Turbo-Jet,1998
# N999DN,Corporation,MCDONNELL DOUGLAS CORPORATION,04/02/1992,MD-88,Valid,Fixed Wing Multi-Engine,Turbo-Jet,1992
create external table plane_info (
    tailnum varchar(4), 
    type varchar(30),
    manufacturer string,
    issue_date varchar(16), 
    model varchar(10), 
    status varchar(10),
    aircraft_type varchar(30),
    pyear int
)
row format serde 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
with serdeproperties (
   "separatorChar" = ",",
   "quoteChar"     = " \" ",
   "escapeChar"    = "\\"
)  
stored as textfile
location '/user/cloudera/rawdata/hadoop/airline_performance/plane_data';


# inserting into hdfs directory as text file with non-default delimiter
insert overwrite directory '/user/cloudera/output/handson_train/hive/insrt_directory'
row format delimited
fields terminated by '::::'
select * from airports limit  100;

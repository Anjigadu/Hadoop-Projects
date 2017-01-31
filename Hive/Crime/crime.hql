# Data Overview
(1) select method, count(1) from crime_incident group by method;

GUN	19435
KNIFE	10356
METHOD	1
OTHERS	276356

(2) select method, shift, count(1) numOccur from crime_incident group by method, shift with rollup;

NULL	NULL	306148
GUN	NULL	19435
GUN	DAY	3773
GUN	EVENING	7193
GUN	MIDNIGHT	8469
KNIFE	NULL	10356
KNIFE	DAY	2297
KNIFE	EVENING	4263
KNIFE	MIDNIGHT	3796
METHOD	NULL	1
METHOD	SHIFT	1
OTHERS	NULL	276356
OTHERS	DAY	112089
OTHERS	EVENING	118464
OTHERS	MIDNIGHT	45803

(3) select method, shift, count(1) numOccur from crime_incident group by method, shift with cube;
NULL	NULL	306148
NULL	DAY	118159
NULL	EVENING	129920
NULL	MIDNIGHT	58068
NULL	SHIFT	1
GUN	NULL	19435
GUN	DAY	3773
GUN	EVENING	7193
GUN	MIDNIGHT	8469
KNIFE	NULL	10356
KNIFE	DAY	2297
KNIFE	EVENING	4263
KNIFE	MIDNIGHT	3796
METHOD	NULL	1
METHOD	SHIFT	1
OTHERS	NULL	276356
OTHERS	DAY	112089
OTHERS	EVENING	118464
OTHERS	MIDNIGHT	45803

# Create db

create database crime;
use crime;

# Create external table
# Content:

head Downloads/Crime_Incidents_2008-2016october.csv

# -77.027635151699997,38.929197822600003,4767,08046657,2008-04-09T10:41:00.000Z,DAY,THEFT/OTHER,
# OTHERS,2016-10-08T07:18:35.000Z,3100 - 3199 BLOCK OF 11TH STREET NW,397604,140146,1,1A,THIRD,
# 302,2,,003000 1,003000,Precinct 39,2008-04-08T19:00:00.000Z,2008-04-09T09:30:00.000Z

create external table crime_incident (
X float,Y float, OBJECTID int, CCN int, REPORTDATETIME string, SHIFT  string, OFFENSE string, METHOD  string, 
LASTMODIFIEDDATE  string, BLOCKSITEADDRESS  string, BLOCKXCOORD float, BLOCKYCOORD float, WARD tinyint, 
ANC string, DISTRICT string, PSA smallint, NEIGHBORHOODCLUSTER tinyint, BUSINESSIMPROVEMENTDISTRICT  string,
BLOCK_GROUP string, CENSUS_TRACT string, VOTING_PRECINCT string, START_DATE  string, END_DATE string
)
row format delimited
fields terminated by ','
location '/user/cloudera/rawdata/hadoop/crime_incidents';

# Query 1.

select METHOD, count(1) frequency, count(1)/all.b ratio
from crime_accident
join
(select count(1) b from crime_accident) all
on 1 = 1
where ANC != 'ANC'
group by METHOD, all.b;

[Output]
GUN	19435	0.06348236800501718
KNIFE	10356	0.03382677659171381
OTHERS	276356	0.9026875890092374

# Query 2.

select count(1)  
from crime_incident 
where ANC != 'ANC' 
AND 
(month(reportdatetime) > month(end_date) OR dayofmonth(reportdatetime) > dayofmonth(end_date));

# TABLE PARTITIONING

create external table crime_incidents_part (
	X float,Y float, OBJECTID int, CCN int, SHIFT  string, OFFENSE string, METHOD  string, LASTMODIFIEDDATE  string, 
	BLOCKSITEADDRESS  string, BLOCKXCOORD float, BLOCKYCOORD float, WARD tinyint, ANC string, 
	DISTRICT string, PSA smallint, NEIGHBORHOODCLUSTER tinyint, BUSINESSIMPROVEMENTDISTRICT  string,
	BLOCK_GROUP string, CENSUS_TRACT string, VOTING_PRECINCT string, START_DATE  string, END_DATE string, 
	REPORTSEC tinyint, REPORTMIN tinyint, REPORTHOUR tinyint, REPORTDAY tinyint, REPORTMONTH tinyint
) 
PARTITIONED BY (REPORTYEAR smallInt)
row format delimited
fields terminated by ','
location '/user/cloudera/rawdata/hadoop/crime_incidents_part';

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;

insert overwrite table crime_incidents_part 
partition (reportYear)
select X,Y, OBJECTID, CCN, SHIFT , OFFENSE, METHOD , LASTMODIFIEDDATE , BLOCKSITEADDRESS , 
BLOCKXCOORD, BLOCKYCOORD, WARD, ANC, DISTRICT, PSA, NEIGHBORHOODCLUSTER, BUSINESSIMPROVEMENTDISTRICT,
BLOCK_GROUP, CENSUS_TRACT, VOTING_PRECINCT, START_DATE , END_DATE, second(REPORTDATETIME), minute(REPORTDATETIME), 
hour(REPORTDATETIME),dayofmonth(REPORTDATETIME), month(REPORTDATETIME), year(REPORTDATETIME) 
from crime_incident 
where ANC != 'ANC';

# Query 1.
# Oracle: nvl() / MYSQL: ifnull() / TSQL: isnull()
# Hive: 
(1) nvl(T value, T default_value)
    Returns default value if value is null else returns value (as of HIve 0.11).
(2) COALESCE(T v1, T v2, ...)
    Returns the first v that is not NULL, or NULL if all v's are NULL.

select year(reportdatetime) reportYear, ward, nvl(count(1),"total") frequency
from crime_incident
where ANC != 'ANC'
group by year(reportdatetime),ward with rollup;

NULL	NULL	306147
2008	NULL	34176
2008	1	4926
2008	2	6297
2008	3	1882
2008	4	3012
2008	5	4116
2008	6	5167
2008	7	4366
2008	8	4410
2009	NULL	31141
2009	NULL	1
2009	1	4433
2009	2	5790
2009	3	1956
2009	4	2870
2009	5	3691
2009	6	4473
2009	7	3747
2009	8	4180


# Query 2.

select year(reportdatetime) reportYear , ward, count(1) frequency 
from crime_incident 
where ANC != 'ANC'  
group by year(reportdatetime), ward with cube;





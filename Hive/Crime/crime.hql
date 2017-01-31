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
2010	NULL	31574
2010	NULL	2
2010	1	4357
2010	2	5550
2010	3	1929
2010	4	3091
2010	5	3970
2010	6	4221
2010	7	4003
2010	8	4451
2011	NULL	33543
2011	NULL	2
2011	1	4921
2011	2	6212
2011	3	1935
2011	4	2929
2011	5	4315
2011	6	4862
2011	7	4045
2011	8	4322
2012	NULL	35361
2012	NULL	4
2012	1	5007
2012	2	6570
2012	3	1788
2012	4	2991
2012	5	4784
2012	6	5513
2012	7	4340
2012	8	4364
2013	NULL	35914
2013	NULL	3
2013	1	5406
2013	2	5960
2013	3	1950
2013	4	3263
2013	5	4609
2013	6	5679
2013	7	4613
2013	8	4431
2014	NULL	38434
2014	NULL	1
2014	1	5407
2014	2	6780
2014	3	1832
2014	4	3808
2014	5	5397
2014	6	6024
2014	7	5102
2014	8	4083
2015	NULL	36561
2015	1	5149
2015	2	6641
2015	3	1882
2015	4	3475
2015	5	5110
2015	6	5956
2015	7	4385
2015	8	3963
2016	NULL	29443
2016	1	4157
2016	2	5772
2016	3	1479
2016	4	2644
2016	5	4006
2016	6	4947
2016	7	3374
2016	8	3064






# Query 2.

select year(reportdatetime) reportYear , ward, count(1) frequency 
from crime_incident 
where ANC != 'ANC'  
group by year(reportdatetime), ward with cube;


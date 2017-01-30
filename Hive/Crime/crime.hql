use project1;

create external table crime_incident (
	X float,Y float, OBJECTID int, CCN int, REPORTDATETIME string, SHIFT  string, OFFENSE string, METHOD  string, LASTMODIFIEDDATE  string, BLOCKSITEADDRESS  string, 
	BLOCKXCOORD float, BLOCKYCOORD float, WARD tinyint, ANC string, DISTRICT string, PSA smallint, NEIGHBORHOODCLUSTER tinyint, BUSINESSIMPROVEMENTDISTRICT  string,
	BLOCK_GROUP string, CENSUS_TRACT string, VOTING_PRECINCT string, START_DATE  string, END_DATE string
)
row format delimited
fields terminated by ','
location '/user/cloudera/rawdata/hadoop_class/crime_incidents';

-- 
select METHOD, count(1) frequency, count(1)/all.b ratio from crime_incident join (select count(1) b from crime_incident) all on 1 = 1 where ANC != 'ANC'  group by METHOD, all.b


-- 
select count(1)  from crime_incident where ANC != 'ANC' AND         (month(reportdatetime) > month(end_date) OR dayofmonth(reportdatetime) > dayofmonth(end_date))


--TABLE PARTITIONING
create external table crime_incidents_part (
	X float,Y float, OBJECTID int, CCN int, SHIFT  string, OFFENSE string, METHOD  string, LASTMODIFIEDDATE  string, BLOCKSITEADDRESS  string, 
	BLOCKXCOORD float, BLOCKYCOORD float, WARD tinyint, ANC string, DISTRICT string, PSA smallint, NEIGHBORHOODCLUSTER tinyint, BUSINESSIMPROVEMENTDISTRICT  string,
	BLOCK_GROUP string, CENSUS_TRACT string, VOTING_PRECINCT string, START_DATE  string, END_DATE string, REPORTSEC tinyint, REPORTMIN tinyint, REPORTHOUR tinyint, REPORTDAY tinyint, REPORTMONTH tinyint
) PARTITIONED BY (REPORTYEAR smallInt)
row format delimited
fields terminated by ','
location '/user/cloudera/rawdata/hadoop_class/crime_incidents_part';

set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;

insert overwrite table crime_incidents_part partition (reportYear)
select X,Y, OBJECTID, CCN, SHIFT , OFFENSE, METHOD , LASTMODIFIEDDATE , BLOCKSITEADDRESS , 
	BLOCKXCOORD, BLOCKYCOORD, WARD, ANC, DISTRICT, PSA, NEIGHBORHOODCLUSTER, BUSINESSIMPROVEMENTDISTRICT,
	BLOCK_GROUP, CENSUS_TRACT, VOTING_PRECINCT, START_DATE , END_DATE, second(REPORTDATETIME), minute(REPORTDATETIME), hour(REPORTDATETIME),
	dayofmonth(REPORTDATETIME), month(REPORTDATETIME), year(REPORTDATETIME) from crime_incident where ANC != 'ANC'



select year(reportdatetime) reportYear , ward, nvl(count(1), "total") frequency from crime_incident 
where ANC != 'ANC'  group by year(reportdatetime), ward with rollup


select year(reportdatetime) reportYear , ward, count(1) frequency from crime_incident 
where ANC != 'ANC'  group by year(reportdatetime), ward with cube

# simple multiple join

select flightnum, year, month, dayofmonth,dayofweek, c.description, f.tailnum, p.aircraft_type,
       concat(a.airport,' ',a.city,',',a.state,',',a.country) origin,
       concat(b.airport,' ',b.city,',',b.state,',',b.country) dest
from flights f
     join carriers c on f.uniquecarrier = c.cdde
     join airports a on f.origin = a.iata
     join airports b on f.dest = b.iata
     join plane_info p on p.tailnum = f.tailnum;

select count(1) from flights;
# 14462945


# explain select * from flights where year=2007;

# beeline -u jdbc:hive2://localhost:10000/yh_airline -n cloudera


create index _index on table t1() as '';
show index on table01;
drop index 




create index xx on table bb () as ''


# find the top 3 airports pairs with the shortest distance between them

add jar /home/cloudera/hadoop-projects/hadoop-training-projects-master/hive/airline_ontime_perf/HiveSwarm-1.0-SNAPSHOT.jar;



create temporary function gps_distance_from 
as 'com.livingsocial.hive.udf.gpsDistanceFrom';

# creating a hive view
create view airport_without_header as
select * from airports where iata <> 'iata';


-- query
select from_airport, to_airport, MIN(dist) minimum_distance from 
	(	select tbl1.airport from_airport, tbl2.airport to_airport, gps_distance_from(tbl1.geolat, tbl1.geolong, tbl2.geolat, tbl2.geolong ) dist from 
		(select  iata, airport, geolong, geolat from airport_without_header) tbl1
		full outer join 
		(select  iata, airport, geolong, geolat from airport_without_header) tbl2
	) v
group by from_airport, to_airport
order by 3 
limit 3;


-- some analytical query with the crime dataset
-- download the dataset from https://drive.google.com/open?id=0B0MdkEsxQHAQU1BIMVJuM2twVW8
-- download the scripts to prepare the hive database and tables from https://drive.google.com/drive/folders/0B0MdkEsxQHAQbjJtOHhMaEpuVUk?usp=sharing

select method, count(1) from crime_incident group by method

select method, shift, count(1) numOccur from crime_incident group by method, shift with rollup

select method, shift, count(1) numOccur from crime_incident group by method, shift with cube

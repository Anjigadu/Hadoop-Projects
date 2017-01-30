## Simple multiple join

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


## Find the top 3 airports pairs with the shortest distance between them

# https://github.com/livingsocial/HiveSwarm
# gps_distance_from(latitude1 double, longitude1 double, latitude2 double, longitude2 double [, Text options])
# Calculate the distance between two gps coordinates, return result in miles (default). 
# Options accepts a parameter of 'km' - returns result in km

add jar /home/cloudera/hadoop-projects/hadoop-training-projects-master/hive/airline_ontime_perf/HiveSwarm-1.0-SNAPSHOT.jar;

create temporary function gps_distance_from as 'com.livingsocial.hive.udf.gpsDistanceFrom';

# Creating a hive view to filter out header
create view airport_without_header as
select * from airports where iata <> 'iata';

## Query

select from_airport, to_airport, MIN(dist) minimum_distance
from
(
  select tbl1.airport from_airport, tbl2.airport to_airport, gps_distance_from(tbl1.geolat, tbl1.geolong, tbl2.geolat, tbl2.geolong ) dist   
  from
  (select iata, airport, geolong, geolat from airport_without_header) tbl1
   full outer join
  (select iata, airport, geolong, geolat from airport_without_header) tbl2			
) v
group by from_airport, to_airport
order by 3
limit 3;

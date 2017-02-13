data = LOAD '/user/aws/rawdata/pig/movielens/latest/movies/movies.csv'
       USING PigStorage(',')
       AS (movieid: chararray, title: chararray, genres: chararray);

headless = FILTER data BY movieid != 'movieid';

projData = FOREACH headless GENERATE genres;

splitted = FOREACH projData GENERATE STRSPLIT(genres,'\\|',0) AS t;

flattened = FOREACH splitted GENERATE FLATTEN(t) AS f;

grouped = GROUP flattened BY f;  

agged = FOREACH grouped GENERATE (chararray)group AS genre, COUNT(flattened) AS num;


hdfs dfs -moveFromLocal home/cloudera/piggybank-0.15.0.jar  rawdata/hadoop_train/movielens/
#  step 1. Registering the jar file 
REGISTER /home/cloudera/piggybank-0.15.0.jar
#  step 2. Defining Alias
DEFINE myCSVLoader org.apache.pig.piggybank.storage.CSVLoader();
#  step 3. Use UDF
# (1)
data = LOAD '/user/cloudera/rawdata/hadoop_train/movielens/latest/movies/movies.csv'
       USING myCSVLoader()
       AS (movieid:chararray,title:chararray, genres:chararray);
# (2)
data = LOAD '/user/cloudera/rawdata/hadoop_train/movielens/latest/movies/movies.csv' 
       using org.apache.pig.piggybank.storage.CSVLoader() 
       AS (movieid:chararray,title:chararray,genres:chararray);
##------------------------------------------------------------------------------------------------------------------------##
# Execute
dump agged;
[Result]
(War,56)
(IMAX,1)
(Crime,2100)
(Drama,10560)
(Action,5095)
(Comedy,9254)
(Horror,2181)
(Sci-Fi,254)
(genres,1)
(Fantasy,205)
(Musical,97)
(Mystery,238)
(Romance,230)
(Western,346)
(Children,799)
(Thriller,530)
(Adventure,1773)
(Animation,971)
(Film-Noir,38)
(Documentary,3284)
((no genres listed),2098)
DESCRIBE agged;
# Sort 
sorted  = ORDER agged BY genre;
# Store data into different file format
#(1) /user/cloudera/output/hadoop_train/movielens/genre_count/text -> PigStorage(',')
STORE sorted into '/user/cloudera/output/hadoop_train/movielens/genre_count/text' using PigStorage(',');
#(2) /user/cloudera/output/hadoop_train/movielens/genre_count/avro -> AvroStorage()
STORE sorted into '/user/cloudera/output/hadoop_train/movielens/genre_count/avro' using AvroStorage();
#(3) /user/cloudera/output/hadoop_train/movielens/genre_count/json -> JsonStorage()
STORE sorted into '/user/cloudera/output/hadoop_train/movielens/genre_count/json' using JsonStorage();
ls /user/cloudera/output/hadoop_train/movielens/genre_count/text/
hdfs://quickstart.cloudera:8020/user/cloudera/output/hadoop_train/movielens/genre_count/text/_SUCCESS<r 1>	0
hdfs://quickstart.cloudera:8020/user/cloudera/output/hadoop_train/movielens/genre_count/text/part-r-00000<r 1>	261
# Analyze the sorted process
EXPLAIN sorted;     # logical plan / physical plan / mapreduce plan

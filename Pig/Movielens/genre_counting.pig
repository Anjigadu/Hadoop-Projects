hdfs dfs -get /user/aws/rawdata/pig/movielens/latest/movies/movies.csv
head movies.csv
head -n -40 movies.csv
wc -l movies.csv

cat genre_counting.pig

## Objective: find all genres and the number of movies

## Sample Data:
- movieId,title,genres
- 1,Toy Story (1995),Adventure|Animation|Children|Comedy|Fantasy 
- 2,Jumanji (1995),Adventure|Children|Fantasy
- 3,Grumpier Old Men (1995),Comedy|Romance
- 4,"Waiting, to Exhale (1995)",Comedy|Drama|Romance
- 5,Father of the Bride Part II (1995),Comedy

## Code:

#  step 1. load data from source
data = LOAD '/user/cloudera/rawdata/hadoop_train/movielens/latest/movies/movies.csv'
       USING PigStorage(',')
       AS (movieid: chararray, title: chararray, genres: chararray);

# inspect the structure
describe data;
=> data: {movieid: chararray,title: chararray,genres: chararray}

# request an example
illustrate data;

 data     | movieid:chararray    | title:chararray         | genres:chararray     | 
------------------------------------------------------------------------------------
|          | 3803                 | Greaser's Palace (1972) | Comedy|Drama|Western | 

#  step 2. remove the header
headless = FILTER data BY movieid != 'movieid';

#  step 3. project one fields genres
projData = FOREACH headless GENERATE genres;

#  step 4. split the genres by a pipe (Adventure,Children,Fantasy)
#  STRSPLIT: Splits a string around matches of a given regular expression
#  STRSPLIT(string, regex, limit)
#  http://pig.apache.org/docs/r0.9.1/func.html#strsplit
splitted = FOREACH projData GENERATE STRSPLIT(genres,'\\|',0) AS t;

#  step 5. flatten the tuple of splitted genres  (Adventure) (Children) (Fantasy)
flattened = FOREACH splitted GENERATE FLATTEN(t) AS f;

# edit filename starting at line 1
vi pig_1485214765234.log     
rm pig_1485214765234.log


#  step 6. group the flattened typle by name
grouped = GROUP flattened BY f;

grouped = GROUP flattened BY (chararray)f;   ## after using myCSVLoader

#  step 7. get the count on each group
agged = FOREACH grouped GENERATE (chararray)group AS genre, COUNT(flattened) AS num;

#  step 8. debugging
ls
cat pig_1485214765234.log
rm pig_1485214765234.log
hdfs dfs -ls -R rawdata rawdata
hdfs dfs -tail rawdata/hadoop_train/movielens/latest/movies/movies.csv
##-----------------------------------------------------------------------------------------------------------------------##
## User-Defined Function
   1. datafu
   2. piggybank : load/storage function
      # https://mvnrepository.com/artifact/org.apache.pig/piggybank/0.15.0
      # a Java repository for accessing UDF written by other users
   3. elephantbird: json

# CSV Loader
# https://pig.apache.org/docs/r0.9.1/api/org/apache/pig/piggybank/storage/CSVLoader.html
pwd
ls home/cloudera/
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

















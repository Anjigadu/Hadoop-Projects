hdfs dfs -get /user/cloudera/rawdata/hadoop_train/movielens/latest/movies/movies.csv
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

#  step 7. get the count on each group
agged = FOREACH grouped GENERATE (chararray)group AS genre, count(group) AS num;

#  step 8. debugging
ls
cat pig_1485214765234.log
rm pig_1485214765234.log
hdfs dfs -ls -R rawdata rawdata
hdfs dfs -tail rawdata/hadoop_train/movielens/latest/movies/movies.csv



register /mnt/home/okmich20/hadoop-training-projects/pig/movielens/piggybank-0.15.0.jar
DEFINE myCSVLoader org.apache.pig.piggybank.storage.CSVLoader();
data = LOAD '/user/cloudera/rawdata/hadoop_train/movielens/latest/movies/movies.csv'
       USING myCSVLoader()
       AS (movieid: chararray, title: chararray, genres: chararry);headless = FILTER data BY movieId != 'movieId';
agged = FOREACH grouped GENERATE (chararray)group as genre, COUNT(flattend) as num;
sorted  = ORDER agged BY genre;
STORE sorted into '/user/okmich20/output/handson_train/movielens/genre_count/text'  USING  PigStorage(',');
STORE sorted into '/user/okmich20/output/handson_train/movielens/genre_count/avro'  using  AvroStorage();
STORE sorted into '/user/okmich20/output/handson_train/movielens/genre_count/json'  using  JsonStorage();

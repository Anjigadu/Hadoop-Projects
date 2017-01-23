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
       USING myCSVLoader()
       AS (movieid: chararray, title: chararray, genres: chararry);
#  step 2.  



- remove the header
- project one fields genres
- split the genres by a pipe   - (Adventure,Children,Fantasy)
- flatten the tuple of splitted genres: (Adventure) (Children) (Fantasy)
- group the flattened tuple by name
- get the count on each group

register /mnt/home/okmich20/hadoop-training-projects/pig/movielens/piggybank-0.15.0.jar

DEFINE myCSVLoader org.apache.pig.piggybank.storage.CSVLoader();

headless = FILTER data BY movieId != 'movieId';
flattend = FOREACH headless GENERATE FLATTEN(STRSPLIT(genres, '\\|', 0)) as f;
grouped = GROUP flattend BY f;
agged = FOREACH grouped GENERATE (chararray)group as genre, COUNT(flattend) as num;
sorted  = ORDER agged BY genre;

STORE sorted into '/user/okmich20/output/handson_train/movielens/genre_count/text'  USING  PigStorage(',');
STORE sorted into '/user/okmich20/output/handson_train/movielens/genre_count/avro'  using  AvroStorage();
STORE sorted into '/user/okmich20/output/handson_train/movielens/genre_count/json'  using  JsonStorage();

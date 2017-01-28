### Create db
create database yelp;

### Change to specified db
use yelp;

### Used UDF
add jar /usr/lib/hive-hcatalog/share/hcatalog/hive-hcatalog-core.jar;

### Create Table
##(1) Create external table for Review
# hdfs dfs -tail /user/cloudera/project/yelp/review/yelp_academic_dataset_review.json
# Content:
# {"votes": {"funny": 0, "useful": 0, "cool": 0}, 
#  "user_id": "maAimqEE4G483rtifPKlYg", 
#  "review_id": "DDmiTM_jMhshjYkXk5Sshg", 
#  "stars": 1, 
#  "date": "2016-07-11", 
#  "text": "2 pm Monday afternoon. Out of sour cream (ridiculous). Waited 15 minutes for what I thought were going to be freshly cooked fajita vegetables only to be told they were out of vegetables! I will never go to any franchise of this chain again!", 
#  "type": "review", 
#  "business_id": "DH2Ujt_hwcMBIz8VvCb0Lg"}

CREATE EXTERNAL TABLE review (
	votes map<string, string>,
	user_id string,
	review_id string,
	stars tinyint,
	date string,
	text string,
	type string,
	business_id string
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'  # https://hive.apache.org/javadocs/r0.13.1/api/hcatalog/core/org/apache/hive/hcatalog/data/JsonSerDe.htmlSTORED AS textfile
STORED AS textfile
LOCATION '/user/cloudera/project/yelp/review';

##(2) Create external table for Checkin
# hdfs dfs -tail /user/cloudera/project/yelp/checkin/yelp_academic_dataset_checkin.json
# Content:
# {"checkin_info": {"2-3": 1, "0-2": 1, "5-2": 1, "1-0": 1, "7-1": 1, "7-6": 2, 
#                   "11-5": 1, "23-0": 2, "13-4": 1, "14-4": 1, "1-3": 1, "14-3": 1}, 
#  "type": "checkin", 
#  "business_id": "HuLzZUBkHEcHk6ETDJIVhQ"}

CREATE EXTERNAL TABLE checkin (
	checkin_info map<string, string>,
	type string,
	business_id string
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS textfile
LOCATION '/user/cloudera/project/yelp/checkin';

##(3) Create external table for Tip
# hdfs dfs -tail /user/cloudera/project/yelp/tip/yelp_academic_dataset_tip.json
# Content:
# {"user_id": "f2yrVy2iVooO1_pMCr9XNg", 
# "text": "Sixth night of Mexican in Phoenix and this place is probably the best!", 
# "business_id": "g0vvhkZWZKlwF8BUeSPaTA", 
# "likes": 0, 
# "date": "2010-06-19", 
# "type": "tip"}

CREATE EXTERNAL TABLE tip (
	user_id string,
	text string,
	business_id string,
	likes tinyint,
	date string,
	type string
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS textfile
LOCATION '/user/cloudera/project/yelp/tips';

##(4) Create external table for User
# hdfs dfs -tail /user/cloudera/project/yelp/user1/yelp_academic_dataset_user.json
# Content:
#{"yelping_since": "2016-04", 
# "votes": {"funny": 1, "useful": 0, "cool": 0}, 
# "review_count": 1, 
# "name": "Amelia", 
# "user_id": "DL0S4Ro4KY77akGPbEkrug", 
# "friends": [], 
# "fans": 0, 
# "average_stars": 5.0, 
# "type": "user",
# "compliments": {}, 
# "elite": []}
 
CREATE EXTERNAL TABLE user1 (
	yelping_since string,
	votes map<string, string>,
	review_count int,
	name string,
	user_id string,
	friends array<string>,
	fans int,
	average_stars float,
	type string,
	compliments map<string, string>,
	elite array<string>
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS textfile
LOCATION '/user/cloudera/project/yelp/user1';

##(5) Create external table for Photo

# Content:

CREATE EXTERNAL TABLE photo (
	photo_id string,
	business_id string,
	caption string,
	label string
)
ROW FORMAT DELIMITED
LOCATION '/user/cloudera/project/yelp/photo';


##(6) Create external table for Business
# Content:
#{"business_id": "DH2Ujt_hwcMBIz8VvCb0Lg", 
# "full_address": "Charlotte Douglas International Airport Terminal E\n5501 Josh Birmingham Parkway\nCharlotte, NC 28208", 
# "hours": {},     #### no ####
# "open": true, 
# "categories": ["Mexican", "Restaurants"], 
# "city": "Charlotte", 
# "review_count": 57, 
# "name": "Salsarita's Express", 
# "neighborhoods": [], 
# "longitude": -80.9402901706085, 
# "state": "NC", 
# "stars": 2.5, 
# "latitude": 35.2242230735555, 
# "attributes": {}, 
# "type": "business"  #### no ####
# }
 
CREATE EXTERNAL TABLE business(
       business_id string,
       full_address string,
       open boolean,
       categories array<string>,
       city string,
       review_count int,
       name string,
       neighborhoods array<string>,
       longitude float,
       state string,
       stars float,
       latitude float
)
STORED AS parquet        
LOCATION '/user/cloudera/project/yelp/transformed/business';

# Parquet is a columnar storage format that supports nested data.


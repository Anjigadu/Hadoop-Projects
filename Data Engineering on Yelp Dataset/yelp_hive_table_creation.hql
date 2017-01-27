### Create db
create database yelp;

### Change to specified db
use yelp;

### Used UDF
add jar /usr/lib/hive-hcatalog/share/hcatalog/hive-hcatalog-core.jar;

### Create Table
##(1) Create external table for Review
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
STORED AS textfile
LOCATION '/user/cloudera/project/yelp/;



ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION '/user/cloudera/hackerday/yelp/review';

##(2) Create external table for Tip
# Content:

CREATE EXTERNAL TABLE tip (
	user_id string,
	text string,
	likes tinyint,
	date string,
	type string
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION '/user/cloudera/hackerday/yelp/tips';

##(3) Create external table for Checkin
# Content:

CREATE EXTERNAL TABLE checkin (
	checkin_info map<string, string>,
	type string,
	business_id string
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
STORED AS TEXTFILE
LOCATION '/user/cloudera/hackerday/yelp/checkins';

##(4) Create external table for User
# Content:CREATE EXTERNAL TABLE user (
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
STORED AS TEXTFILE
LOCATION '/user/cloudera/hackerday/yelp/users';


##(5) Create external table for Photo
# Content:
CREATE EXTERNAL TABLE photo (
	photo_id string,
	business_id string,
	caption string,
	label string
)
ROW FORMAT DELIMITED
LOCATION '/user/cloudera/hackerday/yelp/processed/photos';


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


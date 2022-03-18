-- This data was adapted and modified from: www.kaggle.com/yelp-dataset
LOAD DATA LOCAL INFILE '/usr/local/mysql/bin/user_data.csv' INTO TABLE user
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/usr/local/mysql/bin/business_data.csv' INTO TABLE business
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/usr/local/mysql/bin/review_data.csv' INTO TABLE review
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/usr/local/mysql/bin/tips_data.csv' INTO TABLE tip
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

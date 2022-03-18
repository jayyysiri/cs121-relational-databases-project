-- Drop tables in an order that respects ref integrity.
DROP TABLE IF EXISTS tip;
DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS business;
DROP TABLE IF EXISTS user;

-- Create the user table
CREATE TABLE user (
    user_id CHAR(22),
    user_name VARCHAR(50) NOT NULL,
    review_count SMALLINT NOT NULL DEFAULT 0,
    yelping_since DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    useful_count INT NOT NULL DEFAULT 0,
    friend_count SMALLINT NOT NULL DEFAULT 0,
    cute_count SMALLINT NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id)
);

-- Create the business table
CREATE TABLE business (
    business_id CHAR(22),
    business_name VARCHAR(200) NOT NULL,
    biz_address VARCHAR(200) NOT NULL,
    biz_city VARCHAR(100) NOT NULL,
    biz_state VARCHAR(3) NOT NULL,
    biz_postal_code VARCHAR(10) NOT NULL,
    biz_latitude DECIMAL(15, 10) NOT NULL,
    biz_longitude DECIMAL(15, 10) NOT NULL,
    average_rating DECIMAL(2, 1) NOT NULL,
    biz_review_count SMALLINT NOT NULL, -- deprecated 
    attributes VARCHAR(3000),
    categories VARCHAR(1000),
    PRIMARY KEY (business_id)
);

-- Create the reviews table
CREATE TABLE review (
    review_id CHAR(22),
    user_id CHAR(22),
    business_id CHAR(22),
    review_rating TINYINT CHECK (review_rating in (1, 2, 3, 4, 5)),
    useful_count SMALLINT DEFAULT 0,
    funny_count SMALLINT DEFAULT 0,
    cool_count SMALLINT DEFAULT 0,
    review_text VARCHAR(5000),
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (review_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (business_id) REFERENCES business(business_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create the tip table, which holds info about a business without
-- writing a full review.
CREATE TABLE tip (
    user_id CHAR(22),
    business_id CHAR(22),
    tip_text VARCHAR(3000),
    tip_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    tip_compliment_count TINYINT DEFAULT 0,
    tip_id INT AUTO_INCREMENT,
    PRIMARY KEY (tip_id)
);

-- Create an index to rank businesses by avg rating
CREATE INDEX biz_stars_ranked ON business(average_rating);
-- QUERIES ABOUT DATA ANALYSIS:
-- List cities from most businesses to least businesses
SELECT biz_city, COUNT(business_id) FROM
    business 
	GROUP BY biz_city
	ORDER BY COUNT(business_id) DESC;

-- List cities from most reviewers to least
-- This is for RA 1 (LIMIT 1 to get most).
SELECT biz_city, COUNT(user_id) FROM
    business NATURAL JOIN review NATURAL JOIN user
	GROUP BY biz_city
	ORDER BY COUNT(user_id) DESC;

-- More occurrences of the word "love" or "hate"? (Love wins!:))
SELECT COUNT(review_id) AS hate_count FROM
    review WHERE review_text like '%hate%';
SELECT COUNT(review_id) AS love_count FROM
    review WHERE review_text like '%love%';

-- Sort users by how much they've written in total
-- This is for RA 4 (slightly changed).
SELECT user_name, user.user_id, SUM(text_length) FROM
    (SELECT user_id, LENGTH(review_text) AS text_length FROM
        review) AS t1
    NATURAL JOIN user
    GROUP BY user.user_id
    ORDER BY SUM(text_length) DESC;

-- QUERIES ABOUT SPECIFIC PROCEDURES:
-- Get the top five nearest taco places (here, closest to Caltech).
-- Caltech latitude=34.138000, longitude=-118.125000.
-- This is for RA 2 (slightly changed).
SELECT business_name, biz_address FROM
    (business NATURAL LEFT JOIN review NATURAL LEFT JOIN tip)
    WHERE (tip_text LIKE '%taco%' OR review_text LIKE '%taco%' OR 
        business_name LIKE '%taco%')
    GROUP BY business_id
    ORDER BY
        (POWER((biz_latitude - 34.138000), 2)
        + POWER((biz_longitude - -118.125000), 2))
    LIMIT 5;

-- Get the top business in CA (this is to test the index).
SELECT business_name, business_id, biz_address, average_rating FROM 
    business WHERE biz_state='CA' ORDER BY average_rating DESC LIMIT 1;

-- Get the user who writes the funniest reviews and is in the top 100 of cute_counts.
-- SQL can't dynamically set LIMIT, so just take top 100.
SELECT user_name, user_id FROM (
    (SELECT * FROM user ORDER BY cute_count LIMIT 100) 
    AS t1
    NATURAL JOIN 
    (SELECT user_id, SUM(funny_count) AS funny_total FROM review GROUP BY
    user_id ORDER BY SUM(funny_count))
    AS t2)
    ORDER BY funny_total
    LIMIT 1;

-- Find a CA theater that also has a Chinese restaurant in the city.
SELECT a.business_name, b.business_name FROM
    (business a INNER JOIN business b on a.biz_city = b.biz_city) WHERE
    (a.categories LIKE '%Cinema%') AND 
    (b.categories LIKE '%Chinese%')
    AND a.biz_state='CA';

-- QUERIES ABOUT INSERTION/DELETION:
-- These are for RA 3.
-- Register a new user!
INSERT INTO user (user_id, user_name) VALUES (
    'XTBNwDXNQOO7lIxLXAc2BP',
    'Jay');

-- Add a good review to Santa Barbara Shellfish Company!
INSERT INTO review (review_id, user_id, business_id,
    review_rating, review_text) 
    VALUES (
    '6U2DES8BXTvk8CpCgve677',
    'XTBNwDXNQOO7lIxLXAc2BP',
    '2Y0L3Hf6U-76jGvviKy5pA',
    5,
    'Never been here but it''s probably great!');

-- Delete Jay from the database
DELETE FROM user WHERE user_id='XTBNwDXNQOO7lIxLXAc2BP';

-- Should come up with no records
SELECT * FROM review WHERE user_id='XTBNwDXNQOO7lIxLXAc2BP';
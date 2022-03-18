DROP FUNCTION IF EXISTS search;
-- UDF Function, search for closest businesses with a keyword
-- Parameters: user latitude and longitude, keyword, and min rating (opt.)
DELIMITER !
CREATE FUNCTION search(keyword VARCHAR(30), latitude DECIMAL(15, 10),
    longitude DECIMAL(15, 10), min_rating TINYINT)
RETURNS CHAR(22) DETERMINISTIC
BEGIN
    DECLARE biz_id CHAR(22);
    SET biz_id = '0000000000000000000000';
    IF ISNULL (min_rating) THEN
        SELECT business_id INTO biz_id FROM
        (business NATURAL LEFT JOIN review NATURAL LEFT JOIN tip)
        WHERE (tip_text LIKE CONCAT('%', keyword, '%') OR
            review_text LIKE CONCAT('%', keyword, '%') OR 
            business_name LIKE CONCAT('%', keyword, '%'))
        GROUP BY business_id
        ORDER BY
            (POWER((biz_latitude - latitude), 2)
            + POWER((biz_longitude - longitude), 2))
        LIMIT 1;
    ELSE
        SELECT business_id INTO biz_id FROM
        (business NATURAL LEFT JOIN review NATURAL LEFT JOIN tip)
        WHERE (tip_text LIKE CONCAT('%', keyword, '%') OR
            review_text LIKE CONCAT('%', keyword, '%') OR 
            business_name LIKE CONCAT('%', keyword, '%')) AND
            average_rating > min_rating
        GROUP BY business_id
        ORDER BY
            (POWER((biz_latitude - latitude), 2)
            + POWER((biz_longitude - longitude), 2))
        LIMIT 1;
    END IF;
    RETURN biz_id;
END !
DELIMITER ;
-- Some test queries:
-- SELECT search('taco', 34.138000, -118.125000, NULL); -- Expected El Taco Grande
-- SELECT search('taco', 34.138000, -118.125000, 4); -- Expected The Food Liason, 4.5 average rating
-- SELECT search('Chinese', 57.7, -23.2, 4);

-- Procedure, update the average rating when new review is made
-- Only allow reviews if business already exists
DROP PROCEDURE IF EXISTS sp_update;
DELIMITER !
CREATE PROCEDURE sp_update (biz_id CHAR(22), new_rating TINYINT)
BEGIN
    DECLARE new_avg DECIMAL(2, 1);
    DECLARE old_avg DECIMAL(2, 1);
    DECLARE old_count INT;
    SET old_avg = (SELECT average_rating FROM business WHERE
        business_id=biz_id);
    SET old_count = (SELECT COUNT(*) FROM review NATURAL INNER JOIN 
        business WHERE business_id=biz_id);
    SET new_avg = ((old_avg * old_count) + new_rating)/(old_count + 1);
    UPDATE business SET
        average_rating = new_avg WHERE business_id=biz_id;
END !
DELIMITER ;

-- Trigger
-- Update business rating on insert a new review
DROP TRIGGER IF EXISTS trg_update;
DELIMITER !
CREATE TRIGGER trg_update AFTER INSERT ON review FOR EACH ROW
BEGIN
    CALL sp_update(NEW.business_id, NEW.review_rating);
END !
DELIMITER ;

-- Some test queries
-- From queries.sql:
-- INSERT INTO user (user_id, user_name) VALUES ('XTBNwDXNQOO7lIxLXAc2BP', 'Jay');

-- Add a good review to Santa Barbara Shellfish Company!
-- INSERT INTO review (review_id, user_id, business_id, 
--    review_rating, review_text) 
--   VALUES ('6U2DES8BXTvk8CpCgve677', 'XTBNwDXNQOO7lIxLXAc2BP',
--   '2Y0L3Hf6U-76jGvviKy5pA', 5,
--   'Never been here but it''s probably great!');

-- See that the average rating has updated
-- SELECT average_rating FROM business WHERE business_id='2Y0L3Hf6U-76jGvviKy5pA';

-- Additional partner function to get the top business in the city, state:
DROP FUNCTION IF EXISTS top_business;
DELIMITER !
CREATE FUNCTION top_business(city_name VARCHAR(100), state_name CHAR(2))
RETURNS CHAR(22) DETERMINISTIC
BEGIN
    DECLARE biz_id CHAR(22);
    SET biz_id = '0000000000000000000000';
    SELECT business_id INTO biz_id FROM
    business WHERE biz_city=city_name AND biz_state=state_name
    ORDER BY average_rating
    DESC LIMIT 1;

    RETURN biz_id;
END !
DELIMITER ;
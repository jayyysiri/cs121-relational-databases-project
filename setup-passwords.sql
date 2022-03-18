DROP TABLE IF EXISTS user_info;
DROP FUNCTION IF EXISTS make_salt;
DROP PROCEDURE IF EXISTS sp_add_user;
DROP FUNCTION IF EXISTS authenticate;

-- File for Password Management section of Final Project

-- (Provided) This function generates a specified number of characters for using as a
-- salt in passwords.
DELIMITER !
CREATE FUNCTION make_salt(num_chars INT) 
RETURNS VARCHAR(20) DETERMINISTIC
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';

    -- Don't want to generate more than 20 characters of salt.
    SET num_chars = LEAST(20, num_chars);

    -- Generate the salt!  Characters used are ASCII code 32 (space)
    -- through 126 ('z').
    WHILE num_chars > 0 DO
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * 95)));
        SET num_chars = num_chars - 1;
    END WHILE;

    RETURN salt;
END !
DELIMITER ;

-- Provided (you may modify if you choose)
-- This table holds information for authenticating users based on
-- a password.  Passwords are not stored plaintext so that they
-- cannot be used by people that shouldn't have them.
-- You may extend that table to include an is_admin or role attribute if you 
-- have admin or other roles for users in your application 
-- (e.g. store managers, data managers, etc.)
CREATE TABLE user_info (
    -- Usernames are up to 20 characters.
    username VARCHAR(20) PRIMARY KEY,

    -- Salt will be 8 characters all the time, so we can make this 8.
    salt CHAR(8) NOT NULL,

    -- We use SHA-2 with 256-bit hashes.  MySQL returns the hash
    -- value as a hexadecimal string, which means that each byte is
    -- represented as 2 characters.  Thus, 256 / 8 * 2 = 64.
    -- We can use BINARY or CHAR here; BINARY simply has a different
    -- definition for comparison/sorting than CHAR.
    password_hash BINARY(64) NOT NULL
);

-- [Problem 1a]
-- Adds a new user to the user_info table, using the specified password (max
-- of 20 characters). Salts the password with a newly-generated salt value,
-- and then the salt and hash values are both stored in the table.
DELIMITER !
CREATE PROCEDURE sp_add_user(new_username VARCHAR(20), password VARCHAR(20))
BEGIN
  -- TODO
  DECLARE salt CHAR(8);
  DECLARE salted_password VARCHAR(28);
  DECLARE password_hash BINARY(64);
  SET salt = make_salt(8);
  SET salted_password = CONCAT(salt, password);
  SET password_hash = SHA2(salted_password,256);
  INSERT INTO user_info
  VALUES (new_username, salt, password_hash);
END !
DELIMITER ;

-- [Problem 1b]
-- Authenticates the specified username and password against the data
-- in the user_info table.  Returns 1 if the user appears in the table, and the
-- specified password hashes to the value for the user. Otherwise returns 0.
DELIMITER !
CREATE FUNCTION authenticate(username VARCHAR(20), password VARCHAR(20))
RETURNS TINYINT DETERMINISTIC
BEGIN
  -- TODO
  DECLARE s CHAR(8);
  DECLARE p BINARY(64);
  DECLARE salted_password VARCHAR(28);
  DECLARE pass_hash BINARY(64);
  DECLARE u VARCHAR(20);
  SET u = username;
  IF (NOT EXISTS (SELECT * FROM user_info us WHERE us.username = u)) THEN
        RETURN 0;
  ELSE
      BEGIN
        SELECT salt INTO s FROM user_info us WHERE us.username = u;
        SELECT password_hash INTO p FROM user_info us WHERE us.username = u;
      END;
  END IF;
  SET salted_password = CONCAT(s, password);
  SET pass_hash = SHA2(salted_password, 256);
  IF pass_hash = p THEN
        RETURN 1;
  ELSE
        RETURN 0;
  END IF;
  
END !
DELIMITER ;

-- [Problem 1c]
-- Add at least two users into your user_info table so that when we run this file,
-- we will have examples users in the database.

CALL sp_add_user('username123', 'password123');
CALL sp_add_user('alex', 'hello');
CALL sp_add_user('bowie', 'goodbye');

SELECT authenticate('chaka', 'hello');     -- Should return 0 (false)
SELECT authenticate('alex', 'goodbye');    -- Should return 0 (false)
SELECT authenticate('alex', 'hello');      -- Should return 1 (true)
SELECT authenticate('alex', 'HELLO');      -- Should return 0 (false)
SELECT authenticate('bowie', 'goodbye');   -- Should return 1 (true)

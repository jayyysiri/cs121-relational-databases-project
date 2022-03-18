CREATE USER 'diamondbarlibrary'@'localhost' IDENTIFIED BY 'adminpw';
CREATE USER 'jaysiri'@'localhost' IDENTIFIED BY 'clientpw';
-- Can add more users or refine permissions
GRANT ALL PRIVILEGES ON final.* TO 'diamondbarlibrary'@'localhost';
GRANT SELECT ON final.* TO 'jaysiri'@'localhost';
FLUSH PRIVILEGES;

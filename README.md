# Yelp Dataset Relational Databases Project

This project was created by Jay Siri and Akshay Gowrishankar for Caltech's CS121: Relational Databases course final project. 

We implemented a basic version of a business locator/recommendation system using the Yelp Dataset, which is publicly available at https://www.yelp.com/dataset. 

We pre-processed the data slightly using our `yelp_preprocessing.ipynb` script, and the final dataset we used can be found [here](https://drive.google.com/drive/folders/1W_R5_E5G5uUycE05aysBdS7ZFIuD5HOK?usp=sharing).


## Run the app
To run the app, make sure MySQL 8.0 and Python 3 are installed, then:
~~~
$ cd your-files
$ mysql --local-infile=1 -u root -p
mysql> create database final;
mysql> use final;
mysql> source setup.sql;
mysql> source load-data.sql;
mysql> source setup-passwords.sql;
mysql> source setup-routines.sql;
mysql> source grant-permissions.sql;
mysql> quit;
$ python3 app.py 
~~~

When prompted for a username and password, you can use the test login info we made:
~~~
Username: username123
Password: password123
~~~

Once you enter the app, you will have an option of queries to select:
~~~
What would you like to do?
Queries List
  (a) - Find food near you!
  (b) - Get top businesses in your city
  (c) - Get the cities in your state with most businesses
  (d) - Add a review
  (e) - Get average rating for a business
  (f) - Show reviews for a business
  (q) - quit
~~~

Select a query and enter the parameters you would like to select when prompted. For example:
~~~
Enter an option: a
What would you like to eat?: taco
Enter longitude: -118.1253
Enter latitude: 34.1377
~~~

After a while, the output should be be:
~~~
('El Taco Grande', '1096 Casitas Pass Rd')
('Albertsons', '1018 Casitas Pass Rd')
('Taco Bell', '1045 Casitas Pass Road')
('The Food Liaison', '1033 Casitas Pass Rd')
("Taco's To Go", '794 Linden Ave')
~~~

You can also run `queries.sql` prior to quitting MySQL, which does some basic data analysis and tests our DDL.


*Note: It should be noted that while all of our components work, the data is incomplete, since we only took the first 500,000 reviews and the first 500,000 users from the dataset (but all the businesses and tips in our pre-processed dataset). This means that a business may have a non-zero review count with a valid average number of reviews, but querying to see those reviews won’t return anything since the review data was truncated.

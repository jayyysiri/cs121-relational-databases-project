"""
Names: Akshay Gowrishankar, Jay Siri
Here we have our code for our Yelp-review command line app. It includes functions
to find nearby food, find the city with the most businesses in your state, 
add a review, see reviews/average ratings, and more.
"""
import sys
import mysql.connector
from datetime import datetime
import random
import string
import mysql.connector.errorcode as errorcode

# Debugging flag to print errors when debugging that shouldn't be visible
# to an actual client. Set to False when done testing.
DEBUG = False


def get_conn():
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """
    try:
        conn = mysql.connector.connect(
          host='localhost',
          user='diamondbarlibrary',
          # Find port in MAMP or MySQL Workbench GUI or with
          # SHOW VARIABLES WHERE variable_name LIKE 'port';
          port='3306',
          password='adminpw',
          database='final'
        )
        print('Successfully connected.')
        return conn
    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr('Database does not exist.')
        elif DEBUG:
            sys.stderr(err)
        else:
            sys.stderr('An error occurred, please contact the administrator.')
        sys.exit(1)     

def login():
    """
    Allows a user to login using the SQL authenticate UDF.
    """
    uname = input('Username: ')
    pword = input('Password: ')
    cursor = conn.cursor()  
    sql = 'SELECT authenticate(\'%s\', \'%s\');' %(uname, pword)
    try:
        cursor.execute(sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()
        if len(rows) == 1 and (rows[0]) == (1,):
            pass
        else:
            sys.stderr("Authentication Failed")
            sys.exit(1)
    except mysql.connector.Error as err:
            sys.stderr("Authentication Failed")
            sys.exit(1)

def top_cities(state_name):
    """
    SQL query for find the cities with the most businesses given a state.
    """
    cursor = conn.cursor()
    sql = 'SELECT biz_city, COUNT(user_id) FROM\
    business NATURAL JOIN review\
    WHERE biz_state = \'%s\'\
    GROUP BY biz_city\
    ORDER BY COUNT(user_id) DESC;' %(state_name)
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        if len(rows) == 0:
            print("No Businesses Found!\n")
        for row in rows:
            (col1val) = (row)
            print('City Name: ' + col1val[0])
            print('Number of Businesses: ' + str(int(col1val[1])))
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, please give a valid name.')
    show_options()


def top_businesses(city_name, state_name):
    """
    SQL query to find the top businesses in a given city, state.
    """
    cursor = conn.cursor()
    sql = 'SELECT  business_name, biz_address, average_rating, business_id FROM\
    business WHERE biz_city = \'%s\' AND biz_state=\'%s\'\
    ORDER BY average_rating\
    DESC LIMIT 1;' %(city_name, state_name)
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        if len(rows) == 0:
            print("No Businesses Found!\n")
        else:
            print('Top Businesses in %s, %s:' %(city_name, state_name))
        for row in rows:
            (col1val) = (row)
            print('Business Name: ' + col1val[0])
            print('Business Address: ' + col1val[1])
            print('Average Rating: ' + str(int(col1val[2])))
            print('Yelp Business ID: ' + str(int(col1val[3])))
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, please give valid names.')
    show_options()

def get_food(food,longcoord, latcoord):
    """
    SQL query to get top five nearby business/restaurant options
    given a keyword ('food'), and lat and long coords.
    """
    longcoord = str(longcoord)
    latcoord = str(latcoord)
    cursor = conn.cursor()
    sql = 'SELECT business_name, biz_address, business_id FROM \
    (business NATURAL LEFT JOIN review NATURAL LEFT JOIN tip)\
    WHERE (tip_text LIKE \'%%%s%%\' OR review_text LIKE \'%%%s%%\' OR \
    business_name LIKE \'%%%s%%\') GROUP BY business_id ORDER BY\
    (POWER((biz_latitude - %s), 2) + POWER((biz_longitude\
    - %s), 2)) LIMIT 5;' %(food,food,food,latcoord,longcoord)
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        for row in rows:
            (col1val) = (row)
            print(col1val[:2], ' Business ID: ', col1val[2])
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, please give valid coordinates.')
    show_options()

def add_rating(biz_id, rating_value, review_txt):
    """
    SQL procedure (with trigger) that allows users to add rating and update the
    business's average rating.
    """
    rating_value = str(rating_value)
    review_txt = str(review_txt)
    cursor = conn.cursor()
    uid = ''.join(random.choices(string.ascii_lowercase + \
                                 string.ascii_uppercase + string.digits, k=22))
    rid = ''.join(random.choices(string.ascii_lowercase + \
                                 string.ascii_uppercase + string.digits, k=22))
    uname = input("Username: ")
    sql = 'INSERT INTO user (user_id, user_name) \
    VALUES (\'%s\',\'%s\');' %(uid, uname)
    sql2 = 'INSERT INTO review (review_id, user_id, business_id, review_rating, review_text) \
    VALUES (\'%s\', \'%s\', \'%s\', %s, \'%s\');' %(rid, uid, biz_id, rating_value, review_txt)
    try:
        cursor.execute(sql)
        cursor.execute(sql2)
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, rating could not update')
    show_options()

def show_reviews(biz_id):
    """
    SQL query to show reviews of a business given its business ID.
    """
    biz_id = str(biz_id)
    cursor = conn.cursor()
    sql = 'SELECT review_date, review_rating, review_text FROM review \
        WHERE business_id=\'%s\';' %(biz_id)
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        for row in rows:
            (col1val) = (row)
            print('Date: ', col1val[0].strftime("%m/%d/%Y, %H:%M:%S"))
            print('Rating: ', col1val[1])
            print('Review: ', col1val[2], '\n')
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, reviews could not be shown')
    show_options()

def get_rating(biz_id):
    """
    Get the average rating for a business given its business id.
    """
    cursor = conn.cursor()
    sql = 'SELECT average_rating FROM business \
    WHERE business_id = \'%s\';' %(biz_id)
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        for row in rows:
            (col1val) = (row)
            print('Average Rating For %s: ' %(biz_id) + str(col1val[0]))
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred, please give valid coordinates.')      
    show_options()

# ----------------------------------------------------------------------
# Command-Line Functionality
# ----------------------------------------------------------------------
def show_options():
    """
    Displays options users can choose in the application, such as
    viewing <x>, filtering results with a flag (e.g. -s to sort),
    sending a request to do <x>, etc.
    """
    print('What would you like to do? ')
    print('  Queries List')
    print('  (a) - Find food near you!')
    print('  (b) - Get top businesses in your city')
    print('  (c) - Get the cities in your state with most businesses')
    print('  (d) - Add a review')
    print('  (e) - Get average rating for a business')
    print('  (f) - Show reviews for a business') 
    print('  (q) - quit')
    print()
    ans = input('Enter an option: ').lower()
    if ans == 'q':
        quit_ui()
    elif ans == 'a':
        food = input('What would you like to eat?: ')
        lon = input('Enter longitude: ')
        lat = input('Enter latitude: ')
        get_food(food, lon,lat)
    elif ans == 'b':
        city = input('City: ')
        state = input('State (postal abbreviation): ')
        top_businesses(city, state)
    elif ans == 'c':
        state = input('State (postal abbreviation): ')
        top_cities(state)
    elif ans == 'd':
        biz = input('Business ID: ')
        rat_value = input('Rating Value: ')
        rev_text = input('Review: ')
        add_rating(biz, rat_value, rev_text)
    elif ans == 'e':
        biz = input('Business ID: ')
        get_rating(biz)
    elif ans =='f':
        biz = input('Business ID: ')
        show_reviews(biz)
    else:
        print('Try a different option!')
        show_options()


def quit_ui():
    """
    Quits the program, printing a good bye message to the user.
    """
    print('Good bye!')
    exit()


def main():
    """
    Main function for starting things up.
    """
    login()
    show_options()


if __name__ == '__main__':
    # This conn is a global object that other functinos can access.
    # You'll need to use cursor = conn.cursor() each time you are
    # about to execute a query with cursor.execute(<sqlquery>)
    conn = get_conn()
    main()
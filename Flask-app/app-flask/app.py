'''


'''


import os
import psycopg2
from flask import Flask, render_template, request, url_for, redirect

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(host=os.environ['POSTGRES_HOST'],
                            port = '5432',
                            database=os.environ['POSTGRES_DB'],
                            user=os.environ['POSTGRES_USER'],
                            password=os.environ['POSTGRES_PASSWORD'])
    return conn

@app.route('/')
def index():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM books;')
    books = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('index.html', books=books)


@app.route('/create/', methods=('GET', 'POST'))
def create():
    if request.method == 'POST':
        title = request.form['title']
        author = request.form['author']
        pages_num = int(request.form['pages_num'])
        review = request.form['review']

        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('INSERT INTO books (title, author, pages_num, review)'
                    'VALUES (%s, %s, %s, %s)',
                    (title, author, pages_num, review))
        conn.commit()
        cur.close()
        conn.close()
        return redirect(url_for('index'))

    return render_template('create.html')


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)




#=======================================================================================LOCAL RUN
# SET APPLICATION ENV
#=======================
# conda create -n flaskenv
# conda env install pip
# pip install flask psycopg2-binary



# SET APPLICATION DB
#=======================
# sudo docker pull postgres
# docker run -i -p 5432:5432 --name mypostgres -e POSTGRES_PASSWORD=postgres -d postgres
# docker exec -it mypostgres bin/bash
# psql postgres postgres
# create a db called flask_db (postgres=# CREATE DATABASE flask_db;)

# If needed:
# CREATING A NEW USER
# postgres# CREATE USER cesar WITH PASSWORD '12345';
# postgres# GRANT ALL PRIVILEGES ON DATABASE flask_db TO cesar;

# OTHER COMMANDS
# postgres# \l               # list db 
# postgres# \c flask_db      # switch to flask_db
# postgres# \d               # check available tables
# postgres# select * from <tablename>
# postgres# \q               # quit

# export POSTGRES_DB="flask_db"
# export POSTGRES_USER="cesar"
# export POSTGRES_PASSWORD="12345"
# export POSTGRES_URL="localhost" or.....a given url


# \c flask_db
# CREATE TABLE books (
#     id SERIAL PRIMARY KEY,
#     title VARCHAR(100) NOT NULL,
#     author VARCHAR(100) NOT NULL,
#     pages_num INT NOT NULL,
#     review TEXT
# );

# \d : list tables
# flask_db=# ALTER TABLE books OWNER TO cesar;


# python3 app.py or python3 -m flask run


#=======================================================================================K8S RUN
# Change: host='localhost'                 host='postgres-service'



# REFERENCE
# https://www.digitalocean.com/community/tutorials/how-to-use-a-postgresql-database-in-a-flask-application


import mysql.connector
from mysql.connector import Error

def create_connection():
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="Chaitu_1511",   # replace with your MySQL password
            database="FeedbackDB"     # make sure this DB exists
        )
        if conn.is_connected():
            print("✅ Connected to MySQL database successfully!")
        return conn
    except Error as e:
        print(f"❌ Error while connecting to MySQL: {e}")
        return None

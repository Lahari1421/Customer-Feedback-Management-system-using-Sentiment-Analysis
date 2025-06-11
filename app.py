from flask import Flask, render_template, request, redirect, session, url_for
import mysql.connector
from datetime import datetime
from textblob import TextBlob

app = Flask(__name__)
app.secret_key = 'super_secret_key_change_this'

# 🔌 Connect to MySQL Database
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Chaitu_1511",
    database="FeedbackDB"
)
cursor = db.cursor()

# 🏠 Homepage Route
@app.route('/')
def index():
    cursor.execute("SELECT * FROM Products")
    products = cursor.fetchall()

    cursor.execute("""
        SELECT f.feedback_id, c.name, c.country, p.name, f.feedback_text, f.sentiment, f.feedback_date
        FROM Feedback f
        JOIN Customers c ON f.customer_id = c.customer_id
        JOIN Products p ON f.product_id = p.product_id
        ORDER BY f.feedback_date DESC
    """)
    feedbacks = cursor.fetchall()

    return render_template("index.html", feedbacks=feedbacks, products=products)

# ✉️ Submit Feedback
@app.route('/submit', methods=['POST'])
def submit():
    name = request.form['name']
    email = request.form['email']
    country = request.form['country']
    product_id = request.form['product_id']
    feedback_text = request.form['feedback']
    feedback_date = datetime.today().strftime('%Y-%m-%d')

    sentiment_score = TextBlob(feedback_text).sentiment.polarity
    sentiment = "Positive" if sentiment_score > 0 else "Negative" if sentiment_score < 0 else "Neutral"

    # Check for existing customer or insert
    cursor.execute("SELECT customer_id FROM Customers WHERE email = %s", (email,))
    result = cursor.fetchone()

    if result:
        customer_id = result[0]
    else:
        cursor.execute("INSERT INTO Customers (name, email, country) VALUES (%s, %s, %s)", (name, email, country))
        db.commit()
        customer_id = cursor.lastrowid

    # Call stored procedure to insert feedback
    cursor.callproc('AddFeedback', (email, int(product_id), feedback_text, feedback_date, sentiment))
    db.commit()

    return redirect('/')

# 🔐 Admin Login
@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    error = None
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        # Static credentials (replace with DB check if needed)
        if username == 'admin' and password == '123':
            session['admin_logged_in'] = True
            return redirect(url_for('admin_reports'))
        else:
            error = 'Invalid username or password.'

    return render_template('admin_login.html', error=error)

# 🔓 Admin Logout
@app.route('/admin/logout')
def admin_logout():
    session.pop('admin_logged_in', None)
    return redirect(url_for('admin_login'))

# 📊 Admin Dashboard (Reports Page)
@app.route('/admin/reports')
def admin_reports():
    if not session.get('admin_logged_in'):
        return redirect(url_for('admin_login'))

    # 🏆 Top Customers
    cursor.callproc('TopFeedbackCustomers')
    for result in cursor.stored_results():
        top_customers = result.fetchall()

    # 📦 Product Sentiment Breakdown
    cursor.callproc('ProductSentimentBreakdown')
    for result in cursor.stored_results():
        product_sentiments = result.fetchall()

    # 📅 Daily Sentiment Trend
    cursor.execute("SELECT * FROM DailySentiment ORDER BY feedback_date DESC")
    daily_sentiment = cursor.fetchall()

    # 🌍 Country-wise Feedback
    cursor.execute("SELECT * FROM CountryFeedback")
    country_feedback = cursor.fetchall()

    return render_template('admin_reports.html',
                           top_customers=top_customers,
                           product_sentiments=product_sentiments,
                           daily_sentiment=daily_sentiment,
                           country_feedback=country_feedback)

# 🚀 Run
if __name__ == '__main__':
    app.run(debug=True)

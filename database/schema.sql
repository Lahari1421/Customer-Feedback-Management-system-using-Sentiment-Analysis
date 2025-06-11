-- 🔄 Drop and recreate the full database
DROP DATABASE IF EXISTS FeedbackDB;
CREATE DATABASE FeedbackDB;
USE FeedbackDB;

-- 👤 Customers Table
CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    country VARCHAR(50)
);

-- 📦 Products Table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50)
);

-- 💬 Feedback Table
CREATE TABLE Feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    feedback_text TEXT,
    feedback_date DATE,
    sentiment VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 🛒 Sample Products
INSERT INTO Products (product_id, name, category) VALUES
(101, 'AlphaPhone', 'Electronics'),
(102, 'QuickMeal', 'Food'),
(103, 'SmartWatch', 'Electronics'),
(104, 'CoffeeBlend', 'Food');

-- 🙋 Sample Customers
INSERT INTO Customers (name, email, country) VALUES
('John Doe', 'john@example.com', 'USA'),
('Aditi Sharma', 'aditi@example.com', 'India');

-- 🗣️ Sample Feedback
INSERT INTO Feedback (customer_id, product_id, feedback_text, feedback_date, sentiment) VALUES
(1, 101, 'Great performance and battery', '2024-11-01', 'Positive'),
(2, 102, 'Packaging was poor', '2024-11-05', 'Negative');

-- 🧠 Stored Procedure: AddFeedback
DELIMITER $$

CREATE PROCEDURE AddFeedback(
    IN p_email VARCHAR(100),
    IN p_product_id INT,
    IN p_feedback_text TEXT,
    IN p_feedback_date DATE,
    IN p_sentiment VARCHAR(20)
)
BEGIN
    DECLARE customerId INT;

    -- Get customer_id from email
    SELECT customer_id INTO customerId
    FROM Customers
    WHERE email = p_email;

    -- Insert into Feedback
    INSERT INTO Feedback (customer_id, product_id, feedback_text, feedback_date, sentiment)
    VALUES (customerId, p_product_id, p_feedback_text, p_feedback_date, p_sentiment);
END$$

DELIMITER ;

-- 🏆 Stored Procedure: TopFeedbackCustomers
DELIMITER $$

CREATE PROCEDURE TopFeedbackCustomers()
BEGIN
    SELECT c.name, COUNT(*) AS feedback_count
    FROM Feedback f
    JOIN Customers c ON f.customer_id = c.customer_id
    GROUP BY c.customer_id
    ORDER BY feedback_count DESC
    LIMIT 5;
END$$

DELIMITER ;

-- 📦 Stored Procedure: ProductSentimentBreakdown
DELIMITER $$

CREATE PROCEDURE ProductSentimentBreakdown()
BEGIN
    SELECT 
        p.name AS product_name,
        SUM(CASE WHEN f.sentiment = 'Positive' THEN 1 ELSE 0 END) AS positives,
        SUM(CASE WHEN f.sentiment = 'Negative' THEN 1 ELSE 0 END) AS negatives,
        SUM(CASE WHEN f.sentiment = 'Neutral' THEN 1 ELSE 0 END) AS neutrals
    FROM Feedback f
    JOIN Products p ON f.product_id = p.product_id
    GROUP BY p.product_id;
END$$

DELIMITER ;

-- 📅 View: DailySentiment
CREATE VIEW DailySentiment AS
SELECT 
    feedback_date,
    SUM(CASE WHEN sentiment = 'Positive' THEN 1 ELSE 0 END) AS positives,
    SUM(CASE WHEN sentiment = 'Negative' THEN 1 ELSE 0 END) AS negatives,
    SUM(CASE WHEN sentiment = 'Neutral' THEN 1 ELSE 0 END) AS neutrals
FROM Feedback
GROUP BY feedback_date
ORDER BY feedback_date;

-- 🌍 View: CountryFeedback
CREATE VIEW CountryFeedback AS
SELECT 
    c.country,
    COUNT(*) AS total_feedback
FROM Feedback f
JOIN Customers c ON f.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_feedback DESC;

USE FeedbackDB;

-- Daily Sentiment Summary
CREATE OR REPLACE VIEW DailySentiment AS
SELECT feedback_date,
       COUNT(*) AS total,
       SUM(sentiment = 'Positive') AS positives,
       SUM(sentiment = 'Negative') AS negatives,
       SUM(sentiment = 'Neutral') AS neutrals
FROM Feedback
GROUP BY feedback_date;

-- Product-wise Sentiment Summary
CREATE OR REPLACE VIEW ProductSentiment AS
SELECT p.name AS product_name,
       SUM(sentiment = 'Positive') AS positives,
       SUM(sentiment = 'Negative') AS negatives,
       SUM(sentiment = 'Neutral') AS neutrals
FROM Feedback f
JOIN Products p ON f.product_id = p.product_id
GROUP BY p.name;

-- Country-wise Feedback Summary
CREATE OR REPLACE VIEW CountryFeedback AS
SELECT c.country,
       COUNT(f.feedback_id) AS total_feedback
FROM Feedback f
JOIN Customers c ON f.customer_id = c.customer_id
GROUP BY c.country;

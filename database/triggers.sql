USE FeedbackDB;

-- Drop helper tables if exist
DROP TABLE IF EXISTS NegativeFeedbackLog;
CREATE TABLE NegativeFeedbackLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    feedback_id INT,
    message TEXT,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS SentimentAudit;
CREATE TABLE SentimentAudit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    feedback_id INT,
    old_sentiment VARCHAR(20),
    new_sentiment VARCHAR(20),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

-- Trigger 1: Log negative feedbacks
CREATE TRIGGER AfterNegativeFeedback
AFTER INSERT ON Feedback
FOR EACH ROW
BEGIN
  IF NEW.sentiment = 'Negative' THEN
    INSERT INTO NegativeFeedbackLog (feedback_id, message)
    VALUES (NEW.feedback_id, CONCAT('Negative feedback received: ', NEW.feedback_text));
  END IF;
END;
//

-- Trigger 2: Auto-fill feedback_date if NULL
CREATE TRIGGER BeforeFeedbackInsert
BEFORE INSERT ON Feedback
FOR EACH ROW
BEGIN
  IF NEW.feedback_date IS NULL THEN
    SET NEW.feedback_date = CURDATE();
  END IF;
END;
//

-- Trigger 3: Log sentiment changes on update
CREATE TRIGGER OnSentimentUpdate
AFTER UPDATE ON Feedback
FOR EACH ROW
BEGIN
  IF OLD.sentiment != NEW.sentiment THEN
    INSERT INTO SentimentAudit (feedback_id, old_sentiment, new_sentiment)
    VALUES (OLD.feedback_id, OLD.sentiment, NEW.sentiment);
  END IF;
END;
//

-- Trigger 4: Auto-categorize sentiment before insert if not provided
CREATE TRIGGER AutoCategorizeSentiment
BEFORE INSERT ON Feedback
FOR EACH ROW
BEGIN
  IF NEW.sentiment IS NULL OR NEW.sentiment = '' THEN
    IF LOWER(NEW.feedback_text) LIKE '%good%' OR LOWER(NEW.feedback_text) LIKE '%great%' OR LOWER(NEW.feedback_text) LIKE '%excellent%' THEN
      SET NEW.sentiment = 'Positive';
    ELSEIF LOWER(NEW.feedback_text) LIKE '%bad%' OR LOWER(NEW.feedback_text) LIKE '%poor%' OR LOWER(NEW.feedback_text) LIKE '%terrible%' THEN
      SET NEW.sentiment = 'Negative';
    ELSE
      SET NEW.sentiment = 'Neutral';
    END IF;
  END IF;
END;
//

DELIMITER ;

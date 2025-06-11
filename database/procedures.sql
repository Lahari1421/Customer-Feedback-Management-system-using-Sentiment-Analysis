DROP PROCEDURE IF EXISTS AddFeedback;

DELIMITER //

CREATE PROCEDURE AddFeedback(
  IN cust_email VARCHAR(100),
  IN prod_id INT,
  IN f_text TEXT,
  IN f_date DATE,
  IN f_sentiment VARCHAR(20)
)
BEGIN
  DECLARE c_id INT;
  SELECT customer_id INTO c_id FROM Customers WHERE email = cust_email;
  INSERT INTO Feedback (customer_id, product_id, feedback_text, feedback_date, sentiment)
  VALUES (c_id, prod_id, f_text, f_date, f_sentiment);
END;
//

DELIMITER ;

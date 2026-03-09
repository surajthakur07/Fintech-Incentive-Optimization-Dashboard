CREATE DATABASE fintech_incentive_system;
USE fintech_incentive_system;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    signup_date DATE,
    referred_by INT NULL,
    FOREIGN KEY (referred_by) REFERENCES users(user_id)
);

CREATE TABLE transactions (
    txn_id INT PRIMARY KEY,
    user_id INT,
    txn_date DATE,
    txn_year INT,
    txn_month INT,
    txn_type VARCHAR(20),
    txn_amount DECIMAL(10,2),
    txn_status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE referrals (
    referral_id INT PRIMARY KEY,
    referrer_id INT,
    referred_user_id INT,
    referral_date DATE,
    FOREIGN KEY (referrer_id)
        REFERENCES users (user_id),
    FOREIGN KEY (referred_user_id)
        REFERENCES users (user_id)
);

CREATE TABLE revenue_config (
    txn_type VARCHAR(20) PRIMARY KEY,
    revenue_percent DECIMAL(5,2)
);

INSERT INTO revenue_config VALUES
('UPI', 0.50),
('CARD', 1.20);

SHOW VARIABLES LIKE 'secure_file_priv';

USE fintech_incentive_system;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE transactions;
TRUNCATE TABLE referrals;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(user_id, user_name, signup_date, @referred_by)
SET referred_by = NULLIF(TRIM(@referred_by), '');

SELECT COUNT(*) FROM users WHERE referred_by IS NULL;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE transactions;
SET FOREIGN_KEY_CHECKS = 1;


SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE transactions;
SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(txn_id, user_id, txn_date, txn_year, txn_month, txn_type, txn_amount, txn_status);

SELECT COUNT(*) FROM transactions;

SELECT txn_status, COUNT(*) 
FROM transactions 
GROUP BY txn_status;

SELECT txn_type, COUNT(*) 
FROM transactions 
GROUP BY txn_type;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE referrals;
SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/referrals.csv'
INTO TABLE referrals
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(referral_id, referrer_id, referred_user_id, referral_date);

SELECT COUNT(*) FROM referrals;

SELECT COUNT(*) 
FROM referrals r
LEFT JOIN users u ON r.referred_user_id = u.user_id
WHERE u.user_id IS NULL;

CREATE OR REPLACE VIEW txn_cashback AS
SELECT 
    txn_id,
    user_id,
    txn_date,
    txn_type,
    txn_amount,
    txn_status,
    CASE
        WHEN txn_status = 'SUCCESS' AND txn_type = 'UPI'
            THEN txn_amount * 0.02
        WHEN txn_status = 'SUCCESS' AND txn_type = 'CARD'
            THEN txn_amount * 0.01
        ELSE 0
    END AS cashback_amount
FROM transactions;

SELECT * FROM txn_cashback LIMIT 100;

CREATE OR REPLACE VIEW monthly_cashback_raw AS
SELECT
    user_id,
    YEAR(txn_date) AS txn_year,
    MONTH(txn_date) AS txn_month,
    SUM(cashback_amount) AS total_cashback
FROM txn_cashback
GROUP BY
    user_id,
    YEAR(txn_date),
    MONTH(txn_date);
    
    SELECT *
FROM monthly_cashback_raw
ORDER BY total_cashback DESC
LIMIT 10;

CREATE OR REPLACE VIEW monthly_cashback_capped AS
SELECT
    user_id,
    txn_year,
    txn_month,
    total_cashback,
    CASE
        WHEN total_cashback > 500 THEN 500
        ELSE total_cashback
    END AS cashback_after_cap
FROM monthly_cashback_raw;

SELECT *
FROM monthly_cashback_capped
WHERE total_cashback > 500;

CREATE OR REPLACE VIEW user_failure_rate AS
SELECT 
    user_id,
    COUNT(*) AS total_txns,
    SUM(CASE 
            WHEN txn_status = 'FAILED' THEN 1 
            ELSE 0 
        END) AS failed_txns,
    SUM(CASE 
            WHEN txn_status = 'FAILED' THEN 1 
            ELSE 0 
        END) / COUNT(*) AS failure_rate
FROM transactions
GROUP BY user_id;

SELECT *
FROM user_failure_rate
ORDER BY failure_rate DESC
LIMIT 10;

CREATE OR REPLACE VIEW final_monthly_cashback AS
SELECT 
    m.user_id,
    m.txn_year,
    m.txn_month,
    m.cashback_after_cap,
    u.failure_rate,
    CASE
        WHEN u.failure_rate > 0.20 THEN 0
        ELSE m.cashback_after_cap
    END AS final_cashback_paid
FROM monthly_cashback_capped m
JOIN user_failure_rate u
ON m.user_id = u.user_id;

SELECT *
FROM final_monthly_cashback
WHERE failure_rate > 0.20
LIMIT 10;

CREATE OR REPLACE VIEW user_success_count AS
SELECT
    user_id,
    SUM(CASE 
            WHEN txn_status = 'SUCCESS' THEN 1 
            ELSE 0 
        END) AS success_txns
FROM transactions
GROUP BY user_id;

SELECT *
FROM user_success_count
ORDER BY success_txns DESC
LIMIT 10;

CREATE OR REPLACE VIEW referral_rewards AS
SELECT
    r.referrer_id,
    r.referred_user_id,
    s.success_txns,
    CASE
        WHEN s.success_txns >= 3 THEN 100
        ELSE 0
    END AS referral_bonus
FROM referrals r
JOIN user_success_count s
ON r.referred_user_id = s.user_id;

SELECT *
FROM referral_rewards
LIMIT 10;

SELECT SUM(referral_bonus) AS total_referral_bonus
FROM referral_rewards;

CREATE OR REPLACE VIEW txn_revenue AS
SELECT
    t.txn_id,
    t.user_id,
    t.txn_amount,
    t.txn_type,
    r.revenue_percent,
    (t.txn_amount * r.revenue_percent / 100) AS revenue
FROM transactions t
JOIN revenue_config r
ON t.txn_type = r.txn_type
WHERE TRIM(t.txn_status) = 'SUCCESS';

SELECT *
FROM txn_revenue
LIMIT 10;

SELECT SUM(revenue) AS total_revenue
FROM txn_revenue;

SELECT SUM(final_cashback_paid) AS total_cashback_paid
FROM final_monthly_cashback;

SELECT SUM(referral_bonus) FROM referral_rewards;

SELECT 
(
    (SELECT SUM(final_cashback_paid) FROM final_monthly_cashback)
    +
    (SELECT SUM(referral_bonus) FROM referral_rewards)
)
/
(SELECT SUM(revenue) FROM txn_revenue)
AS incentive_to_revenue_ratio;

CREATE OR REPLACE VIEW final_business_summary AS
SELECT 
    (SELECT SUM(revenue) FROM txn_revenue) AS total_revenue,

    (SELECT SUM(final_cashback_paid) 
     FROM final_monthly_cashback) AS total_cashback_paid,

    (SELECT SUM(referral_bonus) 
     FROM referral_rewards) AS total_referral_bonus,

    (
        (SELECT SUM(final_cashback_paid) FROM final_monthly_cashback)
        +
        (SELECT SUM(referral_bonus) FROM referral_rewards)
    ) AS total_incentive_cost,

    (
        (
            (SELECT SUM(final_cashback_paid) FROM final_monthly_cashback)
            +
            (SELECT SUM(referral_bonus) FROM referral_rewards)
        )
        /
        (SELECT SUM(revenue) FROM txn_revenue)
    ) AS incentive_to_revenue_ratio;
    
    SELECT * FROM final_business_summary;
    
    SELECT * FROM final_monthly_cashback;
    
    SELECT * FROM referral_rewards;
    
    SELECT * FROM txn_revenue;
    
SET SQL_SAFE_UPDATES = 0;

UPDATE transactions
SET 
txn_type = TRIM(REPLACE(txn_type,'\r','')),
txn_status = TRIM(REPLACE(txn_status,'\r',''));

SELECT txn_type, txn_status, LENGTH(txn_type), LENGTH(txn_status)
FROM transactions
LIMIT 10;

SELECT txn_amount, txn_type, txn_status, cashback_amount
FROM txn_cashback
LIMIT 10;

SELECT *
FROM final_business_summary;
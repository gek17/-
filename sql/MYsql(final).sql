CREATE DATABASE Customers_transactions;
UPDATE customers SET Gender = NULL WHERE Gender = ''; 
UPDATE customers set Age = Null Where Age = ''; 
ALTER TABLE customers MODIFY AGE INT NULL;


SELECT * FROM customers;
CREATE TABLE transactions
(date_new DATE,
Id_check INT,
ID_client INT,
Count_products DECIMAL(10,3),
Sum_payment DECIMAL(10,2));
SELECT * FROM transactions;
DESCRIBE transactions;



LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW variables LIKE 'SECURE_FILE_PRIV';



#1 
WITH monthly_activity AS 
(SELECT ID_client,
        DATE_FORMAT(date_new, '%Y-%m') AS month,     
        COUNT(DISTINCT Id_check) AS transaction_count, 
        SUM(Sum_payment) AS total_spent               
    FROM transactions
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01' 
    GROUP BY ID_client, DATE_FORMAT(date_new, '%Y-%m')),
client_summary AS 
(SELECT ID_client,
        COUNT(DISTINCT month) AS active_months,       
        SUM(transaction_count) AS total_transactions, 
        SUM(total_spent) AS total_spent_year,         
        AVG(total_spent) AS avg_monthly_spent         
    FROM monthly_activity
    GROUP BY ID_client
    HAVING active_months = 12 )
(SELECT c.ID_client,
    c.total_spent_year / c.total_transactions AS avg_check,
    c.avg_monthly_spent AS avg_monthly_spent,               
    c.total_transactions AS total_operations               
FROM client_summary c);

#2

#a) 
SELECT DATE_FORMAT(date_new, '%Y-%m') AS month, 
AVG(SUM_payment) as avg_monthly_spent
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;
#b)
SELECT DATE_FORMAT(date_new, '%Y-%m') as month,
AVG(ID_check) as avg_transaction
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;
#c)
WITH monthly_client_count AS (
    SELECT DATE_FORMAT(date_new, '%Y-%m') AS month, 
	COUNT(DISTINCT ID_client) AS client_count 
    FROM transactions
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01' 
    GROUP BY month
    ORDER BY month
)
SELECT AVG(client_count) AS avg_monthly_clients 
FROM monthly_client_count;

#d) 
WITH monthly_summary AS (
SELECT  DATE_FORMAT(date_new, '%Y-%m') AS month, 
        SUM(Sum_payment) AS total_monthly_sales, 
        COUNT(Id_check) AS total_monthly_operations 
    FROM transactions
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY month),
yearly_totals AS (
    SELECT SUM(Sum_payment) AS total_sales_year, 
	COUNT(Id_check) AS total_operations_year 
    FROM transactions
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01')
SELECT ms.month, 
ms.total_monthly_sales / yt.total_sales_year AS sales_share, 
ms.total_monthly_operations / yt.total_operations_year AS operations_share 
FROM monthly_summary ms
CROSS JOIN yearly_totals yt
ORDER BY ms.month;

#e)
SELECT DATE_FORMAT(t.date_new, '%Y-%m') AS month, 
    c.gender,
    COUNT(c.gender) AS count_gender,
    SUM(t.Sum_payment) AS total_payment,
    (SUM(t.Sum_payment) / 
    (SELECT SUM(t.Sum_payment) 
    FROM transactions t)) AS payment_percentage
FROM transactions t
JOIN customers c ON t.ID_client = c.id_client
GROUP BY month, c.gender
ORDER BY month, FIELD(c.gender, 'M', 'F', 'NA');  

#3)

SELECT CASE
        WHEN c.age IS NULL THEN 'NA'
        WHEN c.age BETWEEN 0 AND 9 THEN '0-9'
        WHEN c.age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.age BETWEEN 60 AND 69 THEN '60-69'
        WHEN c.age BETWEEN 70 AND 79 THEN '70-79'
        ELSE '80+' 
    END AS age_group,
    COUNT(t.id_check) AS total_transactions,
    SUM(t.Sum_payment) AS total_payment
FROM transactions t
JOIN customers c ON t.ID_client = c.id_client
GROUP BY age_group
ORDER BY FIELD(age_group, 'NA', '0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80+');








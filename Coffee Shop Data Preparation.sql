-- Step 1: Data Cleaning
-- 1.1. Date and Time Column change

SELECT * FROM coffee_shop_sales_db.coffee_shop_sales;

UPDATE coffee_shop_sales
SET transaction_date = str_to_date(transaction_date, '%d/%m/%Y');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

DESCRIBE coffee_shop_sales;

UPDATE coffee_shop_sales
SET transaction_time = str_to_date(transaction_time, '%H:%i:%s');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

-- 1.2. Column Name Change

ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;

-- Step 2: KPIs Analysis

SELECT ROUND(SUM(unit_price * transaction_qty)) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- MAY MONTH
;

SELECT
	MONTH(transaction_date) AS month, -- Number of Month Column
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales, -- Total Sales Column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- Month Sales Difference
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- Division by Previous Month Sales
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- Percentage
FROM
	coffee_shop_sales
WHERE
	MONTH(transaction_date) IN (4,5) -- for months of April (Previous Month) and May (Current Month)
GROUP BY
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);

SELECT COUNT(transaction_id) AS total_orders
FROM coffee_shop_sales
WHERE
MONTH(transaction_date) = 3; -- THE MONTH

SELECT
	MONTH(transaction_date) AS month, -- Number of Month Column
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- Percentage
FROM 
	coffee_shop_sales
WHERE
	MONTH(transaction_date) IN (4, 5) -- for months of April (Previous Month) and May (Current Month)
GROUP BY
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);

SELECT SUM(transaction_qty) AS total_quantity_sold
FROM coffee_shop_sales
WHERE
MONTH(transaction_date) = 6; -- THE MONTH

SELECT
	MONTH(transaction_date) AS month, -- Number of Month Column
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- Percentage
FROM 
	coffee_shop_sales
WHERE
	MONTH(transaction_date) IN (4, 5) -- for months of April (Previous Month) and May (Current Month)
GROUP BY
	MONTH(transaction_date)
ORDER BY
	MONTH(transaction_date);

-- Step 3: Charts Requirements

SELECT
	CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales,
    CONCAT(ROUND(SUM(transaction_qty)/1000,1), 'K') AS total_qty_sold,
     CONCAT(ROUND(COUNT(transaction_id)/1000,1), 'K') AS total_orders
FROM coffee_shop_sales
WHERE
	transaction_date = '2023-02-01';

-- Weekends - Sat and Sun
-- Weekdays - Mon to Fri

SELECT
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
	ELSE 'Weekdays'
	END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- May Month
GROUP BY
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'Weekends'
	ELSE 'Weekdays'
    END; 
    
SELECT
	store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2), 'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- May
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC;

SELECT
	CONCAT(ROUND(AVG(total_sales)/1000,1), 'K') AS avg_sales
FROM
	(
    SELECT SUM(transaction_qty * unit_price) AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY transaction_date
    ) AS internal_query;

SELECT
	DAY(transaction_date) AS day_of_month,
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date);
    
SELECT
	day_of_month,
	CASE
		WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Equal to Average'
	END AS sales_status,
    total_sales
FROM (
	SELECT
		DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
	FROM
		coffee_shop_sales
	WHERE
		MONTH(transaction_date) = 5
	GROUP BY
		DAY(transaction_date)
) AS sales_data
ORDER BY
	day_of_month;

SELECT
	product_category,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

SELECT
	product_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 AND product_category = "Coffee"
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

SELECT
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales,
    SUM(transaction_qty) AS total_qty,
    COUNT(*) AS total_orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
AND DAYOFWEEK(transaction_date) = 2 -- Monday
AND HOUR(transaction_time) = 8 -- Hour No 8
;

SELECT
	HOUR(transaction_time),
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time) ASC;

SELECT
	CASE
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
	END AS day_of_week,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales
FROM
	coffee_shop_sales
WHERE
	MONTH(transaction_date) = 5
GROUP BY
	CASE
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
	END;
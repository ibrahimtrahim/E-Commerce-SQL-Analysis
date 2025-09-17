/*
=========================================================
Database Exploration
=========================================================
In the exploration phase, I used SQL queries to better understand the structure and content of the e-commerce database. 
The queries helped me inspect the schema, preview sample rows, check table sizes, explore customer demographics, evaluate product categories, 
analyze order values, review ratings, and detect missing data. 
This initial exploration was important to identify patterns, validate data quality, and prepare for deeper business analysis.
=========================================================
*/

-- Preview all reviews
SELECT *
FROM reviews;

-- Preview first 10 orders
SELECT TOP 10 *
FROM orders;

-- Check structure of Orders and Customers tables
EXEC sp_help 'orders';
EXEC sp_help 'customers';

-- Preview first 10 customers
SELECT TOP 10 *
FROM customers;

-- Preview first 10 products
SELECT TOP 10 *
FROM products;

-- Count total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Count total number of products
SELECT COUNT(*) AS total_products
FROM products;

-- Show all products (to explore details)
SELECT *
FROM products;

-- Count total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Number of orders per product category
SELECT product_category, COUNT(*) AS total_orders
FROM orders
GROUP BY product_category;

-- Number of customers per city
SELECT city, COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY total_customers DESC;

-- Average, maximum, and minimum order values
SELECT AVG(order_value) AS avg_order_value, MAX(order_value) AS max_order_value, MIN(order_value) AS min_order_value
FROM orders;

-- Average rating per product
SELECT product_id, AVG(rating) AS avg_rating
FROM reviews
GROUP BY product_id
ORDER BY avg_rating DESC;

-- Count how many products received the maximum rating
SELECT COUNT(DISTINCT product_id) AS product_max_rating
FROM reviews
WHERE rating = (SELECT MAX(rating) FROM Reviews);

-- Check for missing order values
SELECT COUNT(*) AS null_value
FROM orders
WHERE order_value IS NULL;

-- Check for missing ages in Customers
SELECT COUNT(*) AS missing_age
FROM customers
WHERE age IS NULL;

-- Count customers by gender
SELECT COUNT(*)
FROM customers

GROUP BY gender;

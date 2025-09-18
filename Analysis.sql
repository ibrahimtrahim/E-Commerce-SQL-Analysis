-- QUESTION 1: Revenue by product category
SELECT product_category,
       SUM(order_value)   AS total_revenue,
       COUNT(*)           AS orders_count,
       AVG(order_value)   AS avg_order_value
FROM Orders
GROUP BY product_category
ORDER BY total_revenue DESC;
/*
   INSIGHT: Electronics generate the highest revenue and average order value.
   Home and Books have fewer orders but similar revenue, showing high-value purchases.
   Recommendation: Focus marketing and stock management on Electronics and Home categories.
*/

-- QUESTION 2B: Compare average LTV by loyalty bucket
-- Step 1: Calculate each customer's lifetime value
WITH customer_ltv AS (
  SELECT 
    c.customer_id, 
    c.loyalty_score, 
    ISNULL(SUM(o.order_value),0) AS lifetime_value
  FROM Customers c
  LEFT JOIN Orders o 
    ON c.customer_id = o.customer_id
  GROUP BY c.customer_id, c.loyalty_score
)
-- Step 2: Group customers into loyalty score buckets and calculate metrics
SELECT
  CASE
    WHEN loyalty_score >= 80 THEN '80-100'
    WHEN loyalty_score >= 60 THEN '60-79'
    WHEN loyalty_score >= 40 THEN '40-59'
    WHEN loyalty_score >= 20 THEN '20-39'
    ELSE '0-19'
  END AS loyalty_bucket,               -- Create buckets based on loyalty_score
  COUNT(*) AS customers_in_bucket,     -- Number of customers in each bucket
  AVG(lifetime_value) AS avg_ltv       -- Average lifetime value per bucket
FROM customer_ltv
GROUP BY CASE
    WHEN loyalty_score >= 80 THEN '80-100'
    WHEN loyalty_score >= 60 THEN '60-79'
    WHEN loyalty_score >= 40 THEN '40-59'
    WHEN loyalty_score >= 20 THEN '20-39'
    ELSE '0-19'
END
ORDER BY loyalty_bucket DESC;          -- Sort buckets from highest to lowest
/*
INSIGHT:
Customers with loyalty scores 80–100 have the highest avg LTV (177.12),
confirming that loyalty generally correlates with higher spending.
However, customers in 20–39 (163.18) and 0–19 (160.25) buckets also spend significantly,
suggesting loyalty score does not fully capture all high-value customers.
Recommendation:
-Keep rewarding the top loyal group (80–100).
-Re-examine the loyalty scoring system.
-Target low-loyalty but high-spending customers with special campaigns to boost retention.
*/

-- QUESTION 3A: Delivered rate per customer + average rating per customer
-- Goal: To analyze whether delivery performance (delivery success rate) is linked with customer satisfaction (average ratings).

-- For each customer:
-- - Count total orders
-- - Count delivered orders
-- - Calculate delivery rate (delivered / total orders)
-- - Calculate average rating given by the customer
-- - Count number of reviews
WITH customer_delivery AS (
  SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(CASE 
          WHEN delivered = 1 THEN 1
          WHEN LOWER(CAST(delivered AS VARCHAR(10))) IN ('1','true','yes','y') THEN 1
          ELSE 0
        END) AS delivered_count
  FROM Orders
  GROUP BY customer_id
),
customer_rating AS (
  SELECT customer_id, AVG(CAST(rating AS FLOAT)) AS avg_rating, COUNT(*) AS review_count
  FROM Reviews
  GROUP BY customer_id
)
SELECT cd.customer_id,
       cd.total_orders,
       cd.delivered_count,
       CAST(cd.delivered_count AS FLOAT) / NULLIF(cd.total_orders,0) AS delivered_rate,
       cr.avg_rating,
       cr.review_count
FROM customer_delivery cd
LEFT JOIN customer_rating cr ON cd.customer_id = cr.customer_id
ORDER BY delivered_rate ASC, cr.avg_rating ASC;
/*
INSIGHT:
- Customers with perfect delivery rate (100%) tend to have higher average ratings (up to 5 stars).
- Customers with lower delivery success (≤50%) often give lower ratings, showing delivery strongly impacts satisfaction.
- A few customers with perfect delivery but low ratings may reflect product issues rather than delivery problems.
Recommendation:
Improve delivery consistency to boost ratings, while also monitoring product quality for dissatisfied customers despite good delivery.
*/

-- QUESTION 3B: Average rating for customers with all orders delivered vs some undelivered
-- Goal: Compare customer satisfaction depending on whether all their orders were delivered successfully.
WITH customer_delivery AS (
  SELECT customer_id,
         COUNT(*) AS total_orders,
         SUM(CASE WHEN delivered = 1 THEN 1
                  WHEN LOWER(CAST(delivered AS VARCHAR(10))) IN ('1','true','yes','y') THEN 1
                  ELSE 0 END) AS delivered_count
  FROM Orders
  GROUP BY customer_id
),
customer_rating AS (
  SELECT customer_id, AVG(CAST(rating AS FLOAT)) AS avg_rating
  FROM Reviews
  GROUP BY customer_id
)
SELECT 
  CASE WHEN cd.delivered_count = cd.total_orders THEN 'All Delivered' ELSE 'Some Undelivered' END AS delivery_group,
  COUNT(*) AS customers,
  AVG(cr.avg_rating) AS avg_rating
FROM customer_delivery cd
LEFT JOIN customer_rating cr ON cd.customer_id = cr.customer_id
GROUP BY CASE WHEN cd.delivered_count = cd.total_orders THEN 'All Delivered' ELSE 'Some Undelivered' END;
/*
INSIGHT:
- Both groups give nearly the same average rating (~2.95–2.98).
- Customers with all deliveries complete only show a slightly higher satisfaction.
- This suggests delivery consistency does matter, but product/service quality may have stronger influence on ratings.
Recommendation:
Focus on improving product quality and customer experience beyond delivery, 
since delivery alone does not drastically change ratings in this dataset.
*/

-- QUESTION 4: Average rating by category vs revenue by category
-- Goal: Analyze whether customer ratings are aligned with revenue performance across categories.
WITH avg_rating_by_category AS (
  SELECT p.category,
         AVG(CAST(r.rating AS FLOAT)) AS avg_rating,
         COUNT(DISTINCT r.product_id)   AS products_with_reviews,
         COUNT(r.review_id)             AS review_count
  FROM Reviews r
  JOIN Products p ON r.product_id = p.product_id
  GROUP BY p.category
),
revenue_by_category AS (
  SELECT product_category AS category,
         SUM(order_value) AS total_revenue,
         COUNT(*) AS orders_count
  FROM Orders
  GROUP BY product_category
)
SELECT r.category,
       r.total_revenue,
       r.orders_count,
       a.avg_rating,
       a.review_count
FROM revenue_by_category r
LEFT JOIN avg_rating_by_category a ON r.category = a.category
ORDER BY r.total_revenue DESC;
/*
INSIGHT:
- Electronics leads in revenue (~10.8K) but has only average ratings (2.99).
- Home products rank second in revenue and achieve the highest average rating (3.05).
- Clothing generates strong revenue but suffers from the lowest rating (2.90),
suggesting possible quality issues or customer dissatisfaction.
- Books and Beauty perform similarly, with mid-level revenue and average ratings around 2.9–3.0.
Recommendation:
Focus on improving Clothing category quality/service, since high sales are not matched by customer satisfaction.
Electronics could also increase long-term revenue by improving product experience and boosting ratings.
*/

-- QUESTION 5: Which payment methods and cities are most profitable.
-- Goal: Identify which payment methods are most profitable and popular.
-- Payment method revenue
SELECT payment_method,
       SUM(order_value) AS total_revenue,
       COUNT(*)         AS orders_count,
       AVG(order_value) AS avg_order_value
FROM Orders
GROUP BY payment_method
ORDER BY total_revenue DESC;
/*
INSIGHT:
- UPI generates the highest total revenue (~10K) and a strong average order value (~50).
- Cash has the highest number of transactions (222) but lower average order value (~44.7).
- Wallet payments are competitive in both revenue (~9.9K) and average order value (~48.5).
- Credit Cards have fewer transactions but the highest average order value (~52.1),
  suggesting high-value customers prefer this method.
- Debit Cards trail behind in both revenue and average order size.
Recommendation:
Promote UPI and Credit Card usage (discounts, rewards) to maximize revenue.
Streamline cash handling since it brings volume but less profitability.
*/

-- City revenue (join Orders -> Customers)
-- Goal: Identify the most profitable and active cities for the business.
SELECT c.city,
       SUM(o.order_value) AS total_revenue,
       COUNT(*)            AS orders_count,
       AVG(o.order_value)  AS avg_order_value
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY total_revenue DESC;
/*
INSIGHT:
- Mumbai is the top-performing city with the highest revenue (~11K) and most orders (233).
- Delhi generates the second-highest revenue (~9.3K) with the highest average order value (~52.8),
  suggesting customers here spend more per order.
- Hyderabad also shows strong performance, with high average order value (~50.8).
- Chennai, Kolkata, and Bangalore contribute similar revenues (~6.5K–7K) but have slightly lower order values.
Recommendation:
Focus marketing and loyalty programs on Delhi (high-value customers) and Mumbai (high-volume customers).
Explore growth opportunities in Hyderabad, which shows healthy order values but fewer transactions.
*/
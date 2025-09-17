# 🛒 E-Commerce SQL Analysis
![](ecommerce.jpg)
## Business Problem:
The e-commerce company is experiencing **slower sales growth** and **mixed customer satisfaction**.
Management wants to understand:
1. Which **product categories** bring the most revenue.
2. Who their **best customers** are and how loyalty impacts spending.
3. Whether **delivery performance** affects customer satisfaction.
4. How **customer reviews** and **ratings** influence product sales.
5. Which **payment methods** and **cities** are most profitable.

By answering these questions with SQL, the company can:
- Focus marketing on high-value customers.
- Improve stock management for popular products.
- Increase delivery success rate.
- Use customer feedback to improve product quality.

## Dataset Description:
The database has 4 tables:

**Orders**
- order_id  
- customer_id  
- order_date  
- product_category  
- order_value  
- payment_method  
- delivered  

**Customers**
- customer_id  
- gender  
- age  
- city  
- loyalty_score  

**Products**
- product_id  
- product_name  
- category  
- price  
- stock  

**Reviews**
- review_id  
- customer_id  
- product_id  
- rating  
- review_text

## Entity Relationship Diagram (ERD)
![](ERD.png)

## Database Exploration
During this phase, I explored the database structure and content to understand the data before analysis.
I used SQL queries to check tables, counts, averages, and missing values.
You can view all queries in the [exploration.sql](exploration.sql) 
 file.

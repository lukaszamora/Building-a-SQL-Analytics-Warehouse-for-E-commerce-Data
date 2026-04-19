-- 1. Monthly revenue
SELECT
    DATE_TRUNC('month', order_purchase_ts) AS month,
    SUM(total_payment_value) AS revenue
FROM fact_orders
GROUP BY 1
ORDER BY 1;

-- 2. Average order value by month
SELECT
    DATE_TRUNC('month', order_purchase_ts) AS month,
    AVG(total_payment_value) AS avg_order_value
FROM fact_orders
GROUP BY 1
ORDER BY 1;

-- 3. Top 10 product categories by revenue
SELECT
    p.product_category,
    SUM(oi.price) AS revenue
FROM fact_order_items oi
JOIN dim_products p
    ON oi.product_key = p.product_key
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 4. Delivered late rate
SELECT
    AVG(delivered_late_flag) AS late_delivery_rate
FROM fact_orders
WHERE delivered_customer_ts IS NOT NULL;

-- 5. Delivery time by customer state
SELECT
    c.customer_state,
    AVG(days_to_deliver) AS avg_days_to_deliver
FROM fact_orders f
JOIN dim_customers c
    ON f.customer_key = c.customer_key
WHERE days_to_deliver IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 6. Seller GMV ranking
SELECT
    s.seller_state,
    s.seller_id,
    SUM(oi.price) AS gmv,
    RANK() OVER (ORDER BY SUM(oi.price) DESC) AS seller_rank
FROM fact_order_items oi
JOIN dim_sellers s
    ON oi.seller_key = s.seller_key
GROUP BY 1, 2
ORDER BY seller_rank
LIMIT 20;

-- 7. Payment type mix
SELECT
    payment_type,
    COUNT(*) AS payment_records,
    SUM(payment_value) AS total_payment_value
FROM fact_payments
GROUP BY 1
ORDER BY 3 DESC;

-- 8. Repeat customer rate
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT f.order_id) AS order_count
    FROM fact_orders f
    JOIN dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY 1
)
SELECT
    AVG(CASE WHEN order_count > 1 THEN 1.0 ELSE 0.0 END) AS repeat_customer_rate
FROM customer_orders;

-- 9. Top customers by lifetime value
SELECT
    c.customer_unique_id,
    SUM(f.total_payment_value) AS lifetime_value,
    COUNT(DISTINCT f.order_id) AS orders
FROM fact_orders f
JOIN dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY 1
ORDER BY 2 DESC
LIMIT 20;

-- 10. Month-over-month revenue growth
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_purchase_ts) AS month,
        SUM(total_payment_value) AS revenue
    FROM fact_orders
    GROUP BY 1
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) AS mom_growth_rate
FROM monthly_revenue
ORDER BY 1;
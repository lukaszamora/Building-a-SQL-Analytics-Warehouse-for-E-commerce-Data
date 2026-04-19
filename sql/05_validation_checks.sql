-- duplicate orders in fact_orders
SELECT order_id, COUNT(*)
FROM fact_orders
GROUP BY 1
HAVING COUNT(*) > 1;

-- null customer keys
SELECT COUNT(*) AS null_customer_keys
FROM fact_orders
WHERE customer_key IS NULL;

-- order count comparison
SELECT
    (SELECT COUNT(*) FROM stg_orders) AS stg_orders_count,
    (SELECT COUNT(*) FROM fact_orders) AS fact_orders_count;

-- payment reconciliation
SELECT
    SUM(total_payment_value) AS fact_order_payments,
    (SELECT SUM(payment_value) FROM fact_payments) AS payment_table_total
FROM fact_orders;

-- orphaned order items
SELECT COUNT(*) AS orphaned_items
FROM fact_order_items
WHERE product_key IS NULL OR seller_key IS NULL;
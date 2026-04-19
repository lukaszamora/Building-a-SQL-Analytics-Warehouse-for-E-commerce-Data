CREATE OR REPLACE TABLE fact_order_items AS
SELECT
    oi.order_id,
    oi.order_item_id,
    p.product_key,
    s.seller_key,
    CAST(STRFTIME(CAST(oi.shipping_limit_ts AS DATE), '%Y%m%d') AS INTEGER) AS shipping_date_key,
    oi.price,
    oi.freight_value
FROM stg_order_items oi
LEFT JOIN dim_products p
    ON oi.product_id = p.product_id
LEFT JOIN dim_sellers s
    ON oi.seller_id = s.seller_id;

CREATE OR REPLACE TABLE fact_payments AS
SELECT
    op.order_id,
    op.payment_sequential,
    op.payment_type,
    op.payment_installments,
    op.payment_value
FROM stg_order_payments op;

CREATE OR REPLACE TABLE fact_orders AS
WITH item_agg AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        SUM(price) AS gross_item_value,
        SUM(freight_value) AS gross_freight_value
    FROM stg_order_items
    GROUP BY 1
),
payment_agg AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value
    FROM stg_order_payments
    GROUP BY 1
)
SELECT
    o.order_id,
    c.customer_key,
    CAST(STRFTIME(CAST(o.order_purchase_ts AS DATE), '%Y%m%d') AS INTEGER) AS purchase_date_key,
    o.order_status,
    o.order_purchase_ts,
    o.order_approved_ts,
    o.delivered_carrier_ts,
    o.delivered_customer_ts,
    o.estimated_delivery_ts,
    DATE_DIFF('day', CAST(o.order_purchase_ts AS DATE), CAST(o.delivered_customer_ts AS DATE)) AS days_to_deliver,
    DATE_DIFF('day', CAST(o.estimated_delivery_ts AS DATE), CAST(o.delivered_customer_ts AS DATE)) AS days_vs_estimate,
    CASE
        WHEN o.delivered_customer_ts IS NOT NULL
         AND o.estimated_delivery_ts IS NOT NULL
         AND CAST(o.delivered_customer_ts AS DATE) > CAST(o.estimated_delivery_ts AS DATE)
        THEN 1 ELSE 0
    END AS delivered_late_flag,
    COALESCE(i.item_count, 0) AS item_count,
    COALESCE(i.gross_item_value, 0) AS gross_item_value,
    COALESCE(i.gross_freight_value, 0) AS gross_freight_value,
    COALESCE(p.total_payment_value, 0) AS total_payment_value
FROM stg_orders o
LEFT JOIN dim_customers c
    ON o.customer_id = c.customer_id
LEFT JOIN item_agg i
    ON o.order_id = i.order_id
LEFT JOIN payment_agg p
    ON o.order_id = p.order_id;
CREATE OR REPLACE TABLE stg_orders AS
SELECT
    order_id,
    customer_id,
    order_status,
    CAST(order_purchase_timestamp AS TIMESTAMP) AS order_purchase_ts,
    CAST(order_approved_at AS TIMESTAMP) AS order_approved_ts,
    CAST(order_delivered_carrier_date AS TIMESTAMP) AS delivered_carrier_ts,
    CAST(order_delivered_customer_date AS TIMESTAMP) AS delivered_customer_ts,
    CAST(order_estimated_delivery_date AS TIMESTAMP) AS estimated_delivery_ts
FROM raw_orders
WHERE order_id IS NOT NULL;

CREATE OR REPLACE TABLE stg_order_items AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    CAST(shipping_limit_date AS TIMESTAMP) AS shipping_limit_ts,
    CAST(price AS DOUBLE) AS price,
    CAST(freight_value AS DOUBLE) AS freight_value
FROM raw_order_items
WHERE order_id IS NOT NULL
  AND product_id IS NOT NULL;

CREATE OR REPLACE TABLE stg_order_payments AS
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    CAST(payment_value AS DOUBLE) AS payment_value
FROM raw_order_payments
WHERE order_id IS NOT NULL;

CREATE OR REPLACE TABLE stg_products AS
SELECT
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    CAST(product_name_lenght AS INTEGER) AS product_name_length,
    CAST(product_description_lenght AS INTEGER) AS product_description_length,
    CAST(product_photos_qty AS INTEGER) AS product_photos_qty,
    CAST(product_weight_g AS DOUBLE) AS product_weight_g,
    CAST(product_length_cm AS DOUBLE) AS product_length_cm,
    CAST(product_height_cm AS DOUBLE) AS product_height_cm,
    CAST(product_width_cm AS DOUBLE) AS product_width_cm
FROM raw_products p
LEFT JOIN raw_category_translation t
    ON p.product_category_name = t.product_category_name;

CREATE OR REPLACE TABLE stg_customers AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM raw_customers
WHERE customer_id IS NOT NULL;

CREATE OR REPLACE TABLE stg_sellers AS
SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM raw_sellers
WHERE seller_id IS NOT NULL;
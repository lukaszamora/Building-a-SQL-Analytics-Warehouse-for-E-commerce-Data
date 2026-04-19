CREATE OR REPLACE TABLE dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM stg_customers;

CREATE OR REPLACE TABLE dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
    product_id,
    COALESCE(product_category_name_english, product_category_name, 'unknown') AS product_category,
    product_name_length,
    product_description_length,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM stg_products;

CREATE OR REPLACE TABLE dim_sellers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY seller_id) AS seller_key,
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM stg_sellers;

CREATE OR REPLACE TABLE dim_date AS
WITH all_dates AS (
    SELECT DISTINCT CAST(order_purchase_ts AS DATE) AS full_date
    FROM stg_orders
    WHERE order_purchase_ts IS NOT NULL
)
SELECT
    CAST(STRFTIME(full_date, '%Y%m%d') AS INTEGER) AS date_key,
    full_date,
    EXTRACT(YEAR FROM full_date) AS year,
    EXTRACT(MONTH FROM full_date) AS month,
    STRFTIME(full_date, '%B') AS month_name,
    EXTRACT(QUARTER FROM full_date) AS quarter,
    EXTRACT(DAYOFWEEK FROM full_date) AS day_of_week_num,
    STRFTIME(full_date, '%A') AS day_of_week_name
FROM all_dates;
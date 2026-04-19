-- DuckDB version
CREATE OR REPLACE TABLE raw_orders AS
SELECT * FROM read_csv_auto('data/olist_orders_dataset.csv');

CREATE OR REPLACE TABLE raw_order_items AS
SELECT * FROM read_csv_auto('data/olist_order_items_dataset.csv');

CREATE OR REPLACE TABLE raw_order_payments AS
SELECT * FROM read_csv_auto('data/olist_order_payments_dataset.csv');

CREATE OR REPLACE TABLE raw_products AS
SELECT * FROM read_csv_auto('data/olist_products_dataset.csv');

CREATE OR REPLACE TABLE raw_customers AS
SELECT * FROM read_csv_auto('data/olist_customers_dataset.csv');

CREATE OR REPLACE TABLE raw_sellers AS
SELECT * FROM read_csv_auto('data/olist_sellers_dataset.csv');

CREATE OR REPLACE TABLE raw_category_translation AS
SELECT * FROM read_csv_auto('data/product_category_name_translation.csv');
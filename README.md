# Building a SQL Analytics Warehouse for E-commerce Data

This project builds a SQL-based analytics warehouse from raw e-commerce data using the Olist marketplace dataset. The goal is to transform transactional data into a structured model that supports business reporting and analysis.

Rather than running isolated queries, this project focuses on designing a clean relational model and generating reusable business insights through SQL.

---

## Overview

E-commerce data is often spread across multiple operational tables, making direct analysis difficult. This project organizes raw marketplace data into a structured analytics layer using staging, dimension, and fact tables.

The final model supports analysis of:
- revenue trends
- customer behavior
- product performance
- seller performance
- delivery and fulfillment metrics

---

## Dataset

- Source: ![Olist Brazilian E-commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- ~100,000 orders from 2016–2018
- Multiple relational tables including:
  - orders
  - order items
  - payments
  - customers
  - products
  - sellers

---

## Data Model

![Schema Diagram](images/schema.png)

*Star-schema style analytics model. Fact tables capture orders, items, and payments, while dimension tables enable analysis by customer, product, seller, and time.*

### Fact Tables
- `fact_orders` → one row per order
- `fact_order_items` → one row per item
- `fact_payments` → one row per payment record

### Dimension Tables
- `dim_customers`
- `dim_products`
- `dim_sellers`
- `dim_date`

---

## Build Process

### 1. Raw Data Ingestion
CSV files were loaded into DuckDB using `read_csv_auto()`.

### 2. Staging Layer
Data was cleaned and standardized:
- timestamp parsing
- type casting
- column normalization
- joins for category translation

### 3. Dimensional Modeling
Dimension tables were created to provide context for analysis.

### 4. Fact Tables
Fact tables were built at appropriate grain:
- orders
- order items
- payments

Derived metrics include:
- delivery time
- late delivery flag
- total order value
- item counts

---

## Key SQL Concepts Used

- joins across multiple tables
- common table expressions (CTEs)
- window functions (`RANK`, `LAG`)
- aggregations and grouping
- date functions
- data validation checks

---

## Selected Results

### 1. Monthly Revenue Trend

| Month | Revenue |
|------|---------:|
| 2017-01 | 138,488 |
| 2017-02 | 291,908 |
| 2017-03 | 449,864 |
| 2017-08 | 674,396 |
| 2017-11 | 1,194,883 |
| 2018-01 | 1,115,004 |
| 2018-03 | 1,159,652 |
| 2018-04 | 1,160,785 |
| 2018-05 | 1,153,982 |
| 2018-08 | 1,022,425 |

**Interpretation:** Revenue grew substantially across 2017, rising from about **138K in January 2017** to nearly **1.19M in November 2017**. Revenue remained above **1.0M** for much of 2018, suggesting the marketplace reached a larger and more stable operating scale.

*Note: very small values in 2016-09, 2016-12, 2018-09, and 2018-10 appear to reflect partial periods at the edges of the dataset.*

---

### 2. Average Order Value

| Month | Avg Order Value |
|---------|--------:|
| 2017-01 | 173.11 |
| 2017-05 | 160.25 |
| 2017-11 | 158.39 |
| 2018-01 | 153.39 |
| 2018-04 | 167.28 |
| 2018-07 | 169.51 |
| 2018-08 | 157.01 |

**Interpretation:** Average order value stayed relatively stable, mostly in the **147–173** range. This suggests that overall revenue growth was driven more by **higher order volume** than by major increases in basket size.

---

### 3. Top Product Categories by Revenue

| Product Category | Revenue |
|------------------|--------:|
| health_beauty |	1,258,681 |
| watches_gifts |	1,205,006 |
| bed_bath_table |	1,036,989 |
| sports_leisure |	988,049 |
| computers_accessories |	911,954 |
| furniture_decor |	729,762 | 
| cool_stuff|	635,291 |
| housewares |	632,249 |
| auto |	592,720 |
| garden_tools |	485,256 |

**Interpretation:** Revenue is concentrated in a relatively small number of categories. **Health & Beauty** and **Watches & Gifts** each generated more than **1.2M**, while several home and lifestyle categories also performed strongly. This suggests the marketplace depends heavily on a few high-performing segments.

---

### 4. Delivery Performance by State

| Customer State | Avg Days to Deliver |
|----------------|--------------------:|
| RR |	29.34 |
| AP |	27.18 |
| AM |	26.36 |
| AL |	24.50 |
| PA |	23.73 |
| ... |	... |
| DF |	12.90 |
| MG |	11.95 |
| PR |	11.94 |
| SP |	8.70 |

**Interpretation:** Delivery times vary sharply by region. At the high end, states like **RR**, **AP**, and **AM** average **26–29** days, while **SP** averages just **8.7 days**. This points to meaningful geographic differences in logistics efficiency and shipping distance.

---

### 5. Late Delivery Rate

| Metric | Value |
|--------------|----------------:|
| Late delivery rate | 6.77% | 

**Interpretation:** About **6.8%** of delivered orders arrived after the estimated delivery date. That is not catastrophic, but it is large enough to matter operationally and could affect customer experience.

---

### 6. Payment Method Mix

| Payment Type | Payment Records | Total Payment Value |
|--------------|----------------:|--------------------:|
| credit_card |	76,795 |	12,542,084 |
| boleto |	19,784 |	2,869,361 |
| voucher |	5,775 |	379,437 |
| debit_card |	1,529 |	217,990 |
| not_defined |	3 |	0 |

**Interpretation:** The marketplace is overwhelmingly dominated by **credit card** payments, both by volume and value. **Boleto** is a meaningful secondary payment channel, while debit card and voucher usage are much smaller.

---

### 7. Repeat Customer Rate

| Metric | Value |
|--------------|----------------:|
| Repeat customer rate | 3.12% | 

**Interpretation:** Only about **3.1%** of customers placed more than one order. That suggests customer retention is relatively weak, or that the dataset reflects a business with high one-time purchase behavior.

---

### 8. Top Sellers by GMV

| Seller State | Seller Rank | GRV |
|--------------|----------------:|--------------------:|
| SP |	1 |	229,473 |
| BA |	2 |	222,776 |
| SP |	3 |	200,473 |
| SP |	4 |	194,042 |
| SP |	5 |	187,924 |

**Interpretation:** Seller performance is highly concentrated, and **São Paulo (SP)** dominates the top ranks. This suggests both seller activity and marketplace value are clustered in a small number of high-performing merchants and regions.

---

## Key Insights

- Revenue expanded dramatically during 2017, peaking at roughly **1.19M in November 2017**, and remained above **1.0M** for much of 2018.
- Average order value stayed fairly stable, which suggests that revenue growth came primarily from **order volume growth**, not larger baskets.
- A small number of categories, especially **Health & Beauty** and **Watches & Gifts**, drove a disproportionate share of revenue.
- Delivery performance varies substantially across states, with **SP** averaging **8.7 days** compared with **29.3 days** in **RR**.
- Approximately **6.8%** of delivered orders were late, indicating a measurable but not overwhelming fulfillment gap.
- Credit card payments dominate the marketplace, accounting for the vast majority of payment records and total payment value.
- Repeat customer rate is low at **3.1%**, suggesting retention may be a weaker part of the business.
- Seller performance is skewed, with top sellers and top-selling regions contributing a large share of GMV.

---

## Example Query

### Monthly Revenue

```sql
SELECT
    DATE_TRUNC('month', order_purchase_ts) AS month,
    SUM(total_payment_value) AS revenue
FROM fact_orders
GROUP BY 1
ORDER BY 1;
```

### Example Output

| Month | Revenue |
|---------|--------:|
| 2017-08 |	674,396 |
| 2017-09 |	727,762 |
| 2017-10 |	779,678 |
| 2017-11 |	1,194,883 |
| 2017-12 |	878,401 |

## Data Validation

The warehouse includes validation checks to confirm model reliability:

| Check | Result |
|---------|--------:|
| Duplicate `order_id` in `fact_orders` |	0 |
| Null `customer_key` values in `fact_orders` |	0 |
| `stg_orders` count vs `fact_orders` count |	99,441 vs 99,441 |
| Payment total reconciliation |	16.01M vs 16.01M |
| Orphaned order items |	0 |

**Interpretation:** These checks indicate that the warehouse build preserved row-level integrity, maintained key relationships, and reconciled payment values successfully.

## Project Structure

```
Building-a-SQL-Analytics-Warehouse-for-E-commerce-Data/
├── images/
│   └── schema.png
├── sql/
│   ├── 00_load_raw.sql
│   ├── 01_staging.sql
│   ├── 02_dimensions.sql
│   ├── 03_facts.sql
│   ├── 04_kpi_queries.sql
│   ├── 05_validation_checks.sql
└── run_all.sql
└── README.md
```

## Summary

This project demonstrates how raw relational marketplace data can be transformed into a structured analytics warehouse using SQL.

The resulting model supports reporting on revenue, fulfillment, customer behavior, and seller performance, and reflects a workflow much closer to real analytics engineering than isolated query practice.

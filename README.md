# Olist E-Commerce SQL Analytics

## About this project

I built this project to show how I work with a relational business dataset from raw import to business analysis. I did not start directly with top products or monthly sales. I first checked table grain, missing values, duplicate keys, relationships, timestamps and financial reconciliation so that the final KPIs were based on reliable joins.

The project uses PostgreSQL and eight Olist e-commerce tables covering customers, orders, items, payments, products, sellers, reviews and category translations.

## Main business questions

- Is the imported data structurally reliable?
- Which columns can be used as primary, composite and foreign keys?
- How can item and payment tables be joined without multiplying financial values?
- What is the overall order, customer and delivered-value performance?
- How are delivered orders and payment value changing month by month?
- Which customers are repeat buyers and which customers are most valuable?
- Which products, categories and sellers contribute most?
- How does delivery performance relate to review scores?
- What do RFM and cohort retention show about customer behaviour?
- Which indexes improve representative analytical queries?

## Most important SQL finding

The raw order-items and payment tables both contain multiple rows for the same order. A direct join can therefore create a many-to-many multiplication.

For one order used in my validation:

- Item rows: 3
- Payment rows: 21
- Direct joined rows: 63
- Correct item total: 161.32
- Correct payment total: 161.32
- Item total after unsafe join: 3,387.72
- Payment total after unsafe join: 483.96

`COUNT(DISTINCT order_id)` returned one unique order, but the monetary sums remained inflated. I solved this by aggregating items and payments separately to one row per order before joining them.

## Verified findings from my executed analysis

- Total orders: 99,441
- Delivered orders: 96,478, approximately 97.02%
- Canceled orders: 625, approximately 0.63%
- Actual unique customers: 96,096
- Delivered product value: 13,221,498.11
- Delivered freight value: 2,198,275.64
- Delivered item total: 15,419,773.75
- Delivered payment value: 15,422,461.77
- Average delivered order value: 159.83
- Delivered orders with item data: 96,478
- Delivered orders with payment data: 96,477
- Delivered exact-match orders within the selected tolerance: 96,178
- Delivered orders on time: 88,644
- Delivered orders late: 7,826
- Delivered orders missing actual delivery timestamp: 8
- 610 products were missing the same descriptive metadata block
- 2 products were missing all four physical measurements
- 383 item rows had zero freight value
- The order-level reconciliation view contains 98,362 exact matches, 303 mismatches, 775 orders missing item data and 1 order missing payment data

## Important metric decisions

- `customer_id` is used to join customers to orders.
- `customer_unique_id` is used to identify the same actual customer across different orders.
- Item total is product price plus freight charged.
- Reconciliation difference is payment value minus item total. It is not profit.
- On-time delivery means actual delivery was on or before the estimated delivery timestamp.
- RFM uses one day after the maximum purchase date in the dataset as the analysis date.

## SQL skills demonstrated

- Database and schema design
- Primary, composite and foreign keys
- `CHECK`, `NOT NULL`, `UNIQUE` and `DEFAULT`
- Joins, anti joins and safe pre-aggregation
- Subqueries, correlated subqueries and CTEs
- Conditional aggregation using `FILTER`
- Window functions including `LAG`, ranking, running totals, rolling averages and `NTILE`
- Recursive CTE for a continuous monthly calendar
- RFM segmentation and cohort retention
- Views and analytical grain control
- Indexes and `EXPLAIN ANALYZE`

## Project structure

```text
sql/01_setup              schemas, tables and constraints
sql/02_data_quality       key, relationship and quality checks
sql/03_analytics_layer    reusable order-level views
sql/04_business_analysis  KPIs, monthly trends, products, sellers and delivery
sql/05_advanced_analysis  recursive CTE, RFM and retention
sql/06_optimization       indexes and execution plans
docs/                     data dictionary, findings and interview notes
data/                     source-file instructions
```

## Execution order

Run the SQL files in folder order. The raw CSV files are not stored in this repository. Import the eight source files after running the table-creation script, then continue with constraints and analysis.

## Limitations

- The dataset is historical and anonymized.
- The dataset does not contain product cost, operating expenses, commissions or taxes, so profit is not calculated.
- Missing source categories and unmatched translations are reported, not silently replaced.
- Review-text sentiment analysis is outside this SQL-only version.
- Churn is treated as an inactivity-risk proxy, not a guaranteed future event.
- An association between delivery delay and review score does not prove causation.

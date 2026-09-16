# Interview guide

## 60-second explanation

I built an end-to-end PostgreSQL e-commerce analytics project using eight related tables. I first validated row counts, keys, table grains, missing values, foreign-key relationships and business rules. The main technical issue I found was a many-to-many multiplication between order items and payments. I resolved it by separately aggregating both tables to one row per order and then created reusable analytics views. I used those views for executive KPIs, monthly trends, customer analysis, recursive-calendar reporting, RFM, retention, seller and delivery analysis, and query optimization.

## Questions I should be ready to answer

1. Why can a foreign key repeat while a primary key cannot?
2. Why is `(order_id,order_item_id)` a composite primary key?
3. What is table grain and why should it be checked before a join?
4. Why does `COUNT(DISTINCT order_id)` not repair an inflated `SUM()`?
5. Why is `customer_unique_id` used for repeat-customer analysis?
6. Why does the financial view use a `FULL OUTER JOIN`?
7. Why is reconciliation difference not profit?
8. What is the difference between a CTE, temporary table, view and permanent table?
9. How does the recursive CTE stop, and what happens if the stop condition is missing?
10. Why does a missing month make a normal `LAG()` result potentially misleading?
11. How were RFM scoring and the analysis date chosen?
12. What is the correct denominator for cohort retention?
13. Why are foreign-key columns indexed separately?
14. What did `EXPLAIN ANALYZE` show before and after indexing?

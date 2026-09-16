CREATE OR REPLACE VIEW analytics.order_item_summary AS
SELECT order_id,
       COUNT(*) AS total_item_id,
       SUM(price) AS total_price,
       SUM(freight_value) AS total_freight,
       SUM(price+freight_value) AS item_total_value
FROM raw.order_items
GROUP BY order_id;

CREATE OR REPLACE VIEW analytics.order_payment_summary AS
SELECT order_id,
       COUNT(*) AS payment_rows,
       COUNT(DISTINCT payment_type) AS payment_methods_count,
       SUM(payment_value) AS payment_value
FROM raw.order_payments
GROUP BY order_id;

CREATE OR REPLACE VIEW analytics.order_financials AS
SELECT COALESCE(oi.order_id,ps.order_id) AS order_id,
       oi.total_item_id, oi.total_price, oi.total_freight, oi.item_total_value,
       ps.payment_rows, ps.payment_methods_count, ps.payment_value,
       ROUND(ps.payment_value-oi.item_total_value,2) AS reconciliation_difference,
       CASE
           WHEN oi.order_id IS NULL THEN 'missing_item_data'
           WHEN ps.order_id IS NULL THEN 'missing_payment_data'
           WHEN ABS(ps.payment_value-oi.item_total_value)<=0.01 THEN 'Exact match'
           ELSE 'Mismatch'
       END AS reconciliation_status
FROM analytics.order_item_summary AS oi
FULL OUTER JOIN analytics.order_payment_summary AS ps ON oi.order_id=ps.order_id;

CREATE OR REPLACE VIEW analytics.order_review_summary AS
SELECT order_id,
       COUNT(*) AS review_rows,
       COUNT(DISTINCT review_id) AS distinct_review_id,
       ROUND(AVG(review_score),2) AS avg_review_score,
       MIN(review_score) AS min_review_score,
       MAX(review_score) AS max_review_score,
       MAX(review_answer_timestamp) AS latest_review_ans_timestamp
FROM raw.order_reviews
GROUP BY order_id;

CREATE OR REPLACE VIEW analytics.delivery_performance AS
SELECT order_id, order_status, order_purchase_timestamp, order_approved_at,
       order_delivered_carrier_date, order_delivered_customer_date,
       order_estimated_delivery_date,
       EXTRACT(EPOCH FROM (order_delivered_customer_date-order_purchase_timestamp))/86400.0 AS delivery_days,
       EXTRACT(EPOCH FROM (order_delivered_customer_date-order_estimated_delivery_date))/86400.0 AS delay_days,
       CASE
           WHEN order_delivered_customer_date IS NULL THEN 'missing_date'
           WHEN order_delivered_customer_date<=order_estimated_delivery_date THEN 'on time'
           ELSE 'late'
       END AS delivery_status,
       CASE
           WHEN order_purchase_timestamp>order_approved_at
             OR order_approved_at>order_delivered_carrier_date
             OR order_delivered_carrier_date>order_delivered_customer_date
           THEN TRUE ELSE FALSE
       END AS invalid_lifecycle_flag
FROM raw.orders;

CREATE OR REPLACE VIEW analytics.customer_order_history AS
SELECT c.customer_unique_id, c.customer_id, c.customer_city, c.customer_state,
       o.order_id, o.order_status, o.order_purchase_timestamp,
       f.total_price, f.total_freight, f.item_total_value,
       f.payment_value, f.reconciliation_status
FROM raw.customers AS c
INNER JOIN raw.orders AS o ON c.customer_id=o.customer_id
LEFT JOIN analytics.order_financials AS f ON o.order_id=f.order_id;

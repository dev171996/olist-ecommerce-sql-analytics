SELECT delivery_status,
       COUNT(*) AS total_orders,
       ROUND(AVG(delay_days),2) AS avg_delay_days,
       ROUND(AVG(r.avg_review_score),2) AS avg_review_score
FROM analytics.delivery_performance AS d
LEFT JOIN analytics.order_review_summary AS r ON d.order_id=r.order_id
WHERE d.order_status='delivered'
GROUP BY delivery_status
ORDER BY total_orders DESC;

WITH late_orders AS
(
    SELECT order_id,
           EXTRACT(EPOCH FROM (order_delivered_customer_date-order_estimated_delivery_date))/86400.0 AS delay_days
    FROM raw.orders
    WHERE order_status='delivered'
      AND order_delivered_customer_date>order_estimated_delivery_date
),
delay_bucket AS
(
    SELECT order_id, delay_days,
           CASE
               WHEN delay_days<1 THEN 'Less than 1 day'
               WHEN delay_days<=3 THEN '1 to 3 days'
               WHEN delay_days<=7 THEN '4 to 7 days'
               WHEN delay_days<=15 THEN '8 to 15 days'
               ELSE 'More than 15 days'
           END AS delay_category
    FROM late_orders
)
SELECT delay_category, COUNT(*) AS late_order_count,
       ROUND(100.0*COUNT(*)/NULLIF(SUM(COUNT(*)) OVER (),0),2) AS late_order_percentage
FROM delay_bucket
GROUP BY delay_category
ORDER BY late_order_count DESC;

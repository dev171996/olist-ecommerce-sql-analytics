WITH analysis_date AS
(
    SELECT MAX(order_purchase_timestamp)::DATE+1 AS as_of_date
    FROM raw.orders
),
customer_metrics AS
(
    SELECT customer_unique_id,
           a.as_of_date-MAX(order_purchase_timestamp)::DATE AS recency_days,
           COUNT(DISTINCT order_id) AS frequency_orders,
           SUM(payment_value) AS monetary_value
    FROM analytics.customer_order_history
    CROSS JOIN analysis_date AS a
    WHERE order_status='delivered'
      AND payment_value IS NOT NULL
    GROUP BY customer_unique_id,a.as_of_date
),
rfm_score AS
(
    SELECT *,
           6-NTILE(5) OVER (ORDER BY recency_days) AS r_score,
           NTILE(5) OVER (ORDER BY frequency_orders) AS f_score,
           NTILE(5) OVER (ORDER BY monetary_value) AS m_score
    FROM customer_metrics
)
SELECT *,
       CASE
           WHEN r_score>=4 AND f_score>=4 AND m_score>=4 THEN 'Champions'
           WHEN r_score>=3 AND f_score>=3 THEN 'Loyal Customers'
           WHEN r_score>=4 AND f_score<=2 THEN 'Potential Loyalists'
           WHEN r_score<=2 AND f_score>=3 THEN 'At Risk'
           WHEN r_score=1 AND f_score<=2 THEN 'Likely Lost'
           ELSE 'Needs Attention'
       END AS rfm_segment
FROM rfm_score
ORDER BY monetary_value DESC;

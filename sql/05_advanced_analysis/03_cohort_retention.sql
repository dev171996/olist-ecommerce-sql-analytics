WITH customer_month AS
(
    SELECT DISTINCT customer_unique_id,
           DATE_TRUNC('month',order_purchase_timestamp)::DATE AS activity_month
    FROM analytics.customer_order_history
    WHERE order_status='delivered'
),
customer_cohort AS
(
    SELECT customer_unique_id, MIN(activity_month) AS cohort_month
    FROM customer_month
    GROUP BY customer_unique_id
),
cohort_activity AS
(
    SELECT m.customer_unique_id, c.cohort_month, m.activity_month,
           (EXTRACT(YEAR FROM AGE(m.activity_month,c.cohort_month))*12
            +EXTRACT(MONTH FROM AGE(m.activity_month,c.cohort_month)))::INTEGER AS cohort_index
    FROM customer_month AS m
    INNER JOIN customer_cohort AS c USING(customer_unique_id)
),
retention_count AS
(
    SELECT cohort_month, cohort_index,
           COUNT(DISTINCT customer_unique_id) AS retained_customers
    FROM cohort_activity
    GROUP BY cohort_month,cohort_index
),
cohort_size AS
(
    SELECT cohort_month,
           MAX(retained_customers) FILTER (WHERE cohort_index=0) AS total_customers
    FROM retention_count
    GROUP BY cohort_month
)
SELECT r.cohort_month, r.cohort_index, r.retained_customers, s.total_customers,
       ROUND(100.0*r.retained_customers/NULLIF(s.total_customers,0),2) AS retention_percentage
FROM retention_count AS r
INNER JOIN cohort_size AS s USING(cohort_month)
ORDER BY r.cohort_month,r.cohort_index;

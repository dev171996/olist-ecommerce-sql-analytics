-- Continuous monthly calendar. This keeps calendar months that are absent from the source result.
WITH RECURSIVE date_range AS
(
    SELECT DATE_TRUNC('month',MIN(order_purchase_timestamp))::DATE AS first_month,
           DATE_TRUNC('month',MAX(order_purchase_timestamp))::DATE AS last_month
    FROM raw.orders
),
month_calendar AS
(
    SELECT first_month AS order_month, last_month
    FROM date_range

    UNION ALL

    SELECT (order_month+INTERVAL '1 month')::DATE, last_month
    FROM month_calendar
    WHERE order_month<last_month
),
monthly_actual AS
(
    SELECT DATE_TRUNC('month',order_purchase_timestamp)::DATE AS order_month,
           COUNT(*) FILTER (WHERE order_status='delivered') AS delivered_orders,
           SUM(payment_value) FILTER (WHERE order_status='delivered') AS monthly_payment_value
    FROM analytics.customer_order_history
    GROUP BY DATE_TRUNC('month',order_purchase_timestamp)::DATE
),
continuous_months AS
(
    SELECT c.order_month,
           COALESCE(a.delivered_orders,0) AS delivered_orders,
           COALESCE(a.monthly_payment_value,0) AS monthly_payment_value
    FROM month_calendar AS c
    LEFT JOIN monthly_actual AS a ON c.order_month=a.order_month
),
with_previous_month AS
(
    SELECT *,
           LAG(monthly_payment_value) OVER (ORDER BY order_month) AS previous_month_payment_value
    FROM continuous_months
)
SELECT order_month, delivered_orders,
       ROUND(monthly_payment_value,2) AS monthly_payment_value,
       ROUND(previous_month_payment_value,2) AS previous_month_payment_value,
       ROUND(100.0*(monthly_payment_value-previous_month_payment_value)
             /NULLIF(previous_month_payment_value,0),2) AS mom_growth_percentage,
       ROUND(SUM(monthly_payment_value) OVER
             (ORDER BY order_month ROWS UNBOUNDED PRECEDING),2) AS running_payment_value,
       ROUND(AVG(monthly_payment_value) OVER
             (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS rolling_3_month_payment_value
FROM with_previous_month
ORDER BY order_month;

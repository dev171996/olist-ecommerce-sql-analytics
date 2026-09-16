WITH monthly_financials AS
(
    SELECT DATE_TRUNC('month',order_purchase_timestamp)::DATE AS order_month,
           COUNT(*) AS delivered_orders,
           SUM(total_price) AS monthly_product_value,
           SUM(total_freight) AS monthly_freight_value,
           SUM(item_total_value) AS monthly_item_total_value,
           SUM(payment_value) AS monthly_payment_value,
           AVG(item_total_value) AS avg_order_item_value
    FROM analytics.customer_order_history
    WHERE order_status='delivered'
    GROUP BY DATE_TRUNC('month',order_purchase_timestamp)::DATE
),
with_previous_month AS
(
    SELECT *,
           LAG(monthly_payment_value) OVER (ORDER BY order_month) AS previous_month_payment_value
    FROM monthly_financials
)
SELECT order_month, delivered_orders,
       ROUND(monthly_product_value,2) AS monthly_product_value,
       ROUND(monthly_freight_value,2) AS monthly_freight_value,
       ROUND(monthly_item_total_value,2) AS monthly_item_total_value,
       ROUND(monthly_payment_value,2) AS monthly_payment_value,
       ROUND(avg_order_item_value,2) AS avg_order_item_value,
       ROUND(previous_month_payment_value,2) AS previous_month_payment_value,
       ROUND(monthly_payment_value-previous_month_payment_value,2) AS payment_value_change,
       ROUND(100.0*(monthly_payment_value-previous_month_payment_value)
             /NULLIF(previous_month_payment_value,0),2) AS mom_growth_percentage
FROM with_previous_month
ORDER BY order_month;

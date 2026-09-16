SELECT COUNT(*) AS total_orders,
       COUNT(*) FILTER (WHERE order_status='delivered') AS delivered_orders,
       COUNT(*) FILTER (WHERE order_status='canceled') AS canceled_orders,
       COUNT(DISTINCT customer_unique_id) AS unique_customers,
       ROUND(100.0*COUNT(*) FILTER (WHERE order_status='delivered')/NULLIF(COUNT(*),0),2) AS delivered_order_percentage,
       ROUND(100.0*COUNT(*) FILTER (WHERE order_status='canceled')/NULLIF(COUNT(*),0),2) AS canceled_order_percentage
FROM analytics.customer_order_history;

SELECT COUNT(*) AS delivered_orders,
       ROUND(SUM(total_price),2) AS delivered_product_value,
       ROUND(SUM(total_freight),2) AS delivered_freight_value,
       ROUND(SUM(item_total_value),2) AS delivered_item_total_value,
       ROUND(SUM(payment_value),2) AS delivered_payment_value,
       ROUND(AVG(item_total_value),2) AS average_delivered_order_value,
       ROUND(SUM(payment_value)-SUM(item_total_value),2) AS delivered_reconciliation_difference
FROM analytics.customer_order_history
WHERE order_status='delivered';

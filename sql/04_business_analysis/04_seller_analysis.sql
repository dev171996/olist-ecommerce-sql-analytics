WITH seller_orders AS
(
    SELECT oi.seller_id,
           COUNT(DISTINCT oi.order_id) AS total_orders,
           SUM(oi.price) AS product_value,
           SUM(oi.freight_value) AS freight_value,
           COUNT(DISTINCT oi.order_id) FILTER
               (WHERE o.order_delivered_customer_date>o.order_estimated_delivery_date) AS late_orders,
           AVG(r.avg_review_score) AS avg_review_score
    FROM raw.order_items AS oi
    INNER JOIN raw.orders AS o ON oi.order_id=o.order_id
    LEFT JOIN analytics.order_review_summary AS r ON oi.order_id=r.order_id
    WHERE o.order_status='delivered'
    GROUP BY oi.seller_id
)
SELECT seller_id, total_orders,
       ROUND(product_value,2) AS product_value,
       ROUND(freight_value,2) AS freight_value,
       late_orders,
       ROUND(100.0*late_orders/NULLIF(total_orders,0),2) AS late_order_percentage,
       ROUND(avg_review_score,2) AS avg_review_score,
       DENSE_RANK() OVER (ORDER BY product_value DESC) AS seller_value_rank
FROM seller_orders
ORDER BY product_value DESC;

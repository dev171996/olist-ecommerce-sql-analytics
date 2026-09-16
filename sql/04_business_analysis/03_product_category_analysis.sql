WITH category_summary AS
(
    SELECT COALESCE(t.product_category_name_english,p.product_category_name,'unknown') AS category_name,
           COUNT(DISTINCT oi.order_id) AS total_orders,
           SUM(oi.price) AS product_value,
           SUM(oi.freight_value) AS freight_value
    FROM raw.order_items AS oi
    INNER JOIN raw.orders AS o ON oi.order_id=o.order_id
    INNER JOIN raw.products AS p ON oi.product_id=p.product_id
    LEFT JOIN raw.product_category_translation AS t
        ON p.product_category_name=t.product_category_name
    WHERE o.order_status='delivered'
    GROUP BY COALESCE(t.product_category_name_english,p.product_category_name,'unknown')
)
SELECT category_name, total_orders,
       ROUND(product_value,2) AS product_value,
       ROUND(freight_value,2) AS freight_value,
       ROUND(100.0*product_value/SUM(product_value) OVER (),2) AS value_contribution_percentage,
       DENSE_RANK() OVER (ORDER BY product_value DESC) AS category_rank,
       ROUND(100.0*SUM(product_value) OVER (ORDER BY product_value DESC ROWS UNBOUNDED PRECEDING)
             /SUM(product_value) OVER (),2) AS cumulative_value_percentage
FROM category_summary
ORDER BY product_value DESC;

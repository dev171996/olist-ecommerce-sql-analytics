-- Table inventory
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM raw.customers
UNION ALL SELECT 'orders', COUNT(*) FROM raw.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM raw.order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM raw.order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM raw.order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM raw.products
UNION ALL SELECT 'sellers', COUNT(*) FROM raw.sellers
UNION ALL SELECT 'product_category_translation', COUNT(*) FROM raw.product_category_translation;

-- Single-key health example
SELECT COUNT(*) AS total_rows,
       COUNT(order_id) AS non_null_order_ids,
       COUNT(DISTINCT order_id) AS distinct_order_ids,
       COUNT(*) FILTER (WHERE order_id IS NULL OR TRIM(order_id)='') AS missing_order_ids,
       COUNT(order_id)-COUNT(DISTINCT order_id) AS duplicate_order_rows
FROM raw.orders;

-- Composite-key health
SELECT COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE order_id IS NOT NULL AND order_item_id IS NOT NULL) AS complete_key_rows,
       COUNT(DISTINCT (order_id,order_item_id)) AS distinct_composite_keys,
       COUNT(*) FILTER (WHERE order_id IS NOT NULL AND order_item_id IS NOT NULL)
         - COUNT(DISTINCT (order_id,order_item_id)) AS duplicate_composite_rows
FROM raw.order_items;

-- Core orphan checks
SELECT COUNT(*) AS orphan_orders
FROM raw.orders AS o
LEFT JOIN raw.customers AS c ON o.customer_id=c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS orphan_order_items
FROM raw.order_items AS oi
LEFT JOIN raw.orders AS o ON oi.order_id=o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS orphan_payments
FROM raw.order_payments AS p
LEFT JOIN raw.orders AS o ON p.order_id=o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS orphan_reviews
FROM raw.order_reviews AS r
LEFT JOIN raw.orders AS o ON r.order_id=o.order_id
WHERE o.order_id IS NULL;

-- Product completeness
SELECT COUNT(*) AS total_products,
       COUNT(*) FILTER (WHERE product_category_name IS NULL OR TRIM(product_category_name)='') AS missing_category,
       COUNT(*) FILTER (WHERE product_name_length IS NULL) AS missing_name_length,
       COUNT(*) FILTER (WHERE product_description_length IS NULL) AS missing_description_length,
       COUNT(*) FILTER (WHERE product_photos_qty IS NULL) AS missing_photos,
       COUNT(*) FILTER (WHERE product_weight_g IS NULL) AS missing_weight,
       COUNT(*) FILTER (WHERE product_length_cm IS NULL) AS missing_length,
       COUNT(*) FILTER (WHERE product_height_cm IS NULL) AS missing_height,
       COUNT(*) FILTER (WHERE product_width_cm IS NULL) AS missing_width
FROM raw.products;

-- Order lifecycle quality
SELECT order_status, COUNT(*) AS total_orders,
       COUNT(*) FILTER (WHERE order_approved_at IS NULL) AS missing_approval,
       COUNT(*) FILTER (WHERE order_delivered_carrier_date IS NULL) AS missing_carrier,
       COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS missing_customer_delivery
FROM raw.orders
GROUP BY order_status
ORDER BY total_orders DESC;

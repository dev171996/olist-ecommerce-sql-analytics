-- Replace the sample customer ID with an existing value before running.
EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM raw.orders
WHERE customer_id='replace_with_existing_customer_id';

CREATE INDEX IF NOT EXISTS idx_orders_customer_id
    ON raw.orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_purchase_timestamp
    ON raw.orders(order_purchase_timestamp);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id
    ON raw.order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_seller_id
    ON raw.order_items(seller_id);
CREATE INDEX IF NOT EXISTS idx_order_payments_order_id
    ON raw.order_payments(order_id);
CREATE INDEX IF NOT EXISTS idx_order_reviews_order_id
    ON raw.order_reviews(order_id);

EXPLAIN (ANALYZE,BUFFERS)
SELECT *
FROM raw.orders
WHERE customer_id='replace_with_existing_customer_id';

-- Replace this customer ID with an existing customer_id
-- before running the performance test.

-- Remove only the test index so that the first plan
-- represents performance before indexing.

DROP INDEX IF EXISTS raw.idx_orders_customer_id;


-- Performance before index

EXPLAIN (ANALYZE, BUFFERS)

SELECT *
FROM raw.orders
WHERE customer_id = 'replace_with_existing_customer_id';


-- Index for frequent customer-level filtering and joins

CREATE INDEX idx_orders_customer_id
ON raw.orders(customer_id);


-- Performance after index
-- The query is intentionally kept exactly the same
-- for a fair comparison.

EXPLAIN (ANALYZE, BUFFERS)

SELECT *
FROM raw.orders
WHERE customer_id = 'replace_with_existing_customer_id';


-- Additional useful indexes for analytical filtering and joins

CREATE INDEX IF NOT EXISTS idx_orders_purchase_timestamp
ON raw.orders(order_purchase_timestamp);

CREATE INDEX IF NOT EXISTS idx_order_items_product_id
ON raw.order_items(product_id);

CREATE INDEX IF NOT EXISTS idx_order_items_seller_id
ON raw.order_items(seller_id);

# Data dictionary

## raw.customers
Customer master used to connect orders and identify actual customers.

- `customer_id`: order-level customer key used for joins
- `customer_unique_id`: actual customer identifier used for repeat and RFM analysis
- `customer_zip_code_prefex`: source column spelling retained in this project
- `customer_city`, `customer_state`: customer geography

## raw.orders
One row per order. Contains status and lifecycle timestamps.

## raw.order_items
One row per `(order_id, order_item_id)`. Contains product, seller, price and freight.

## raw.order_payments
One row per `(order_id, payment_sequential)`. Contains payment method, installments and value.

## raw.order_reviews
One row per validated `(order_id, review_id)` source record. Contains score, comments and timestamps.

## raw.products
Product category, descriptive metadata and physical measurements.

## raw.sellers
Seller identifier and location.

## raw.product_category_translation
Portuguese-to-English product-category mapping.

-- Run after importing and validating the source data.

ALTER TABLE raw.customers
    ADD CONSTRAINT pk_customer PRIMARY KEY (customer_id);
ALTER TABLE raw.orders
    ADD CONSTRAINT pk_orders_id PRIMARY KEY (order_id);
ALTER TABLE raw.products
    ADD CONSTRAINT pk_product_id PRIMARY KEY (product_id);
ALTER TABLE raw.sellers
    ADD CONSTRAINT pk_seller_id PRIMARY KEY (seller_id);
ALTER TABLE raw.product_category_translation
    ADD CONSTRAINT pk_product_category_translation PRIMARY KEY (product_category_name);

ALTER TABLE raw.order_items
    ADD CONSTRAINT pk_order_item PRIMARY KEY (order_id, order_item_id);
ALTER TABLE raw.order_payments
    ADD CONSTRAINT pk_order_payment PRIMARY KEY (order_id, payment_sequential);
ALTER TABLE raw.order_reviews
    ADD CONSTRAINT pk_order_reviews PRIMARY KEY (order_id, review_id);

ALTER TABLE raw.orders
    ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id)
    REFERENCES raw.customers(customer_id);
ALTER TABLE raw.order_items
    ADD CONSTRAINT fk_order_items_orders FOREIGN KEY (order_id)
    REFERENCES raw.orders(order_id);
ALTER TABLE raw.order_items
    ADD CONSTRAINT fk_order_items_products FOREIGN KEY (product_id)
    REFERENCES raw.products(product_id);
ALTER TABLE raw.order_items
    ADD CONSTRAINT fk_order_items_sellers FOREIGN KEY (seller_id)
    REFERENCES raw.sellers(seller_id);
ALTER TABLE raw.order_payments
    ADD CONSTRAINT fk_order_payments_orders FOREIGN KEY (order_id)
    REFERENCES raw.orders(order_id);
ALTER TABLE raw.order_reviews
    ADD CONSTRAINT fk_order_review_orders FOREIGN KEY (order_id)
    REFERENCES raw.orders(order_id);

ALTER TABLE raw.order_reviews
    ADD CONSTRAINT chk_order_review_score CHECK (review_score BETWEEN 1 AND 5);
ALTER TABLE raw.order_reviews
    ALTER COLUMN review_score SET NOT NULL;
ALTER TABLE raw.order_items
    ADD CONSTRAINT chk_order_items_price_positive CHECK (price > 0);
ALTER TABLE raw.order_items
    ADD CONSTRAINT chk_order_items_freight_nonnegative CHECK (freight_value >= 0);
ALTER TABLE raw.order_payments
    ADD CONSTRAINT chk_order_payment_seq_positive CHECK (payment_sequential > 0);
ALTER TABLE raw.order_payments
    ADD CONSTRAINT chk_order_payment_nonnegative CHECK (payment_value >= 0);
ALTER TABLE raw.order_payments
    ADD CONSTRAINT chk_order_payment_installment_nonnegative CHECK (payment_installment >= 0);

SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'raw'
  AND (constraint_type IN ('PRIMARY KEY','FOREIGN KEY') OR constraint_name LIKE 'chk%')
ORDER BY table_name, constraint_type, constraint_name;

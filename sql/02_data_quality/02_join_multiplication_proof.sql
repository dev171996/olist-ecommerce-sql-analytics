-- The order below has 3 item rows and 21 payment rows.
-- It is used to show why both detail tables should not be summed after a direct join.

SELECT order_id, COUNT(*) AS item_rows,
       SUM(price) AS product_value,
       SUM(freight_value) AS freight_value,
       SUM(price+freight_value) AS correct_item_total
FROM raw.order_items
WHERE order_id='895ab968e7bb0d5659d16cd74cd1650c'
GROUP BY order_id;

SELECT order_id, COUNT(*) AS payment_rows,
       SUM(payment_value) AS correct_payment_total
FROM raw.order_payments
WHERE order_id='895ab968e7bb0d5659d16cd74cd1650c'
GROUP BY order_id;

SELECT COUNT(*) AS joined_rows,
       COUNT(DISTINCT oi.order_id) AS distinct_order_count,
       SUM(oi.price+oi.freight_value) AS inflated_item_total,
       SUM(p.payment_value) AS inflated_payment_total
FROM raw.order_items AS oi
INNER JOIN raw.order_payments AS p ON oi.order_id=p.order_id
WHERE oi.order_id='895ab968e7bb0d5659d16cd74cd1650c';

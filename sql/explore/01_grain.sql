-- Grain checks: if rows == distinct_keys, the key is unique (it IS the grain).


SELECT
    'orders.order_id' AS check_name,
    COUNT(*) AS rows,
    COUNT(DISTINCT order_id) AS distinct_keys
FROM orders

UNION ALL

SELECT
    'order_items.order_id',
    COUNT(*),
    COUNT(DISTINCT order_id)
FROM order_items

UNION ALL

SELECT
    'order_items.(order_id, order_item_id)',
    COUNT(*),
    COUNT(DISTINCT (order_id, order_item_id))
FROM order_items

UNION ALL

SELECT
    'payments.order_id',
    COUNT(*),
    COUNT(DISTINCT order_id)
FROM payments

UNION ALL

SELECT
    'reviews.review_id',
    COUNT(*),
    COUNT(DISTINCT review_id)
FROM reviews

UNION ALL

SELECT
    'reviews.order_id',
    COUNT(*),
    COUNT(DISTINCT order_id)
FROM reviews

UNION ALL

SELECT
    'customers.customer_id',
    COUNT(*),
    COUNT(DISTINCT customer_id)
FROM customers

UNION ALL

SELECT
    'customers.customer_unique_id',
    COUNT(*),
    COUNT(DISTINCT customer_unique_id)
FROM customers;

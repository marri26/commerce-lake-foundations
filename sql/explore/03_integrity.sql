SELECT
    'orders -> customers (customer_id)' AS check_name,
    COUNT(*) AS orphan_rows
FROM orders c
ANTI JOIN customers p USING (customer_id)

UNION ALL

SELECT
    'order_items -> orders (order_id)',
    COUNT(*)
FROM order_items c
ANTI JOIN orders p USING (order_id)

UNION ALL

SELECT
    'order_items -> products (product_id)',
    COUNT(*)
FROM order_items c
ANTI JOIN products p USING (product_id)

UNION ALL

SELECT
    'order_items -> sellers (seller_id)',
    COUNT(*)
FROM order_items c
ANTI JOIN sellers p USING (seller_id)

UNION ALL

SELECT
    'payments -> orders (order_id)',
    COUNT(*)
FROM payments c
ANTI JOIN orders p USING (order_id)

UNION ALL

SELECT
    'reviews -> orders (order_id)',
    COUNT(*)
FROM reviews c
ANTI JOIN orders p USING (order_id)

UNION ALL

SELECT
    'products -> category_translation (product_category_name)',
    COUNT(*)
FROM products c
ANTI JOIN category_translation p
    USING (product_category_name)

UNION ALL

SELECT
    'customers -> geolocation (zip_code_prefix)',
    COUNT(*)
FROM customers c
ANTI JOIN geolocation p
    ON c.customer_zip_code_prefix = p.geolocation_zip_code_prefix;

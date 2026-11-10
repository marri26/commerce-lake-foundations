CREATE OR REPLACE VIEW order_revenue AS
WITH items_per_order AS (
    -- 112,650 item rows -> one row per order
    SELECT
        order_id,
        sum(price) AS gmv,
        sum(price + freight_value) AS order_revenue,
        count(*) AS n_items
    FROM order_items
    GROUP BY order_id
),

payments_per_order AS (
    -- 103,886 payment rows -> one row per order
    SELECT
        order_id,
        sum(payment_value) AS cash_collected,
        count(*) AS n_payments,
        max(payment_installments) AS max_installments
    FROM payments
    GROUP BY order_id
)

SELECT
    o.order_id,
    o.order_status,
    -- Sao Paulo local calendar date (source timestamps carry no time zone)
    o.order_purchase_timestamp::DATE AS purchase_date,
    coalesce(i.gmv, 0) AS gmv,
    coalesce(i.order_revenue, 0) AS order_revenue,
    coalesce(p.cash_collected, 0) AS cash_collected,
    coalesce(i.n_items, 0) AS n_items,
    coalesce(p.n_payments, 0) AS n_payments,
    p.max_installments
-- orders drives the grain: exactly one row per order
FROM orders AS o
-- LEFT joins keep the 775 item-less orders and the 1 payment-less order
LEFT JOIN items_per_order AS i USING (order_id)
LEFT JOIN payments_per_order AS p USING (order_id);


-- Guard: no fan-out. Expect 99441 | 99441
SELECT
    count(*) AS rows,
    count(DISTINCT order_id) AS distinct_orders
FROM order_revenue;



-- B1. Whole-dataset totals for the three measures

SELECT
    round(sum(gmv), 2) AS gmv,
    round(sum(order_revenue), 2) AS order_revenue,
    round(sum(cash_collected), 2) AS cash_collected
FROM order_revenue;


-- Busiest purchase days

SELECT
    purchase_date,
    count(*) AS orders,
    round(sum(gmv), 2) AS gmv,
    round(sum(order_revenue), 2) AS order_revenue,
    round(sum(cash_collected), 2) AS cash_collected
FROM order_revenue
GROUP BY purchase_date
ORDER BY orders DESC
LIMIT 3;


SELECT
    order_status,
    count(*) AS orders,
    round(sum(order_revenue), 2) AS order_revenue,
    round(sum(cash_collected), 2) AS cash_collected
FROM order_revenue
WHERE purchase_date = DATE '2017-11-24'
GROUP BY order_status
ORDER BY orders DESC;



SELECT
    order_status,
    count(*) AS orders,
    round(sum(cash_collected), 2) AS cash_collected
FROM order_revenue
WHERE n_items = 0
GROUP BY order_status
ORDER BY cash_collected DESC;


-- Where cash and revenue disagree (orders with items, 0.01 tolerance)

SELECT
    CASE
        WHEN cash_collected - order_revenue > 0.01 THEN 'cash > revenue'
        ELSE 'cash < revenue'
    END AS direction,
    count(*) AS orders,
    count(*) FILTER (WHERE max_installments > 1) AS on_instalments,
    round(sum(cash_collected - order_revenue), 2) AS total_difference
FROM order_revenue
WHERE
    n_items > 0
    AND abs(cash_collected - order_revenue) > 0.01
GROUP BY direction;


-- Data edges: sparse start, truncated end

SELECT
    strftime(purchase_date, '%Y-%m') AS month,
    count(*) AS orders
FROM order_revenue
WHERE
    purchase_date < DATE '2017-01-01'
    OR purchase_date >= DATE '2018-08-01'
GROUP BY month
ORDER BY month;


-- Daily revenue v1 (the definition in docs/metrics.md)

SELECT
    purchase_date,
    count(*) AS orders,
    round(sum(order_revenue), 2) AS daily_revenue_brl
FROM order_revenue
WHERE order_status NOT IN ('canceled', 'unavailable')
GROUP BY purchase_date
ORDER BY purchase_date;

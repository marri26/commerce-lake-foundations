-- 00_views.sql
-- Named views over the raw Olist CSVs, so we can write `FROM orders`
-- instead of a file path. Views store only the query, never a copy of data.
-- Paths are RELATIVE: always start duckdb from the project root.

CREATE OR REPLACE VIEW customers    AS SELECT * FROM read_csv('data/source/olist/olist_customers_dataset.csv');
CREATE OR REPLACE VIEW geolocation  AS SELECT * FROM read_csv('data/source/olist/olist_geolocation_dataset.csv');
CREATE OR REPLACE VIEW orders       AS SELECT * FROM read_csv('data/source/olist/olist_orders_dataset.csv');
CREATE OR REPLACE VIEW order_items  AS SELECT * FROM read_csv('data/source/olist/olist_order_items_dataset.csv');
CREATE OR REPLACE VIEW payments     AS SELECT * FROM read_csv('data/source/olist/olist_order_payments_dataset.csv');
CREATE OR REPLACE VIEW reviews      AS SELECT * FROM read_csv('data/source/olist/olist_order_reviews_dataset.csv');
CREATE OR REPLACE VIEW products     AS SELECT * FROM read_csv('data/source/olist/olist_products_dataset.csv');
CREATE OR REPLACE VIEW sellers      AS SELECT * FROM read_csv('data/source/olist/olist_sellers_dataset.csv');
CREATE OR REPLACE VIEW category_translation AS SELECT * FROM read_csv('data/source/olist/product_category_name_translation.csv');

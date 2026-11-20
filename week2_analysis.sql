-- AnalystLab Africa | Week 2 | Track 1: Data Analytics
-- Maven Fuzzy Factory - SQL business analysis (MySQL syntax)
-- Written in MySQL syntax; the query logic was tested against the data in SQLite (all results match). For PostgreSQL replace DATE_FORMAT(created_dt, '%Y-%m') with TO_CHAR(created_dt, 'YYYY-MM').
-- For SQL Server use FORMAT(created_dt, 'yyyy-MM') and replace "LIMIT 5" with "SELECT TOP 5".
-- Assumes tables: website_sessions, website_pageviews, orders_mav, order_items,
-- order_item_refunds, products. created_at must be DATETIME (CSV text is M/D/YYYY H:MM).
-- If imported as text, convert once:
--   ALTER TABLE orders_mav ADD COLUMN created_dt DATETIME;
--   UPDATE orders_mav SET created_dt = STR_TO_DATE(created_at, '%m/%d/%Y %H:%i');
-- (repeat for website_sessions, order_items, order_item_refunds). Then use created_dt below.

-- Q1. Total unique orders                                     -> 32,313
SELECT COUNT(DISTINCT order_id) AS total_orders FROM orders_mav;

-- Q2. Total revenue                                           -> 1,938,509.75
SELECT ROUND(SUM(price_usd), 2) AS total_revenue FROM orders_mav;

-- Q3. Top 5 products by revenue (only 4 products exist)       -> Mr. Fuzzy first
SELECT p.product_name,
       COUNT(*)                    AS items_sold,
       ROUND(SUM(oi.price_usd), 2) AS revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 5;

-- Q4. Product performance (no category field exists, so product = type)
SELECT p.product_name,
       ROUND(SUM(oi.price_usd), 2)                                    AS revenue,
       ROUND(100.0 * SUM(oi.price_usd) / SUM(SUM(oi.price_usd)) OVER (), 1) AS pct_of_revenue,
       ROUND(SUM(oi.price_usd - oi.cogs_usd), 2)                      AS gross_margin
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

-- Q5. Sessions by marketing source (NULL = direct/organic)
SELECT COALESCE(utm_source, 'direct/organic') AS marketing_source,
       COUNT(*) AS sessions
FROM website_sessions
GROUP BY COALESCE(utm_source, 'direct/organic')
ORDER BY sessions DESC;

-- Q6. Sessions by device type
SELECT device_type, COUNT(*) AS sessions
FROM website_sessions
GROUP BY device_type
ORDER BY sessions DESC;

-- Q7. Session-to-order conversion rate                        -> 6.83%
SELECT COUNT(DISTINCT s.website_session_id)                        AS sessions,
       COUNT(DISTINCT o.order_id)                                  AS orders,
       ROUND(100.0 * COUNT(DISTINCT o.order_id)
             / COUNT(DISTINCT s.website_session_id), 2)            AS conversion_rate_pct
FROM website_sessions s
LEFT JOIN orders_mav o ON o.website_session_id = s.website_session_id;

-- Q8. Total number and value of refunds                       -> 1,731 / 85,338.69
SELECT COUNT(*) AS refund_count,
       ROUND(SUM(refund_amount_usd), 2) AS refund_value
FROM order_item_refunds;

-- Q9. Monthly revenue; highest and lowest months
SELECT DATE_FORMAT(created_dt, '%Y-%m') AS month,
       ROUND(SUM(price_usd), 2)         AS revenue,
       COUNT(*)                         AS orders
FROM orders_mav
GROUP BY DATE_FORMAT(created_dt, '%Y-%m')
ORDER BY revenue DESC;          -- top row = highest (2014-12), bottom row = lowest (2012-03, partial launch month)

-- Q10. Average order value                                    -> 59.99
SELECT ROUND(SUM(price_usd) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM orders_mav;

-- Extra (for insights): conversion by device
SELECT s.device_type,
       COUNT(*) AS sessions,
       COUNT(o.order_id) AS orders,
       ROUND(100.0 * COUNT(o.order_id) / COUNT(*), 2) AS conversion_rate_pct
FROM website_sessions s
LEFT JOIN orders_mav o ON o.website_session_id = s.website_session_id
GROUP BY s.device_type;

-- Extra: conversion by source
SELECT COALESCE(s.utm_source, 'direct/organic') AS source,
       COUNT(*) AS sessions,
       COUNT(o.order_id) AS orders,
       ROUND(100.0 * COUNT(o.order_id) / COUNT(*), 2) AS conversion_rate_pct
FROM website_sessions s
LEFT JOIN orders_mav o ON o.website_session_id = s.website_session_id
GROUP BY COALESCE(s.utm_source, 'direct/organic')
ORDER BY sessions DESC;

-- Extra: refund rate by product
SELECT p.product_name,
       COUNT(r.order_item_refund_id)                              AS refunds,
       ROUND(SUM(r.refund_amount_usd), 2)                         AS refund_value,
       ROUND(100.0 * COUNT(r.order_item_refund_id) / COUNT(oi.order_item_id), 2) AS refund_rate_pct
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
LEFT JOIN order_item_refunds r ON r.order_item_id = oi.order_item_id
GROUP BY p.product_name
ORDER BY refund_rate_pct DESC;

-- Project 03 reference-style SQL
-- 1 User profile
SELECT gender, COUNT(DISTINCT customer_id) users FROM jd_events GROUP BY gender;
-- 2 Weekly activity
SELECT DATE_TRUNC('week', action_date) week, COUNT(*) pageviews, COUNT(DISTINCT customer_id) view_users
FROM jd_events WHERE type='PageView' GROUP BY 1 ORDER BY 1;
-- 3 Next-day retention
WITH first_seen AS (SELECT customer_id, MIN(DATE(action_date)) first_date FROM jd_events GROUP BY customer_id)
SELECT COUNT(*) eligible_users,
       SUM(CASE WHEN EXISTS (SELECT 1 FROM jd_events e WHERE e.customer_id=f.customer_id AND DATE(e.action_date)=DATE(f.first_date,'+1 day')) THEN 1 ELSE 0 END) retained_users
FROM first_seen f WHERE f.first_date <= DATE((SELECT MAX(action_date) FROM jd_events),'-1 day');
-- 4 Category and brand preference
SELECT category, COUNT(*) pageviews FROM jd_events WHERE type='PageView' GROUP BY category ORDER BY pageviews DESC;
SELECT brand, COUNT(*) pageviews FROM jd_events WHERE type='PageView' GROUP BY brand ORDER BY pageviews DESC;
-- 5 New-product acceptance
SELECT COUNT(DISTINCT customer_id) new_product_buyers FROM jd_events
WHERE type='Order' AND julianday(action_date)-julianday(product_market_date) BETWEEN 0 AND 30;
-- 6 Funnel
SELECT COUNT(DISTINCT CASE WHEN type='PageView' THEN customer_id END) view_users,
       COUNT(DISTINCT CASE WHEN type='SavedCart' THEN customer_id END) cart_users,
       COUNT(DISTINCT CASE WHEN type='Order' THEN customer_id END) order_users,
       COUNT(DISTINCT CASE WHEN type='PageView' THEN customer_id END) view_user_count
FROM jd_events;
-- 7 RFM base
WITH rfm_base AS (
 SELECT customer_id, MAX(action_date) last_order, COUNT(*) frequency,
        COUNT(DISTINCT category) category_n, COUNT(DISTINCT brand) brand_n, COUNT(DISTINCT shop_id) shop_n
 FROM jd_events WHERE type='Order' GROUP BY customer_id)
SELECT * FROM rfm_base;
-- 8 Store operations
SELECT shop_id, AVG(shop_score) score, SUM(CASE WHEN type='PageView' THEN 1 ELSE 0 END) pageviews,
       SUM(CASE WHEN type='Order' THEN 1 ELSE 0 END) orders
FROM jd_events GROUP BY shop_id;

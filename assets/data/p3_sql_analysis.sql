-- ===== 01_daily_kpi =====
-- 京东消费者行为项目 SQL 查询
WITH base AS (SELECT action_date_only AS activity_date, customer_id, type FROM jd_events)
SELECT activity_date, COUNT(*) AS events, COUNT(DISTINCT customer_id) AS active_users,
       SUM(CASE WHEN type='PageView' THEN 1 ELSE 0 END) AS pageviews,
       SUM(CASE WHEN type='SavedCart' THEN 1 ELSE 0 END) AS carts,
       SUM(CASE WHEN type='Order' THEN 1 ELSE 0 END) AS orders,
       ROUND(1.0*SUM(CASE WHEN type='Order' THEN 1 ELSE 0 END)/NULLIF(SUM(CASE WHEN type='PageView' THEN 1 ELSE 0 END),0),6) AS order_event_to_pageview
FROM base GROUP BY activity_date ORDER BY activity_date;

-- ===== 02_segment_funnel =====
-- 京东消费者行为项目 SQL 查询
WITH u AS (
 SELECT customer_id, age_group, gender_label, city_group, customer_tier,
        MAX(CASE WHEN type='PageView' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN type='SavedCart' THEN 1 ELSE 0 END) AS carted,
        MAX(CASE WHEN type='Order' THEN 1 ELSE 0 END) AS ordered
 FROM jd_events GROUP BY customer_id, age_group, gender_label, city_group, customer_tier)
SELECT age_group, gender_label, city_group, customer_tier, SUM(viewed) AS viewers, SUM(carted) AS cart_users,
       SUM(ordered) AS order_users, ROUND(1.0*SUM(ordered)/NULLIF(SUM(viewed),0),6) AS viewer_order_rate,
       ROUND(1.0*SUM(carted)/NULLIF(SUM(viewed),0),6) AS viewer_cart_rate
FROM u GROUP BY age_group, gender_label, city_group, customer_tier;

-- ===== 03_session_path =====
-- 京东消费者行为项目 SQL 查询
WITH ordered AS (
 SELECT customer_id, action_date, action_id, type,
        LAG(action_date) OVER(PARTITION BY customer_id ORDER BY action_date, action_id) AS prev_ts FROM jd_events),
sess AS (
 SELECT *, SUM(CASE WHEN prev_ts IS NULL OR (julianday(action_date)-julianday(prev_ts))*1440>30 THEN 1 ELSE 0 END)
        OVER(PARTITION BY customer_id ORDER BY action_date, action_id) AS session_seq FROM ordered),
paths AS (
 SELECT customer_id, session_seq, GROUP_CONCAT(type,'→') AS raw_path,
        MAX(CASE WHEN type='Order' THEN 1 ELSE 0 END) AS has_order
 FROM sess GROUP BY customer_id, session_seq)
SELECT raw_path, COUNT(*) AS sessions, SUM(has_order) AS order_sessions,
       ROUND(1.0*SUM(has_order)/COUNT(*),6) AS order_session_rate
FROM paths GROUP BY raw_path ORDER BY sessions DESC;

-- ===== 04_cohort_retention =====
-- 京东消费者行为项目 SQL 查询
WITH first_seen AS (SELECT customer_id, MIN(date(action_date)) AS first_date FROM jd_events GROUP BY customer_id),
active AS (SELECT DISTINCT customer_id, date(action_date) AS active_date FROM jd_events),
check_days AS (SELECT 1 AS day_n UNION ALL SELECT 3 UNION ALL SELECT 7 UNION ALL SELECT 14 UNION ALL SELECT 30)
SELECT c.day_n, COUNT(DISTINCT f.customer_id) AS eligible_users,
       COUNT(DISTINCT CASE WHEN a.active_date=date(f.first_date,'+'||c.day_n||' day') THEN f.customer_id END) AS retained_users,
       ROUND(1.0*COUNT(DISTINCT CASE WHEN a.active_date=date(f.first_date,'+'||c.day_n||' day') THEN f.customer_id END)/COUNT(DISTINCT f.customer_id),6) AS retention
FROM check_days c JOIN first_seen f JOIN active a ON a.customer_id=f.customer_id
WHERE f.first_date <= date((SELECT MAX(action_date) FROM jd_events),'-'||c.day_n||' day')
GROUP BY c.day_n ORDER BY c.day_n;

-- ===== 05_rfm_period1 =====
-- 京东消费者行为项目 SQL 查询
WITH base AS (
 SELECT customer_id, julianday('2018-03-08')-julianday(date(MAX(action_date))) AS recency_days,
        COUNT(*) AS frequency, SUM(CASE WHEN type='Order' THEN 1 ELSE 0 END) AS purchase_count
 FROM jd_events WHERE date(action_date) BETWEEN '2018-02-01' AND '2018-03-08' GROUP BY customer_id),
ranked AS (SELECT *, ROW_NUMBER() OVER(ORDER BY recency_days ASC,customer_id) AS r_rank,
        ROW_NUMBER() OVER(ORDER BY frequency ASC,customer_id) AS f_rank,
        ROW_NUMBER() OVER(ORDER BY purchase_count ASC,customer_id) AS p_rank, COUNT(*) OVER() AS n FROM base)
SELECT customer_id, recency_days, frequency, purchase_count,
       NTILE(5) OVER(ORDER BY recency_days DESC,customer_id) AS r_score,
       NTILE(5) OVER(ORDER BY frequency,customer_id) AS f_score,
       NTILE(5) OVER(ORDER BY purchase_count,customer_id) AS p_score
FROM ranked ORDER BY customer_id;

-- ===== 06_store_score_sensitivity =====
-- 京东消费者行为项目 SQL 查询
WITH shop AS (
 SELECT shop_id, shop_category, AVG(CASE WHEN shop_score>0 THEN shop_score END) AS valid_score,
        COUNT(*) AS events, SUM(CASE WHEN type='Order' THEN 1 ELSE 0 END) AS orders
 FROM jd_events GROUP BY shop_id, shop_category)
SELECT shop_category, COUNT(*) AS shops, SUM(CASE WHEN valid_score IS NULL THEN 1 ELSE 0 END) AS score_missing_shops,
       ROUND(AVG(CASE WHEN valid_score IS NULL THEN orders END),2) AS avg_orders_missing_score,
       ROUND(AVG(CASE WHEN valid_score IS NOT NULL THEN orders END),2) AS avg_orders_valid_score
FROM shop GROUP BY shop_category ORDER BY shops DESC;

-- ===== 07_category_competition =====
-- 京东消费者行为项目 SQL 查询
WITH brand AS (SELECT category,brand,COUNT(*) AS orders FROM jd_events WHERE type='Order' GROUP BY category,brand),
shares AS (SELECT category,brand,orders,1.0*orders/SUM(orders) OVER(PARTITION BY category) AS share FROM brand)
SELECT category, SUM(orders) AS orders, COUNT(*) AS brands, ROUND(SUM(share*share),4) AS brand_hhi,
       ROUND(MAX(share),4) AS top_brand_share FROM shares GROUP BY category ORDER BY orders DESC;

-- ===== 08_target_opportunity =====
-- 京东消费者行为项目 SQL 查询
WITH u AS (
 SELECT customer_id, city_group, MAX(CASE WHEN type='PageView' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN type='Order' THEN 1 ELSE 0 END) AS ordered FROM jd_events GROUP BY customer_id,city_group),
seg AS (SELECT city_group,COUNT(*) AS viewers,SUM(ordered) AS order_users,1.0*SUM(ordered)/COUNT(*) AS order_rate
        FROM u WHERE viewed=1 GROUP BY city_group),
base AS (SELECT 1.0*SUM(ordered)/SUM(viewed) AS overall_rate FROM u)
SELECT city_group,viewers,order_users,ROUND(order_rate,6) AS order_rate,
       ROUND((SELECT overall_rate FROM base)-order_rate,6) AS gap_to_overall,
       ROUND(MAX(0,(SELECT overall_rate FROM base)-order_rate)*viewers,1) AS theoretical_opportunity_orders
FROM seg ORDER BY theoretical_opportunity_orders DESC;

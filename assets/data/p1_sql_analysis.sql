-- 03_analysis.sql  经营分析查询（8 个任务，均基于 v_metrics 视图）
-- 说明：v_metrics 已含期初值，可直接算同比与周转；NULLIF 防除零。

-- Q1 2025 年营业收入最高的公司
SELECT company_name, revenue AS revenue_2025
FROM v_metrics WHERE fiscal_year = 2025 ORDER BY revenue DESC LIMIT 1;

-- Q2 各公司 2020→2025 营业收入 CAGR（年均复合增长率，%）
SELECT a.company_name,
       ROUND((POWER(b.revenue / a.revenue, 1.0/5) - 1) * 100, 2) AS cagr_pct
FROM v_metrics a JOIN v_metrics b
  ON b.company_code = a.company_code AND a.fiscal_year = 2020 AND b.fiscal_year = 2025
ORDER BY cagr_pct DESC;

-- Q3 2025 年毛利率与同业排名（窗口函数 RANK）
SELECT company_name,
       ROUND((1 - cost / NULLIF(revenue,0)) * 100, 2) AS gross_margin_pct,
       RANK() OVER (ORDER BY (1 - cost / NULLIF(revenue,0)) DESC) AS rnk
FROM v_metrics WHERE fiscal_year = 2025;

-- Q4 各公司营业收入同比增速（LAG 取上年）
SELECT company_name, fiscal_year, revenue,
       ROUND((revenue / NULLIF(prev_revenue,0) - 1) * 100, 2) AS revenue_yoy_pct
FROM v_metrics WHERE prev_revenue IS NOT NULL
ORDER BY company_code, fiscal_year;

-- Q5 2025 年毛利率低于同业均值、但存货周转更快的公司（对标）——识别薄利快周转
WITH base AS (
  SELECT company_name,
         (1 - cost / NULLIF(revenue,0)) * 100 AS gm,
         360.0 * (prev_inventory + inventory) / 2 / NULLIF(cost,0) AS inv_days
  FROM v_metrics WHERE fiscal_year = 2025 AND prev_inventory IS NOT NULL
)
SELECT company_name,
       ROUND(gm,2) AS gross_margin_pct,
       ROUND(inv_days,1) AS inventory_days,
       ROUND((SELECT AVG(gm) FROM base),2) AS peer_avg_gm
FROM base
WHERE gm < (SELECT AVG(gm) FROM base)
ORDER BY inv_days ASC;

-- Q6 2025 年“营收—毛利率—存货周转天数”对照表（CTE）
WITH t AS (
  SELECT company_name, revenue,
         ROUND((1 - cost / NULLIF(revenue,0)) * 100, 2) AS gm,
         ROUND(360.0 * (prev_inventory + inventory) / 2 / NULLIF(cost,0), 1) AS inv_days
  FROM v_metrics WHERE fiscal_year = 2025 AND prev_inventory IS NOT NULL
)
SELECT company_name, ROUND(revenue,2) AS revenue, gm AS gross_margin_pct, inv_days AS inventory_days
FROM t ORDER BY revenue DESC;

-- Q7 行业合计营业收入与行业增速（分组聚合 + 窗口）
WITH yr AS (
  SELECT fiscal_year, SUM(revenue) AS industry_revenue, SUM(net_profit) AS industry_profit
  FROM v_metrics GROUP BY fiscal_year
)
SELECT fiscal_year,
       ROUND(industry_revenue, 2) AS industry_revenue,
       ROUND(industry_profit, 2)  AS industry_profit,
       ROUND((industry_revenue / NULLIF(LAG(industry_revenue) OVER (ORDER BY fiscal_year),0) - 1) * 100, 2) AS industry_yoy_pct
FROM yr ORDER BY fiscal_year;

-- Q8 数据异常与留痕校验：列出被调整记录及毛利率异常年份
SELECT company_name, fiscal_year, adjustment_note,
       ROUND((1 - cost / NULLIF(revenue,0)) * 100, 2) AS gross_margin_pct
FROM v_metrics
WHERE adjustment_note IS NOT NULL OR (1 - cost / NULLIF(revenue,0)) < 0.03
ORDER BY company_name, fiscal_year;

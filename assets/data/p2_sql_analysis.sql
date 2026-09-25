-- 03_analysis.sql  8 类分析查询（医药零售连锁 · SQL + Tableau 项目）
-- 基于 v_retail 视图；NULLIF 防除零。

-- Q1 2025 年营收规模排名
SELECT chain_name, ROUND(revenue,2) AS revenue_2025
FROM v_retail WHERE fiscal_year = 2025 ORDER BY revenue DESC;

-- Q2 营收与净利五年 CAGR 对照 —— 识别“增收不增利”
WITH edge AS (
  SELECT a.chain_name, a.revenue AS rev0, b.revenue AS rev1,
         a.net_profit AS np0, b.net_profit AS np1
  FROM v_retail a JOIN v_retail b
    ON b.chain_code = a.chain_code AND a.fiscal_year = 2020 AND b.fiscal_year = 2025
)
SELECT chain_name,
       ROUND((POWER(rev1/rev0, 1.0/5)-1)*100, 2) AS revenue_cagr_pct,
       ROUND((POWER(np1/np0,  1.0/5)-1)*100, 2) AS profit_cagr_pct,
       CASE WHEN np1/np0 < rev1/rev0 THEN '增收不增利' ELSE '量利同增' END AS pattern
FROM edge ORDER BY revenue_cagr_pct DESC;

-- Q3 并购风险：商誉占净资产比重排名（2025）
SELECT chain_name, ROUND(goodwill,2) AS goodwill, ROUND(net_assets,2) AS net_assets,
       ROUND(goodwill/NULLIF(net_assets,0)*100, 2) AS goodwill_to_equity_pct,
       RANK() OVER (ORDER BY goodwill/NULLIF(net_assets,0) DESC) AS risk_rank
FROM v_retail WHERE fiscal_year = 2025;

-- Q4 逐年营收增速（窗口函数 LAG）
SELECT chain_name, fiscal_year, ROUND(revenue,2) AS revenue,
       ROUND((revenue/NULLIF(prev_revenue,0)-1)*100, 2) AS revenue_yoy_pct
FROM v_retail WHERE prev_revenue IS NOT NULL ORDER BY chain_code, fiscal_year;

-- Q5 营运效率对标：存货周转天数 + 应收周转天数（平均余额口径）
SELECT chain_name,
       ROUND(360.0*(prev_inventory+inventory)/2/NULLIF(cost,0), 1) AS inventory_days,
       ROUND(360.0*(prev_receivable+receivable)/2/NULLIF(revenue,0), 1) AS receivable_days,
       ROUND(360.0*(prev_inventory+inventory)/2/NULLIF(cost,0)
           + 360.0*(prev_receivable+receivable)/2/NULLIF(revenue,0), 1) AS working_capital_days
FROM v_retail WHERE fiscal_year = 2025 AND prev_inventory IS NOT NULL
ORDER BY working_capital_days ASC;

-- Q6 费用结构与盈利能力对照（2025）
SELECT chain_name,
       ROUND((1-cost/NULLIF(revenue,0))*100, 2) AS gross_margin_pct,
       ROUND(selling_exp/NULLIF(revenue,0)*100, 2) AS selling_exp_pct,
       ROUND(net_profit/NULLIF(revenue,0)*100, 2) AS net_margin_pct
FROM v_retail WHERE fiscal_year = 2025 ORDER BY net_margin_pct DESC;

-- Q7 行业合计与增速（聚合后再开窗）
WITH yr AS (
  SELECT fiscal_year, SUM(revenue) AS industry_revenue, SUM(net_profit) AS industry_profit,
         SUM(goodwill) AS industry_goodwill, SUM(net_assets) AS industry_equity
  FROM v_retail GROUP BY fiscal_year
)
SELECT fiscal_year, ROUND(industry_revenue,2) AS industry_revenue,
       ROUND(industry_profit,2) AS industry_profit,
       ROUND(industry_goodwill/NULLIF(industry_equity,0)*100, 2) AS goodwill_to_equity_pct,
       ROUND((industry_revenue/NULLIF(LAG(industry_revenue) OVER (ORDER BY fiscal_year),0)-1)*100, 2) AS industry_yoy_pct
FROM yr ORDER BY fiscal_year;

-- Q8 综合风险画像：商誉占比 + 营运资金占用天数（2025，含标准化打分）
WITH base AS (
  SELECT chain_name, goodwill/NULLIF(net_assets,0) AS gw_ratio,
         360.0*(prev_inventory+inventory)/2/NULLIF(cost,0)
         + 360.0*(prev_receivable+receivable)/2/NULLIF(revenue,0) AS wc_days
  FROM v_retail WHERE fiscal_year = 2025 AND prev_inventory IS NOT NULL
)
SELECT chain_name, ROUND(gw_ratio*100,2) AS goodwill_to_equity_pct, ROUND(wc_days,1) AS working_capital_days,
       ROUND(gw_ratio/MAX(gw_ratio) OVER () * 50 + wc_days/MAX(wc_days) OVER () * 50, 1) AS risk_score
FROM base ORDER BY risk_score DESC;

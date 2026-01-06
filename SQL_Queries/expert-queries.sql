
-- Analyze product performance across different lifecycle stages:
-- 0–6 months after launch
-- 6–12 months after launch
-- More than 12 months after launch
-- For each product, calculate:
-- Total units sold
-- Total revenue
-- Compare how product performance changes as products mature.
SELECT
    s.product_id,
    CASE
        WHEN TIMESTAMPDIFF(MONTH, p.launch_date, s.sale_date) <= 6
            THEN '0–6 months'
        WHEN TIMESTAMPDIFF(MONTH, p.launch_date, s.sale_date) <= 12
            THEN '6–12 months'
        ELSE '12+ months'
    END AS lifecycle_stage,
    SUM(s.quantity) AS units_sold,
    SUM(s.quantity * s.unit_price) AS total_revenue
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
GROUP BY
    s.product_id,
    lifecycle_stage
ORDER BY
    s.product_id,
    lifecycle_stage;
-- if dataset is large then better to calculate the mnonth difference once and use that everywhere in when to compare




--  Portfolio-Ready Tough Question
-- Product Sustainability & Revenue Stability Analysis
-- Question
-- Identify products that demonstrate long-term sustainability by satisfying all of the following:
-- Generate at least 40% of their total revenue after the first 12 months from launch
-- Show consistent year-over-year revenue growth for at least 3 years
-- Have a warranty claim rate lower than the global average
-- Output for each qualifying product:
-- Product ID
-- Product name
-- Total lifetime revenue
-- Revenue generated after 12 months
-- Warranty claim rate




WITH yearly_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        YEAR(s.sale_date) AS sales_year,
        SUM(s.quantity * s.unit_price) AS yearly_revenue
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        YEAR(s.sale_date)
),


yoy_comparison AS (
    SELECT
        product_id,
        product_name,
        sales_year,
        yearly_revenue,
        LAG(yearly_revenue) OVER (
            PARTITION BY product_id
            ORDER BY sales_year
        ) AS prev_year_revenue
    FROM yearly_revenue
),

consistent_growth_products AS (
    SELECT
        product_id
    FROM yoy_comparison
    WHERE
        prev_year_revenue IS NOT NULL
        AND yearly_revenue > prev_year_revenue
    GROUP BY product_id
    HAVING COUNT(*) >= 3
),

revenue_breakdown AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(s.quantity * s.unit_price) AS total_revenue,
        SUM(
            CASE
                WHEN TIMESTAMPDIFF(
                        MONTH,
                        p.launch_date,
                        s.sale_date
                     ) > 12
                THEN s.quantity * s.unit_price
                ELSE 0
            END
        ) AS revenue_after_12_months
    FROM sales s
    JOIN products p
        ON s.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name
),


product_warranty_rate AS (
    SELECT
        s.product_id,
        COUNT(w.claim_id) / COUNT(s.sale_id) * 100 AS warranty_claim_rate
    FROM sales s
    LEFT JOIN warranty w
        ON s.sale_id = w.sale_id
    GROUP BY s.product_id
),


global_warranty_avg AS (
    SELECT
        COUNT(w.claim_id) / COUNT(s.sale_id) * 100 AS global_avg_rate
    FROM sales s
    LEFT JOIN warranty w
        ON s.sale_id = w.sale_id
)


SELECT
    rb.product_id,
    rb.product_name,
    ROUND(rb.total_revenue, 2) AS total_lifetime_revenue,
    ROUND(rb.revenue_after_12_months, 2) AS revenue_after_12_months,
    ROUND(pwr.warranty_claim_rate, 2) AS warranty_claim_rate
FROM revenue_breakdown rb
JOIN consistent_growth_products cg
    ON rb.product_id = cg.product_id
JOIN product_warranty_rate pwr
    ON rb.product_id = pwr.product_id
CROSS JOIN global_warranty_avg gwa
WHERE
    rb.revenue_after_12_months / rb.total_revenue >= 0.40
    AND pwr.warranty_claim_rate < gwa.global_avg_rate
ORDER BY rb.product_id;
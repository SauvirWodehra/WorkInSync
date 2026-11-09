-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 02_kpi_activation_rate.sql
-- KPI: Employee Activation Rate (overall + per client + weekly trend)
-- Uses: CTEs, Window Functions (LAG, LEAD, running totals), Aggregations
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- QUERY 2A: Per-Client Activation Rate with Benchmarks
-- ─────────────────────────────────────────────────────────────
WITH activation_summary AS (
    SELECT
        client_id,
        client_name,
        industry,
        region,
        total_employees,
        employees_activated,
        activation_rate_pct,
        onboarding_status,
        -- Activation rate tier (business threshold)
        CASE
            WHEN activation_rate_pct >= 90 THEN 'Excellent  (≥90%)'
            WHEN activation_rate_pct >= 75 THEN 'Good       (75-89%)'
            WHEN activation_rate_pct >= 60 THEN 'Acceptable (60-74%)'
            ELSE                                'Poor       (<60%)'
        END AS activation_tier,
        -- Employees still NOT activated
        total_employees - employees_activated AS employees_pending,
        -- Rank by activation rate
        RANK() OVER (ORDER BY activation_rate_pct DESC)         AS activation_rank,
        -- Percentile (100 = top)
        ROUND(
            PERCENT_RANK() OVER (ORDER BY activation_rate_pct) * 100, 1
        ) AS activation_percentile
    FROM vw_client_summary
),
-- Portfolio-level activation totals
portfolio_activation AS (
    SELECT
        SUM(total_employees)       AS total_portfolio_employees,
        SUM(employees_activated)   AS total_portfolio_activated,
        ROUND(SUM(employees_activated) * 100.0 / NULLIF(SUM(total_employees),0), 2)
                                   AS portfolio_activation_rate_pct
    FROM vw_client_summary
)

SELECT
    a.activation_rank,
    a.client_id,
    a.client_name,
    a.industry,
    a.region,
    a.total_employees,
    a.employees_activated,
    a.employees_pending,
    a.activation_rate_pct,
    a.activation_tier,
    a.activation_percentile,
    a.onboarding_status,
    -- Delta vs portfolio average
    ROUND(a.activation_rate_pct - pa.portfolio_activation_rate_pct, 2) AS delta_vs_portfolio,
    pa.portfolio_activation_rate_pct
FROM activation_summary a
CROSS JOIN portfolio_activation pa
ORDER BY a.activation_rank;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2B: Weekly Activation Trend — WoW Delta per Client
-- Uses LAG() window function
-- ─────────────────────────────────────────────────────────────
WITH weekly_data AS (
    SELECT
        client_id,
        client_name,
        industry,
        snapshot_date,
        week_num,
        employees_activated,
        activation_rate_pct,
        wow_activation_delta,
        wow_completion_delta,
        -- Acceleration: change in WoW delta (is it speeding up or slowing down?)
        wow_activation_delta
          - LAG(wow_activation_delta, 1, 0)
            OVER (PARTITION BY client_id ORDER BY snapshot_date)   AS activation_acceleration,
        -- Cumulative activations so far
        SUM(wow_activation_delta)
          OVER (PARTITION BY client_id ORDER BY snapshot_date
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)  AS cumulative_new_activations
    FROM vw_weekly_trends
)
SELECT
    client_id,
    client_name,
    industry,
    snapshot_date,
    week_num,
    employees_activated,
    ROUND(activation_rate_pct, 2)        AS activation_rate_pct,
    wow_activation_delta,
    -- Flag weeks where activation slowed down
    CASE
        WHEN wow_activation_delta < 0                                THEN 'Declining'
        WHEN wow_activation_delta = 0                                THEN 'Stalled'
        WHEN activation_acceleration < -50                           THEN 'Slowing'
        WHEN activation_acceleration > 50                            THEN 'Accelerating'
        ELSE 'Steady'
    END AS activation_momentum,
    wow_completion_delta,
    cumulative_new_activations
FROM weekly_data
ORDER BY client_id, snapshot_date;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2C: Clients with Low Activation but High Setup Completion
--           (Operational Risk — setup done but employees not onboarding)
-- ─────────────────────────────────────────────────────────────
SELECT
    client_id,
    client_name,
    industry,
    setup_completion_pct,
    activation_rate_pct,
    total_employees,
    employees_activated,
    total_employees - employees_activated AS employees_still_pending,
    health_score,
    -- Gap between setup and activation (should be low for healthy clients)
    ROUND(setup_completion_pct - activation_rate_pct, 2) AS setup_activation_gap
FROM vw_client_summary
WHERE setup_completion_pct >= 70           -- Setup largely done
  AND activation_rate_pct  < 80            -- But activation still low
ORDER BY setup_activation_gap DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 2D: Activation Rate by Industry (aggregated)
-- ─────────────────────────────────────────────────────────────
SELECT
    industry,
    SUM(total_employees)       AS industry_total_employees,
    SUM(employees_activated)   AS industry_total_activated,
    ROUND(SUM(employees_activated) * 100.0 / NULLIF(SUM(total_employees), 0), 2)
                               AS industry_activation_rate_pct,
    COUNT(*)                   AS client_count,
    ROUND(AVG(activation_rate_pct), 2) AS avg_client_activation_rate
FROM vw_client_summary
GROUP BY industry
ORDER BY industry_activation_rate_pct DESC;


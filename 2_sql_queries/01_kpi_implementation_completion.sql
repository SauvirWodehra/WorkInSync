-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 01_kpi_implementation_completion.sql
-- KPI: Implementation Completion Rate (overall + per client + by industry)
-- Uses: CTEs, Window Functions, Aggregation
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- QUERY 1A: Overall & Per-Client Completion Rate
-- ─────────────────────────────────────────────────────────────
WITH client_completion AS (
    SELECT
        cs.client_id,
        cs.client_name,
        cs.industry,
        cs.region,
        cs.subscription_plan,
        cs.setup_completion_pct,
        cs.onboarding_status,
        cs.health_score,
        -- Rank clients from most to least complete (within industry)
        RANK() OVER (
            PARTITION BY cs.industry
            ORDER BY cs.setup_completion_pct DESC
        ) AS rank_in_industry,
        -- Rank globally
        RANK() OVER (
            ORDER BY cs.setup_completion_pct DESC
        ) AS global_rank,
        -- Running average as we iterate by rank
        ROUND(AVG(cs.setup_completion_pct) OVER (
            ORDER BY cs.setup_completion_pct DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2) AS running_avg_completion
    FROM vw_client_summary cs
),

-- Overall portfolio KPI
portfolio_summary AS (
    SELECT
        COUNT(*)                                                   AS total_clients,
        COUNT(*) FILTER (WHERE onboarding_status = 'Completed')   AS completed_clients,
        COUNT(*) FILTER (WHERE onboarding_status = 'On Track')    AS on_track_clients,
        COUNT(*) FILTER (WHERE onboarding_status = 'At Risk')     AS at_risk_clients,
        COUNT(*) FILTER (WHERE onboarding_status = 'Delayed')     AS delayed_clients,
        ROUND(AVG(setup_completion_pct), 2)                       AS avg_completion_rate_pct,
        ROUND(MIN(setup_completion_pct), 2)                       AS min_completion_pct,
        ROUND(MAX(setup_completion_pct), 2)                       AS max_completion_pct,
        -- % of clients that have reached >= 90% completion
        ROUND(
            COUNT(*) FILTER (WHERE setup_completion_pct >= 90) * 100.0 / COUNT(*), 1
        )                                                         AS pct_clients_near_complete
    FROM vw_client_summary
)

-- Main output: per-client completion with portfolio context
SELECT
    cc.global_rank,
    cc.client_id,
    cc.client_name,
    cc.industry,
    cc.region,
    cc.subscription_plan,
    cc.setup_completion_pct,
    cc.onboarding_status,
    cc.health_score,
    cc.rank_in_industry,
    cc.running_avg_completion,
    -- Completion gap to 100%
    ROUND(100 - cc.setup_completion_pct, 2)              AS gap_to_completion_pct,
    -- Portfolio benchmarks (same value across all rows — for reference)
    ps.avg_completion_rate_pct                           AS portfolio_avg_completion,
    ps.total_clients,
    ps.completed_clients,
    ps.at_risk_clients,
    ps.delayed_clients,
    -- Above or below portfolio average
    CASE
        WHEN cc.setup_completion_pct >= ps.avg_completion_rate_pct THEN 'Above Average'
        ELSE 'Below Average'
    END AS vs_portfolio_avg
FROM client_completion cc
CROSS JOIN portfolio_summary ps
ORDER BY cc.global_rank;


-- ─────────────────────────────────────────────────────────────
-- QUERY 1B: Completion Rate by Industry (aggregated)
-- ─────────────────────────────────────────────────────────────
SELECT
    industry,
    COUNT(*)                                                   AS client_count,
    ROUND(AVG(setup_completion_pct), 2)                        AS avg_completion_pct,
    ROUND(MIN(setup_completion_pct), 2)                        AS min_completion_pct,
    ROUND(MAX(setup_completion_pct), 2)                        AS max_completion_pct,
    COUNT(*) FILTER (WHERE onboarding_status = 'Completed')    AS completed,
    COUNT(*) FILTER (WHERE onboarding_status = 'Delayed')      AS delayed,
    -- Industry completion relative to overall average
    ROUND(AVG(setup_completion_pct) - (
        SELECT AVG(setup_completion_pct) FROM vw_client_summary
    ), 2) AS delta_vs_overall_avg
FROM vw_client_summary
GROUP BY industry
ORDER BY avg_completion_pct DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 1C: Completion Rate by Account Manager
-- ─────────────────────────────────────────────────────────────
SELECT
    account_manager,
    COUNT(*)                                   AS clients_managed,
    ROUND(AVG(setup_completion_pct), 2)        AS avg_completion_pct,
    ROUND(AVG(health_score), 1)                AS avg_health_score,
    COUNT(*) FILTER (WHERE onboarding_status = 'Delayed') AS delayed_clients,
    COUNT(*) FILTER (WHERE onboarding_status = 'Completed') AS completed_clients,
    SUM(contract_value_inr)                    AS total_portfolio_value_inr
FROM vw_client_summary
GROUP BY account_manager
ORDER BY avg_completion_pct DESC;


-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 08_executive_summary.sql
-- Purpose: Single master query for executive reporting & Power BI import
-- Uses: Multiple CTEs chained, all KPIs in one result set
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- QUERY 8A: Executive KPI Summary (single row — portfolio level)
-- ─────────────────────────────────────────────────────────────
WITH portfolio AS (
    SELECT
        COUNT(*)                                                   AS total_clients,
        SUM(total_employees)                                       AS total_employees,
        SUM(employees_activated)                                   AS total_activated,
        ROUND(SUM(employees_activated)*100.0/NULLIF(SUM(total_employees),0),2)
                                                                   AS overall_activation_rate_pct,
        ROUND(AVG(setup_completion_pct), 2)                        AS avg_completion_rate_pct,
        ROUND(AVG(onboarding_days), 1)                             AS avg_onboarding_days,
        SUM(open_issues)                                           AS total_open_issues,
        SUM(critical_open_issues)                                  AS total_critical_issues,
        ROUND(AVG(avg_resolution_days), 2)                         AS avg_resolution_days,
        ROUND(AVG(health_score), 1)                                AS avg_health_score,
        COUNT(*) FILTER (WHERE onboarding_status = 'Completed')    AS completed_clients,
        COUNT(*) FILTER (WHERE onboarding_status = 'On Track')     AS on_track_clients,
        COUNT(*) FILTER (WHERE onboarding_status = 'At Risk')      AS at_risk_clients,
        COUNT(*) FILTER (WHERE onboarding_status = 'Delayed')      AS delayed_clients,
        SUM(contract_value_inr)                                    AS total_arr_inr,
        -- ARR at risk (health < 70)
        SUM(contract_value_inr) FILTER (WHERE health_score < 70)   AS arr_at_risk_inr,
        -- % of clients delivered on time
        ROUND(
            COUNT(*) FILTER (WHERE actual_go_live_date IS NOT NULL
                              AND go_live_delay_days <= 0) * 100.0
            / NULLIF(COUNT(*) FILTER (WHERE actual_go_live_date IS NOT NULL), 0), 1
        )                                                          AS on_time_delivery_pct
    FROM vw_client_summary
)
SELECT
    total_clients,
    total_employees,
    total_activated,
    overall_activation_rate_pct,
    avg_completion_rate_pct,
    avg_onboarding_days,
    total_open_issues,
    total_critical_issues,
    avg_resolution_days,
    avg_health_score,
    completed_clients,
    on_track_clients,
    at_risk_clients,
    delayed_clients,
    ROUND(total_arr_inr / 1e7, 2)      AS total_arr_crore,
    ROUND(arr_at_risk_inr / 1e7, 2)   AS arr_at_risk_crore,
    ROUND(arr_at_risk_inr * 100.0 / NULLIF(total_arr_inr, 0), 1)
                                       AS pct_arr_at_risk,
    on_time_delivery_pct
FROM portfolio;


-- ─────────────────────────────────────────────────────────────
-- QUERY 8B: Full Client Master — Power BI import query
-- (All KPIs in one flat table — used as the main data source)
-- ─────────────────────────────────────────────────────────────
SELECT
    cs.client_id,
    cs.client_name,
    cs.industry,
    cs.region,
    cs.subscription_plan,
    cs.account_manager,
    cs.total_employees,
    cs.contract_start_date,
    cs.expected_go_live_date,
    cs.actual_go_live_date,
    ROUND(cs.contract_value_inr / 1e7, 2)   AS contract_value_crore,

    -- Timing KPIs
    cs.onboarding_days,
    cs.go_live_delay_days,

    -- Progress KPIs
    cs.employees_uploaded,
    cs.employees_activated,
    cs.setup_completion_pct,
    cs.activation_rate_pct,

    -- Milestone KPIs
    cs.total_milestones,
    cs.milestones_done,
    cs.milestones_failed,
    cs.milestones_overdue,
    cs.avg_milestone_delay,

    -- Issue KPIs
    cs.total_issues_ever,
    cs.open_issues,
    cs.critical_open_issues,
    cs.resolved_issues,
    cs.avg_resolution_days,

    -- Composite KPIs
    cs.health_score,
    cs.onboarding_status,

    -- Categorisation helpers for Power BI slicers
    CASE
        WHEN cs.health_score >= 90 THEN '1-Excellent'
        WHEN cs.health_score >= 80 THEN '2-Good'
        WHEN cs.health_score >= 65 THEN '3-Needs Attention'
        WHEN cs.health_score >= 50 THEN '4-At Risk'
        ELSE                            '5-Critical'
    END AS health_tier,

    CASE
        WHEN cs.activation_rate_pct >= 90 THEN '1-Excellent (≥90%)'
        WHEN cs.activation_rate_pct >= 75 THEN '2-Good (75-89%)'
        WHEN cs.activation_rate_pct >= 60 THEN '3-Acceptable (60-74%)'
        ELSE                                   '4-Poor (<60%)'
    END AS activation_tier,

    CASE
        WHEN cs.onboarding_days <= 21 THEN '1-Fast (≤21d)'
        WHEN cs.onboarding_days <= 35 THEN '2-Normal (22-35d)'
        WHEN cs.onboarding_days <= 60 THEN '3-Slow (36-60d)'
        ELSE                               '4-Critical (>60d)'
    END AS duration_bucket,

    -- Boolean flags for Power BI conditional formatting
    (cs.critical_open_issues > 0)       AS has_critical_issues,
    (cs.milestones_failed > 0)          AS has_failed_milestones,
    (cs.actual_go_live_date IS NULL
     AND cs.expected_go_live_date < CURRENT_DATE) AS is_past_go_live_date,
    (cs.activation_rate_pct < 70)       AS low_activation_flag

FROM vw_client_summary cs
ORDER BY cs.health_score ASC;  -- Most at-risk first


-- ─────────────────────────────────────────────────────────────
-- QUERY 8C: Insight Narratives — Actionable summaries per client
-- (For the "Insights" tab in Power BI / Excel report)
-- ─────────────────────────────────────────────────────────────
SELECT
    cs.client_id,
    cs.client_name,
    cs.onboarding_status,
    cs.health_score,
    -- Auto-generated narrative
    CONCAT(
        cs.client_name, ' (',  cs.industry, ') — ',
        'Health Score: ', cs.health_score, '/100. ',
        'Setup: ', cs.setup_completion_pct, '% complete. ',
        'Activated ', cs.employees_activated, '/', cs.total_employees,
        ' employees (', cs.activation_rate_pct, '%). ',
        CASE
            WHEN cs.open_issues = 0 THEN 'No open issues. '
            ELSE CONCAT(cs.open_issues, ' open issue(s), incl. ',
                        cs.critical_open_issues, ' critical. ')
        END,
        CASE
            WHEN cs.actual_go_live_date IS NOT NULL THEN
                CONCAT('Went live on ', cs.actual_go_live_date,
                       CASE WHEN cs.go_live_delay_days > 0
                            THEN CONCAT(' (', cs.go_live_delay_days, ' days late).')
                            WHEN cs.go_live_delay_days < 0
                            THEN CONCAT(' (', ABS(cs.go_live_delay_days), ' days early).')
                            ELSE ' (on time).' END)
            WHEN cs.expected_go_live_date < CURRENT_DATE THEN
                CONCAT('Go-live was expected ', cs.expected_go_live_date,
                       ' — now ', (CURRENT_DATE - cs.expected_go_live_date),
                       ' days overdue.')
            ELSE CONCAT('Go-live expected: ', cs.expected_go_live_date, '.')
        END
    ) AS insight_narrative
FROM vw_client_summary cs
ORDER BY cs.health_score ASC;


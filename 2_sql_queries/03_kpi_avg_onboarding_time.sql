-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 03_kpi_avg_onboarding_time.sql
-- KPI: Average Onboarding Time (overall, per industry, SLA adherence)
-- Uses: CTEs, DATE arithmetic, CASE, Window Functions
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- QUERY 3A: Per-Client Onboarding Duration vs Target
-- Target SLA: 30 days from contract start to go-live
-- ─────────────────────────────────────────────────────────────
WITH onboarding_time_analysis AS (
    SELECT
        c.client_id,
        c.client_name,
        c.industry,
        c.region,
        c.subscription_plan,
        c.total_employees,
        c.contract_start_date,
        c.expected_go_live_date,
        c.actual_go_live_date,

        -- Target SLA in days (plan-based)
        CASE c.subscription_plan
            WHEN 'Enterprise'    THEN 45  -- larger setup budget
            WHEN 'Professional'  THEN 30
            WHEN 'Basic'         THEN 21
        END AS sla_target_days,

        -- Expected duration (from contract)
        (c.expected_go_live_date - c.contract_start_date) AS planned_duration_days,

        -- Actual duration (live date or today if still in progress)
        CASE
            WHEN c.actual_go_live_date IS NOT NULL
                THEN c.actual_go_live_date - c.contract_start_date
            ELSE
                CURRENT_DATE - c.contract_start_date
        END AS actual_duration_days,

        -- Is the client live yet?
        c.actual_go_live_date IS NOT NULL AS is_live,

        -- Days of delay vs expected go-live (NULL if live and on-time)
        CASE
            WHEN c.actual_go_live_date IS NOT NULL
                THEN c.actual_go_live_date - c.expected_go_live_date
            WHEN c.actual_go_live_date IS NULL AND c.expected_go_live_date < CURRENT_DATE
                THEN CURRENT_DATE - c.expected_go_live_date
            ELSE 0
        END AS go_live_delay_days
    FROM clients c
),

-- Add SLA breach flag and ranks
time_ranked AS (
    SELECT
        *,
        -- SLA breach check
        CASE
            WHEN is_live AND actual_duration_days <= sla_target_days THEN 'Within SLA'
            WHEN is_live AND actual_duration_days >  sla_target_days THEN 'SLA Breached'
            WHEN NOT is_live AND (CURRENT_DATE - contract_start_date) > sla_target_days
                                                                     THEN 'SLA Breached (In Progress)'
            ELSE 'Within SLA (In Progress)'
        END AS sla_status,
        -- Percentile rank by onboarding time (fastest = highest percentile)
        ROUND(
            PERCENT_RANK() OVER (ORDER BY actual_duration_days DESC) * 100, 1
        ) AS speed_percentile
    FROM onboarding_time_analysis
)
SELECT
    client_id,
    client_name,
    industry,
    region,
    subscription_plan,
    total_employees,
    contract_start_date,
    expected_go_live_date,
    actual_go_live_date,
    planned_duration_days,
    actual_duration_days,
    sla_target_days,
    go_live_delay_days,
    sla_status,
    speed_percentile,
    -- Bucket by duration
    CASE
        WHEN actual_duration_days <= 21  THEN 'Fast     (≤21 days)'
        WHEN actual_duration_days <= 35  THEN 'Normal   (22–35 days)'
        WHEN actual_duration_days <= 60  THEN 'Slow     (36–60 days)'
        ELSE                                  'Critical (>60 days)'
    END AS duration_bucket
FROM time_ranked
ORDER BY actual_duration_days;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3B: Average Onboarding Time by Industry & Plan
-- ─────────────────────────────────────────────────────────────
SELECT
    c.industry,
    c.subscription_plan,
    COUNT(*)                                   AS client_count,
    ROUND(AVG(
        CASE
            WHEN c.actual_go_live_date IS NOT NULL
                THEN c.actual_go_live_date - c.contract_start_date
            ELSE CURRENT_DATE - c.contract_start_date
        END
    ), 1)                                      AS avg_onboarding_days,
    MIN(
        CASE
            WHEN c.actual_go_live_date IS NOT NULL
                THEN c.actual_go_live_date - c.contract_start_date
            ELSE CURRENT_DATE - c.contract_start_date
        END
    )                                          AS fastest_days,
    MAX(
        CASE
            WHEN c.actual_go_live_date IS NOT NULL
                THEN c.actual_go_live_date - c.contract_start_date
            ELSE CURRENT_DATE - c.contract_start_date
        END
    )                                          AS slowest_days,
    -- Clients on time
    COUNT(*) FILTER (WHERE c.actual_go_live_date IS NOT NULL
                       AND c.actual_go_live_date <= c.expected_go_live_date) AS on_time_deliveries,
    COUNT(*) FILTER (WHERE c.actual_go_live_date IS NOT NULL
                       AND c.actual_go_live_date >  c.expected_go_live_date) AS late_deliveries
FROM clients c
GROUP BY c.industry, c.subscription_plan
ORDER BY avg_onboarding_days DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 3C: Milestone-Level Time Analysis — Where Do Clients Get Stuck?
-- Uses: Aggregation across the milestone pipeline stage
-- ─────────────────────────────────────────────────────────────
SELECT
    im.milestone_name,
    im.milestone_order,
    COUNT(*)                                             AS total_executions,
    COUNT(*) FILTER (WHERE im.status = 'Completed')     AS completed_count,
    COUNT(*) FILTER (WHERE im.status = 'Failed')        AS failed_count,
    COUNT(*) FILTER (WHERE im.status IN ('Pending','In Progress')
                     AND im.planned_date < CURRENT_DATE) AS overdue_count,
    ROUND(AVG(im.delay_days) FILTER (WHERE im.delay_days > 0), 1) AS avg_delay_when_late,
    MAX(im.delay_days)                                   AS max_delay_days,
    -- % of clients that failed or overdue this milestone
    ROUND(
        (COUNT(*) FILTER (WHERE im.status = 'Failed'
                            OR (im.status IN ('Pending','In Progress')
                                AND im.planned_date < CURRENT_DATE)
        )) * 100.0 / COUNT(*), 1
    ) AS pct_problematic
FROM implementation_milestones im
GROUP BY im.milestone_name, im.milestone_order
ORDER BY im.milestone_order;


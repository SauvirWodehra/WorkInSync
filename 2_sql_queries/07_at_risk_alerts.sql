-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 07_at_risk_alerts.sql
-- Purpose: Identify clients at risk of delayed onboarding — alert report
-- Uses: Multi-CTE, UNION, EXISTS, Scoring, Window Functions
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- QUERY 7A: At-Risk Client Alert Report
-- Composite risk scoring across 5 risk dimensions
-- ─────────────────────────────────────────────────────────────
WITH

-- Risk Dimension 1: Critical open issues
risk_issues AS (
    SELECT
        client_id,
        COUNT(*) FILTER (WHERE severity = 'Critical' AND status <> 'Resolved') AS critical_open,
        COUNT(*) FILTER (WHERE status <> 'Resolved')                           AS total_open,
        CASE
            WHEN COUNT(*) FILTER (WHERE severity = 'Critical' AND status <> 'Resolved') >= 2 THEN 15
            WHEN COUNT(*) FILTER (WHERE severity = 'Critical' AND status <> 'Resolved') = 1  THEN 10
            WHEN COUNT(*) FILTER (WHERE status <> 'Resolved') >= 10                          THEN 8
            WHEN COUNT(*) FILTER (WHERE status <> 'Resolved') >= 5                           THEN 5
            ELSE 0
        END AS issue_risk_score
    FROM configuration_issues
    GROUP BY client_id
),

-- Risk Dimension 2: Milestone failures or overdue
risk_milestones AS (
    SELECT
        client_id,
        COUNT(*) FILTER (WHERE status = 'Failed')                               AS failed_milestones,
        COUNT(*) FILTER (WHERE status IN ('Pending','In Progress')
                         AND planned_date < CURRENT_DATE)                       AS overdue_milestones,
        CASE
            WHEN COUNT(*) FILTER (WHERE status = 'Failed') >= 2                THEN 15
            WHEN COUNT(*) FILTER (WHERE status = 'Failed') = 1                 THEN 10
            WHEN COUNT(*) FILTER (WHERE status IN ('Pending','In Progress')
                                  AND planned_date < CURRENT_DATE) >= 3        THEN 8
            WHEN COUNT(*) FILTER (WHERE status IN ('Pending','In Progress')
                                  AND planned_date < CURRENT_DATE) >= 1        THEN 5
            ELSE 0
        END AS milestone_risk_score
    FROM implementation_milestones
    GROUP BY client_id
),

-- Risk Dimension 3: Low activation relative to expected timeline
risk_activation AS (
    SELECT
        cs.client_id,
        cs.activation_rate_pct,
        cs.onboarding_days,
        CASE
            WHEN cs.activation_rate_pct < 50 AND cs.onboarding_days > 30  THEN 15
            WHEN cs.activation_rate_pct < 70 AND cs.onboarding_days > 45  THEN 10
            WHEN cs.activation_rate_pct < 80 AND cs.onboarding_days > 30  THEN 5
            ELSE 0
        END AS activation_risk_score
    FROM vw_client_summary cs
),

-- Risk Dimension 4: Go-live delay (past expected go-live date)
risk_timeline AS (
    SELECT
        client_id,
        CASE
            WHEN actual_go_live_date IS NULL AND expected_go_live_date < CURRENT_DATE
                THEN GREATEST(CURRENT_DATE - expected_go_live_date, 0)
            ELSE 0
        END AS days_past_go_live,
        CASE
            WHEN actual_go_live_date IS NULL AND expected_go_live_date < CURRENT_DATE - 30  THEN 15
            WHEN actual_go_live_date IS NULL AND expected_go_live_date < CURRENT_DATE - 14  THEN 10
            WHEN actual_go_live_date IS NULL AND expected_go_live_date < CURRENT_DATE       THEN 5
            ELSE 0
        END AS timeline_risk_score
    FROM clients
),

-- Risk Dimension 5: Stalling — activation not growing (last 2 weeks flat)
risk_stalling AS (
    SELECT
        t1.client_id,
        t1.employees_activated                              AS current_activated,
        t2.employees_activated                              AS two_weeks_ago_activated,
        t1.employees_activated - t2.employees_activated     AS two_week_activation_delta,
        CASE
            WHEN t1.employees_activated - t2.employees_activated = 0
              AND t1.employees_activated < (SELECT total_employees FROM clients c2
                                            WHERE c2.client_id = t1.client_id) * 0.9
            THEN 10
            WHEN t1.employees_activated - t2.employees_activated < 10
              AND t1.employees_activated < (SELECT total_employees FROM clients c2
                                            WHERE c2.client_id = t1.client_id) * 0.8
            THEN 5
            ELSE 0
        END AS stall_risk_score
    FROM (
        SELECT DISTINCT ON (client_id) client_id, employees_activated, snapshot_date
        FROM onboarding_progress ORDER BY client_id, snapshot_date DESC
    ) t1
    JOIN (
        SELECT DISTINCT ON (client_id) client_id, employees_activated, snapshot_date
        FROM onboarding_progress
        WHERE snapshot_date <= CURRENT_DATE - 14
        ORDER BY client_id, snapshot_date DESC
    ) t2 ON t1.client_id = t2.client_id
),

-- Combine all risk dimensions
combined_risk AS (
    SELECT
        cs.client_id,
        cs.client_name,
        cs.industry,
        cs.region,
        cs.account_manager,
        cs.contract_value_inr,
        cs.health_score,
        cs.onboarding_status,
        cs.setup_completion_pct,
        cs.activation_rate_pct,
        cs.onboarding_days,
        COALESCE(ri.critical_open, 0)           AS critical_open_issues,
        COALESCE(ri.total_open, 0)              AS total_open_issues,
        COALESCE(rm.failed_milestones, 0)       AS failed_milestones,
        COALESCE(rm.overdue_milestones, 0)      AS overdue_milestones,
        COALESCE(rt.days_past_go_live, 0)       AS days_past_go_live,
        -- Individual risk scores
        COALESCE(ri.issue_risk_score, 0)        AS issue_risk_score,
        COALESCE(rm.milestone_risk_score, 0)    AS milestone_risk_score,
        COALESCE(ra.activation_risk_score, 0)   AS activation_risk_score,
        COALESCE(rt.timeline_risk_score, 0)     AS timeline_risk_score,
        COALESCE(rs.stall_risk_score, 0)        AS stall_risk_score,
        -- Total composite risk score (0–75 scale; >25 = alert)
        COALESCE(ri.issue_risk_score, 0)
          + COALESCE(rm.milestone_risk_score, 0)
          + COALESCE(ra.activation_risk_score, 0)
          + COALESCE(rt.timeline_risk_score, 0)
          + COALESCE(rs.stall_risk_score, 0)   AS composite_risk_score
    FROM vw_client_summary cs
    LEFT JOIN risk_issues      ri ON ri.client_id = cs.client_id
    LEFT JOIN risk_milestones  rm ON rm.client_id = cs.client_id
    LEFT JOIN risk_activation  ra ON ra.client_id = cs.client_id
    LEFT JOIN risk_timeline    rt ON rt.client_id = cs.client_id
    LEFT JOIN risk_stalling    rs ON rs.client_id = cs.client_id
)

-- Final Alert Report
SELECT
    RANK() OVER (ORDER BY composite_risk_score DESC)  AS alert_priority,
    client_id,
    client_name,
    industry,
    region,
    account_manager,
    contract_value_inr,
    health_score,
    onboarding_status,
    setup_completion_pct,
    activation_rate_pct,
    onboarding_days,
    critical_open_issues,
    total_open_issues,
    failed_milestones,
    overdue_milestones,
    days_past_go_live,
    -- Risk score breakdown
    issue_risk_score,
    milestone_risk_score,
    activation_risk_score,
    timeline_risk_score,
    stall_risk_score,
    composite_risk_score,
    -- Alert level
    CASE
        WHEN composite_risk_score >= 35 THEN '🔴 CRITICAL — Escalate Immediately'
        WHEN composite_risk_score >= 20 THEN '🟠 HIGH — Needs Urgent Action'
        WHEN composite_risk_score >= 10 THEN '🟡 MEDIUM — Monitor Closely'
        ELSE                                 '🟢 LOW — Healthy'
    END AS alert_level,
    -- Recommended action
    CASE
        WHEN composite_risk_score >= 35 AND critical_open_issues > 0
            THEN 'Escalate to CXO: Critical issues blocking go-live'
        WHEN composite_risk_score >= 35 AND failed_milestones > 0
            THEN 'Emergency workshop: Multiple milestones have failed'
        WHEN composite_risk_score >= 20 AND days_past_go_live > 14
            THEN 'Schedule executive review: Go-live overdue by 2+ weeks'
        WHEN composite_risk_score >= 20 AND activation_rate_pct < 50
            THEN 'Launch activation drive: Less than 50% employees onboarded'
        WHEN composite_risk_score >= 10
            THEN 'Weekly check-in: Risk indicators trending upward'
        ELSE 'Routine monitoring'
    END AS recommended_action
FROM combined_risk
WHERE composite_risk_score > 0        -- Only clients with any risk
ORDER BY composite_risk_score DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 7B: Clients where Contract Value is HIGH but Health is LOW
--           (Revenue at Risk report)
-- ─────────────────────────────────────────────────────────────
SELECT
    client_id,
    client_name,
    industry,
    account_manager,
    contract_value_inr,
    health_score,
    onboarding_status,
    setup_completion_pct,
    activation_rate_pct,
    open_issues,
    critical_open_issues,
    -- ARR at risk (clients with health < 70 and contract > 1 Cr)
    ROUND(contract_value_inr / 1e7, 2) AS contract_value_crore
FROM vw_client_summary
WHERE health_score < 70
  AND contract_value_inr > 10000000  -- > 1 Crore INR
ORDER BY contract_value_inr DESC;


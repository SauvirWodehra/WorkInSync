-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 04_kpi_pending_issues.sql
-- KPI: Pending Configuration Issues (count, severity, category, SLA)
-- Uses: CTEs, CASE, HAVING, GROUP BY, Window Functions
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- QUERY 4A: Open Issues Per Client — Severity-Weighted View
-- ─────────────────────────────────────────────────────────────
WITH issue_weights AS (
    SELECT
        ci.client_id,
        c.client_name,
        c.industry,
        c.account_manager,
        ci.issue_id,
        ci.issue_type,
        ci.issue_category,
        ci.severity,
        ci.status,
        ci.reported_date,
        CURRENT_DATE - ci.reported_date       AS days_open,
        -- Severity weight for priority scoring
        CASE ci.severity
            WHEN 'Critical' THEN 10
            WHEN 'High'     THEN 5
            WHEN 'Medium'   THEN 2
            WHEN 'Low'      THEN 1
        END                                   AS severity_weight,
        -- SLA breach check (days allowed: Critical=1, High=3, Medium=5, Low=7)
        CASE
            WHEN ci.severity = 'Critical' AND (CURRENT_DATE - ci.reported_date) > 1  THEN TRUE
            WHEN ci.severity = 'High'     AND (CURRENT_DATE - ci.reported_date) > 3  THEN TRUE
            WHEN ci.severity = 'Medium'   AND (CURRENT_DATE - ci.reported_date) > 5  THEN TRUE
            WHEN ci.severity = 'Low'      AND (CURRENT_DATE - ci.reported_date) > 7  THEN TRUE
            ELSE FALSE
        END                                   AS is_sla_breached
    FROM configuration_issues ci
    JOIN clients c ON c.client_id = ci.client_id
    WHERE ci.status <> 'Resolved'    -- Only open/in-progress
),
client_issue_summary AS (
    SELECT
        client_id,
        client_name,
        industry,
        account_manager,
        COUNT(*)                                              AS total_open_issues,
        COUNT(*) FILTER (WHERE severity = 'Critical')        AS critical_issues,
        COUNT(*) FILTER (WHERE severity = 'High')            AS high_issues,
        COUNT(*) FILTER (WHERE severity = 'Medium')          AS medium_issues,
        COUNT(*) FILTER (WHERE severity = 'Low')             AS low_issues,
        SUM(severity_weight)                                 AS weighted_issue_score,
        COUNT(*) FILTER (WHERE is_sla_breached = TRUE)       AS sla_breached_count,
        ROUND(AVG(days_open), 1)                             AS avg_days_open,
        MAX(days_open)                                       AS max_days_open
    FROM issue_weights
    GROUP BY client_id, client_name, industry, account_manager
)
SELECT
    client_id,
    client_name,
    industry,
    account_manager,
    total_open_issues,
    critical_issues,
    high_issues,
    medium_issues,
    low_issues,
    weighted_issue_score,
    sla_breached_count,
    avg_days_open,
    max_days_open,
    -- Issue risk tier based on weighted score
    CASE
        WHEN weighted_issue_score >= 40  THEN 'Critical Risk'
        WHEN weighted_issue_score >= 20  THEN 'High Risk'
        WHEN weighted_issue_score >= 10  THEN 'Medium Risk'
        ELSE                                  'Low Risk'
    END AS issue_risk_tier,
    -- Rank by weighted score (most urgent first)
    RANK() OVER (ORDER BY weighted_issue_score DESC) AS urgency_rank
FROM client_issue_summary
ORDER BY weighted_issue_score DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4B: Issues by Category — Where Are Gaps Concentrated?
-- ─────────────────────────────────────────────────────────────
SELECT
    issue_category,
    COUNT(*)                                              AS total_issues,
    COUNT(*) FILTER (WHERE status <> 'Resolved')         AS open_issues,
    COUNT(*) FILTER (WHERE status = 'Resolved')          AS resolved_issues,
    COUNT(*) FILTER (WHERE severity IN ('Critical','High')
                     AND status <> 'Resolved')           AS critical_or_high_open,
    ROUND(
        COUNT(*) FILTER (WHERE status = 'Resolved') * 100.0 / NULLIF(COUNT(*), 0), 1
    )                                                    AS resolution_rate_pct,
    ROUND(AVG(resolution_days) FILTER (WHERE resolution_days IS NOT NULL), 1)
                                                         AS avg_resolution_days,
    -- Rank by open issue count
    RANK() OVER (ORDER BY COUNT(*) FILTER (WHERE status <> 'Resolved') DESC)
                                                         AS category_risk_rank
FROM configuration_issues
GROUP BY issue_category
ORDER BY open_issues DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4C: SLA Breach Report — All Open Issues Past SLA Deadline
-- ─────────────────────────────────────────────────────────────
SELECT
    vit.client_id,
    vit.client_name,
    vit.industry,
    vit.account_manager,
    vit.issue_id,
    vit.issue_type,
    vit.issue_category,
    vit.severity,
    vit.reported_date,
    vit.days_open,
    -- SLA deadline
    vit.reported_date + CASE vit.severity
        WHEN 'Critical' THEN 1
        WHEN 'High'     THEN 3
        WHEN 'Medium'   THEN 5
        ELSE 7
    END                                      AS sla_deadline,
    -- Days past SLA
    vit.days_open - CASE vit.severity
        WHEN 'Critical' THEN 1
        WHEN 'High'     THEN 3
        WHEN 'Medium'   THEN 5
        ELSE 7
    END                                      AS days_past_sla
FROM vw_issue_tracker vit
WHERE vit.is_sla_breached = TRUE
ORDER BY vit.severity, days_past_sla DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 4D: Clients with ZERO open issues (clean portfolio view)
-- ─────────────────────────────────────────────────────────────
SELECT
    cs.client_id,
    cs.client_name,
    cs.industry,
    cs.setup_completion_pct,
    cs.activation_rate_pct,
    cs.onboarding_status,
    cs.health_score
FROM vw_client_summary cs
WHERE cs.open_issues = 0
ORDER BY cs.health_score DESC;


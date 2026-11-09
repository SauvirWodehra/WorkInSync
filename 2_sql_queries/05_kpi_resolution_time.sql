-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 05_kpi_resolution_time.sql
-- KPI: Time Taken to Resolve Implementation Issues
-- Uses: CTEs, Window Functions (NTILE, PERCENTILE_CONT), Aggregations
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- QUERY 5A: Resolution Time Statistics Per Client
-- ─────────────────────────────────────────────────────────────
WITH resolved_issues AS (
    SELECT
        ci.client_id,
        c.client_name,
        c.industry,
        c.account_manager,
        ci.issue_id,
        ci.severity,
        ci.issue_category,
        ci.reported_date,
        ci.resolved_date,
        ci.resolution_days,
        -- SLA target per severity
        CASE ci.severity
            WHEN 'Critical' THEN 1
            WHEN 'High'     THEN 3
            WHEN 'Medium'   THEN 5
            WHEN 'Low'      THEN 7
        END AS sla_days,
        -- Was it resolved within SLA?
        ci.resolution_days <= CASE ci.severity
            WHEN 'Critical' THEN 1
            WHEN 'High'     THEN 3
            WHEN 'Medium'   THEN 5
            WHEN 'Low'      THEN 7
        END AS within_sla
    FROM configuration_issues ci
    JOIN clients c ON c.client_id = ci.client_id
    WHERE ci.status = 'Resolved'
      AND ci.resolution_days IS NOT NULL
),
client_resolution_stats AS (
    SELECT
        client_id,
        client_name,
        industry,
        account_manager,
        COUNT(*)                                   AS total_resolved,
        ROUND(AVG(resolution_days), 2)             AS avg_resolution_days,
        MIN(resolution_days)                       AS min_resolution_days,
        MAX(resolution_days)                       AS max_resolution_days,
        -- Median using PERCENTILE_CONT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY resolution_days)
                                                   AS median_resolution_days,
        -- P90 — worst 10% of issues
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY resolution_days)
                                                   AS p90_resolution_days,
        COUNT(*) FILTER (WHERE within_sla = TRUE)  AS resolved_within_sla,
        COUNT(*) FILTER (WHERE within_sla = FALSE) AS resolved_outside_sla,
        ROUND(
            COUNT(*) FILTER (WHERE within_sla = TRUE) * 100.0 / NULLIF(COUNT(*),0), 1
        )                                          AS sla_compliance_pct
    FROM resolved_issues
    GROUP BY client_id, client_name, industry, account_manager
)
SELECT
    client_id,
    client_name,
    industry,
    account_manager,
    total_resolved,
    avg_resolution_days,
    median_resolution_days,
    p90_resolution_days,
    min_resolution_days,
    max_resolution_days,
    resolved_within_sla,
    resolved_outside_sla,
    sla_compliance_pct,
    -- Rank by average resolution time (fastest = rank 1)
    RANK() OVER (ORDER BY avg_resolution_days)   AS resolution_speed_rank,
    -- Quartile bucket (1=fastest 25%, 4=slowest 25%)
    NTILE(4) OVER (ORDER BY avg_resolution_days) AS resolution_quartile
FROM client_resolution_stats
ORDER BY avg_resolution_days;


-- ─────────────────────────────────────────────────────────────
-- QUERY 5B: Resolution Time by Severity & Category
-- ─────────────────────────────────────────────────────────────
SELECT
    severity,
    issue_category,
    COUNT(*)                                       AS total_resolved,
    ROUND(AVG(resolution_days), 2)                 AS avg_resolution_days,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY resolution_days)
                                                   AS median_resolution_days,
    MIN(resolution_days)                           AS fastest_days,
    MAX(resolution_days)                           AS slowest_days,
    -- SLA target for this severity
    CASE severity
        WHEN 'Critical' THEN 1
        WHEN 'High'     THEN 3
        WHEN 'Medium'   THEN 5
        WHEN 'Low'      THEN 7
    END                                            AS sla_target_days,
    -- How many beat the SLA?
    COUNT(*) FILTER (WHERE resolution_days <= CASE severity
        WHEN 'Critical' THEN 1 WHEN 'High' THEN 3
        WHEN 'Medium'   THEN 5 WHEN 'Low'  THEN 7 END
    )                                              AS within_sla_count,
    ROUND(
        COUNT(*) FILTER (WHERE resolution_days <= CASE severity
            WHEN 'Critical' THEN 1 WHEN 'High' THEN 3
            WHEN 'Medium'   THEN 5 WHEN 'Low'  THEN 7 END
        ) * 100.0 / NULLIF(COUNT(*), 0), 1
    )                                              AS sla_compliance_pct
FROM configuration_issues
WHERE status = 'Resolved'
  AND resolution_days IS NOT NULL
GROUP BY severity, issue_category
ORDER BY severity, avg_resolution_days DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 5C: Resolution Trend — Monthly resolution volumes
-- ─────────────────────────────────────────────────────────────
SELECT
    DATE_TRUNC('month', resolved_date)             AS resolution_month,
    COUNT(*)                                       AS issues_resolved,
    ROUND(AVG(resolution_days), 2)                 AS avg_days_to_resolve,
    COUNT(*) FILTER (WHERE severity = 'Critical')  AS critical_resolved,
    COUNT(*) FILTER (WHERE severity = 'High')      AS high_resolved,
    -- Running total of issues resolved
    SUM(COUNT(*)) OVER (
        ORDER BY DATE_TRUNC('month', resolved_date)
    )                                              AS cumulative_resolved
FROM configuration_issues
WHERE status = 'Resolved'
  AND resolved_date IS NOT NULL
GROUP BY DATE_TRUNC('month', resolved_date)
ORDER BY resolution_month;


-- ─────────────────────────────────────────────────────────────
-- QUERY 5D: Account Manager SLA Performance
-- ─────────────────────────────────────────────────────────────
SELECT
    c.account_manager,
    COUNT(ci.issue_id)                                   AS total_issues_handled,
    COUNT(ci.issue_id) FILTER (WHERE ci.status = 'Resolved')   AS resolved_count,
    COUNT(ci.issue_id) FILTER (WHERE ci.status <> 'Resolved')  AS open_count,
    ROUND(AVG(ci.resolution_days)
          FILTER (WHERE ci.status = 'Resolved'), 2)      AS avg_resolution_days,
    ROUND(
        COUNT(ci.issue_id) FILTER (WHERE ci.status = 'Resolved'
          AND ci.resolution_days <= CASE ci.severity
              WHEN 'Critical' THEN 1 WHEN 'High' THEN 3
              WHEN 'Medium'   THEN 5 ELSE 7 END
        ) * 100.0 / NULLIF(
            COUNT(ci.issue_id) FILTER (WHERE ci.status = 'Resolved'), 0
        ), 1
    )                                                    AS sla_compliance_pct
FROM configuration_issues ci
JOIN clients c ON c.client_id = ci.client_id
GROUP BY c.account_manager
ORDER BY sla_compliance_pct DESC;


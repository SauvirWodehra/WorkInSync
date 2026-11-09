-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 03_views.sql
-- Purpose: Reusable views consumed by SQL queries, Python & Power BI
-- =============================================================

-- =============================================================
-- VIEW 1: vw_client_summary
-- One row per client with all core KPI columns pre-aggregated
-- =============================================================
CREATE OR REPLACE VIEW vw_client_summary AS
WITH

-- Count employees per client from the employees table
emp_counts AS (
    SELECT
        client_id,
        COUNT(*)                                              AS employees_in_db,
        COUNT(*) FILTER (WHERE is_activated = TRUE)          AS activated_in_db,
        COUNT(*) FILTER (WHERE data_upload_date IS NOT NULL) AS employees_uploaded_db
    FROM employees
    GROUP BY client_id
),

-- Latest snapshot per client from onboarding_progress
latest_snapshot AS (
    SELECT DISTINCT ON (client_id)
        client_id,
        snapshot_date,
        employees_uploaded,
        employees_activated,
        setup_completion_pct,
        open_issues_count,
        milestones_completed
    FROM onboarding_progress
    ORDER BY client_id, snapshot_date DESC
),

-- Milestone stats per client
milestone_stats AS (
    SELECT
        client_id,
        COUNT(*)                                                   AS total_milestones,
        COUNT(*) FILTER (WHERE status = 'Completed')               AS milestones_done,
        COUNT(*) FILTER (WHERE status = 'Failed')                  AS milestones_failed,
        COUNT(*) FILTER (WHERE status IN ('Pending','In Progress')
                         AND planned_date < CURRENT_DATE)          AS milestones_overdue,
        MAX(delay_days)                                            AS max_milestone_delay_days,
        SUM(delay_days)                                            AS total_delay_days
    FROM implementation_milestones
    GROUP BY client_id
),

-- Issue stats per client
issue_stats AS (
    SELECT
        client_id,
        COUNT(*)                                              AS total_issues_ever,
        COUNT(*) FILTER (WHERE status = 'Open')              AS open_issues,
        COUNT(*) FILTER (WHERE status = 'In Progress')       AS inprogress_issues,
        COUNT(*) FILTER (WHERE status = 'Resolved')          AS resolved_issues,
        COUNT(*) FILTER (WHERE severity = 'Critical'
                         AND status <> 'Resolved')           AS critical_open_issues,
        ROUND(AVG(resolution_days) FILTER (WHERE resolution_days IS NOT NULL), 1)
                                                             AS avg_resolution_days,
        MAX(resolution_days)                                 AS max_resolution_days
    FROM configuration_issues
    GROUP BY client_id
),

-- Actual onboarding duration (contract start to go-live or today)
onboard_duration AS (
    SELECT
        client_id,
        CASE
            WHEN actual_go_live_date IS NOT NULL
                THEN actual_go_live_date - contract_start_date
            ELSE CURRENT_DATE - contract_start_date
        END AS onboarding_days,
        CASE
            WHEN actual_go_live_date IS NOT NULL
                THEN actual_go_live_date - expected_go_live_date
            ELSE NULL
        END AS go_live_delay_days   -- positive = late, negative = early
    FROM clients
)

SELECT
    c.client_id,
    c.client_name,
    c.industry,
    c.region,
    c.subscription_plan,
    c.account_manager,
    c.total_employees,
    c.contract_start_date,
    c.expected_go_live_date,
    c.actual_go_live_date,
    c.contract_value_inr,

    -- Onboarding duration
    od.onboarding_days,
    od.go_live_delay_days,

    -- Latest progress snapshot
    ls.employees_uploaded,
    ls.employees_activated,
    ls.setup_completion_pct,
    ls.open_issues_count           AS snapshot_open_issues,
    ls.milestones_completed        AS snapshot_milestones_done,

    -- Milestone stats
    ms.total_milestones,
    ms.milestones_done,
    ms.milestones_failed,
    ms.milestones_overdue,
    ms.max_milestone_delay_days,
    ROUND(ms.total_delay_days * 1.0 / NULLIF(ms.total_milestones,0), 1) AS avg_milestone_delay,

    -- Issue stats
    COALESCE(iss.total_issues_ever, 0)      AS total_issues_ever,
    COALESCE(iss.open_issues, 0)            AS open_issues,
    COALESCE(iss.inprogress_issues, 0)      AS inprogress_issues,
    COALESCE(iss.resolved_issues, 0)        AS resolved_issues,
    COALESCE(iss.critical_open_issues, 0)   AS critical_open_issues,
    COALESCE(iss.avg_resolution_days, 0)    AS avg_resolution_days,
    COALESCE(iss.max_resolution_days, 0)    AS max_resolution_days,

    -- Derived KPI: Activation rate %
    ROUND(ls.employees_activated * 100.0 / NULLIF(c.total_employees, 0), 2) AS activation_rate_pct,

    -- Derived KPI: Health Score (0–100)
    -- Formula:
    --   40% weight → activation rate
    --   35% weight → setup completion
    --   25% base  → penalties from issues, delays, failed milestones
    GREATEST(0, LEAST(100, ROUND(
        (ls.employees_activated * 100.0 / NULLIF(c.total_employees,0)) * 0.40
      + ls.setup_completion_pct * 0.35
      + 25
      - LEAST(COALESCE(iss.open_issues,0) * 2.0, 25)
      - LEAST(GREATEST(od.onboarding_days - 25, 0) * 0.5, 15)
      - LEAST(COALESCE(ms.milestones_failed,0) * 5.0, 10)
      - LEAST(COALESCE(iss.critical_open_issues,0) * 3.0, 15)
    ))) AS health_score,

    -- Status label (derived from health_score and completion)
    CASE
        WHEN ls.setup_completion_pct = 100
         AND COALESCE(iss.open_issues,0) = 0           THEN 'Completed'
        WHEN GREATEST(0, LEAST(100, ROUND(
                (ls.employees_activated * 100.0 / NULLIF(c.total_employees,0)) * 0.40
              + ls.setup_completion_pct * 0.35
              + 25
              - LEAST(COALESCE(iss.open_issues,0) * 2.0, 25)
              - LEAST(GREATEST(od.onboarding_days - 25, 0) * 0.5, 15)
              - LEAST(COALESCE(ms.milestones_failed,0) * 5.0, 10)
              - LEAST(COALESCE(iss.critical_open_issues,0) * 3.0, 15)
            ))) >= 80                                   THEN 'On Track'
        WHEN GREATEST(0, LEAST(100, ROUND(
                (ls.employees_activated * 100.0 / NULLIF(c.total_employees,0)) * 0.40
              + ls.setup_completion_pct * 0.35
              + 25
              - LEAST(COALESCE(iss.open_issues,0) * 2.0, 25)
              - LEAST(GREATEST(od.onboarding_days - 25, 0) * 0.5, 15)
              - LEAST(COALESCE(ms.milestones_failed,0) * 5.0, 10)
              - LEAST(COALESCE(iss.critical_open_issues,0) * 3.0, 15)
            ))) >= 60                                   THEN 'At Risk'
        ELSE 'Delayed'
    END AS onboarding_status

FROM clients             c
LEFT JOIN onboard_duration  od  ON od.client_id  = c.client_id
LEFT JOIN latest_snapshot   ls  ON ls.client_id  = c.client_id
LEFT JOIN milestone_stats   ms  ON ms.client_id  = c.client_id
LEFT JOIN issue_stats       iss ON iss.client_id = c.client_id;


-- =============================================================
-- VIEW 2: vw_weekly_trends
-- Weekly activation and completion trends per client
-- =============================================================
CREATE OR REPLACE VIEW vw_weekly_trends AS
SELECT
    op.client_id,
    c.client_name,
    c.industry,
    op.snapshot_date,
    -- Week number within the client's onboarding journey
    ROW_NUMBER() OVER (PARTITION BY op.client_id ORDER BY op.snapshot_date) AS week_num,
    op.employees_uploaded,
    op.employees_activated,
    ROUND(op.employees_activated * 100.0 / NULLIF(c.total_employees, 0), 2) AS activation_rate_pct,
    op.setup_completion_pct,
    op.open_issues_count,
    op.milestones_completed,
    -- Week-over-week activation change
    op.employees_activated
      - LAG(op.employees_activated, 1, 0)
        OVER (PARTITION BY op.client_id ORDER BY op.snapshot_date)         AS wow_activation_delta,
    -- Week-over-week completion change
    op.setup_completion_pct
      - LAG(op.setup_completion_pct, 1, 0)
        OVER (PARTITION BY op.client_id ORDER BY op.snapshot_date)         AS wow_completion_delta
FROM onboarding_progress op
JOIN clients c ON c.client_id = op.client_id
ORDER BY op.client_id, op.snapshot_date;


-- =============================================================
-- VIEW 3: vw_milestone_tracker
-- Current milestone status with delay info per client
-- =============================================================
CREATE OR REPLACE VIEW vw_milestone_tracker AS
SELECT
    im.milestone_id,
    im.client_id,
    c.client_name,
    c.industry,
    im.milestone_name,
    im.milestone_order,
    im.planned_date,
    im.actual_date,
    im.status,
    im.delay_days,
    im.notes,
    CASE
        WHEN im.status = 'Completed' AND im.delay_days = 0 THEN 'On Time'
        WHEN im.status = 'Completed' AND im.delay_days > 0 THEN 'Completed Late'
        WHEN im.status = 'Completed' AND im.actual_date < im.planned_date THEN 'Completed Early'
        WHEN im.status = 'Failed'                           THEN 'Failed'
        WHEN im.status = 'In Progress'                     THEN 'In Progress'
        WHEN im.status = 'Pending' AND im.planned_date < CURRENT_DATE THEN 'Overdue'
        ELSE 'Upcoming'
    END AS milestone_health
FROM implementation_milestones im
JOIN clients c ON c.client_id = im.client_id;


-- =============================================================
-- VIEW 4: vw_issue_tracker
-- Full issue detail with client context and SLA breach flag
-- =============================================================
CREATE OR REPLACE VIEW vw_issue_tracker AS
SELECT
    ci.issue_id,
    ci.client_id,
    c.client_name,
    c.industry,
    c.account_manager,
    ci.issue_type,
    ci.issue_category,
    ci.severity,
    ci.reported_date,
    ci.resolved_date,
    ci.status,
    ci.resolution_days,
    -- Days since issue was reported (for open issues)
    CASE
        WHEN ci.status <> 'Resolved'
        THEN CURRENT_DATE - ci.reported_date
        ELSE NULL
    END AS days_open,
    -- SLA breach: Critical >1d, High >3d, Medium >5d, Low >7d
    CASE
        WHEN ci.status = 'Resolved' THEN FALSE
        WHEN ci.severity = 'Critical' AND (CURRENT_DATE - ci.reported_date) > 1  THEN TRUE
        WHEN ci.severity = 'High'     AND (CURRENT_DATE - ci.reported_date) > 3  THEN TRUE
        WHEN ci.severity = 'Medium'   AND (CURRENT_DATE - ci.reported_date) > 5  THEN TRUE
        WHEN ci.severity = 'Low'      AND (CURRENT_DATE - ci.reported_date) > 7  THEN TRUE
        ELSE FALSE
    END AS is_sla_breached
FROM configuration_issues ci
JOIN clients c ON c.client_id = ci.client_id;


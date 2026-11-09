-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 06_kpi_health_score.sql
-- KPI: Client-wise Onboarding Health Score (0–100)
-- Uses: Complex CTE chain, weighted formula, CASE, Window Functions
-- =============================================================

-- ─────────────────────────────────────────────────────────────
-- QUERY 6A: Health Score Calculation — Full Breakdown
-- Health Score Formula (all components shown separately):
--   Component A (40%): Employee Activation Rate
--   Component B (35%): Setup Completion %
--   Component C (25%): Issue & Delay Penalties
--     - Open issues:         -2 pts each   (max -25)
--     - Onboarding days >25: -0.5/day      (max -15)
--     - Failed milestones:   -5 pts each   (max -10)
--     - Critical open issues:-3 pts each   (max -15)
-- ─────────────────────────────────────────────────────────────
WITH health_components AS (
    SELECT
        cs.client_id,
        cs.client_name,
        cs.industry,
        cs.region,
        cs.subscription_plan,
        cs.account_manager,
        cs.total_employees,
        cs.contract_value_inr,

        -- Component A: Activation
        ROUND(cs.activation_rate_pct * 0.40, 2)                        AS comp_a_activation,
        -- Component B: Setup completion
        ROUND(cs.setup_completion_pct * 0.35, 2)                       AS comp_b_setup,
        -- Penalties breakdown
        LEAST(cs.open_issues * 2.0, 25)                                AS penalty_open_issues,
        LEAST(GREATEST(cs.onboarding_days - 25, 0) * 0.5, 15)         AS penalty_time_overrun,
        LEAST(cs.milestones_failed * 5.0, 10)                          AS penalty_failed_milestones,
        LEAST(cs.critical_open_issues * 3.0, 15)                       AS penalty_critical_issues,

        -- Raw sub-scores
        cs.activation_rate_pct,
        cs.setup_completion_pct,
        cs.open_issues,
        cs.critical_open_issues,
        cs.milestones_failed,
        cs.onboarding_days,
        cs.health_score,
        cs.onboarding_status
    FROM vw_client_summary cs
),
scored AS (
    SELECT
        *,
        -- Total penalty
        ROUND(penalty_open_issues + penalty_time_overrun
              + penalty_failed_milestones + penalty_critical_issues, 2)      AS total_penalty,
        -- Verify: health_score = comp_a + comp_b + 25 - total_penalty (clamped 0–100)
        GREATEST(0, LEAST(100,
            ROUND(comp_a_activation + comp_b_setup + 25
                  - (penalty_open_issues + penalty_time_overrun
                     + penalty_failed_milestones + penalty_critical_issues), 0)
        ))                                                                   AS computed_health_score,
        -- Health tier
        CASE
            WHEN health_score >= 90 THEN 'Excellent'
            WHEN health_score >= 80 THEN 'Good'
            WHEN health_score >= 65 THEN 'Needs Attention'
            WHEN health_score >= 50 THEN 'At Risk'
            ELSE                        'Critical'
        END AS health_tier,
        -- Rank (1 = healthiest)
        RANK() OVER (ORDER BY health_score DESC) AS health_rank,
        -- Portfolio average for comparison
        ROUND(AVG(health_score) OVER (), 1)       AS portfolio_avg_health
    FROM health_components
)
SELECT
    health_rank,
    client_id,
    client_name,
    industry,
    region,
    subscription_plan,
    account_manager,
    contract_value_inr,
    -- Component breakdown
    activation_rate_pct,
    comp_a_activation,
    setup_completion_pct,
    comp_b_setup,
    -- Penalties
    penalty_open_issues,
    penalty_time_overrun,
    penalty_failed_milestones,
    penalty_critical_issues,
    total_penalty,
    -- Final scores
    computed_health_score   AS health_score,
    health_tier,
    onboarding_status,
    portfolio_avg_health,
    -- Delta vs portfolio average
    computed_health_score - portfolio_avg_health  AS delta_vs_portfolio
FROM scored
ORDER BY health_rank;


-- ─────────────────────────────────────────────────────────────
-- QUERY 6B: Health Score by Industry
-- ─────────────────────────────────────────────────────────────
SELECT
    industry,
    COUNT(*)                                           AS client_count,
    ROUND(AVG(health_score), 1)                        AS avg_health_score,
    MIN(health_score)                                  AS min_health_score,
    MAX(health_score)                                  AS max_health_score,
    COUNT(*) FILTER (WHERE health_score >= 80)         AS healthy_clients,
    COUNT(*) FILTER (WHERE health_score < 60)          AS critical_clients,
    SUM(contract_value_inr)                            AS industry_arr_inr
FROM vw_client_summary
GROUP BY industry
ORDER BY avg_health_score DESC;


-- ─────────────────────────────────────────────────────────────
-- QUERY 6C: Health Score Movement — Week-over-Week Change
-- (using onboarding_progress snapshots to simulate score over time)
-- ─────────────────────────────────────────────────────────────
WITH weekly_health AS (
    SELECT
        op.client_id,
        c.client_name,
        c.total_employees,
        op.snapshot_date,
        ROW_NUMBER() OVER (PARTITION BY op.client_id ORDER BY op.snapshot_date) AS week_num,
        -- Recompute health score for each weekly snapshot
        GREATEST(0, LEAST(100, ROUND(
            (op.employees_activated * 100.0 / NULLIF(c.total_employees,0)) * 0.40
          + op.setup_completion_pct * 0.35
          + 25
          - LEAST(op.open_issues_count * 2.0, 25)
          - LEAST(GREATEST((op.snapshot_date - c.contract_start_date - 25), 0) * 0.5, 15)
        ))) AS weekly_health_score
    FROM onboarding_progress op
    JOIN clients c ON c.client_id = op.client_id
)
SELECT
    client_id,
    client_name,
    snapshot_date,
    week_num,
    weekly_health_score,
    -- Week-over-week health change
    weekly_health_score
      - LAG(weekly_health_score, 1, 0)
        OVER (PARTITION BY client_id ORDER BY snapshot_date)   AS wow_health_delta,
    -- Flag deteriorating health (negative WoW change)
    CASE
        WHEN weekly_health_score
           - LAG(weekly_health_score, 1, weekly_health_score)
             OVER (PARTITION BY client_id ORDER BY snapshot_date) < -5
        THEN 'Deteriorating'
        WHEN weekly_health_score
           - LAG(weekly_health_score, 1, weekly_health_score)
             OVER (PARTITION BY client_id ORDER BY snapshot_date) > 5
        THEN 'Improving'
        ELSE 'Stable'
    END AS health_trend
FROM weekly_health
ORDER BY client_id, snapshot_date;


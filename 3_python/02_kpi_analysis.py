# =============================================================
# WorkInSync Implementation Dashboard
# File: 02_kpi_analysis.py
# Purpose: Compute all 6 KPIs using Pandas — validating SQL outputs
# Run:  python 02_kpi_analysis.py
# =============================================================

import pandas as pd
import numpy as np
from sqlalchemy import create_engine, text
from config import DB_CONFIG


def get_engine():
    conn_str = (
        f"postgresql+psycopg2://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
    )
    return create_engine(conn_str, echo=False)


# ─────────────────────────────────────────────────────────────
# Load base DataFrames
# ─────────────────────────────────────────────────────────────
def load_data() -> dict[str, pd.DataFrame]:
    engine = get_engine()
    with engine.connect() as conn:
        return {
            "cs":       pd.read_sql(text("SELECT * FROM vw_client_summary"), conn),
            "trends":   pd.read_sql(text("SELECT * FROM vw_weekly_trends"), conn),
            "issues":   pd.read_sql(text("SELECT * FROM vw_issue_tracker"), conn),
            "milestones": pd.read_sql(text("SELECT * FROM vw_milestone_tracker"), conn),
            "clients":  pd.read_sql(text("SELECT * FROM clients"), conn),
        }


# ─────────────────────────────────────────────────────────────
# KPI 1: Implementation Completion Rate
# ─────────────────────────────────────────────────────────────
def kpi_completion_rate(cs: pd.DataFrame) -> pd.DataFrame:
    """
    Returns per-client completion rate and portfolio summary.
    Business rule: Setup % from latest onboarding_progress snapshot.
    """
    result = cs[[
        "client_id", "client_name", "industry", "region",
        "subscription_plan", "setup_completion_pct", "onboarding_status",
        "health_score"
    ]].copy()

    result["completion_gap"] = 100 - result["setup_completion_pct"]
    result["completion_tier"] = pd.cut(
        result["setup_completion_pct"],
        bins=[0, 50, 70, 90, 100],
        labels=["Low (<50%)", "Medium (50-70%)", "Good (70-90%)", "Complete (>90%)"],
        right=True,
    )

    portfolio_avg = result["setup_completion_pct"].mean()
    result["vs_portfolio_avg"] = result["setup_completion_pct"] - portfolio_avg
    result["rank_global"] = result["setup_completion_pct"].rank(ascending=False, method="min").astype(int)

    print(f"\n── KPI 1: Implementation Completion Rate ──────────")
    print(f"  Portfolio Average : {portfolio_avg:.2f}%")
    print(f"  Clients ≥ 90%     : {(result['setup_completion_pct'] >= 90).sum()}")
    print(f"  Clients < 70%     : {(result['setup_completion_pct'] < 70).sum()}")
    return result.sort_values("rank_global")


# ─────────────────────────────────────────────────────────────
# KPI 2: Average Onboarding Time
# ─────────────────────────────────────────────────────────────
def kpi_onboarding_time(cs: pd.DataFrame) -> pd.DataFrame:
    """
    Per-client onboarding duration + SLA compliance.
    SLA targets: Enterprise=45d, Professional=30d, Basic=21d
    """
    SLA_MAP = {"Enterprise": 45, "Professional": 30, "Basic": 21}

    result = cs[[
        "client_id", "client_name", "industry", "subscription_plan",
        "onboarding_days", "go_live_delay_days", "onboarding_status"
    ]].copy()

    result["sla_target_days"] = result["subscription_plan"].map(SLA_MAP)
    result["within_sla"] = result["onboarding_days"] <= result["sla_target_days"]
    result["days_over_sla"] = (result["onboarding_days"] - result["sla_target_days"]).clip(lower=0)
    result["duration_bucket"] = pd.cut(
        result["onboarding_days"],
        bins=[0, 21, 35, 60, 999],
        labels=["Fast (≤21d)", "Normal (22-35d)", "Slow (36-60d)", "Critical (>60d)"],
        right=True,
    )
    result["rank"] = result["onboarding_days"].rank(ascending=True, method="min").astype(int)

    avg_days = result["onboarding_days"].mean()
    sla_pct  = result["within_sla"].mean() * 100

    print(f"\n── KPI 2: Average Onboarding Time ─────────────────")
    print(f"  Portfolio Average : {avg_days:.1f} days")
    print(f"  Within SLA        : {sla_pct:.1f}% of clients")
    print(f"  Fastest           : {result['onboarding_days'].min()} days ({result.loc[result['onboarding_days'].idxmin(),'client_name']})")
    print(f"  Slowest           : {result['onboarding_days'].max()} days ({result.loc[result['onboarding_days'].idxmax(),'client_name']})")
    return result.sort_values("rank")


# ─────────────────────────────────────────────────────────────
# KPI 3: Employee Activation Rate
# ─────────────────────────────────────────────────────────────
def kpi_activation_rate(cs: pd.DataFrame, trends: pd.DataFrame) -> dict:
    """
    Returns:
      - per_client: activation rate per client with tier
      - by_industry: aggregated by industry
      - trend: week-over-week activation momentum
    """
    # Per-client
    per_client = cs[[
        "client_id", "client_name", "industry", "total_employees",
        "employees_activated", "activation_rate_pct", "onboarding_status"
    ]].copy()
    per_client["employees_pending"] = per_client["total_employees"] - per_client["employees_activated"]
    per_client["activation_tier"] = pd.cut(
        per_client["activation_rate_pct"],
        bins=[0, 60, 75, 90, 100],
        labels=["Poor (<60%)", "Acceptable (60-75%)", "Good (75-90%)", "Excellent (≥90%)"],
        right=True,
    )
    per_client["rank"] = per_client["activation_rate_pct"].rank(ascending=False, method="min").astype(int)

    # By industry
    by_industry = (
        cs.groupby("industry")
        .agg(
            total_employees=("total_employees", "sum"),
            total_activated=("employees_activated", "sum"),
            client_count=("client_id", "count"),
        )
        .assign(
            industry_activation_pct=lambda d:
                (d["total_activated"] / d["total_employees"] * 100).round(2)
        )
        .reset_index()
        .sort_values("industry_activation_pct", ascending=False)
    )

    # Trend (week-over-week)
    trend = trends[[
        "client_id", "client_name", "snapshot_date", "week_num",
        "employees_activated", "activation_rate_pct",
        "wow_activation_delta", "wow_completion_delta"
    ]].copy()
    trend["momentum"] = np.select(
        [trend["wow_activation_delta"] < 0,
         trend["wow_activation_delta"] == 0,
         trend["wow_activation_delta"] > 100],
        ["Declining", "Stalled", "Accelerating"],
        default="Steady"
    )

    overall_rate = cs["employees_activated"].sum() / cs["total_employees"].sum() * 100

    print(f"\n── KPI 3: Employee Activation Rate ────────────────")
    print(f"  Portfolio Rate    : {overall_rate:.2f}%")
    print(f"  Total Activated   : {cs['employees_activated'].sum():,} / {cs['total_employees'].sum():,}")
    print(f"  Clients Excellent : {(per_client['activation_rate_pct'] >= 90).sum()}")
    print(f"  Clients Poor      : {(per_client['activation_rate_pct'] < 60).sum()}")

    return {"per_client": per_client.sort_values("rank"),
            "by_industry": by_industry,
            "trend": trend}


# ─────────────────────────────────────────────────────────────
# KPI 4: Pending Configuration Issues
# ─────────────────────────────────────────────────────────────
def kpi_pending_issues(issues_df: pd.DataFrame, cs: pd.DataFrame) -> dict:
    """
    Returns:
      - open_issues: all currently open/in-progress issues
      - by_category: issue counts aggregated by category
      - sla_breach: issues past their SLA deadline
    """
    SLA_DAYS = {"Critical": 1, "High": 3, "Medium": 5, "Low": 7}
    open_df = issues_df[issues_df["status"] != "Resolved"].copy()
    open_df["sla_target_days"] = open_df["severity"].map(SLA_DAYS)
    open_df["is_sla_breached"] = open_df["days_open"] > open_df["sla_target_days"]
    open_df["days_past_sla"] = (open_df["days_open"] - open_df["sla_target_days"]).clip(lower=0)

    # Severity weight for urgency scoring
    WEIGHTS = {"Critical": 10, "High": 5, "Medium": 2, "Low": 1}
    open_df["severity_weight"] = open_df["severity"].map(WEIGHTS)

    # Per-client summary
    client_issues = (
        open_df.groupby(["client_id", "client_name"])
        .agg(
            total_open=("issue_id", "count"),
            critical_open=("severity", lambda x: (x == "Critical").sum()),
            high_open=("severity", lambda x: (x == "High").sum()),
            sla_breached=("is_sla_breached", "sum"),
            weighted_score=("severity_weight", "sum"),
        )
        .reset_index()
        .sort_values("weighted_score", ascending=False)
    )

    # By category
    by_cat = (
        open_df.groupby("issue_category")
        .agg(open_issues=("issue_id", "count"), sla_breached=("is_sla_breached", "sum"))
        .reset_index()
        .sort_values("open_issues", ascending=False)
    )

    sla_breach = open_df[open_df["is_sla_breached"] == True].sort_values(
        ["severity", "days_past_sla"], ascending=[True, False]
    )

    print(f"\n── KPI 4: Pending Configuration Issues ────────────")
    print(f"  Total Open Issues : {len(open_df)}")
    print(f"  Critical Open     : {(open_df['severity'] == 'Critical').sum()}")
    print(f"  SLA Breached      : {open_df['is_sla_breached'].sum()}")
    print(f"  Clients Affected  : {open_df['client_id'].nunique()}")

    return {"open_issues": open_df, "by_category": by_cat,
            "client_summary": client_issues, "sla_breach": sla_breach}


# ─────────────────────────────────────────────────────────────
# KPI 5: Resolution Time
# ─────────────────────────────────────────────────────────────
def kpi_resolution_time(issues_df: pd.DataFrame) -> dict:
    """
    Returns resolved issue stats with SLA compliance and percentiles.
    """
    resolved = issues_df[
        (issues_df["status"] == "Resolved") & (issues_df["resolution_days"].notna())
    ].copy()

    SLA_DAYS = {"Critical": 1, "High": 3, "Medium": 5, "Low": 7}
    resolved["sla_target"] = resolved["severity"].map(SLA_DAYS)
    resolved["within_sla"] = resolved["resolution_days"] <= resolved["sla_target"]

    # Per-client stats
    per_client = (
        resolved.groupby(["client_id", "client_name"])
        .agg(
            total_resolved=("issue_id", "count"),
            avg_resolution_days=("resolution_days", "mean"),
            median_resolution_days=("resolution_days", "median"),
            p90_resolution_days=("resolution_days", lambda x: x.quantile(0.9)),
            within_sla_count=("within_sla", "sum"),
        )
        .assign(
            avg_resolution_days=lambda d: d["avg_resolution_days"].round(2),
            sla_compliance_pct=lambda d: (d["within_sla_count"] / d["total_resolved"] * 100).round(1),
        )
        .reset_index()
        .sort_values("avg_resolution_days")
    )

    # By severity
    by_severity = (
        resolved.groupby("severity")
        .agg(
            count=("issue_id", "count"),
            avg_days=("resolution_days", "mean"),
            median_days=("resolution_days", "median"),
            within_sla=("within_sla", "sum"),
        )
        .assign(
            avg_days=lambda d: d["avg_days"].round(2),
            sla_pct=lambda d: (d["within_sla"] / d["count"] * 100).round(1),
        )
        .reset_index()
    )

    overall_avg = resolved["resolution_days"].mean()
    sla_pct     = resolved["within_sla"].mean() * 100

    print(f"\n── KPI 5: Issue Resolution Time ────────────────────")
    print(f"  Overall Avg       : {overall_avg:.2f} days")
    print(f"  SLA Compliance    : {sla_pct:.1f}%")
    print(f"  Fastest Resolution: {resolved['resolution_days'].min()} days")
    print(f"  Slowest Resolution: {resolved['resolution_days'].max()} days")

    return {"per_client": per_client, "by_severity": by_severity, "resolved_issues": resolved}


# ─────────────────────────────────────────────────────────────
# KPI 6: Health Score
# ─────────────────────────────────────────────────────────────
def kpi_health_score(cs: pd.DataFrame) -> pd.DataFrame:
    """
    Recompute and validate health scores, add tier and ranking.
    Health Score = (Activation% * 0.40) + (Setup% * 0.35) + 25
                  - min(open_issues * 2, 25)
                  - min(max(onboarding_days - 25, 0) * 0.5, 15)
                  - min(failed_milestones * 5, 10)
                  - min(critical_open_issues * 3, 15)
    """
    df = cs[[
        "client_id", "client_name", "industry", "region",
        "subscription_plan", "account_manager", "contract_value_inr",
        "activation_rate_pct", "setup_completion_pct", "open_issues",
        "critical_open_issues", "milestones_failed", "onboarding_days",
        "health_score", "onboarding_status"
    ]].copy()

    # Recompute for validation
    df["comp_a"] = df["activation_rate_pct"] * 0.40
    df["comp_b"] = df["setup_completion_pct"] * 0.35
    df["pen_issues"]     = (df["open_issues"] * 2).clip(upper=25)
    df["pen_time"]       = ((df["onboarding_days"] - 25).clip(lower=0) * 0.5).clip(upper=15)
    df["pen_milestones"] = (df["milestones_failed"] * 5).clip(upper=10)
    df["pen_critical"]   = (df["critical_open_issues"] * 3).clip(upper=15)
    df["total_penalty"]  = df[["pen_issues","pen_time","pen_milestones","pen_critical"]].sum(axis=1)
    df["computed_score"] = (df["comp_a"] + df["comp_b"] + 25 - df["total_penalty"]).clip(0, 100).round(0).astype(int)
    df["score_matches"]  = df["health_score"] == df["computed_score"]

    df["health_tier"] = pd.cut(
        df["health_score"],
        bins=[0, 50, 65, 80, 90, 100],
        labels=["Critical (<50)", "At Risk (50-64)", "Needs Attention (65-79)",
                "Good (80-89)", "Excellent (90-100)"],
        right=True,
    )
    df["rank"] = df["health_score"].rank(ascending=False, method="min").astype(int)

    portfolio_avg = df["health_score"].mean()
    print(f"\n── KPI 6: Client-wise Health Score ────────────────")
    print(f"  Portfolio Average : {portfolio_avg:.1f}")
    print(f"  Excellent (≥90)   : {(df['health_score'] >= 90).sum()}")
    print(f"  Critical  (<50)   : {(df['health_score'] < 50).sum()}")
    if not df["score_matches"].all():
        print(f"  ⚠️  Score mismatch : {(~df['score_matches']).sum()} rows")
    else:
        print("  ✅  All health scores match computed formula")

    return df.sort_values("rank")


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 55)
    print("  WorkInSync KPI Analysis")
    print("=" * 55)

    data = load_data()
    cs       = data["cs"]
    trends   = data["trends"]
    issues   = data["issues"]
    ms       = data["milestones"]

    kpi1 = kpi_completion_rate(cs)
    kpi2 = kpi_onboarding_time(cs)
    kpi3 = kpi_activation_rate(cs, trends)
    kpi4 = kpi_pending_issues(issues, cs)
    kpi5 = kpi_resolution_time(issues)
    kpi6 = kpi_health_score(cs)

    print("\n" + "=" * 55)
    print("  All KPIs computed successfully.")
    print("  Run 03_export_excel.py to generate the Excel report.")
    print("=" * 55)


# =============================================================
# WorkInSync Implementation Dashboard
# File: 03_export_excel.py
# Purpose: Generate a fully formatted, multi-sheet Excel report
#          using openpyxl with colours, conditional formatting,
#          charts, and an Executive Summary.
# Run:  python 03_export_excel.py
# =============================================================

import os
import sys
import pandas as pd
import numpy as np
from sqlalchemy import create_engine, text
from openpyxl import Workbook
from openpyxl.styles import (
    PatternFill, Font, Alignment, Border, Side, GradientFill
)
from openpyxl.utils import get_column_letter
from openpyxl.chart import BarChart, LineChart, Reference
from openpyxl.chart.series import DataPoint
from openpyxl.formatting.rule import ColorScaleRule, DataBarRule, CellIsRule
from openpyxl.utils.dataframe import dataframe_to_rows
from config import DB_CONFIG, EXCEL_OUTPUT_PATH

# ─────────────────────────────────────────────────────────────
# Colour palette
# ─────────────────────────────────────────────────────────────
C = {
    "bg_dark":     "1A1D2E",
    "bg_mid":      "242740",
    "accent":      "6366F1",
    "accent_lt":   "818CF8",
    "green":       "22C55E",
    "green_lt":    "BBF7D0",
    "yellow":      "F59E0B",
    "yellow_lt":   "FEF3C7",
    "red":         "EF4444",
    "red_lt":      "FEE2E2",
    "orange":      "F97316",
    "orange_lt":   "FFEDD5",
    "white":       "FFFFFF",
    "light_grey":  "F1F5F9",
    "mid_grey":    "CBD5E1",
    "text_dark":   "0F172A",
}

def fill(hex_color: str) -> PatternFill:
    return PatternFill("solid", fgColor=hex_color)

def font(bold=False, color="0F172A", size=11, italic=False) -> Font:
    return Font(bold=bold, color=color, size=size, italic=italic,
                name="Calibri")

def border_thin():
    s = Side(border_style="thin", color="CBD5E1")
    return Border(left=s, right=s, top=s, bottom=s)

def border_bottom():
    s = Side(border_style="medium", color="6366F1")
    return Border(bottom=s)

def align(h="left", v="center", wrap=False) -> Alignment:
    return Alignment(horizontal=h, vertical=v, wrap_text=wrap)


# ─────────────────────────────────────────────────────────────
# Helper: write a styled header row
# ─────────────────────────────────────────────────────────────
def write_header(ws, row: int, columns: list[str], bg=C["bg_mid"], fg=C["white"]):
    for col_idx, col_name in enumerate(columns, start=1):
        cell = ws.cell(row=row, column=col_idx, value=col_name)
        cell.fill = fill(bg)
        cell.font = font(bold=True, color=fg, size=10)
        cell.alignment = align(h="center", wrap=True)
        cell.border = border_thin()

def write_df(ws, df: pd.DataFrame, start_row: int = 2,
             header_bg=C["bg_mid"], header_fg=C["white"],
             stripe=True):
    """Write a DataFrame to a worksheet with header + data rows."""
    write_header(ws, start_row, list(df.columns), bg=header_bg, fg=header_fg)
    for r_idx, row in enumerate(df.itertuples(index=False), start=start_row + 1):
        for c_idx, value in enumerate(row, start=1):
            cell = ws.cell(row=r_idx, column=c_idx, value=value)
            cell.border = border_thin()
            cell.alignment = align(h="center")
            cell.font = font(size=10)
            if stripe and r_idx % 2 == 0:
                cell.fill = fill(C["light_grey"])

def auto_width(ws, min_w=10, max_w=35):
    for col in ws.columns:
        max_len = max((len(str(cell.value or "")) for cell in col), default=10)
        ws.column_dimensions[get_column_letter(col[0].column)].width = max(min_w, min(max_w, max_len + 2))


# ─────────────────────────────────────────────────────────────
# Database connection
# ─────────────────────────────────────────────────────────────
def get_engine():
    return create_engine(
        f"postgresql+psycopg2://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}",
        echo=False
    )

def load_all():
    engine = get_engine()
    with engine.connect() as conn:
        return {
            "cs":       pd.read_sql(text("SELECT * FROM vw_client_summary ORDER BY health_score ASC"), conn),
            "trends":   pd.read_sql(text("SELECT * FROM vw_weekly_trends ORDER BY client_id, snapshot_date"), conn),
            "issues":   pd.read_sql(text("SELECT * FROM vw_issue_tracker ORDER BY client_id, reported_date"), conn),
            "milestones": pd.read_sql(text("SELECT * FROM vw_milestone_tracker ORDER BY client_id, milestone_order"), conn),
        }


# ─────────────────────────────────────────────────────────────
# SHEET 1: Executive Summary
# ─────────────────────────────────────────────────────────────
def sheet_executive_summary(wb: Workbook, cs: pd.DataFrame):
    ws = wb.active
    ws.title = "📊 Executive Summary"
    ws.sheet_view.showGridLines = False

    # Title banner
    ws.merge_cells("A1:L2")
    title_cell = ws["A1"]
    title_cell.value = "WorkInSync — Implementation Dashboard  |  Executive Summary  |  Q4 2026"
    title_cell.fill = fill(C["bg_dark"])
    title_cell.font = Font(bold=True, color=C["white"], size=18, name="Calibri")
    title_cell.alignment = align(h="center", v="center")
    ws.row_dimensions[1].height = 30
    ws.row_dimensions[2].height = 15

    # ── KPI Cards (row 4–9) ──
    kpis = [
        ("Total Clients",           len(cs),                                           C["accent"],  "A"),
        ("Avg Completion Rate",     f"{cs['setup_completion_pct'].mean():.1f}%",        C["green"],   "C"),
        ("Employee Activation",     f"{(cs['employees_activated'].sum()/cs['total_employees'].sum()*100):.1f}%", C["yellow"], "E"),
        ("Total Open Issues",       int(cs["open_issues"].sum()),                       C["red"],     "G"),
        ("Avg Onboarding Days",     f"{cs['onboarding_days'].mean():.1f}d",             C["orange"],  "I"),
        ("Portfolio Health Score",  f"{cs['health_score'].mean():.0f}/100",             C["accent"],  "K"),
    ]

    for label, value, color, col in kpis:
        # Label cell
        lc = ws[f"{col}4"]
        lc.value = label
        lc.fill = fill(color)
        lc.font = font(bold=True, color=C["white"], size=10)
        lc.alignment = align(h="center")
        ws.merge_cells(f"{col}4:{chr(ord(col)+1)}4")

        # Value cell
        vc = ws[f"{col}5"]
        vc.value = value
        vc.fill = fill(C["light_grey"])
        vc.font = font(bold=True, size=20, color=color)
        vc.alignment = align(h="center", v="center")
        ws.merge_cells(f"{col}5:{chr(ord(col)+1)}7")
        ws.row_dimensions[5].height = 40

    # ── Status Summary (row 10) ──
    status_counts = cs["onboarding_status"].value_counts().to_dict()
    status_data = [
        ("✅ Completed", status_counts.get("Completed", 0), C["green"]),
        ("🔵 On Track",  status_counts.get("On Track",  0), C["accent"]),
        ("⚠️ At Risk",   status_counts.get("At Risk",   0), C["yellow"]),
        ("🔴 Delayed",   status_counts.get("Delayed",   0), C["red"]),
    ]
    for i, (label, count, color) in enumerate(status_data):
        col_start = 1 + i * 3
        ws.merge_cells(start_row=10, start_column=col_start, end_row=10, end_column=col_start+2)
        cell = ws.cell(row=10, column=col_start, value=f"{label}: {count}")
        cell.fill = fill(color)
        cell.font = font(bold=True, color=C["white"], size=12)
        cell.alignment = align(h="center")
    ws.row_dimensions[10].height = 25

    # ── ARR Summary ──
    ws.cell(row=12, column=1, value="Total ARR (Crore ₹)").font = font(bold=True, size=11)
    ws.cell(row=12, column=2, value=f"₹{cs['contract_value_inr'].sum()/1e7:.2f} Cr").font = font(bold=True, color=C["green"], size=12)
    ws.cell(row=13, column=1, value="ARR at Risk (Health < 70)").font = font(bold=True, size=11)
    arr_at_risk = cs.loc[cs["health_score"] < 70, "contract_value_inr"].sum()
    ws.cell(row=13, column=2, value=f"₹{arr_at_risk/1e7:.2f} Cr").font = font(bold=True, color=C["red"], size=12)

    # ── Top 5 Clients At Risk ──
    ws.cell(row=15, column=1, value="🚨 Top Clients Requiring Immediate Attention").font = font(bold=True, size=12, color=C["red"])
    at_risk_df = cs[cs["onboarding_status"].isin(["Delayed", "At Risk"])].sort_values("health_score").head(5)
    headers = ["Client", "Industry", "Health", "Setup%", "Activation%", "Open Issues", "Status"]
    write_header(ws, 16, headers, bg=C["red"], fg=C["white"])
    for r, row in enumerate(at_risk_df.itertuples(), start=17):
        data = [row.client_name, row.industry, row.health_score,
                f"{row.setup_completion_pct}%", f"{row.activation_rate_pct}%",
                row.open_issues, row.onboarding_status]
        for c, val in enumerate(data, start=1):
            cell = ws.cell(row=r, column=c, value=val)
            cell.border = border_thin()
            cell.alignment = align(h="center")
            cell.font = font(size=10)
            if c == 3:  # health score
                cell.font = font(bold=True, color=C["red"], size=10)

    auto_width(ws)


# ─────────────────────────────────────────────────────────────
# SHEET 2: Client Master (all KPIs per client)
# ─────────────────────────────────────────────────────────────
def sheet_client_master(wb: Workbook, cs: pd.DataFrame):
    ws = wb.create_sheet("📋 Client Master")
    ws.sheet_view.showGridLines = False

    ws.merge_cells("A1:N1")
    ws["A1"].value = "Client-wise Onboarding Master — All KPIs"
    ws["A1"].fill = fill(C["bg_mid"])
    ws["A1"].font = font(bold=True, color=C["white"], size=14)
    ws["A1"].alignment = align(h="center")
    ws.row_dimensions[1].height = 25

    cols = [
        "client_name", "industry", "region", "subscription_plan",
        "setup_completion_pct", "activation_rate_pct", "onboarding_days",
        "open_issues", "critical_open_issues", "avg_resolution_days",
        "health_score", "onboarding_status", "contract_value_inr",
        "milestones_done", "milestones_failed"
    ]
    headers = [
        "Client", "Industry", "Region", "Plan",
        "Setup %", "Activation %", "Onboarding Days",
        "Open Issues", "Critical Issues", "Avg Resolution (d)",
        "Health Score", "Status", "Contract Value (₹)",
        "Milestones Done", "Milestones Failed"
    ]
    display = cs[cols].copy()
    display.columns = headers
    write_df(ws, display, start_row=2, header_bg=C["accent"], stripe=True)

    # Conditional formatting — Health Score (column K = 11)
    health_col = get_column_letter(headers.index("Health Score") + 1)
    ws.conditional_formatting.add(
        f"{health_col}3:{health_col}{len(display)+2}",
        ColorScaleRule(
            start_type="num", start_value=0,  start_color=C["red"],
            mid_type="num",   mid_value=70,   mid_color=C["yellow"],
            end_type="num",   end_value=100,  end_color=C["green"],
        )
    )

    # Data bar for Setup % (column E = 5)
    setup_col = get_column_letter(headers.index("Setup %") + 1)
    ws.conditional_formatting.add(
        f"{setup_col}3:{setup_col}{len(display)+2}",
        DataBarRule(start_type="num", start_value=0,
                    end_type="num", end_value=100,
                    color=C["accent"])
    )

    auto_width(ws)


# ─────────────────────────────────────────────────────────────
# SHEET 3: Issue Tracker
# ─────────────────────────────────────────────────────────────
def sheet_issues(wb: Workbook, issues: pd.DataFrame):
    ws = wb.create_sheet("🛠️ Issue Tracker")
    ws.sheet_view.showGridLines = False

    ws.merge_cells("A1:K1")
    ws["A1"].value = "Configuration Issue Tracker — All Clients"
    ws["A1"].fill = fill(C["red"])
    ws["A1"].font = font(bold=True, color=C["white"], size=14)
    ws["A1"].alignment = align(h="center")
    ws.row_dimensions[1].height = 25

    cols = [
        "client_name", "issue_type", "issue_category", "severity",
        "reported_date", "resolved_date", "status",
        "resolution_days", "days_open", "is_sla_breached", "account_manager"
    ]
    headers = [
        "Client", "Issue", "Category", "Severity",
        "Reported", "Resolved", "Status",
        "Resolution Days", "Days Open", "SLA Breached?", "Account Manager"
    ]
    display = issues[cols].copy()
    display.columns = headers
    write_df(ws, display, start_row=2, header_bg=C["red"])

    # Colour rows by severity
    sev_colors = {"Critical": C["red_lt"], "High": C["orange_lt"],
                  "Medium": C["yellow_lt"], "Low": C["green_lt"]}
    for r_idx, row in enumerate(display.itertuples(index=False), start=3):
        sev = row[3]  # Severity column
        bg = sev_colors.get(sev, C["white"])
        for c_idx in range(1, len(headers) + 1):
            ws.cell(row=r_idx, column=c_idx).fill = fill(bg)

    auto_width(ws)


# ─────────────────────────────────────────────────────────────
# SHEET 4: Milestone Tracker
# ─────────────────────────────────────────────────────────────
def sheet_milestones(wb: Workbook, ms: pd.DataFrame):
    ws = wb.create_sheet("🗓️ Milestone Tracker")
    ws.sheet_view.showGridLines = False

    ws.merge_cells("A1:I1")
    ws["A1"].value = "Implementation Milestone Tracker — All Clients"
    ws["A1"].fill = fill(C["accent"])
    ws["A1"].font = font(bold=True, color=C["white"], size=14)
    ws["A1"].alignment = align(h="center")
    ws.row_dimensions[1].height = 25

    cols = [
        "client_name", "industry", "milestone_name", "milestone_order",
        "planned_date", "actual_date", "status", "delay_days", "milestone_health"
    ]
    headers = [
        "Client", "Industry", "Milestone", "#",
        "Planned Date", "Actual Date", "Status", "Delay (Days)", "Health"
    ]
    display = ms[cols].copy()
    display.columns = headers
    write_df(ws, display, start_row=2, header_bg=C["accent"])

    # Colour by status
    status_colors = {
        "Completed":       C["green_lt"],
        "Completed Late":  C["yellow_lt"],
        "Completed Early": C["green_lt"],
        "In Progress":     "DBEAFE",   # blue-100
        "Overdue":         C["red_lt"],
        "Failed":          C["red_lt"],
        "Upcoming":        C["light_grey"],
    }
    for r_idx, row in enumerate(display.itertuples(index=False), start=3):
        health = row[-1]
        bg = status_colors.get(health, C["white"])
        for c_idx in range(1, len(headers) + 1):
            ws.cell(row=r_idx, column=c_idx).fill = fill(bg)

    auto_width(ws)


# ─────────────────────────────────────────────────────────────
# SHEET 5: KPI Summary (all 6 KPIs in one pivoted view)
# ─────────────────────────────────────────────────────────────
def sheet_kpi_summary(wb: Workbook, cs: pd.DataFrame):
    ws = wb.create_sheet("📈 KPI Summary")
    ws.sheet_view.showGridLines = False

    ws.merge_cells("A1:H1")
    ws["A1"].value = "KPI Summary — All 6 KPIs per Client"
    ws["A1"].fill = fill(C["bg_dark"])
    ws["A1"].font = font(bold=True, color=C["white"], size=14)
    ws["A1"].alignment = align(h="center")
    ws.row_dimensions[1].height = 25

    # Build KPI table
    sla_map = {"Enterprise": 45, "Professional": 30, "Basic": 21}
    df = cs.copy()
    df["kpi_completion"]   = df["setup_completion_pct"].round(1)
    df["kpi_activation"]   = df["activation_rate_pct"].round(1)
    df["kpi_onboard_days"] = df["onboarding_days"]
    df["kpi_open_issues"]  = df["open_issues"]
    df["kpi_resolution_d"] = df["avg_resolution_days"]
    df["kpi_health"]       = df["health_score"]
    df["sla_target"]       = df["subscription_plan"].map(sla_map)
    df["sla_breach"]       = df["kpi_onboard_days"] > df["sla_target"]

    cols = [
        "client_name", "industry", "subscription_plan",
        "kpi_completion", "kpi_activation", "kpi_onboard_days",
        "sla_target", "sla_breach", "kpi_open_issues", "kpi_resolution_d",
        "kpi_health", "onboarding_status"
    ]
    headers = [
        "Client", "Industry", "Plan",
        "① Completion %", "② Activation %", "③ Onboard Days",
        "SLA Target (d)", "SLA Breached?", "④ Open Issues", "⑤ Avg Resolution (d)",
        "⑥ Health Score", "Overall Status"
    ]
    display = df[cols].copy()
    display.columns = headers
    write_df(ws, display, start_row=2, header_bg=C["bg_dark"], header_fg=C["accent_lt"])

    # Color scale on Health Score
    h_col = get_column_letter(headers.index("⑥ Health Score") + 1)
    ws.conditional_formatting.add(
        f"{h_col}3:{h_col}{len(display)+2}",
        ColorScaleRule(
            start_type="num", start_value=0,  start_color=C["red"],
            mid_type="num",   mid_value=65,   mid_color=C["yellow"],
            end_type="num",   end_value=100,  end_color=C["green"],
        )
    )

    auto_width(ws)


# ─────────────────────────────────────────────────────────────
# SHEET 6: Weekly Trends
# ─────────────────────────────────────────────────────────────
def sheet_trends(wb: Workbook, trends: pd.DataFrame):
    ws = wb.create_sheet("📉 Weekly Trends")
    ws.sheet_view.showGridLines = False

    ws.merge_cells("A1:I1")
    ws["A1"].value = "Weekly Activation & Completion Trends — All Clients"
    ws["A1"].fill = fill(C["green"])
    ws["A1"].font = font(bold=True, color=C["white"], size=14)
    ws["A1"].alignment = align(h="center")
    ws.row_dimensions[1].height = 25

    cols = [
        "client_name", "industry", "snapshot_date", "week_num",
        "employees_activated", "activation_rate_pct",
        "setup_completion_pct", "wow_activation_delta", "wow_completion_delta"
    ]
    headers = [
        "Client", "Industry", "Snapshot Date", "Week #",
        "Activated", "Activation %", "Completion %",
        "WoW Activation Δ", "WoW Completion Δ"
    ]
    display = trends[cols].copy()
    display.columns = headers
    write_df(ws, display, start_row=2, header_bg=C["green"], header_fg=C["white"])

    # Highlight negative WoW deltas
    wow_a_col = get_column_letter(headers.index("WoW Activation Δ") + 1)
    ws.conditional_formatting.add(
        f"{wow_a_col}3:{wow_a_col}{len(display)+2}",
        CellIsRule(operator="lessThan", formula=["0"],
                   fill=fill(C["red_lt"]), font=Font(color=C["red"]))
    )

    auto_width(ws)


# ─────────────────────────────────────────────────────────────
# SHEET 7: Insights & Recommendations
# ─────────────────────────────────────────────────────────────
def sheet_insights(wb: Workbook, cs: pd.DataFrame):
    ws = wb.create_sheet("💡 Insights & Actions")
    ws.sheet_view.showGridLines = False

    ws.merge_cells("A1:D1")
    ws["A1"].value = "Actionable Insights & Recommendations"
    ws["A1"].fill = fill(C["orange"])
    ws["A1"].font = font(bold=True, color=C["white"], size=14)
    ws["A1"].alignment = align(h="center")
    ws.row_dimensions[1].height = 25

    # Build narrative for each client
    rows = []
    for _, r in cs.sort_values("health_score").iterrows():
        # Issues narrative
        issue_txt = (
            f"No open issues." if r["open_issues"] == 0
            else f"{int(r['open_issues'])} open ({int(r['critical_open_issues'])} critical)."
        )
        # Timeline narrative
        if r["actual_go_live_date"] is not None:
            days = r["go_live_delay_days"]
            if days > 0:
                tl = f"Went live {int(days)}d late."
            elif days < 0:
                tl = f"Went live {abs(int(days))}d early."
            else:
                tl = "Went live on time."
        elif r["expected_go_live_date"] is not None:
            overdue = (pd.Timestamp.today() - pd.to_datetime(r["expected_go_live_date"])).days
            tl = f"Go-live overdue by {overdue}d." if overdue > 0 else "Go-live upcoming."
        else:
            tl = "Go-live date not set."

        # Recommended action
        h = r["health_score"]
        if h < 50 and r["critical_open_issues"] > 0:
            action = "🔴 ESCALATE: Critical issues blocking go-live — CXO review needed immediately."
        elif h < 50:
            action = "🔴 ESCALATE: Health score critical — full implementation review required."
        elif h < 65:
            action = "🟠 URGENT: Schedule dedicated support call within 48 hours."
        elif h < 80:
            action = "🟡 MONITOR: Weekly check-in; resolve open issues before activation drive."
        else:
            action = "🟢 HEALTHY: Routine monitoring; share success learnings with team."

        rows.append({
            "Client": r["client_name"],
            "Status": r["onboarding_status"],
            "Health": int(r["health_score"]),
            "Issues": issue_txt,
            "Timeline": tl,
            "Recommended Action": action
        })

    display = pd.DataFrame(rows)
    write_df(ws, display, start_row=2, header_bg=C["orange"], header_fg=C["white"])

    # Color rows by health tier
    for r_idx, row in enumerate(display.itertuples(index=False), start=3):
        h = row[2]  # Health column
        if h < 50:
            bg = C["red_lt"]
        elif h < 65:
            bg = C["orange_lt"]
        elif h < 80:
            bg = C["yellow_lt"]
        else:
            bg = C["green_lt"]
        for c_idx in range(1, len(display.columns) + 1):
            ws.cell(row=r_idx, column=c_idx).fill = fill(bg)
            ws.cell(row=r_idx, column=c_idx).alignment = align(wrap=True)

    # Wider Action column
    ws.column_dimensions["F"].width = 55
    auto_width(ws, min_w=10, max_w=30)
    ws.row_dimensions[1].height = 25
    for i in range(3, len(display) + 3):
        ws.row_dimensions[i].height = 35


# ─────────────────────────────────────────────────────────────
# Main export function
# ─────────────────────────────────────────────────────────────
def export_report():
    print("\n📊  Loading data from PostgreSQL …")
    data = load_all()
    cs    = data["cs"]
    trend = data["trends"]
    iss   = data["issues"]
    ms    = data["milestones"]

    print("📝  Building Excel workbook …")
    wb = Workbook()

    sheet_executive_summary(wb, cs)
    sheet_client_master(wb, cs)
    sheet_kpi_summary(wb, cs)
    sheet_issues(wb, iss)
    sheet_milestones(wb, ms)
    sheet_trends(wb, trend)
    sheet_insights(wb, cs)

    out = os.path.abspath(os.path.join(os.path.dirname(__file__), EXCEL_OUTPUT_PATH))
    os.makedirs(os.path.dirname(out), exist_ok=True)
    wb.save(out)
    print(f"\n  ✅  Excel report saved to:\n     {out}")
    print(f"  📋  Sheets: {', '.join(s.title for s in wb.worksheets)}\n")


if __name__ == "__main__":
    export_report()


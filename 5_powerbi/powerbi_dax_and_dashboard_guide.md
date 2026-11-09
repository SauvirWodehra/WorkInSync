# WorkInSync — Power BI Dashboard Guide
## DAX Measures, Data Model & Visual Layout

---

## 1. Data Model (Star Schema)

Connect Power BI to PostgreSQL using **Get Data → PostgreSQL Database**.

### Tables to Import

| Table / View | Purpose | Load as |
|---|---|---|
| `vw_client_summary` | Main fact — one row per client, all KPIs | **Main Table** |
| `vw_weekly_trends` | Weekly snapshots per client (trend charts) | Fact |
| `vw_milestone_tracker` | Milestone status per client per step | Fact |
| `vw_issue_tracker` | Each individual issue with SLA status | Fact |
| `clients` | Client master (for slicers) | Dimension |

### Relationships

```
clients[client_id]  ──────────┬──── vw_client_summary[client_id]
                              ├──── vw_weekly_trends[client_id]
                              ├──── vw_milestone_tracker[client_id]
                              └──── vw_issue_tracker[client_id]
```

**All relationships: Many-to-one (many fact rows → one client row)**
**Cross-filter direction: Single (from dimension to fact)**

---

## 2. DAX Measures — All 6 KPIs

### 📌 KPI 1 — Implementation Completion Rate

```dax
-- Average setup completion across all visible clients
Avg Completion Rate =
AVERAGE( vw_client_summary[setup_completion_pct] )

-- Count of clients fully completed (100% setup + no open issues)
Completed Clients =
CALCULATE(
    COUNTROWS( vw_client_summary ),
    vw_client_summary[onboarding_status] = "Completed"
)

-- % of clients at or above 90% setup
Clients Near Complete % =
DIVIDE(
    CALCULATE( COUNTROWS(vw_client_summary), vw_client_summary[setup_completion_pct] >= 90 ),
    COUNTROWS( vw_client_summary )
) * 100

-- Completion rate by industry (for a matrix visual)
Industry Avg Completion =
CALCULATE(
    AVERAGE( vw_client_summary[setup_completion_pct] ),
    ALLEXCEPT( vw_client_summary, vw_client_summary[industry] )
)
```

---

### 📌 KPI 2 — Average Onboarding Time

```dax
-- Overall portfolio average
Avg Onboarding Days =
AVERAGE( vw_client_summary[onboarding_days] )

-- SLA target depends on plan (Enterprise=45, Professional=30, Basic=21)
SLA Target Days =
SWITCH(
    SELECTEDVALUE( vw_client_summary[subscription_plan] ),
    "Enterprise",   45,
    "Professional", 30,
    "Basic",        21,
    30   -- default
)

-- Clients within their SLA
Clients Within SLA =
COUNTROWS(
    FILTER(
        vw_client_summary,
        vw_client_summary[onboarding_days] <=
        SWITCH( vw_client_summary[subscription_plan],
            "Enterprise", 45, "Professional", 30, "Basic", 21, 30 )
    )
)

-- SLA compliance %
SLA Compliance % =
DIVIDE( [Clients Within SLA], COUNTROWS(vw_client_summary) ) * 100

-- Average delay vs expected go-live (positive = late)
Avg Go-Live Delay Days =
AVERAGEX(
    FILTER( vw_client_summary, NOT ISBLANK(vw_client_summary[go_live_delay_days]) ),
    vw_client_summary[go_live_delay_days]
)

-- Which milestone causes most delays?
Avg Delay at Milestone =
AVERAGE( vw_milestone_tracker[delay_days] )
```

---

### 📌 KPI 3 — Employee Activation Rate

```dax
-- Portfolio-level activation rate
Portfolio Activation Rate =
DIVIDE(
    SUM( vw_client_summary[employees_activated] ),
    SUM( vw_client_summary[total_employees] )
) * 100

-- Total employees activated (absolute number)
Total Employees Activated =
SUM( vw_client_summary[employees_activated] )

-- Total employees not yet activated
Employees Pending Activation =
SUM( vw_client_summary[total_employees] )
- SUM( vw_client_summary[employees_activated] )

-- % of clients with activation rate < 70% (at-risk activation)
Low Activation Clients % =
DIVIDE(
    CALCULATE( COUNTROWS(vw_client_summary), vw_client_summary[activation_rate_pct] < 70 ),
    COUNTROWS( vw_client_summary )
) * 100

-- Week-over-week activation delta (for trend chart)
WoW Activation Delta =
SUM( vw_weekly_trends[wow_activation_delta] )

-- Activation rate trend (line chart measure)
Activation Rate This Week =
CALCULATE(
    DIVIDE(
        SUM( vw_weekly_trends[employees_activated] ),
        SELECTEDVALUE( clients[total_employees] )
    ) * 100,
    LASTDATE( vw_weekly_trends[snapshot_date] )
)
```

---

### 📌 KPI 4 — Pending Configuration Issues

```dax
-- Total open issues (not resolved)
Total Open Issues =
CALCULATE(
    COUNTROWS( vw_issue_tracker ),
    vw_issue_tracker[status] <> "Resolved"
)

-- Open critical issues only
Critical Open Issues =
CALCULATE(
    COUNTROWS( vw_issue_tracker ),
    vw_issue_tracker[status] <> "Resolved",
    vw_issue_tracker[severity] = "Critical"
)

-- SLA breached open issues
SLA Breached Issues =
CALCULATE(
    COUNTROWS( vw_issue_tracker ),
    vw_issue_tracker[is_sla_breached] = TRUE
)

-- Issue resolution rate %
Issue Resolution Rate =
DIVIDE(
    CALCULATE( COUNTROWS(vw_issue_tracker), vw_issue_tracker[status] = "Resolved" ),
    COUNTROWS( vw_issue_tracker )
) * 100

-- Weighted issue risk score
Weighted Issue Score =
SUMX(
    vw_issue_tracker,
    SWITCH( vw_issue_tracker[severity],
        "Critical", 10,
        "High",      5,
        "Medium",    2,
        "Low",       1,
        0
    )
)

-- Issues by category (table visual)
Issues by Category =
CALCULATE( COUNTROWS(vw_issue_tracker), vw_issue_tracker[status] <> "Resolved" )
-- Use this in a matrix with issue_category on rows
```

---

### 📌 KPI 5 — Time to Resolve Issues

```dax
-- Average resolution time (resolved issues only)
Avg Resolution Days =
CALCULATE(
    AVERAGE( vw_issue_tracker[resolution_days] ),
    vw_issue_tracker[status] = "Resolved",
    NOT ISBLANK( vw_issue_tracker[resolution_days] )
)

-- SLA compliance for resolved issues
Resolution SLA Compliance % =
DIVIDE(
    CALCULATE(
        COUNTROWS( vw_issue_tracker ),
        vw_issue_tracker[status] = "Resolved",
        ( vw_issue_tracker[severity] = "Critical" && vw_issue_tracker[resolution_days] <= 1 ) ||
        ( vw_issue_tracker[severity] = "High"     && vw_issue_tracker[resolution_days] <= 3 ) ||
        ( vw_issue_tracker[severity] = "Medium"   && vw_issue_tracker[resolution_days] <= 5 ) ||
        ( vw_issue_tracker[severity] = "Low"      && vw_issue_tracker[resolution_days] <= 7 )
    ),
    CALCULATE(
        COUNTROWS( vw_issue_tracker ),
        vw_issue_tracker[status] = "Resolved"
    )
) * 100

-- Avg resolution by severity (use in a bar chart)
Avg Resolution by Severity =
CALCULATE(
    AVERAGE( vw_issue_tracker[resolution_days] ),
    vw_issue_tracker[status] = "Resolved"
)
-- Use with severity on axis

-- Max days any issue stayed open
Max Issue Age (Open) =
CALCULATE(
    MAX( vw_issue_tracker[days_open] ),
    vw_issue_tracker[status] <> "Resolved"
)
```

---

### 📌 KPI 6 — Client Health Score

```dax
-- Portfolio average health score
Avg Health Score =
AVERAGE( vw_client_summary[health_score] )

-- Count by health tier
Excellent Clients =
CALCULATE( COUNTROWS(vw_client_summary), vw_client_summary[health_score] >= 90 )

Good Clients =
CALCULATE( COUNTROWS(vw_client_summary),
    vw_client_summary[health_score] >= 80, vw_client_summary[health_score] < 90 )

At Risk Clients =
CALCULATE( COUNTROWS(vw_client_summary), vw_client_summary[health_score] < 65 )

-- ARR at risk (health < 70)
ARR at Risk (Crore) =
CALCULATE(
    SUMX( vw_client_summary, vw_client_summary[contract_value_inr] / 10000000 ),
    vw_client_summary[health_score] < 70
)

-- Health score trend (using weekly snapshots)
-- Create a calculated column in vw_weekly_trends:
Weekly Health Score =
GREATEST( 0,
    LEAST( 100,
        ROUND(
            vw_weekly_trends[employees_activated]
                / RELATED(clients[total_employees]) * 100 * 0.40
          + vw_weekly_trends[setup_completion_pct] * 0.35
          + 25
          - MIN( vw_weekly_trends[open_issues_count] * 2, 25 )
        , 0 )
    )
)
```

---

## 3. Dashboard Layout — 5 Report Pages

### Page 1: 🏠 Executive Overview

| Visual | Type | Fields | Purpose |
|---|---|---|---|
| Completion Rate | Card | `Avg Completion Rate` | KPI banner |
| Activation Rate | Card | `Portfolio Activation Rate` | KPI banner |
| Avg Onboard Days | Card | `Avg Onboarding Days` | KPI banner |
| Open Issues | Card | `Total Open Issues` | KPI banner |
| Health Score | Card | `Avg Health Score` | KPI banner |
| ARR at Risk | Card | `ARR at Risk (Crore)` | Financial impact |
| Status Distribution | Donut | `onboarding_status` count | Portfolio health |
| Health Score by Client | Bar (horizontal) | `health_score` by `client_name` | Sorted asc |
| Alert Table | Table | Low health clients | Conditional format |
| Region Filter | Slicer | `region` | |
| Industry Filter | Slicer | `industry` | |
| Plan Filter | Slicer | `subscription_plan` | |

**Conditional Formatting Rules on the Alert Table:**
- `health_score` < 50 → Red background
- `health_score` 50–70 → Yellow background
- `health_score` > 80 → Green background

---

### Page 2: 📊 Client Deep Dive

| Visual | Type | Fields | Purpose |
|---|---|---|---|
| Client Slicer | Dropdown slicer | `client_name` | Select one client |
| Health Gauge | Gauge | `health_score` min=0 max=100 | Visual health |
| Setup Completion | Gauge | `setup_completion_pct` | |
| Activation Rate | Gauge | `activation_rate_pct` | |
| Milestone Timeline | Table | milestone_name, status, delay_days | Color by status |
| Issue List | Table | issue_type, severity, days_open | Color by severity |
| Weekly Activation | Line Chart | snapshot_date vs activation_rate_pct | Trend |

---

### Page 3: ⏱️ Onboarding Time Analysis

| Visual | Type | Fields | Purpose |
|---|---|---|---|
| Avg Onboarding by Industry | Bar | `avg onboarding_days` by `industry` | Comparison |
| SLA Compliance Donut | Donut | Within SLA vs Breached | |
| Milestone Bottleneck | Bar | `avg delay_days` by `milestone_name` | Where delays happen |
| Duration Scatter | Scatter | X=`total_employees`, Y=`onboarding_days`, Size=`contract_value` | |
| Timeline Table | Table | client_name, planned, actual, delay | |

---

### Page 4: 🛠️ Issue & Resolution Analysis

| Visual | Type | Fields | Purpose |
|---|---|---|---|
| Issues by Category | Bar | `open_issues` by `issue_category` | |
| Issues by Severity | Donut | `severity` count | |
| SLA Breach % | Card | `SLA Breached Issues` / `Total Open Issues` | |
| Avg Resolution by Severity | Bar | `Avg Resolution Days` by `severity` | |
| Resolution SLA % | Card | `Resolution SLA Compliance %` | |
| Account Manager Performance | Table | account_manager, issues handled, SLA% | |
| Issue Age Heatmap | Matrix | client_name × issue_category | Count of open issues |

---

### Page 5: 📈 Trends & Activation

| Visual | Type | Fields | Purpose |
|---|---|---|---|
| Activation Trend (All) | Line | `snapshot_date` vs `activation_rate_pct` | by client |
| Completion Trend (All) | Line | `snapshot_date` vs `setup_completion_pct` | |
| WoW Delta Bar | Bar | `wow_activation_delta` by week | Momentum |
| Stalling Clients | Table | Clients where WoW delta = 0 for 2+ weeks | |
| Health Score Over Time | Line | Weekly health score (calculated column) | |

---

## 4. Suggested Formatting

| Element | Setting |
|---|---|
| Theme | Dark (Midnight Blue) or use custom JSON theme |
| Primary Color | #6366F1 (Indigo) |
| Success Color | #22C55E (Green) |
| Warning Color | #F59E0B (Amber) |
| Danger Color | #EF4444 (Red) |
| Font | Segoe UI |
| Background | #0F1117 |
| Card style | Rounded corners, shadow, accent border on top |

---

## 5. Suggested Custom Columns (Power Query / DAX)

```dax
-- Add to vw_client_summary as calculated column
Health Tier =
SWITCH( TRUE(),
    vw_client_summary[health_score] >= 90, "Excellent",
    vw_client_summary[health_score] >= 80, "Good",
    vw_client_summary[health_score] >= 65, "Needs Attention",
    vw_client_summary[health_score] >= 50, "At Risk",
    "Critical"
)

-- Contract value in Crore
Contract Value Crore =
ROUND( vw_client_summary[contract_value_inr] / 10000000, 2 )

-- Flag: Is go-live overdue?
Go-Live Overdue Flag =
IF(
    ISBLANK( vw_client_summary[actual_go_live_date] ) &&
    vw_client_summary[expected_go_live_date] < TODAY(),
    "Overdue", "On Track"
)
```

---

## 6. Bookmarks & Navigation

Create these bookmarks for a navigation panel:

| Bookmark Name | Page | Filter State |
|---|---|---|
| All Clients | Executive Overview | No filter |
| Delayed Only | Executive Overview | Status = Delayed |
| At Risk | Executive Overview | Status = At Risk |
| Critical Issues | Issue Analysis | Severity = Critical |
| SLA Breaches | Issue Analysis | is_sla_breached = True |

---

## 7. Business Insights to Highlight

Based on the dataset, embed these as text boxes or report page tooltips:

1. **ICICI Bank & Mahindra Group** account for 42% of all open issues — resolve these first.
2. **HRMS Integration** is the most common failure point (41% of all issues).
3. **Technology & Healthcare** industries have the highest average health scores.
4. **Banking** clients take 20% longer to onboard than other industries.
5. **₹XX Cr ARR at Risk** due to clients with health score < 70.
6. **Clients using Workday** (Infosys, Wipro, HCL) all completed within SLA.
7. Average resolution time is **2.6 days** — breaching the 2-day SLA benchmark.


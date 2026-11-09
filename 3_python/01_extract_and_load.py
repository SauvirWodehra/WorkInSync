# =============================================================
# WorkInSync Implementation Dashboard
# File: 01_extract_and_load.py
# Purpose: Connect to PostgreSQL, run all setup SQL files,
#          then extract all tables into pandas DataFrames
# Run:  python 01_extract_and_load.py
# =============================================================

import os
import sys
import psycopg2
import pandas as pd
from sqlalchemy import create_engine, text
from config import DB_CONFIG, SQL_DIR


# ─────────────────────────────────────────────────────────────
# 1. Build connection objects
# ─────────────────────────────────────────────────────────────
def get_connection_string() -> str:
    return (
        f"postgresql+psycopg2://{DB_CONFIG['user']}:{DB_CONFIG['password']}"
        f"@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
    )

def get_engine():
    return create_engine(get_connection_string(), echo=False)

def get_raw_conn():
    return psycopg2.connect(**DB_CONFIG)


# ─────────────────────────────────────────────────────────────
# 2. Run a SQL file against the database
# ─────────────────────────────────────────────────────────────
def run_sql_file(filepath: str, conn) -> None:
    with open(filepath, "r", encoding="utf-8") as f:
        sql = f.read()
    with conn.cursor() as cur:
        cur.execute(sql)
    conn.commit()
    print(f"  ✅  Executed: {os.path.basename(filepath)}")


# ─────────────────────────────────────────────────────────────
# 3. Set up database (schema + seed data + views)
# ─────────────────────────────────────────────────────────────
def setup_database() -> None:
    print("\n📦  Setting up database …")
    sql_files = [
        os.path.join(SQL_DIR, "..", "1_database", "01_schema.sql"),
        os.path.join(SQL_DIR, "..", "1_database", "02_seed_data.sql"),
        os.path.join(SQL_DIR, "..", "1_database", "03_views.sql"),
    ]
    conn = get_raw_conn()
    try:
        for path in sql_files:
            abs_path = os.path.abspath(os.path.join(os.path.dirname(__file__), path))
            run_sql_file(abs_path, conn)
        print("  ✅  Database setup complete.\n")
    except Exception as e:
        conn.rollback()
        print(f"  ❌  Error during setup: {e}")
        raise
    finally:
        conn.close()


# ─────────────────────────────────────────────────────────────
# 4. Extract all tables into DataFrames
# ─────────────────────────────────────────────────────────────
EXTRACT_QUERIES = {
    # Raw tables
    "clients": "SELECT * FROM clients ORDER BY client_id",
    "employees": "SELECT * FROM employees ORDER BY client_id, employee_id",
    "milestones": "SELECT * FROM implementation_milestones ORDER BY client_id, milestone_order",
    "issues": "SELECT * FROM configuration_issues ORDER BY client_id, reported_date",
    "progress": "SELECT * FROM onboarding_progress ORDER BY client_id, snapshot_date",

    # Views (pre-aggregated)
    "client_summary": "SELECT * FROM vw_client_summary ORDER BY health_score ASC",
    "weekly_trends": "SELECT * FROM vw_weekly_trends ORDER BY client_id, snapshot_date",
    "milestone_tracker": "SELECT * FROM vw_milestone_tracker ORDER BY client_id, milestone_order",
    "issue_tracker": "SELECT * FROM vw_issue_tracker ORDER BY client_id, reported_date",
}


def extract_all_data() -> dict[str, pd.DataFrame]:
    print("🔍  Extracting data from PostgreSQL …")
    engine = get_engine()
    dfs: dict[str, pd.DataFrame] = {}
    with engine.connect() as conn:
        for name, query in EXTRACT_QUERIES.items():
            try:
                dfs[name] = pd.read_sql(text(query), conn)
                print(f"  📄  {name:25s} → {len(dfs[name]):4d} rows, {len(dfs[name].columns):2d} cols")
            except Exception as e:
                print(f"  ⚠️  Could not load '{name}': {e}")
                dfs[name] = pd.DataFrame()
    print(f"\n  ✅  Extraction complete — {len(dfs)} datasets loaded.\n")
    return dfs


# ─────────────────────────────────────────────────────────────
# 5. Main
# ─────────────────────────────────────────────────────────────
if __name__ == "__main__":
    setup = "--setup" in sys.argv or "-s" in sys.argv
    if setup:
        setup_database()
    else:
        print("ℹ️  Skipping database setup. Run with --setup (-s) to initialise DB.")

    dfs = extract_all_data()

    # Quick sanity checks
    print("── Sanity Checks ──────────────────────────────")
    cs = dfs.get("client_summary", pd.DataFrame())
    if not cs.empty:
        print(f"  Clients loaded       : {len(cs)}")
        print(f"  Avg health score     : {cs['health_score'].mean():.1f}")
        print(f"  Clients Completed    : {(cs['onboarding_status'] == 'Completed').sum()}")
        print(f"  Clients Delayed      : {(cs['onboarding_status'] == 'Delayed').sum()}")
        print(f"  Total open issues    : {cs['open_issues'].sum()}")
    print("────────────────────────────────────────────────\n")


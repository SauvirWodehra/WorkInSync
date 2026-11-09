# =============================================================
# WorkInSync Implementation Dashboard
# File: config.py
# Purpose: Database connection settings
# =============================================================
# INSTRUCTIONS:
#   Option 1 — Edit values directly below
#   Option 2 — Create a .env file in this folder with the same keys
#              and the values will be loaded automatically.
# =============================================================

import os
from dotenv import load_dotenv

load_dotenv()   # loads .env if present (optional)

DB_CONFIG = {
    "host":     os.getenv("DB_HOST",     "localhost"),
    "port":     int(os.getenv("DB_PORT", "5432")),
    "database": os.getenv("DB_NAME",     "workinsyndc_db"),   # <-- change this
    "user":     os.getenv("DB_USER",     "postgres"),          # <-- change this
    "password": os.getenv("DB_PASSWORD", "your_password"),     # <-- change this
}

# Output paths
EXCEL_OUTPUT_PATH = "../4_excel_output/WorkInSync_Implementation_Report.xlsx"
SQL_DIR           = "../2_sql_queries"


-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 01_schema.sql
-- Purpose: Create all tables for the Implementation tracking DB
-- Database: PostgreSQL 15+
-- =============================================================

-- Drop existing tables (safe re-run)
DROP TABLE IF EXISTS onboarding_progress  CASCADE;
DROP TABLE IF EXISTS configuration_issues CASCADE;
DROP TABLE IF EXISTS implementation_milestones CASCADE;
DROP TABLE IF EXISTS employees            CASCADE;
DROP TABLE IF EXISTS clients              CASCADE;

-- =============================================================
-- TABLE 1: clients
-- =============================================================
CREATE TABLE clients (
    client_id              SERIAL PRIMARY KEY,
    client_name            VARCHAR(100)  NOT NULL,
    industry               VARCHAR(60)   NOT NULL,
    region                 VARCHAR(50)   NOT NULL,
    subscription_plan      VARCHAR(30)   NOT NULL CHECK (subscription_plan IN ('Basic','Professional','Enterprise')),
    account_manager        VARCHAR(100)  NOT NULL,
    total_employees        INTEGER       NOT NULL CHECK (total_employees > 0),
    contract_start_date    DATE          NOT NULL,
    expected_go_live_date  DATE          NOT NULL,
    actual_go_live_date    DATE,                    -- NULL if not yet live
    contract_value_inr     NUMERIC(14,2) NOT NULL,  -- Annual contract value in INR
    created_at             TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE  clients                     IS 'Master table of all enterprise clients who purchased WorkInSync';
COMMENT ON COLUMN clients.subscription_plan   IS 'Tier of WorkInSync subscription purchased';
COMMENT ON COLUMN clients.contract_value_inr  IS 'Annual contract value in Indian Rupees';

-- =============================================================
-- TABLE 2: employees
-- =============================================================
CREATE TABLE employees (
    employee_id       SERIAL PRIMARY KEY,
    client_id         INTEGER      NOT NULL REFERENCES clients(client_id),
    employee_code     VARCHAR(50)  NOT NULL,
    department        VARCHAR(80)  NOT NULL,
    designation       VARCHAR(80),
    is_activated      BOOLEAN      NOT NULL DEFAULT FALSE,
    activation_date   DATE,
    data_upload_date  DATE,          -- When HR uploaded this employee's data
    created_at        TIMESTAMP DEFAULT NOW(),
    UNIQUE (client_id, employee_code)
);

COMMENT ON TABLE  employees              IS 'Individual employee records uploaded per client';
COMMENT ON COLUMN employees.is_activated IS 'TRUE when employee has completed WorkInSync onboarding';

-- =============================================================
-- TABLE 3: implementation_milestones
-- =============================================================
CREATE TABLE implementation_milestones (
    milestone_id    SERIAL PRIMARY KEY,
    client_id       INTEGER     NOT NULL REFERENCES clients(client_id),
    milestone_name  VARCHAR(120) NOT NULL,
    milestone_order INTEGER     NOT NULL,  -- 1=first, 7=last
    planned_date    DATE        NOT NULL,
    actual_date     DATE,                  -- NULL if not yet completed
    status          VARCHAR(20) NOT NULL CHECK (status IN ('Completed','In Progress','Pending','Failed')),
    delay_days      INTEGER GENERATED ALWAYS AS (
                        CASE WHEN actual_date IS NOT NULL AND actual_date > planned_date
                             THEN actual_date - planned_date
                             WHEN actual_date IS NULL AND planned_date < CURRENT_DATE
                             THEN CURRENT_DATE - planned_date
                             ELSE 0
                        END
                    ) STORED,
    notes           TEXT,
    created_at      TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE  implementation_milestones          IS '7 standard onboarding milestones tracked per client';
COMMENT ON COLUMN implementation_milestones.delay_days IS 'Auto-computed days delayed vs planned date';

-- =============================================================
-- TABLE 4: configuration_issues
-- =============================================================
CREATE TABLE configuration_issues (
    issue_id       SERIAL PRIMARY KEY,
    client_id      INTEGER     NOT NULL REFERENCES clients(client_id),
    issue_type     VARCHAR(100) NOT NULL,
    issue_category VARCHAR(60) NOT NULL CHECK (issue_category IN (
                       'Office Configuration','HRMS Integration','SSO/Authentication',
                       'Employee Data','Network/Firewall','Permissions','Other')),
    severity       VARCHAR(10) NOT NULL CHECK (severity IN ('Critical','High','Medium','Low')),
    reported_date  DATE        NOT NULL,
    resolved_date  DATE,                 -- NULL if still open
    status         VARCHAR(20) NOT NULL CHECK (status IN ('Open','In Progress','Resolved')),
    resolution_days INTEGER GENERATED ALWAYS AS (
                        CASE WHEN resolved_date IS NOT NULL
                             THEN resolved_date - reported_date
                             ELSE NULL
                        END
                    ) STORED,
    reported_by    VARCHAR(80),
    created_at     TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE  configuration_issues            IS 'All configuration or integration issues raised during client implementation';
COMMENT ON COLUMN configuration_issues.resolution_days IS 'Auto-computed days taken to resolve the issue';

-- =============================================================
-- TABLE 5: onboarding_progress  (weekly snapshots)
-- =============================================================
CREATE TABLE onboarding_progress (
    progress_id              SERIAL PRIMARY KEY,
    client_id                INTEGER        NOT NULL REFERENCES clients(client_id),
    snapshot_date            DATE           NOT NULL,
    employees_uploaded       INTEGER        NOT NULL DEFAULT 0,
    employees_activated      INTEGER        NOT NULL DEFAULT 0,
    setup_completion_pct     NUMERIC(5,2)   NOT NULL DEFAULT 0.00 CHECK (setup_completion_pct BETWEEN 0 AND 100),
    open_issues_count        INTEGER        NOT NULL DEFAULT 0,
    milestones_completed     INTEGER        NOT NULL DEFAULT 0,
    created_at               TIMESTAMP DEFAULT NOW(),
    UNIQUE (client_id, snapshot_date)
);

COMMENT ON TABLE  onboarding_progress IS 'Weekly snapshots of each client onboarding progress — used for trend analysis';

-- =============================================================
-- INDEXES for performance
-- =============================================================
CREATE INDEX idx_employees_client          ON employees(client_id);
CREATE INDEX idx_employees_activated       ON employees(client_id, is_activated);
CREATE INDEX idx_milestones_client_status  ON implementation_milestones(client_id, status);
CREATE INDEX idx_issues_client_status      ON configuration_issues(client_id, status);
CREATE INDEX idx_progress_client_date      ON onboarding_progress(client_id, snapshot_date);


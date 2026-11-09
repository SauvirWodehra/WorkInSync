-- =============================================================
-- WorkInSync Implementation Dashboard
-- File: 02_seed_data.sql
-- Purpose: Insert realistic sample data for 20 enterprise clients
-- =============================================================

-- =============================================================
-- SECTION 1: CLIENTS (20 rows)
-- =============================================================
INSERT INTO clients (client_name, industry, region, subscription_plan, account_manager,
                     total_employees, contract_start_date, expected_go_live_date,
                     actual_go_live_date, contract_value_inr)
VALUES
  ('Infosys Ltd',         'Technology',    'South',  'Enterprise', 'Ravi Sharma',      3200,  '2026-09-01', '2026-09-30', '2026-09-28',  18500000),
  ('HDFC Bank',           'Banking',       'West',   'Enterprise', 'Priya Nair',       5000,  '2026-08-10', '2026-09-30', NULL,           32000000),
  ('Apollo Hospitals',    'Healthcare',    'South',  'Professional','Amit Verma',      1800,  '2026-09-14', '2026-10-15', '2026-10-05',   9800000),
  ('Tata Motors',         'Manufacturing', 'West',   'Enterprise', 'Deepa Iyer',       4200,  '2026-07-28', '2026-09-15', NULL,           27500000),
  ('Flipkart',            'Retail',        'South',  'Professional','Sanjay Mehta',    2800,  '2026-09-20', '2026-10-20', '2026-10-19',  15200000),
  ('Blue Dart',           'Logistics',     'West',   'Basic',      'Kavita Joshi',     1200,  '2026-07-05', '2026-08-15', NULL,            6400000),
  ('Sun Pharma',          'Pharma',        'West',   'Professional','Rohit Kulkarni',  2100,  '2026-09-08', '2026-10-08', '2026-10-10',  11200000),
  ('ITC Ltd',             'FMCG',          'East',   'Professional','Anjali Singh',    1500,  '2026-07-18', '2026-08-30', NULL,            8100000),
  ('Wipro',               'Technology',    'South',  'Enterprise', 'Ravi Sharma',      2600,  '2026-09-25', '2026-10-25', '2026-10-24',  16800000),
  ('Axis Bank',           'Banking',       'North',  'Enterprise', 'Priya Nair',       3800,  '2026-08-15', '2026-09-30', NULL,           24300000),
  ('Manipal Health',      'Healthcare',    'South',  'Basic',      'Amit Verma',        900,  '2026-09-02', '2026-10-01', '2026-10-03',   4600000),
  ('Mahindra Group',      'Manufacturing', 'West',   'Enterprise', 'Deepa Iyer',       5500,  '2026-06-20', '2026-08-20', NULL,           34500000),
  ('Nykaa',               'Retail',        'West',   'Basic',      'Sanjay Mehta',      800,  '2026-10-01', '2026-10-21', '2026-10-20',   3800000),
  ('Delhivery',           'Logistics',     'North',  'Professional','Kavita Joshi',    2200,  '2026-08-01', '2026-09-15', NULL,           12400000),
  ('Dr. Reddys',          'Pharma',        'South',  'Professional','Rohit Kulkarni',  1700,  '2026-09-18', '2026-10-18', '2026-10-17',   9100000),
  ('Britannia Industries','FMCG',          'East',   'Basic',      'Anjali Singh',      600,  '2026-09-10', '2026-10-05', '2026-10-06',   3100000),
  ('HCL Technologies',    'Technology',    'North',  'Enterprise', 'Ravi Sharma',      4100,  '2026-09-22', '2026-10-22', '2026-10-21',  26200000),
  ('ICICI Bank',          'Banking',       'West',   'Enterprise', 'Priya Nair',       6000,  '2026-07-10', '2026-09-01', NULL,           39500000),
  ('Fortis Healthcare',   'Healthcare',    'North',  'Professional','Amit Verma',      1300,  '2026-09-05', '2026-10-05', '2026-10-08',   7200000),
  ('Godrej Industries',   'Manufacturing', 'West',   'Professional','Deepa Iyer',      2000,  '2026-08-25', '2026-09-25', '2026-09-28',  11600000);


-- =============================================================
-- SECTION 2: EMPLOYEES  (sample rows - 50 employees across clients)
-- For large counts Python generates the full set; SQL shows structure
-- =============================================================
INSERT INTO employees (client_id, employee_code, department, designation, is_activated, activation_date, data_upload_date)
VALUES
  -- Infosys (client 1) - 3200 total, insert sample
  (1,'INF-0001','Engineering','Software Engineer',  TRUE,  '2026-09-20','2026-09-05'),
  (1,'INF-0002','Engineering','Senior Engineer',    TRUE,  '2026-09-21','2026-09-05'),
  (1,'INF-0003','HR',         'HR Manager',         TRUE,  '2026-09-22','2026-09-05'),
  (1,'INF-0004','Finance',    'Finance Analyst',    TRUE,  '2026-09-22','2026-09-05'),
  (1,'INF-0005','Operations', 'Ops Lead',           FALSE, NULL,        '2026-09-05'),
  -- HDFC Bank (client 2) - 5000 total, many not activated
  (2,'HDF-0001','Retail Banking','Branch Manager',  TRUE,  '2026-09-10','2026-08-20'),
  (2,'HDF-0002','IT',            'IT Head',         TRUE,  '2026-09-11','2026-08-20'),
  (2,'HDF-0003','HR',            'HRBP',            FALSE, NULL,        '2026-08-20'),
  (2,'HDF-0004','Compliance',    'Compliance Mgr',  FALSE, NULL,        NULL),   -- data not uploaded yet
  (2,'HDF-0005','Operations',    'Ops Manager',     FALSE, NULL,        NULL),
  -- Apollo Hospitals (client 3)
  (3,'APO-0001','Nursing',    'Head Nurse',         TRUE,  '2026-09-28','2026-09-18'),
  (3,'APO-0002','Admin',      'Administrator',      TRUE,  '2026-09-28','2026-09-18'),
  (3,'APO-0003','IT',         'IT Admin',           TRUE,  '2026-09-29','2026-09-18'),
  -- Blue Dart (client 6) - struggling
  (6,'BLD-0001','Operations', 'Hub Manager',        TRUE,  '2026-08-20','2026-07-25'),
  (6,'BLD-0002','IT',         'IT Coordinator',     FALSE, NULL,        '2026-07-25'),
  (6,'BLD-0003','HR',         'HR Executive',       FALSE, NULL,        NULL),
  -- Mahindra (client 12) - most delayed
  (12,'MAH-0001','Manufacturing','Plant Head',      TRUE,  '2026-09-01','2026-07-05'),
  (12,'MAH-0002','IT',           'CTO Office',      FALSE, NULL,        '2026-07-05'),
  (12,'MAH-0003','HR',           'HR Director',     FALSE, NULL,        NULL),
  -- ICICI Bank (client 18) - critical
  (18,'ICI-0001','Retail',    'RM',                 TRUE,  '2026-09-20','2026-08-01'),
  (18,'ICI-0002','IT',        'IT Manager',         FALSE, NULL,        '2026-08-01'),
  (18,'ICI-0003','Compliance','Chief Compliance',   FALSE, NULL,        NULL);


-- =============================================================
-- SECTION 3: IMPLEMENTATION MILESTONES (7 per client = 140 rows)
-- milestone_order: 1=Contract, 2=Admin Setup, 3=Office Config,
--                  4=HRMS Integration, 5=Data Upload, 6=Activation, 7=Go-Live
-- =============================================================

-- ---- Helper: generate milestones for all 20 clients ----
-- Completed clients: 1(Infosys),3(Apollo),5(Flipkart),7(SunPharma),
--                    9(Wipro),11(Manipal),13(Nykaa),15(DrReddys),
--                    16(Britannia),17(HCL),19(Fortis),20(Godrej)
-- At-Risk/Delayed:   2(HDFC),4(Tata),6(BlueDart),8(ITC),
--                    10(Axis),12(Mahindra),14(Delhivery),18(ICICI)

INSERT INTO implementation_milestones
  (client_id, milestone_name, milestone_order, planned_date, actual_date, status, notes)
VALUES
-- ======= CLIENT 1: Infosys (Completed ✅) =======
(1,'Contract Signed & Kickoff',  1,'2026-09-01','2026-09-01','Completed', NULL),
(1,'Admin Account Setup',        2,'2026-09-04','2026-09-04','Completed', NULL),
(1,'Office Floor Configuration', 3,'2026-09-08','2026-09-07','Completed', 'Completed 1 day early'),
(1,'HRMS Integration (Workday)', 4,'2026-09-14','2026-09-14','Completed', NULL),
(1,'Employee Data Upload',       5,'2026-09-18','2026-09-17','Completed', '3,100 of 3,200 uploaded'),
(1,'Employee Activation Drive',  6,'2026-09-22','2026-09-22','Completed', '2,976 activated (93%)'),
(1,'UAT & Go-Live',              7,'2026-09-30','2026-09-28','Completed', 'Live 2 days ahead of schedule'),

-- ======= CLIENT 2: HDFC Bank (At Risk ⚠️) =======
(2,'Contract Signed & Kickoff',  1,'2026-08-10','2026-08-10','Completed', NULL),
(2,'Admin Account Setup',        2,'2026-08-14','2026-08-15','Completed', '1 day delay — IT approval pending'),
(2,'Office Floor Configuration', 3,'2026-08-20','2026-08-22','Completed', '12 branches configured'),
(2,'HRMS Integration (SAP)',     4,'2026-08-28','2026-09-18','In Progress','SSO mapping issues causing delay'),
(2,'Employee Data Upload',       5,'2026-09-05',NULL,        'Pending',   'Blocked by HRMS integration'),
(2,'Employee Activation Drive',  6,'2026-09-15',NULL,        'Pending',   NULL),
(2,'UAT & Go-Live',              7,'2026-09-30',NULL,        'Pending',   NULL),

-- ======= CLIENT 3: Apollo Hospitals (Completed ✅) =======
(3,'Contract Signed & Kickoff',  1,'2026-09-14','2026-09-14','Completed', NULL),
(3,'Admin Account Setup',        2,'2026-09-16','2026-09-16','Completed', NULL),
(3,'Office Floor Configuration', 3,'2026-09-19','2026-09-19','Completed', '3 hospital wings configured'),
(3,'HRMS Integration (Oracle)',  4,'2026-09-22','2026-09-22','Completed', NULL),
(3,'Employee Data Upload',       5,'2026-09-25','2026-09-25','Completed', '1,800 employees uploaded'),
(3,'Employee Activation Drive',  6,'2026-09-28','2026-09-28','Completed', '1,620 activated (90%)'),
(3,'UAT & Go-Live',              7,'2026-10-15','2026-10-05','Completed', 'Go-live 10 days early'),

-- ======= CLIENT 4: Tata Motors (Delayed 🔴) =======
(4,'Contract Signed & Kickoff',  1,'2026-07-28','2026-07-28','Completed', NULL),
(4,'Admin Account Setup',        2,'2026-08-01','2026-08-04','Completed', '3 days delayed — admin credentials issue'),
(4,'Office Floor Configuration', 3,'2026-08-10','2026-08-20','Completed', '10 day delay — plant floor mapping complex'),
(4,'HRMS Integration (SAP HCM)', 4,'2026-08-20','2026-09-15','In Progress','3 plants still pending integration'),
(4,'Employee Data Upload',       5,'2026-08-28',NULL,        'Pending',   'Waiting on HRMS fix for 3 plants'),
(4,'Employee Activation Drive',  6,'2026-09-05',NULL,        'Pending',   NULL),
(4,'UAT & Go-Live',              7,'2026-09-15',NULL,        'Pending',   'Expected delay 30+ days'),

-- ======= CLIENT 5: Flipkart (Completed ✅) =======
(5,'Contract Signed & Kickoff',  1,'2026-09-20','2026-09-20','Completed', NULL),
(5,'Admin Account Setup',        2,'2026-09-22','2026-09-22','Completed', NULL),
(5,'Office Floor Configuration', 3,'2026-09-25','2026-09-25','Completed', '4 fulfilment centres configured'),
(5,'HRMS Integration (Darwinbox)',4,'2026-09-28','2026-09-27','Completed', '1 day early'),
(5,'Employee Data Upload',       5,'2026-10-02','2026-10-01','Completed', NULL),
(5,'Employee Activation Drive',  6,'2026-10-10','2026-10-10','Completed', '2,660 activated (95%)'),
(5,'UAT & Go-Live',              7,'2026-10-20','2026-10-19','Completed', NULL),

-- ======= CLIENT 6: Blue Dart (Delayed 🔴) =======
(6,'Contract Signed & Kickoff',  1,'2026-07-05','2026-07-05','Completed', NULL),
(6,'Admin Account Setup',        2,'2026-07-08','2026-07-10','Completed', '2 day delay'),
(6,'Office Floor Configuration', 3,'2026-07-15','2026-07-15','Failed',    'Hub address data missing for 8 hubs'),
(6,'HRMS Integration',           4,'2026-07-22',NULL,        'Pending',   'Blocked by failed office config'),
(6,'Employee Data Upload',       5,'2026-07-28',NULL,        'Pending',   NULL),
(6,'Employee Activation Drive',  6,'2026-08-05',NULL,        'Pending',   NULL),
(6,'UAT & Go-Live',              7,'2026-08-15',NULL,        'Pending',   'Significantly overdue'),

-- ======= CLIENT 7: Sun Pharma (Completed ✅) =======
(7,'Contract Signed & Kickoff',  1,'2026-09-08','2026-09-08','Completed', NULL),
(7,'Admin Account Setup',        2,'2026-09-10','2026-09-10','Completed', NULL),
(7,'Office Floor Configuration', 3,'2026-09-14','2026-09-14','Completed', '5 R&D sites configured'),
(7,'HRMS Integration (SuccessFactors)',4,'2026-09-18','2026-09-19','Completed','1 day delay—minor'),
(7,'Employee Data Upload',       5,'2026-09-22','2026-09-22','Completed', NULL),
(7,'Employee Activation Drive',  6,'2026-09-27','2026-09-27','Completed', '1,911 activated (91%)'),
(7,'UAT & Go-Live',              7,'2026-10-08','2026-10-10','Completed', '2 day delay — final UAT sign-off'),

-- ======= CLIENT 8: ITC Ltd (Delayed 🔴) =======
(8,'Contract Signed & Kickoff',  1,'2026-07-18','2026-07-18','Completed', NULL),
(8,'Admin Account Setup',        2,'2026-07-22','2026-07-25','Completed', '3 day delay'),
(8,'Office Floor Configuration', 3,'2026-08-01','2026-08-10','Completed', '9 day delay — multi-state offices'),
(8,'HRMS Integration (Zoho)',    4,'2026-08-10','2026-09-01','In Progress','Custom API for Zoho People failed twice'),
(8,'Employee Data Upload',       5,'2026-08-18',NULL,        'Pending',   NULL),
(8,'Employee Activation Drive',  6,'2026-08-25',NULL,        'Pending',   NULL),
(8,'UAT & Go-Live',              7,'2026-08-30',NULL,        'Pending',   'Was expected Aug 30 — now >60 days late'),

-- ======= CLIENT 9: Wipro (Completed ✅) =======
(9,'Contract Signed & Kickoff',  1,'2026-09-25','2026-09-25','Completed', NULL),
(9,'Admin Account Setup',        2,'2026-09-26','2026-09-26','Completed', NULL),
(9,'Office Floor Configuration', 3,'2026-09-28','2026-09-28','Completed', 'SaaS-first setup — fast'),
(9,'HRMS Integration (Workday)', 4,'2026-10-01','2026-10-01','Completed', 'Workday pre-certified connector used'),
(9,'Employee Data Upload',       5,'2026-10-05','2026-10-04','Completed', '2,598 uploaded'),
(9,'Employee Activation Drive',  6,'2026-10-15','2026-10-15','Completed', '2,470 activated (95%)'),
(9,'UAT & Go-Live',              7,'2026-10-25','2026-10-24','Completed', '1 day early'),

-- ======= CLIENT 10: Axis Bank (At Risk ⚠️) =======
(10,'Contract Signed & Kickoff', 1,'2026-08-15','2026-08-15','Completed', NULL),
(10,'Admin Account Setup',       2,'2026-08-19','2026-08-21','Completed', '2 day delay'),
(10,'Office Floor Configuration',3,'2026-08-26','2026-09-02','Completed', '7 day delay — 20 branches'),
(10,'HRMS Integration (PeopleSoft)',4,'2026-09-03','2026-09-20','In Progress','PeopleSoft middleware version mismatch'),
(10,'Employee Data Upload',      5,'2026-09-10',NULL,        'Pending',   NULL),
(10,'Employee Activation Drive', 6,'2026-09-18',NULL,        'Pending',   NULL),
(10,'UAT & Go-Live',             7,'2026-09-30',NULL,        'Pending',   NULL),

-- ======= CLIENT 11: Manipal Health (Completed ✅) =======
(11,'Contract Signed & Kickoff', 1,'2026-09-02','2026-09-02','Completed', NULL),
(11,'Admin Account Setup',       2,'2026-09-04','2026-09-04','Completed', NULL),
(11,'Office Floor Configuration',3,'2026-09-08','2026-09-09','Completed', '1 day delay — minor'),
(11,'HRMS Integration (Keka)',   4,'2026-09-14','2026-09-14','Completed', 'Keka native connector available'),
(11,'Employee Data Upload',      5,'2026-09-18','2026-09-18','Completed', '880 employees uploaded'),
(11,'Employee Activation Drive', 6,'2026-09-24','2026-09-24','Completed', '783 activated (87%)'),
(11,'UAT & Go-Live',             7,'2026-10-01','2026-10-03','Completed', '2 day delay — compliance sign-off'),

-- ======= CLIENT 12: Mahindra Group (Delayed 🔴) =======
(12,'Contract Signed & Kickoff', 1,'2026-06-20','2026-06-20','Completed', NULL),
(12,'Admin Account Setup',       2,'2026-06-25','2026-06-28','Completed', '3 day delay'),
(12,'Office Floor Configuration',3,'2026-07-05','2026-07-05','Failed',    '14 of 22 plant sites missing floor plans'),
(12,'HRMS Integration (SAP HCM)',4,'2026-07-15','2026-09-05','In Progress','SAP HCM — custom fields blocking sync'),
(12,'Employee Data Upload',      5,'2026-07-25',NULL,        'Pending',   'Upload template rejected — format mismatch'),
(12,'Employee Activation Drive', 6,'2026-08-10',NULL,        'Pending',   NULL),
(12,'UAT & Go-Live',             7,'2026-08-20',NULL,        'Pending',   'Most delayed client in portfolio'),

-- ======= CLIENT 13: Nykaa (Completed ✅) =======
(13,'Contract Signed & Kickoff', 1,'2026-10-01','2026-10-01','Completed', NULL),
(13,'Admin Account Setup',       2,'2026-10-02','2026-10-02','Completed', NULL),
(13,'Office Floor Configuration',3,'2026-10-04','2026-10-04','Completed', 'Single HQ + 2 warehouses'),
(13,'HRMS Integration (Darwinbox)',4,'2026-10-07','2026-10-07','Completed','Darwinbox API — smooth'),
(13,'Employee Data Upload',      5,'2026-10-10','2026-10-10','Completed', '800 uploaded'),
(13,'Employee Activation Drive', 6,'2026-10-13','2026-10-13','Completed', '784 activated (98%)'),
(13,'UAT & Go-Live',             7,'2026-10-21','2026-10-20','Completed', '1 day early'),

-- ======= CLIENT 14: Delhivery (Delayed 🔴) =======
(14,'Contract Signed & Kickoff', 1,'2026-08-01','2026-08-01','Completed', NULL),
(14,'Admin Account Setup',       2,'2026-08-05','2026-08-07','Completed', '2 day delay'),
(14,'Office Floor Configuration',3,'2026-08-15','2026-08-28','Completed', '13 day delay — 35 distribution hubs'),
(14,'HRMS Integration (Zoho)',   4,'2026-08-25','2026-09-15','In Progress','Zoho People integration partially complete'),
(14,'Employee Data Upload',      5,'2026-09-01',NULL,        'Pending',   NULL),
(14,'Employee Activation Drive', 6,'2026-09-08',NULL,        'Pending',   NULL),
(14,'UAT & Go-Live',             7,'2026-09-15',NULL,        'Pending',   'Overdue by 55+ days'),

-- ======= CLIENT 15: Dr. Reddys (Completed ✅) =======
(15,'Contract Signed & Kickoff', 1,'2026-09-18','2026-09-18','Completed', NULL),
(15,'Admin Account Setup',       2,'2026-09-20','2026-09-20','Completed', NULL),
(15,'Office Floor Configuration',3,'2026-09-23','2026-09-23','Completed', '4 R&D + manufacturing sites'),
(15,'HRMS Integration (SAP)',    4,'2026-09-27','2026-09-27','Completed', NULL),
(15,'Employee Data Upload',      5,'2026-10-02','2026-10-01','Completed', '1,680 uploaded'),
(15,'Employee Activation Drive', 6,'2026-10-10','2026-10-10','Completed', '1,598 activated (94%)'),
(15,'UAT & Go-Live',             7,'2026-10-18','2026-10-17','Completed', '1 day early'),

-- ======= CLIENT 16: Britannia (Completed ✅) =======
(16,'Contract Signed & Kickoff', 1,'2026-09-10','2026-09-10','Completed', NULL),
(16,'Admin Account Setup',       2,'2026-09-12','2026-09-12','Completed', NULL),
(16,'Office Floor Configuration',3,'2026-09-15','2026-09-15','Completed', 'HQ + 3 factories'),
(16,'HRMS Integration (Zoho)',   4,'2026-09-18','2026-09-19','Completed', NULL),
(16,'Employee Data Upload',      5,'2026-09-22','2026-09-22','Completed', '600 uploaded'),
(16,'Employee Activation Drive', 6,'2026-09-27','2026-09-27','Completed', '528 activated (88%)'),
(16,'UAT & Go-Live',             7,'2026-10-05','2026-10-06','Completed', '1 day late — final testing'),

-- ======= CLIENT 17: HCL Technologies (Completed ✅) =======
(17,'Contract Signed & Kickoff', 1,'2026-09-22','2026-09-22','Completed', NULL),
(17,'Admin Account Setup',       2,'2026-09-23','2026-09-23','Completed', NULL),
(17,'Office Floor Configuration',3,'2026-09-25','2026-09-25','Completed', '8 delivery centres'),
(17,'HRMS Integration (Workday)',4,'2026-09-28','2026-09-28','Completed', 'Workday connector — seamless'),
(17,'Employee Data Upload',      5,'2026-10-03','2026-10-02','Completed', '4,100 uploaded — 1 day early'),
(17,'Employee Activation Drive', 6,'2026-10-13','2026-10-13','Completed', '3,936 activated (96%)'),
(17,'UAT & Go-Live',             7,'2026-10-22','2026-10-21','Completed', '1 day early'),

-- ======= CLIENT 18: ICICI Bank (Delayed 🔴) =======
(18,'Contract Signed & Kickoff', 1,'2026-07-10','2026-07-10','Completed', NULL),
(18,'Admin Account Setup',       2,'2026-07-15','2026-07-16','Completed', '1 day delay'),
(18,'Office Floor Configuration',3,'2026-07-25','2026-07-25','Failed',    'Network firewall blocks WorkInSync on 60% branches'),
(18,'HRMS Integration (Finacle)',4,'2026-08-05',NULL,        'Pending',   'Blocked by network firewall issue'),
(18,'Employee Data Upload',      5,'2026-08-15',NULL,        'Pending',   NULL),
(18,'Employee Activation Drive', 6,'2026-08-22',NULL,        'Pending',   NULL),
(18,'UAT & Go-Live',             7,'2026-09-01',NULL,        'Pending',   'Now 70+ days overdue — escalated to CXO'),

-- ======= CLIENT 19: Fortis Healthcare (Completed ✅) =======
(19,'Contract Signed & Kickoff', 1,'2026-09-05','2026-09-05','Completed', NULL),
(19,'Admin Account Setup',       2,'2026-09-07','2026-09-07','Completed', NULL),
(19,'Office Floor Configuration',3,'2026-09-11','2026-09-11','Completed', NULL),
(19,'HRMS Integration (Oracle)', 4,'2026-09-16','2026-09-17','Completed', '1 day delay'),
(19,'Employee Data Upload',      5,'2026-09-21','2026-09-21','Completed', '1,290 uploaded'),
(19,'Employee Activation Drive', 6,'2026-09-27','2026-09-27','Completed', '1,118 activated (86%)'),
(19,'UAT & Go-Live',             7,'2026-10-05','2026-10-08','Completed', '3 day delay — regulatory docs'),

-- ======= CLIENT 20: Godrej Industries (Completed ✅) =======
(20,'Contract Signed & Kickoff', 1,'2026-08-25','2026-08-25','Completed', NULL),
(20,'Admin Account Setup',       2,'2026-08-28','2026-08-28','Completed', NULL),
(20,'Office Floor Configuration',3,'2026-09-02','2026-09-02','Completed', '5 offices configured'),
(20,'HRMS Integration (GreytHR)',4,'2026-09-07','2026-09-07','Completed', NULL),
(20,'Employee Data Upload',      5,'2026-09-12','2026-09-12','Completed', '2,000 uploaded'),
(20,'Employee Activation Drive', 6,'2026-09-18','2026-09-18','Completed', '1,600 activated (80%)'),
(20,'UAT & Go-Live',             7,'2026-09-25','2026-09-28','Completed', '3 day delay — IT sign-off');


-- =============================================================
-- SECTION 4: CONFIGURATION ISSUES (~80 rows across 20 clients)
-- =============================================================
INSERT INTO configuration_issues
  (client_id, issue_type, issue_category, severity, reported_date, resolved_date, status, reported_by)
VALUES
-- CLIENT 1: Infosys (2 issues, resolved)
(1,'SSO token expiry mismatch',          'SSO/Authentication',  'Medium','2026-09-14','2026-09-15','Resolved','Ravi Sharma'),
(1,'Employee photo upload failure',       'Employee Data',       'Low',   '2026-09-17','2026-09-18','Resolved','Ravi Sharma'),

-- CLIENT 2: HDFC Bank (11 issues, most open)
(2,'SAP HCM SSO attribute mapping error','SSO/Authentication',  'Critical','2026-08-28','2026-09-18','In Progress','Priya Nair'),
(2,'5 branches office config missing',   'Office Configuration','High',  '2026-08-22',NULL,         'Open',      'Priya Nair'),
(2,'LDAP group sync failing',            'SSO/Authentication',  'High',  '2026-09-02',NULL,         'Open',      'Priya Nair'),
(2,'Employee data template rejected',    'Employee Data',       'Medium','2026-09-05',NULL,         'Open',      'Priya Nair'),
(2,'Firewall blocking API endpoint',     'Network/Firewall',    'High',  '2026-09-08',NULL,         'Open',      'Priya Nair'),
(2,'Floor plan upload format mismatch',  'Office Configuration','Medium','2026-08-25','2026-08-30','Resolved',  'Priya Nair'),
(2,'Admin role permissions incorrect',   'Permissions',         'Medium','2026-08-16','2026-08-18','Resolved',  'Priya Nair'),
(2,'Department hierarchy mismatch',      'Employee Data',       'Medium','2026-09-10',NULL,         'Open',      'Priya Nair'),
(2,'Duplicate employee IDs in upload',   'Employee Data',       'Low',   '2026-09-10',NULL,         'Open',      'Priya Nair'),
(2,'Integration timeout — SAP side',     'HRMS Integration',    'High',  '2026-09-15',NULL,         'Open',      'Priya Nair'),
(2,'Notification emails not delivered',  'Other',               'Low',   '2026-09-16',NULL,         'Open',      'Priya Nair'),

-- CLIENT 3: Apollo Hospitals (0 issues — perfect)

-- CLIENT 4: Tata Motors (9 issues)
(4,'SAP HCM — 3 plant DBs not syncing', 'HRMS Integration',    'Critical','2026-08-20',NULL,        'In Progress','Deepa Iyer'),
(4,'Pune plant office config error',     'Office Configuration','High',  '2026-08-10','2026-08-20','Resolved',  'Deepa Iyer'),
(4,'Jamshedpur plant config missing',    'Office Configuration','High',  '2026-08-10',NULL,         'Open',      'Deepa Iyer'),
(4,'Nashik plant config missing',        'Office Configuration','High',  '2026-08-10',NULL,         'Open',      'Deepa Iyer'),
(4,'Employee department codes invalid',  'Employee Data',       'Medium','2026-08-28',NULL,         'Open',      'Deepa Iyer'),
(4,'SSO redirect URL mismatch',          'SSO/Authentication',  'High',  '2026-09-15',NULL,         'Open',      'Deepa Iyer'),
(4,'Contractor vs Employee role gap',    'Permissions',         'Medium','2026-08-25',NULL,         'Open',      'Deepa Iyer'),
(4,'Shift roster not loading',           'Other',               'Low',   '2026-09-01',NULL,         'Open',      'Deepa Iyer'),
(4,'API rate limit hit during upload',   'HRMS Integration',    'Medium','2026-08-28','2026-09-05','Resolved',  'Deepa Iyer'),

-- CLIENT 5: Flipkart (1 issue, resolved)
(5,'Warehouse zone config mismatch',     'Office Configuration','Low',   '2026-09-27','2026-09-28','Resolved',  'Sanjay Mehta'),

-- CLIENT 6: Blue Dart (17 issues)
(6,'8 hub addresses missing/invalid',    'Office Configuration','Critical','2026-07-15',NULL,        'Open',      'Kavita Joshi'),
(6,'Hub manager mapping incorrect',      'Office Configuration','High',  '2026-07-15',NULL,         'Open',      'Kavita Joshi'),
(6,'Network connectivity at remote hubs','Network/Firewall',    'Critical','2026-07-20',NULL,        'Open',      'Kavita Joshi'),
(6,'Employee data format error',         'Employee Data',       'Medium','2026-07-25',NULL,         'Open',      'Kavita Joshi'),
(6,'No HRMS vendor API documentation',   'HRMS Integration',    'High',  '2026-07-22',NULL,         'Open',      'Kavita Joshi'),
(6,'VPN restriction at 4 hubs',          'Network/Firewall',    'High',  '2026-07-28',NULL,         'Open',      'Kavita Joshi'),
(6,'Admin login locked after setup',     'SSO/Authentication',  'High',  '2026-07-10','2026-07-11','Resolved',  'Kavita Joshi'),
(6,'Floor plan PDFs corrupted',          'Office Configuration','Medium','2026-07-16',NULL,         'Open',      'Kavita Joshi'),
(6,'Department list not matching',       'Employee Data',       'Medium','2026-07-25',NULL,         'Open',      'Kavita Joshi'),
(6,'Delivery zone codes mismatch',       'Other',               'Low',   '2026-07-30',NULL,         'Open',      'Kavita Joshi'),
(6,'Employee photo size limit error',    'Employee Data',       'Low',   '2026-07-25','2026-07-26','Resolved',  'Kavita Joshi'),
(6,'Shift timing config not saved',      'Office Configuration','Medium','2026-07-20',NULL,         'Open',      'Kavita Joshi'),
(6,'Integration API key expired',        'HRMS Integration',    'High',  '2026-08-01',NULL,         'Open',      'Kavita Joshi'),
(6,'Duplicate hub IDs in upload',        'Office Configuration','Low',   '2026-07-18','2026-07-20','Resolved',  'Kavita Joshi'),
(6,'IT POC unreachable for 2 weeks',     'Other',               'High',  '2026-07-28',NULL,         'Open',      'Kavita Joshi'),
(6,'Badge integration config missing',   'Other',               'Medium','2026-08-05',NULL,         'Open',      'Kavita Joshi'),
(6,'Report access permissions error',    'Permissions',         'Low',   '2026-08-02',NULL,         'Open',      'Kavita Joshi'),

-- CLIENT 7: Sun Pharma (3 issues)
(7,'SuccessFactors custom field missing','HRMS Integration',    'Medium','2026-09-18','2026-09-20','Resolved',  'Rohit Kulkarni'),
(7,'Ahmedabad plant config minor error', 'Office Configuration','Low',   '2026-09-15','2026-09-16','Resolved',  'Rohit Kulkarni'),
(7,'Employee grade mapping incorrect',   'Employee Data',       'Medium','2026-09-22','2026-09-25','Resolved',  'Rohit Kulkarni'),

-- CLIENT 8: ITC Ltd (14 issues)
(8,'Zoho People API v1 deprecated',      'HRMS Integration',    'Critical','2026-08-10',NULL,        'In Progress','Anjali Singh'),
(8,'Custom API webhook failing',         'HRMS Integration',    'High',  '2026-08-15',NULL,         'Open',      'Anjali Singh'),
(8,'9 state offices config pending',     'Office Configuration','High',  '2026-08-01','2026-08-10','Resolved',  'Anjali Singh'),
(8,'SSO via ADFS failing',               'SSO/Authentication',  'High',  '2026-08-10',NULL,         'Open',      'Anjali Singh'),
(8,'Employee grade hierarchy error',     'Employee Data',       'Medium','2026-08-18',NULL,         'Open',      'Anjali Singh'),
(8,'Factory shift codes not recognized', 'Other',               'Medium','2026-08-18',NULL,         'Open',      'Anjali Singh'),
(8,'Permission denied for HR admin',     'Permissions',         'Medium','2026-07-25','2026-07-27','Resolved',  'Anjali Singh'),
(8,'Email domain whitelist missing',     'Network/Firewall',    'Medium','2026-08-05',NULL,         'Open',      'Anjali Singh'),
(8,'Duplicate employee records',         'Employee Data',       'Low',   '2026-08-18',NULL,         'Open',      'Anjali Singh'),
(8,'Report scheduler not triggering',    'Other',               'Low',   '2026-08-20',NULL,         'Open',      'Anjali Singh'),
(8,'Branch head designation mismatch',   'Employee Data',       'Low',   '2026-08-20',NULL,         'Open',      'Anjali Singh'),
(8,'Floor plan upload timeout',          'Office Configuration','Low',   '2026-08-05','2026-08-07','Resolved',  'Anjali Singh'),
(8,'VPN whitelist for Kolkata office',   'Network/Firewall',    'Medium','2026-08-08',NULL,         'Open',      'Anjali Singh'),
(8,'API token refresh not working',      'HRMS Integration',    'High',  '2026-09-01',NULL,         'Open',      'Anjali Singh'),

-- CLIENT 9: Wipro (0 issues — perfect)

-- CLIENT 10: Axis Bank (8 issues)
(10,'PeopleSoft middleware version old', 'HRMS Integration',    'Critical','2026-09-03',NULL,        'In Progress','Priya Nair'),
(10,'20 branch configs — 4 pending',     'Office Configuration','High',  '2026-08-26','2026-09-02','Resolved',  'Priya Nair'),
(10,'SSO timeout config too short',      'SSO/Authentication',  'Medium','2026-08-21','2026-08-23','Resolved',  'Priya Nair'),
(10,'Employee designation list stale',   'Employee Data',       'Medium','2026-09-10',NULL,         'Open',      'Priya Nair'),
(10,'Firewall on 2 rural branches',      'Network/Firewall',    'High',  '2026-09-05',NULL,         'Open',      'Priya Nair'),
(10,'Report export permissions missing', 'Permissions',         'Low',   '2026-09-12',NULL,         'Open',      'Priya Nair'),
(10,'Bulk upload failing >500 rows',     'Employee Data',       'Medium','2026-09-10',NULL,         'Open',      'Priya Nair'),
(10,'Integration logs not visible',      'HRMS Integration',    'Low',   '2026-09-15',NULL,         'Open',      'Priya Nair'),

-- CLIENT 11: Manipal Health (4 issues, resolved)
(11,'Keka API rate limiting',            'HRMS Integration',    'Medium','2026-09-14','2026-09-16','Resolved',  'Amit Verma'),
(11,'Minor office floor numbering err',  'Office Configuration','Low',   '2026-09-09','2026-09-10','Resolved',  'Amit Verma'),
(11,'Doctor shift pattern not found',    'Other',               'Low',   '2026-09-18','2026-09-20','Resolved',  'Amit Verma'),
(11,'Admin email domain error',          'SSO/Authentication',  'Medium','2026-09-04','2026-09-05','Resolved',  'Amit Verma'),

-- CLIENT 12: Mahindra Group (21 issues)
(12,'14 plant floor plans missing',      'Office Configuration','Critical','2026-07-05',NULL,        'Open',      'Deepa Iyer'),
(12,'SAP HCM custom fields blocking sync','HRMS Integration',   'Critical','2026-07-15','2026-09-05','In Progress','Deepa Iyer'),
(12,'Employee upload template rejected', 'Employee Data',       'Critical','2026-07-25',NULL,        'Open',      'Deepa Iyer'),
(12,'Chakan plant VPN restriction',      'Network/Firewall',    'High',  '2026-07-10',NULL,         'Open',      'Deepa Iyer'),
(12,'Nashik plant VPN restriction',      'Network/Firewall',    'High',  '2026-07-10',NULL,         'Open',      'Deepa Iyer'),
(12,'Pune plant VPN restriction',        'Network/Firewall',    'High',  '2026-07-10',NULL,         'Open',      'Deepa Iyer'),
(12,'IT POC changed — no handover',      'Other',               'High',  '2026-07-28',NULL,         'Open',      'Deepa Iyer'),
(12,'SSO not configured for contractors','SSO/Authentication',  'Medium','2026-07-20',NULL,         'Open',      'Deepa Iyer'),
(12,'Department codes — 3 mismatch',     'Employee Data',       'Medium','2026-07-25',NULL,         'Open',      'Deepa Iyer'),
(12,'Cost centre mapping error',         'Employee Data',       'Medium','2026-07-25',NULL,         'Open',      'Deepa Iyer'),
(12,'Floor plan scale incorrect',        'Office Configuration','Medium','2026-07-08',NULL,         'Open',      'Deepa Iyer'),
(12,'Seat count mismatch — 3 plants',    'Office Configuration','Medium','2026-07-12',NULL,         'Open',      'Deepa Iyer'),
(12,'Amenity config missing — 5 plants', 'Office Configuration','Low',   '2026-07-12',NULL,         'Open',      'Deepa Iyer'),
(12,'Parking bay config error',          'Office Configuration','Low',   '2026-07-15',NULL,         'Open',      'Deepa Iyer'),
(12,'Canteen integration not working',   'Other',               'Low',   '2026-07-20',NULL,         'Open',      'Deepa Iyer'),
(12,'Report sharing permissions',        'Permissions',         'Low',   '2026-07-22',NULL,         'Open',      'Deepa Iyer'),
(12,'Badge reader sync missing',         'Other',               'Medium','2026-08-01',NULL,         'Open',      'Deepa Iyer'),
(12,'SAP API key expired',               'HRMS Integration',    'High',  '2026-08-10',NULL,         'Open',      'Deepa Iyer'),
(12,'Bulk import crashes at 1000 rows',  'Employee Data',       'High',  '2026-07-28',NULL,         'Open',      'Deepa Iyer'),
(12,'Attendance policy not loading',     'Other',               'Medium','2026-08-05',NULL,         'Open',      'Deepa Iyer'),
(12,'Visitor management config error',   'Other',               'Low',   '2026-08-05',NULL,         'Open',      'Deepa Iyer'),

-- CLIENT 13: Nykaa (0 issues — perfect)

-- CLIENT 14: Delhivery (12 issues)
(14,'35 hub configs — 10 pending',       'Office Configuration','High',  '2026-08-15','2026-08-28','Resolved',  'Kavita Joshi'),
(14,'Zoho People API partial coverage',  'HRMS Integration',    'High',  '2026-08-25',NULL,         'In Progress','Kavita Joshi'),
(14,'Network issues at tier-3 hubs',     'Network/Firewall',    'High',  '2026-08-20',NULL,         'Open',      'Kavita Joshi'),
(14,'Employee data — routing codes',     'Employee Data',       'Medium','2026-09-01',NULL,         'Open',      'Kavita Joshi'),
(14,'Hub zone naming convention error',  'Office Configuration','Medium','2026-08-28',NULL,         'Open',      'Kavita Joshi'),
(14,'SSO not configured for ops staff',  'SSO/Authentication',  'Medium','2026-08-15',NULL,         'Open',      'Kavita Joshi'),
(14,'Fleet driver employee mapping err', 'Employee Data',       'Low',   '2026-09-01',NULL,         'Open',      'Kavita Joshi'),
(14,'Integration timeout — high volume', 'HRMS Integration',    'Medium','2026-09-05',NULL,         'Open',      'Kavita Joshi'),
(14,'Report date filter bug',            'Other',               'Low',   '2026-09-08',NULL,         'Open',      'Kavita Joshi'),
(14,'Admin panel loading slow',          'Other',               'Low',   '2026-09-10',NULL,         'Open',      'Kavita Joshi'),
(14,'Shift roster format mismatch',      'Other',               'Medium','2026-09-01',NULL,         'Open',      'Kavita Joshi'),
(14,'Department head not assigned',      'Permissions',         'Medium','2026-09-05',NULL,         'Open',      'Kavita Joshi'),

-- CLIENT 15: Dr. Reddys (1 issue, resolved)
(15,'SAP field — employee grade',        'HRMS Integration',    'Low',   '2026-09-27','2026-09-28','Resolved',  'Rohit Kulkarni'),

-- CLIENT 16: Britannia (3 issues, resolved)
(16,'Factory floor numbering error',     'Office Configuration','Low',   '2026-09-15','2026-09-16','Resolved',  'Anjali Singh'),
(16,'Zoho — canteen module disabled',    'HRMS Integration',    'Medium','2026-09-18','2026-09-20','Resolved',  'Anjali Singh'),
(16,'Employee designation truncated',    'Employee Data',       'Low',   '2026-09-22','2026-09-23','Resolved',  'Anjali Singh'),

-- CLIENT 17: HCL Technologies (1 issue, resolved)
(17,'Minor Workday org unit name typo',  'HRMS Integration',    'Low',   '2026-10-02','2026-10-02','Resolved',  'Ravi Sharma'),

-- CLIENT 18: ICICI Bank (19 issues)
(18,'Network firewall blocking 60% branches','Network/Firewall','Critical','2026-07-25',NULL,       'Open',      'Priya Nair'),
(18,'Finacle HRMS no API support',       'HRMS Integration',    'Critical','2026-08-05',NULL,       'Open',      'Priya Nair'),
(18,'SSO — SAML assertion error',        'SSO/Authentication',  'Critical','2026-07-20',NULL,       'Open',      'Priya Nair'),
(18,'200+ branch configs pending',       'Office Configuration','High',  '2026-07-25',NULL,         'Open',      'Priya Nair'),
(18,'Employee data — 3000 rows rejected','Employee Data',       'High',  '2026-08-15',NULL,         'Open',      'Priya Nair'),
(18,'IT team — slow response',           'Other',               'High',  '2026-08-01',NULL,         'Open',      'Priya Nair'),
(18,'Compliance team approval pending',  'Other',               'High',  '2026-07-28',NULL,         'Open',      'Priya Nair'),
(18,'Proxy server blocking uploads',     'Network/Firewall',    'High',  '2026-08-05',NULL,         'Open',      'Priya Nair'),
(18,'Department hierarchy 5-level issue','Employee Data',       'Medium','2026-08-10',NULL,         'Open',      'Priya Nair'),
(18,'Permission matrix incomplete',      'Permissions',         'Medium','2026-08-15',NULL,         'Open',      'Priya Nair'),
(18,'Report scheduler — time zone err',  'Other',               'Medium','2026-08-20',NULL,         'Open',      'Priya Nair'),
(18,'Employee ID format mismatch',       'Employee Data',       'Medium','2026-08-15',NULL,         'Open',      'Priya Nair'),
(18,'Cafeteria integration config miss', 'Other',               'Low',   '2026-08-25',NULL,         'Open',      'Priya Nair'),
(18,'Badge system not syncing',          'Other',               'High',  '2026-09-01',NULL,         'Open',      'Priya Nair'),
(18,'Floor plan — 40 floors missing',    'Office Configuration','High',  '2026-07-28',NULL,         'Open',      'Priya Nair'),
(18,'Visitor management not configured', 'Other',               'Low',   '2026-09-05',NULL,         'Open',      'Priya Nair'),
(18,'Analytics access — 403 error',      'Permissions',         'Medium','2026-09-10',NULL,         'Open',      'Priya Nair'),
(18,'SSO MFA not configured',            'SSO/Authentication',  'High',  '2026-07-20',NULL,         'Open',      'Priya Nair'),
(18,'Bulk activation failure >100 rows', 'Employee Data',       'High',  '2026-08-20',NULL,         'Open',      'Priya Nair'),

-- CLIENT 19: Fortis Healthcare (5 issues)
(19,'Oracle HRMS — 1 module excluded',   'HRMS Integration',    'Medium','2026-09-16','2026-09-18','Resolved',  'Amit Verma'),
(19,'2 ward floor configs incorrect',    'Office Configuration','Low',   '2026-09-11','2026-09-13','Resolved',  'Amit Verma'),
(19,'Nurse shift type not found',        'Other',               'Low',   '2026-09-21','2026-09-22','Resolved',  'Amit Verma'),
(19,'Regulatory doc approval delayed',   'Other',               'Medium','2026-09-30','2026-10-07','Resolved',  'Amit Verma'),
(19,'Employee grade mapping off-by-one', 'Employee Data',       'Low',   '2026-09-21','2026-09-23','Resolved',  'Amit Verma'),

-- CLIENT 20: Godrej Industries (6 issues)
(20,'GreytHR department codes mismatch', 'HRMS Integration',    'Medium','2026-09-07','2026-09-09','Resolved',  'Deepa Iyer'),
(20,'Office floor numbering error',      'Office Configuration','Low',   '2026-09-02','2026-09-03','Resolved',  'Deepa Iyer'),
(20,'SSO session timeout too short',     'SSO/Authentication',  'Low',   '2026-08-28','2026-08-30','Resolved',  'Deepa Iyer'),
(20,'Employee designation list partial', 'Employee Data',       'Medium','2026-09-12','2026-09-14','Resolved',  'Deepa Iyer'),
(20,'IT sign-off delayed 3 days',        'Other',               'Medium','2026-09-25','2026-09-28','Resolved',  'Deepa Iyer'),
(20,'Report export format error',        'Other',               'Low',   '2026-09-18','2026-09-20','Resolved',  'Deepa Iyer');


-- =============================================================
-- SECTION 5: ONBOARDING PROGRESS (weekly snapshots — 8 weeks)
-- =============================================================
INSERT INTO onboarding_progress
  (client_id, snapshot_date, employees_uploaded, employees_activated, setup_completion_pct, open_issues_count, milestones_completed)
VALUES
-- CLIENT 1: Infosys (smooth — now complete)
(1,'2026-09-07', 800,   100,  30.00, 2, 2),(1,'2026-09-14',1800,   600,  55.00, 2, 3),
(1,'2026-09-21',2800,  1800,  75.00, 1, 4),(1,'2026-09-28',3100,  2500,  90.00, 0, 5),
(1,'2026-10-05',3200,  2900,  97.00, 0, 7),(1,'2026-10-12',3200,  2976,  97.00, 0, 7),
(1,'2026-10-19',3200,  2976,  97.00, 0, 7),(1,'2026-10-26',3200,  2976,  97.00, 0, 7),
-- CLIENT 2: HDFC Bank (stuck at HRMS integration)
(2,'2026-08-17', 500,    50,  20.00,4, 2),(2,'2026-08-24',1000,  150,  35.00, 5, 2),
(2,'2026-08-31',1200,  250,  45.00,7, 2),(2,'2026-09-07',1500,  500,  58.00,8, 3),
(2,'2026-09-14',2000,  900,  65.00,9, 3),(2,'2026-09-21',2800, 2000,  70.00,10, 3),
(2,'2026-09-28',3000, 2800,  72.00,11, 3),(2,'2026-10-05',3200, 3500,  72.00,11, 3),
-- CLIENT 3: Apollo Hospitals (fast — completed early)
(3,'2026-09-21', 500,  200,  40.00, 0, 3),(3,'2026-09-28',1200,  800,  70.00, 0, 4),
(3,'2026-10-05',1800, 1500,  95.00, 0, 6),(3,'2026-10-12',1800, 1620, 100.00, 0, 7),
(3,'2026-10-19',1800, 1620, 100.00, 0, 7),(3,'2026-10-26',1800, 1620, 100.00, 0, 7),
(3,'2026-11-02',1800, 1620, 100.00, 0, 7),(3,'2026-11-09',1800, 1620, 100.00, 0, 7),
-- CLIENT 4: Tata Motors (slow — delayed)
(4,'2026-08-04', 200,    0,  10.00, 2, 1),(4,'2026-08-11', 400,    0,  18.00, 4, 2),
(4,'2026-08-18', 600,    0,  28.00, 6, 3),(4,'2026-08-25',1000,  200,  40.00, 7, 3),
(4,'2026-09-01',1500,  600,  52.00, 8, 3),(4,'2026-09-08',2000, 1200,  62.00, 9, 4),
(4,'2026-09-15',2500, 1800,  70.00, 9, 4),(4,'2026-09-22',3000, 2940,  75.00, 9, 4),
-- CLIENT 5: Flipkart (smooth — completed)
(5,'2026-09-27', 400,  100,  25.00, 1, 2),(5,'2026-10-04',1200,  600,  60.00, 1, 4),
(5,'2026-10-11',2200, 1800,  85.00, 0, 5),(5,'2026-10-18',2800, 2660,  98.00, 0, 7),
(5,'2026-10-25',2800, 2660,  98.00, 0, 7),(5,'2026-11-01',2800, 2660,  98.00, 0, 7),
(5,'2026-11-08',2800, 2660,  98.00, 0, 7),(5,'2026-11-09',2800, 2660,  98.00, 0, 7),
-- CLIENT 6: Blue Dart (critical — stuck)
(6,'2026-07-12', 100,    0,   5.00, 3, 1),(6,'2026-07-19', 200,   20,  10.00, 7, 2),
(6,'2026-07-26', 300,   50,  15.00,10, 2),(6,'2026-08-02', 400,  100,  20.00,12, 2),
(6,'2026-08-09', 500,  200,  28.00,14, 2),(6,'2026-08-16', 600,  350,  40.00,15, 2),
(6,'2026-08-23', 700,  500,  50.00,16, 2),(6,'2026-08-30', 800,  720,  60.00,17, 2),
-- CLIENT 7: Sun Pharma (smooth — completed)
(7,'2026-09-14', 300,   50,  25.00, 2, 2),(7,'2026-09-21', 900,  400,  55.00, 1, 3),
(7,'2026-09-28',1800, 1200,  80.00, 0, 5),(7,'2026-10-05',2100, 1911,  95.00, 0, 7),
(7,'2026-10-12',2100, 1911,  95.00, 0, 7),(7,'2026-10-19',2100, 1911,  95.00, 0, 7),
(7,'2026-10-26',2100, 1911,  95.00, 0, 7),(7,'2026-11-02',2100, 1911,  95.00, 0, 7),
-- CLIENT 8: ITC Ltd (stuck on HRMS)
(8,'2026-07-25', 100,    0,  10.00, 2, 1),(8,'2026-08-01', 200,    0,  20.00, 4, 2),
(8,'2026-08-08', 400,    0,  35.00, 7, 3),(8,'2026-08-15', 600,  100,  45.00, 9, 3),
(8,'2026-08-22', 800,  300,  52.00,11, 3),(8,'2026-08-29',1000,  600,  58.00,12, 3),
(8,'2026-09-05',1100,  800,  62.00,13, 3),(8,'2026-09-12',1200, 1050,  65.00,14, 3),
-- CLIENT 9: Wipro (fastest — completed)
(9,'2026-09-29', 600,  100,  30.00, 0, 2),(9,'2026-10-06',1500,  800,  65.00, 0, 4),
(9,'2026-10-13',2200, 1800,  85.00, 0, 5),(9,'2026-10-20',2600, 2470,  99.00, 0, 7),
(9,'2026-10-27',2600, 2470,  99.00, 0, 7),(9,'2026-11-03',2600, 2470,  99.00, 0, 7),
(9,'2026-11-09',2600, 2470,  99.00, 0, 7),(9,'2026-11-09',2600, 2470,  99.00, 0, 7),
-- CLIENT 10: Axis Bank (at risk)
(10,'2026-08-22', 300,    0,  15.00, 3, 1),(10,'2026-08-29', 700,  100,  28.00, 4, 2),
(10,'2026-09-05',1200,  400,  42.00, 6, 3),(10,'2026-09-12',2000, 1000,  58.00, 7, 3),
(10,'2026-09-19',2800, 1800,  68.00, 8, 3),(10,'2026-09-26',3200, 2200,  74.00, 8, 3),
(10,'2026-10-03',3500, 2500,  76.00, 8, 3),(10,'2026-10-10',3800, 2660,  78.00, 8, 3),
-- CLIENT 11: Manipal Health (completed)
(11,'2026-09-08', 150,   20,  20.00, 2, 1),(11,'2026-09-15', 400,  200,  48.00, 1, 3),
(11,'2026-09-22', 700,  500,  70.00, 0, 5),(11,'2026-09-29', 900,  783,  92.00, 0, 7),
(11,'2026-10-06', 900,  783,  92.00, 0, 7),(11,'2026-10-13', 900,  783,  92.00, 0, 7),
(11,'2026-10-20', 900,  783,  92.00, 0, 7),(11,'2026-10-27', 900,  783,  92.00, 0, 7),
-- CLIENT 12: Mahindra Group (most delayed)
(12,'2026-06-27', 100,    0,   5.00, 5, 1),(12,'2026-07-04', 200,    0,   8.00, 8, 2),
(12,'2026-07-11', 300,    0,  12.00,12, 2),(12,'2026-07-18', 500,   50,  18.00,14, 2),
(12,'2026-07-25', 700,  150,  25.00,16, 2),(12,'2026-08-01',1000,  400,  35.00,18, 2),
(12,'2026-08-08',1500,  800,  45.00,19, 2),(12,'2026-08-15',2000, 3025,  62.00,21, 2),
-- CLIENT 13: Nykaa (fastest small client)
(13,'2026-10-05', 200,   50,  30.00, 0, 2),(13,'2026-10-12', 500,  300,  65.00, 0, 4),
(13,'2026-10-19', 800,  784, 100.00, 0, 7),(13,'2026-10-26', 800,  784, 100.00, 0, 7),
(13,'2026-11-02', 800,  784, 100.00, 0, 7),(13,'2026-11-09', 800,  784, 100.00, 0, 7),
(13,'2026-11-09', 800,  784, 100.00, 0, 7),(13,'2026-11-09', 800,  784, 100.00, 0, 7),
-- CLIENT 14: Delhivery (delayed)
(14,'2026-08-08', 200,    0,  10.00, 3, 1),(14,'2026-08-15', 400,    0,  22.00, 5, 2),
(14,'2026-08-22', 700,  100,  38.00, 7, 3),(14,'2026-08-29',1000,  400,  52.00, 9, 3),
(14,'2026-09-05',1400,  800,  60.00,10, 3),(14,'2026-09-12',1800, 1100,  65.00,11, 3),
(14,'2026-09-19',2000, 1300,  68.00,12, 3),(14,'2026-09-26',2200, 1540,  70.00,12, 3),
-- CLIENT 15: Dr. Reddys (smooth — completed)
(15,'2026-09-25', 300,   50,  25.00, 1, 2),(15,'2026-10-02', 900,  400,  60.00, 0, 4),
(15,'2026-10-09',1500, 1000,  85.00, 0, 5),(15,'2026-10-16',1700, 1598,  97.00, 0, 7),
(15,'2026-10-23',1700, 1598,  97.00, 0, 7),(15,'2026-10-30',1700, 1598,  97.00, 0, 7),
(15,'2026-11-06',1700, 1598,  97.00, 0, 7),(15,'2026-11-09',1700, 1598,  97.00, 0, 7),
-- CLIENT 16: Britannia (small, smooth)
(16,'2026-09-14', 150,   20,  25.00, 2, 1),(16,'2026-09-21', 350,  150,  55.00, 1, 3),
(16,'2026-09-28', 600,  450,  85.00, 0, 6),(16,'2026-10-05', 600,  528,  90.00, 0, 7),
(16,'2026-10-12', 600,  528,  90.00, 0, 7),(16,'2026-10-19', 600,  528,  90.00, 0, 7),
(16,'2026-10-26', 600,  528,  90.00, 0, 7),(16,'2026-11-02', 600,  528,  90.00, 0, 7),
-- CLIENT 17: HCL Technologies (smooth — completed)
(17,'2026-09-29', 600,   50,  22.00, 1, 2),(17,'2026-10-06',1800,  800,  58.00, 0, 3),
(17,'2026-10-13',3000, 2200,  80.00, 0, 5),(17,'2026-10-20',4100, 3936,  98.00, 0, 7),
(17,'2026-10-27',4100, 3936,  98.00, 0, 7),(17,'2026-11-03',4100, 3936,  98.00, 0, 7),
(17,'2026-11-09',4100, 3936,  98.00, 0, 7),(17,'2026-11-09',4100, 3936,  98.00, 0, 7),
-- CLIENT 18: ICICI Bank (critical — stuck at milestone 2)
(18,'2026-07-17', 200,   30,   8.00, 4, 1),(18,'2026-07-24', 400,  100,  12.00, 8, 2),
(18,'2026-07-31', 600,  200,  18.00,10, 2),(18,'2026-08-07', 800,  400,  22.00,13, 2),
(18,'2026-08-14',1000,  700,  28.00,15, 2),(18,'2026-08-21',1500, 1200,  38.00,17, 2),
(18,'2026-08-28',2000, 2000,  50.00,18, 2),(18,'2026-09-04',2500, 3600,  68.00,19, 2),
-- CLIENT 19: Fortis Healthcare (smooth — completed)
(19,'2026-09-12', 200,   30,  20.00, 2, 2),(19,'2026-09-19', 500,  250,  50.00, 1, 3),
(19,'2026-09-26', 900,  700,  75.00, 1, 5),(19,'2026-10-03',1300, 1118,  88.00, 0, 7),
(19,'2026-10-10',1300, 1118,  88.00, 0, 7),(19,'2026-10-17',1300, 1118,  88.00, 0, 7),
(19,'2026-10-24',1300, 1118,  88.00, 0, 7),(19,'2026-10-31',1300, 1118,  88.00, 0, 7),
-- CLIENT 20: Godrej Industries (smooth — completed)
(20,'2026-09-01', 300,   50,  18.00, 2, 2),(20,'2026-09-08', 700,  300,  40.00, 2, 3),
(20,'2026-09-15',1300,  800,  65.00, 1, 5),(20,'2026-09-22',2000, 1600,  83.00, 0, 7),
(20,'2026-09-29',2000, 1600,  83.00, 0, 7),(20,'2026-10-06',2000, 1600,  83.00, 0, 7),
(20,'2026-10-13',2000, 1600,  83.00, 0, 7),(20,'2026-10-20',2000, 1600,  83.00, 0, 7);


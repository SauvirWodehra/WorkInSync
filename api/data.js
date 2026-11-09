// api/data.js — Shared dataset and KPI calculations for Vercel Serverless Functions
'use strict';

const CLIENTS = [
  { id:1,  name:'Infosys Ltd',          industry:'Technology',    region:'South', plan:'Enterprise',    manager:'Ravi Sharma',     employees:3200, contractStart:'2026-09-01', expectedGoLive:'2026-09-30', actualGoLive:'2026-09-28', contractValueCr:1.85 },
  { id:2,  name:'HDFC Bank',            industry:'Banking',       region:'West',  plan:'Enterprise',    manager:'Priya Nair',      employees:5000, contractStart:'2026-08-10', expectedGoLive:'2026-09-30', actualGoLive:null,          contractValueCr:3.20 },
  { id:3,  name:'Apollo Hospitals',     industry:'Healthcare',    region:'South', plan:'Professional',  manager:'Amit Verma',      employees:1800, contractStart:'2026-09-14', expectedGoLive:'2026-10-15', actualGoLive:'2026-10-05', contractValueCr:0.98 },
  { id:4,  name:'Tata Motors',          industry:'Manufacturing', region:'West',  plan:'Enterprise',    manager:'Deepa Iyer',      employees:4200, contractStart:'2026-07-28', expectedGoLive:'2026-09-15', actualGoLive:null,          contractValueCr:2.75 },
  { id:5,  name:'Flipkart',             industry:'Retail',        region:'South', plan:'Professional',  manager:'Sanjay Mehta',    employees:2800, contractStart:'2026-09-20', expectedGoLive:'2026-10-20', actualGoLive:'2026-10-19', contractValueCr:1.52 },
  { id:6,  name:'Blue Dart',            industry:'Logistics',     region:'West',  plan:'Basic',         manager:'Kavita Joshi',    employees:1200, contractStart:'2026-07-05', expectedGoLive:'2026-08-15', actualGoLive:null,          contractValueCr:0.64 },
  { id:7,  name:'Sun Pharma',           industry:'Pharma',        region:'West',  plan:'Professional',  manager:'Rohit Kulkarni',  employees:2100, contractStart:'2026-09-08', expectedGoLive:'2026-10-08', actualGoLive:'2026-10-10', contractValueCr:1.12 },
  { id:8,  name:'ITC Ltd',              industry:'FMCG',          region:'East',  plan:'Professional',  manager:'Anjali Singh',    employees:1500, contractStart:'2026-07-18', expectedGoLive:'2026-08-30', actualGoLive:null,          contractValueCr:0.81 },
  { id:9,  name:'Wipro',                industry:'Technology',    region:'South', plan:'Enterprise',    manager:'Ravi Sharma',     employees:2600, contractStart:'2026-09-25', expectedGoLive:'2026-10-25', actualGoLive:'2026-10-24', contractValueCr:1.68 },
  { id:10, name:'Axis Bank',            industry:'Banking',       region:'North', plan:'Enterprise',    manager:'Priya Nair',      employees:3800, contractStart:'2026-08-15', expectedGoLive:'2026-09-30', actualGoLive:null,          contractValueCr:2.43 },
  { id:11, name:'Manipal Health',       industry:'Healthcare',    region:'South', plan:'Basic',         manager:'Amit Verma',      employees:900,  contractStart:'2026-09-02', expectedGoLive:'2026-10-01', actualGoLive:'2026-10-03', contractValueCr:0.46 },
  { id:12, name:'Mahindra Group',       industry:'Manufacturing', region:'West',  plan:'Enterprise',    manager:'Deepa Iyer',      employees:5500, contractStart:'2026-06-20', expectedGoLive:'2026-08-20', actualGoLive:null,          contractValueCr:3.45 },
  { id:13, name:'Nykaa',               industry:'Retail',        region:'West',  plan:'Basic',         manager:'Sanjay Mehta',    employees:800,  contractStart:'2026-10-01', expectedGoLive:'2026-10-21', actualGoLive:'2026-10-20', contractValueCr:0.38 },
  { id:14, name:'Delhivery',           industry:'Logistics',     region:'North', plan:'Professional',  manager:'Kavita Joshi',    employees:2200, contractStart:'2026-08-01', expectedGoLive:'2026-09-15', actualGoLive:null,          contractValueCr:1.24 },
  { id:15, name:"Dr. Reddy's",         industry:'Pharma',        region:'South', plan:'Professional',  manager:'Rohit Kulkarni',  employees:1700, contractStart:'2026-09-18', expectedGoLive:'2026-10-18', actualGoLive:'2026-10-17', contractValueCr:0.91 },
  { id:16, name:'Britannia Industries', industry:'FMCG',         region:'East',  plan:'Basic',         manager:'Anjali Singh',    employees:600,  contractStart:'2026-09-10', expectedGoLive:'2026-10-05', actualGoLive:'2026-10-06', contractValueCr:0.31 },
  { id:17, name:'HCL Technologies',    industry:'Technology',    region:'North', plan:'Enterprise',    manager:'Ravi Sharma',     employees:4100, contractStart:'2026-09-22', expectedGoLive:'2026-10-22', actualGoLive:'2026-10-21', contractValueCr:2.62 },
  { id:18, name:'ICICI Bank',          industry:'Banking',       region:'West',  plan:'Enterprise',    manager:'Priya Nair',      employees:6000, contractStart:'2026-07-10', expectedGoLive:'2026-09-01', actualGoLive:null,          contractValueCr:3.95 },
  { id:19, name:'Fortis Healthcare',   industry:'Healthcare',    region:'North', plan:'Professional',  manager:'Amit Verma',      employees:1300, contractStart:'2026-09-05', expectedGoLive:'2026-10-05', actualGoLive:'2026-10-08', contractValueCr:0.72 },
  { id:20, name:'Godrej Industries',   industry:'Manufacturing', region:'West',  plan:'Professional',  manager:'Deepa Iyer',      employees:2000, contractStart:'2026-08-25', expectedGoLive:'2026-09-25', actualGoLive:'2026-09-28', contractValueCr:1.16 },
];

const PROGRESS = {
  1:  { uploaded:3200, activated:2976, setupPct:97,  openIssues:0,  msDone:7 },
  2:  { uploaded:3200, activated:3500, setupPct:72,  openIssues:11, msDone:3 },
  3:  { uploaded:1800, activated:1620, setupPct:100, openIssues:0,  msDone:7 },
  4:  { uploaded:3000, activated:2940, setupPct:75,  openIssues:9,  msDone:4 },
  5:  { uploaded:2800, activated:2660, setupPct:98,  openIssues:0,  msDone:7 },
  6:  { uploaded:800,  activated:720,  setupPct:60,  openIssues:17, msDone:2 },
  7:  { uploaded:2100, activated:1911, setupPct:95,  openIssues:0,  msDone:7 },
  8:  { uploaded:1200, activated:1050, setupPct:65,  openIssues:14, msDone:3 },
  9:  { uploaded:2600, activated:2470, setupPct:99,  openIssues:0,  msDone:7 },
  10: { uploaded:3800, activated:2660, setupPct:78,  openIssues:8,  msDone:3 },
  11: { uploaded:900,  activated:783,  setupPct:92,  openIssues:0,  msDone:7 },
  12: { uploaded:2000, activated:3025, setupPct:62,  openIssues:21, msDone:2 },
  13: { uploaded:800,  activated:784,  setupPct:100, openIssues:0,  msDone:7 },
  14: { uploaded:2200, activated:1540, setupPct:70,  openIssues:12, msDone:3 },
  15: { uploaded:1700, activated:1598, setupPct:97,  openIssues:0,  msDone:7 },
  16: { uploaded:600,  activated:528,  setupPct:90,  openIssues:0,  msDone:7 },
  17: { uploaded:4100, activated:3936, setupPct:98,  openIssues:0,  msDone:7 },
  18: { uploaded:2500, activated:3600, setupPct:68,  openIssues:19, msDone:2 },
  19: { uploaded:1300, activated:1118, setupPct:88,  openIssues:0,  msDone:7 },
  20: { uploaded:2000, activated:1600, setupPct:83,  openIssues:0,  msDone:7 },
};

const MILESTONE_ISSUES = {
  1:[0,0], 2:[0,3], 3:[0,0], 4:[0,3], 5:[0,0], 6:[1,3], 7:[0,0],
  8:[0,3], 9:[0,0],10:[0,3],11:[0,0],12:[1,3],13:[0,0],14:[0,3],
  15:[0,0],16:[0,0],17:[0,0],18:[1,3],19:[0,0],20:[0,0]
};

const WEEKLY_TRENDS = {
  1:  [{w:1,act:100, s:30, oi:2},{w:2,act:600,  s:55, oi:2},{w:3,act:1800,s:75, oi:1},{w:4,act:2500,s:90, oi:0},{w:5,act:2900,s:97, oi:0},{w:6,act:2976,s:97,  oi:0},{w:7,act:2976,s:97, oi:0},{w:8,act:2976,s:97, oi:0}],
  2:  [{w:1,act:50,  s:20, oi:4},{w:2,act:150,  s:35, oi:5},{w:3,act:250, s:45, oi:7},{w:4,act:500, s:58, oi:8},{w:5,act:900, s:65, oi:9},{w:6,act:2000,s:70,  oi:10},{w:7,act:2800,s:72, oi:11},{w:8,act:3500,s:72,oi:11}],
  3:  [{w:1,act:200, s:40, oi:0},{w:2,act:800,  s:70, oi:0},{w:3,act:1500,s:95, oi:0},{w:4,act:1620,s:100,oi:0},{w:5,act:1620,s:100,oi:0},{w:6,act:1620,s:100, oi:0},{w:7,act:1620,s:100,oi:0},{w:8,act:1620,s:100,oi:0}],
  4:  [{w:1,act:0,   s:10, oi:2},{w:2,act:0,    s:18, oi:4},{w:3,act:0,   s:28, oi:6},{w:4,act:200, s:40, oi:7},{w:5,act:600, s:52, oi:8},{w:6,act:1200,s:62,  oi:9},{w:7,act:1800,s:70, oi:9},{w:8,act:2940,s:75, oi:9}],
  5:  [{w:1,act:100, s:25, oi:1},{w:2,act:600,  s:60, oi:1},{w:3,act:1800,s:85, oi:0},{w:4,act:2660,s:98, oi:0},{w:5,act:2660,s:98, oi:0},{w:6,act:2660,s:98,  oi:0},{w:7,act:2660,s:98, oi:0},{w:8,act:2660,s:98, oi:0}],
  6:  [{w:1,act:0,   s:5,  oi:3},{w:2,act:20,   s:10, oi:7},{w:3,act:50,  s:15, oi:10},{w:4,act:100,s:20, oi:12},{w:5,act:200,s:28, oi:14},{w:6,act:350, s:40, oi:15},{w:7,act:500, s:50, oi:16},{w:8,act:720, s:60, oi:17}],
  7:  [{w:1,act:50,  s:25, oi:2},{w:2,act:400,  s:55, oi:1},{w:3,act:1200,s:80, oi:0},{w:4,act:1911,s:95, oi:0},{w:5,act:1911,s:95, oi:0},{w:6,act:1911,s:95,  oi:0},{w:7,act:1911,s:95, oi:0},{w:8,act:1911,s:95,oi:0}],
  8:  [{w:1,act:0,   s:10, oi:2},{w:2,act:0,    s:20, oi:4},{w:3,act:0,   s:35, oi:7},{w:4,act:100, s:45, oi:9},{w:5,act:300, s:52, oi:11},{w:6,act:600, s:58, oi:12},{w:7,act:800, s:62, oi:13},{w:8,act:1050,s:65,oi:14}],
  9:  [{w:1,act:100, s:30, oi:0},{w:2,act:800,  s:65, oi:0},{w:3,act:1800,s:85, oi:0},{w:4,act:2470,s:99, oi:0},{w:5,act:2470,s:99, oi:0},{w:6,act:2470,s:99,  oi:0},{w:7,act:2470,s:99, oi:0},{w:8,act:2470,s:99,oi:0}],
  10: [{w:1,act:0,   s:15, oi:3},{w:2,act:100,  s:28, oi:4},{w:3,act:400, s:42, oi:6},{w:4,act:1000,s:58, oi:7},{w:5,act:1800,s:68, oi:8},{w:6,act:2200,s:74,  oi:8},{w:7,act:2500,s:76, oi:8},{w:8,act:2660,s:78,oi:8}],
  11: [{w:1,act:20,  s:20, oi:2},{w:2,act:200,  s:48, oi:1},{w:3,act:500, s:70, oi:0},{w:4,act:783, s:92, oi:0},{w:5,act:783, s:92, oi:0},{w:6,act:783, s:92,  oi:0},{w:7,act:783, s:92, oi:0},{w:8,act:783, s:92,oi:0}],
  12: [{w:1,act:0,   s:5,  oi:5},{w:2,act:0,    s:8,  oi:8},{w:3,act:0,   s:12, oi:12},{w:4,act:50, s:18, oi:14},{w:5,act:150,s:25, oi:16},{w:6,act:400, s:35, oi:18},{w:7,act:800, s:45, oi:19},{w:8,act:3025,s:62,oi:21}],
  13: [{w:1,act:50,  s:30, oi:0},{w:2,act:300,  s:65, oi:0},{w:3,act:784, s:100,oi:0},{w:4,act:784, s:100,oi:0},{w:5,act:784, s:100,oi:0},{w:6,act:784, s:100, oi:0},{w:7,act:784, s:100,oi:0},{w:8,act:784,s:100,oi:0}],
  14: [{w:1,act:0,   s:10, oi:3},{w:2,act:0,    s:22, oi:5},{w:3,act:100, s:38, oi:7},{w:4,act:400, s:52, oi:9},{w:5,act:800, s:60, oi:10},{w:6,act:1100,s:65, oi:11},{w:7,act:1300,s:68, oi:12},{w:8,act:1540,s:70,oi:12}],
  15: [{w:1,act:50,  s:25, oi:1},{w:2,act:400,  s:60, oi:0},{w:3,act:1000,s:85, oi:0},{w:4,act:1598,s:97, oi:0},{w:5,act:1598,s:97, oi:0},{w:6,act:1598,s:97,  oi:0},{w:7,act:1598,s:97, oi:0},{w:8,act:1598,s:97,oi:0}],
  16: [{w:1,act:20,  s:25, oi:2},{w:2,act:150,  s:55, oi:1},{w:3,act:450, s:85, oi:0},{w:4,act:528, s:90, oi:0},{w:5,act:528, s:90, oi:0},{w:6,act:528, s:90,  oi:0},{w:7,act:528, s:90, oi:0},{w:8,act:528, s:90,oi:0}],
  17: [{w:1,act:50,  s:22, oi:1},{w:2,act:800,  s:58, oi:0},{w:3,act:2200,s:80, oi:0},{w:4,act:3936,s:98, oi:0},{w:5,act:3936,s:98, oi:0},{w:6,act:3936,s:98,  oi:0},{w:7,act:3936,s:98, oi:0},{w:8,act:3936,s:98,oi:0}],
  18: [{w:1,act:30,  s:8,  oi:4},{w:2,act:100,  s:12, oi:8},{w:3,act:200, s:18, oi:10},{w:4,act:400,s:22, oi:13},{w:5,act:700, s:28, oi:15},{w:6,act:1200,s:38, oi:17},{w:7,act:2000,s:50, oi:18},{w:8,act:3600,s:68,oi:19}],
  19: [{w:1,act:30,  s:20, oi:2},{w:2,act:250,  s:50, oi:1},{w:3,act:700, s:75, oi:1},{w:4,act:1118,s:88, oi:0},{w:5,act:1118,s:88, oi:0},{w:6,act:1118,s:88,  oi:0},{w:7,act:1118,s:88, oi:0},{w:8,act:1118,s:88,oi:0}],
  20: [{w:1,act:50,  s:18, oi:2},{w:2,act:300,  s:40, oi:2},{w:3,act:800, s:65, oi:1},{w:4,act:1600,s:83, oi:0},{w:5,act:1600,s:83, oi:0},{w:6,act:1600,s:83,  oi:0},{w:7,act:1600,s:83, oi:0},{w:8,act:1600,s:83,oi:0}],
};

const ISSUES_BY_CAT = [
  {clientId:2,  name:'HDFC Bank',       cat:'SSO/Authentication',  sev:'Critical', cnt:1},
  {clientId:2,  name:'HDFC Bank',       cat:'Office Configuration', sev:'High',     cnt:2},
  {clientId:2,  name:'HDFC Bank',       cat:'HRMS Integration',     sev:'High',     cnt:2},
  {clientId:2,  name:'HDFC Bank',       cat:'Employee Data',        sev:'Medium',   cnt:4},
  {clientId:2,  name:'HDFC Bank',       cat:'Network/Firewall',     sev:'High',     cnt:1},
  {clientId:2,  name:'HDFC Bank',       cat:'Other',                sev:'Low',      cnt:1},
  {clientId:4,  name:'Tata Motors',     cat:'HRMS Integration',     sev:'Critical', cnt:1},
  {clientId:4,  name:'Tata Motors',     cat:'Office Configuration', sev:'High',     cnt:2},
  {clientId:4,  name:'Tata Motors',     cat:'SSO/Authentication',   sev:'High',     cnt:1},
  {clientId:4,  name:'Tata Motors',     cat:'Employee Data',        sev:'Medium',   cnt:2},
  {clientId:4,  name:'Tata Motors',     cat:'Permissions',          sev:'Medium',   cnt:1},
  {clientId:4,  name:'Tata Motors',     cat:'Other',                sev:'Low',      cnt:2},
  {clientId:6,  name:'Blue Dart',       cat:'Office Configuration', sev:'Critical', cnt:4},
  {clientId:6,  name:'Blue Dart',       cat:'Network/Firewall',     sev:'High',     cnt:2},
  {clientId:6,  name:'Blue Dart',       cat:'HRMS Integration',     sev:'High',     cnt:2},
  {clientId:6,  name:'Blue Dart',       cat:'Employee Data',        sev:'Medium',   cnt:3},
  {clientId:6,  name:'Blue Dart',       cat:'Other',                sev:'Medium',   cnt:4},
  {clientId:6,  name:'Blue Dart',       cat:'Permissions',          sev:'Low',      cnt:1},
  {clientId:8,  name:'ITC Ltd',         cat:'HRMS Integration',     sev:'Critical', cnt:2},
  {clientId:8,  name:'ITC Ltd',         cat:'SSO/Authentication',   sev:'High',     cnt:1},
  {clientId:8,  name:'ITC Ltd',         cat:'Employee Data',        sev:'Medium',   cnt:3},
  {clientId:8,  name:'ITC Ltd',         cat:'Network/Firewall',     sev:'Medium',   cnt:1},
  {clientId:8,  name:'ITC Ltd',         cat:'Other',                sev:'Medium',   cnt:4},
  {clientId:8,  name:'ITC Ltd',         cat:'Permissions',          sev:'Low',      cnt:1},
  {clientId:8,  name:'ITC Ltd',         cat:'Office Configuration', sev:'Low',      cnt:2},
  {clientId:10, name:'Axis Bank',       cat:'HRMS Integration',     sev:'Critical', cnt:1},
  {clientId:10, name:'Axis Bank',       cat:'Network/Firewall',     sev:'High',     cnt:1},
  {clientId:10, name:'Axis Bank',       cat:'Employee Data',        sev:'Medium',   cnt:2},
  {clientId:10, name:'Axis Bank',       cat:'Permissions',          sev:'Low',      cnt:1},
  {clientId:10, name:'Axis Bank',       cat:'Other',                sev:'Low',      cnt:3},
  {clientId:12, name:'Mahindra Group',  cat:'Office Configuration', sev:'Critical', cnt:4},
  {clientId:12, name:'Mahindra Group',  cat:'HRMS Integration',     sev:'Critical', cnt:2},
  {clientId:12, name:'Mahindra Group',  cat:'Employee Data',        sev:'High',     cnt:3},
  {clientId:12, name:'Mahindra Group',  cat:'Network/Firewall',     sev:'High',     cnt:3},
  {clientId:12, name:'Mahindra Group',  cat:'SSO/Authentication',   sev:'Medium',   cnt:1},
  {clientId:12, name:'Mahindra Group',  cat:'Other',                sev:'Medium',   cnt:5},
  {clientId:12, name:'Mahindra Group',  cat:'Permissions',          sev:'Low',      cnt:1},
  {clientId:12, name:'Mahindra Group',  cat:'Office Configuration', sev:'Medium',   cnt:2},
  {clientId:14, name:'Delhivery',       cat:'HRMS Integration',     sev:'High',     cnt:2},
  {clientId:14, name:'Delhivery',       cat:'Network/Firewall',     sev:'High',     cnt:1},
  {clientId:14, name:'Delhivery',       cat:'Office Configuration', sev:'Medium',   cnt:2},
  {clientId:14, name:'Delhivery',       cat:'Employee Data',        sev:'Medium',   cnt:2},
  {clientId:14, name:'Delhivery',       cat:'SSO/Authentication',   sev:'Medium',   cnt:1},
  {clientId:14, name:'Delhivery',       cat:'Other',                sev:'Low',      cnt:3},
  {clientId:14, name:'Delhivery',       cat:'Permissions',          sev:'Medium',   cnt:1},
  {clientId:18, name:'ICICI Bank',      cat:'Network/Firewall',     sev:'Critical', cnt:2},
  {clientId:18, name:'ICICI Bank',      cat:'HRMS Integration',     sev:'Critical', cnt:1},
  {clientId:18, name:'ICICI Bank',      cat:'SSO/Authentication',   sev:'Critical', cnt:2},
  {clientId:18, name:'ICICI Bank',      cat:'Office Configuration', sev:'High',     cnt:2},
  {clientId:18, name:'ICICI Bank',      cat:'Employee Data',        sev:'High',     cnt:3},
  {clientId:18, name:'ICICI Bank',      cat:'Other',                sev:'High',     cnt:4},
  {clientId:18, name:'ICICI Bank',      cat:'Permissions',          sev:'Medium',   cnt:2},
  {clientId:18, name:'ICICI Bank',      cat:'Employee Data',        sev:'Medium',   cnt:1},
  {clientId:18, name:'ICICI Bank',      cat:'Other',                sev:'Low',      cnt:2},
];

const MILESTONES_DATA = {
  1:  [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:0},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:0}],
  2:  [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:1},{m:'Office Config',s:'Completed',d:2},{m:'HRMS Integration',s:'In Progress',d:21},{m:'Employee Upload',s:'Pending',d:35},{m:'Activation Drive',s:'Pending',d:0},{m:'UAT & Go-Live',s:'Pending',d:0}],
  3:  [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:0},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:0}],
  4:  [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:3},{m:'Office Config',s:'Completed',d:10},{m:'HRMS Integration',s:'In Progress',d:26},{m:'Employee Upload',s:'Pending',d:40},{m:'Activation Drive',s:'Pending',d:0},{m:'UAT & Go-Live',s:'Pending',d:0}],
  5:  [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:0},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:0}],
  6:  [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:2},{m:'Office Config',s:'Failed',d:0},{m:'HRMS Integration',s:'Pending',d:0},{m:'Employee Upload',s:'Pending',d:0},{m:'Activation Drive',s:'Pending',d:0},{m:'UAT & Go-Live',s:'Pending',d:0}],
  7:  [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:1},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:2}],
  8:  [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:3},{m:'Office Config',s:'Completed',d:9},{m:'HRMS Integration',s:'In Progress',d:22},{m:'Employee Upload',s:'Pending',d:35},{m:'Activation Drive',s:'Pending',d:0},{m:'UAT & Go-Live',s:'Pending',d:0}],
  9:  [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:0},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:0}],
  10: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:2},{m:'Office Config',s:'Completed',d:7},{m:'HRMS Integration',s:'In Progress',d:17},{m:'Employee Upload',s:'Pending',d:28},{m:'Activation Drive',s:'Pending',d:0},{m:'UAT & Go-Live',s:'Pending',d:0}],
  11: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:1},{m:'HRMS Integration',s:'Completed',d:0},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:2}],
  12: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:3},{m:'Office Config',s:'Failed',d:0},{m:'HRMS Integration',s:'In Progress',d:51},{m:'Employee Upload',s:'Pending',d:65},{m:'Activation Drive',s:'Pending',d:0},{m:'UAT & Go-Live',s:'Pending',d:0}],
  13: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:0},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:0}],
  14: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:2},{m:'Office Config',s:'Completed',d:13},{m:'HRMS Integration',s:'In Progress',d:21},{m:'Employee Upload',s:'Pending',d:35},{m:'Activation Drive',s:'Pending',d:0},{m:'UAT & Go-Live',s:'Pending',d:0}],
  15: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:0},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:0}],
  16: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:0},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:1}],
  17: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:0},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:0}],
  18: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:1},{m:'Office Config',s:'Failed',d:0},{m:'HRMS Integration',s:'Pending',d:65},{m:'Employee Upload',s:'Pending',d:0},{m:'Activation Drive',s:'Pending',d:0},{m:'UAT & Go-Live',s:'Pending',d:0}],
  19: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:1},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:3}],
  20: [{m:'Contract & Kickoff',s:'Completed',d:0},{m:'Admin Setup',s:'Completed',d:0},{m:'Office Config',s:'Completed',d:0},{m:'HRMS Integration',s:'Completed',d:0},{m:'Employee Upload',s:'Completed',d:0},{m:'Activation Drive',s:'Completed',d:0},{m:'UAT & Go-Live',s:'Completed',d:3}],
};

const TODAY = new Date('2026-11-09');

function daysBetween(d1Str, d2Str) {
  if (!d1Str || !d2Str) return null;
  return Math.round((new Date(d2Str) - new Date(d1Str)) / 86400000);
}

function computeHealthScore(activationPct, setupPct, openIssues, onboardDays, failedMs, criticalOpenIssues) {
  const compA = activationPct * 0.40;
  const compB = setupPct * 0.35;
  const penIssues   = Math.min(openIssues * 2, 25);
  const penTime     = Math.min(Math.max(onboardDays - 25, 0) * 0.5, 15);
  const penFailed   = Math.min(failedMs * 5, 10);
  const penCritical = Math.min(criticalOpenIssues * 3, 15);
  const raw = compA + compB + 25 - penIssues - penTime - penFailed - penCritical;
  return Math.max(0, Math.min(100, Math.round(raw)));
}

function statusLabel(health, setupPct, openIssues) {
  if (setupPct === 100 && openIssues === 0) return 'Completed';
  if (health >= 80) return 'On Track';
  if (health >= 60) return 'At Risk';
  return 'Delayed';
}

function computeAllClients() {
  return CLIENTS.map(c => {
    const p = PROGRESS[c.id];
    const ms = MILESTONE_ISSUES[c.id];
    const failedMs   = ms[0];
    const criticalOI = ISSUES_BY_CAT
      .filter(i => i.clientId === c.id && i.sev === 'Critical')
      .reduce((s, i) => s + i.cnt, 0);

    const onboardDays = c.actualGoLive
      ? daysBetween(c.contractStart, c.actualGoLive)
      : daysBetween(c.contractStart, TODAY.toISOString().slice(0,10));

    const goLiveDelay = c.actualGoLive
      ? daysBetween(c.expectedGoLive, c.actualGoLive)
      : (new Date(c.expectedGoLive) < TODAY
          ? daysBetween(c.expectedGoLive, TODAY.toISOString().slice(0,10))
          : null);

    const activationPct = parseFloat(((p.activated / c.employees) * 100).toFixed(2));
    const health = computeHealthScore(
      activationPct, p.setupPct, p.openIssues, onboardDays, failedMs, criticalOI
    );
    const status = statusLabel(health, p.setupPct, p.openIssues);

    const slaDays = {Enterprise:45, Professional:30, Basic:21}[c.plan];
    const withinSLA = onboardDays <= slaDays;

    return {
      ...c,
      uploaded:      p.uploaded,
      activated:     p.activated,
      setupPct:      p.setupPct,
      openIssues:    p.openIssues,
      msDone:        p.msDone,
      failedMs,
      criticalOpenIssues: criticalOI,
      onboardDays,
      goLiveDelay,
      activationPct,
      health,
      status,
      slaDays,
      withinSLA,
      pending: c.employees - p.activated,
    };
  });
}

function apiSummary(clients) {
  const totalEmp   = clients.reduce((s,c) => s+c.employees, 0);
  const totalAct   = clients.reduce((s,c) => s+c.activated, 0);
  const avgSetup   = +(clients.reduce((s,c) => s+c.setupPct, 0) / clients.length).toFixed(2);
  const avgOnboard = +(clients.reduce((s,c) => s+c.onboardDays, 0) / clients.length).toFixed(1);
  const totalOpenIssues = clients.reduce((s,c) => s+c.openIssues, 0);
  const avgHealth  = +(clients.reduce((s,c) => s+c.health, 0) / clients.length).toFixed(1);
  const totalARR   = +clients.reduce((s,c) => s+c.contractValueCr, 0).toFixed(2);
  const arrAtRisk  = +clients.filter(c=>c.health<70).reduce((s,c)=>s+c.contractValueCr,0).toFixed(2);
  const statusCount = {Completed:0,'On Track':0,'At Risk':0,Delayed:0};
  clients.forEach(c => { statusCount[c.status] = (statusCount[c.status]||0)+1; });
  const slaOK = clients.filter(c=>c.withinSLA).length;
  const activePct = +((totalAct/totalEmp)*100).toFixed(2);

  return { totalClients:clients.length, totalEmp, totalAct, activePct,
    avgSetup, avgOnboard, totalOpenIssues, avgHealth,
    totalARR, arrAtRisk, pctARRAtRisk: +((arrAtRisk/totalARR)*100).toFixed(1),
    slaCompliance: +((slaOK/clients.length)*100).toFixed(1),
    ...statusCount };
}

function apiIssuesByCat() {
  const catMap = {};
  ISSUES_BY_CAT.forEach(i => {
    if (!catMap[i.cat]) catMap[i.cat] = {category:i.cat, total:0, critical:0, high:0, medium:0, low:0};
    catMap[i.cat].total += i.cnt;
    catMap[i.cat][i.sev.toLowerCase()] += i.cnt;
  });
  return Object.values(catMap).sort((a,b)=>b.total-a.total);
}

module.exports = {
  CLIENTS,
  PROGRESS,
  WEEKLY_TRENDS,
  MILESTONES_DATA,
  ISSUES_BY_CAT,
  computeAllClients,
  apiSummary,
  apiIssuesByCat,
};

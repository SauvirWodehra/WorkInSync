const { CLIENTS, WEEKLY_TRENDS } = require('./data.js');

module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');
  const all = [];
  Object.entries(WEEKLY_TRENDS).forEach(([cid, weeks]) => {
    const c = CLIENTS.find(x => x.id === +cid);
    weeks.forEach((w, i) => {
      const prev = i > 0 ? weeks[i - 1].act : 0;
      all.push({
        clientId: +cid,
        clientName: c.name,
        industry: c.industry,
        week: w.w,
        activated: w.act,
        setupPct: w.s,
        openIssues: w.oi,
        wowDelta: w.act - prev,
        activationPct: parseFloat(((w.act / c.employees) * 100).toFixed(2)),
      });
    });
  });
  res.status(200).json(all);
};

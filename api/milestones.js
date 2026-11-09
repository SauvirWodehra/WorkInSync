const { CLIENTS, MILESTONES_DATA } = require('./data.js');

module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');
  const all = [];
  Object.entries(MILESTONES_DATA).forEach(([cid, ms]) => {
    const c = CLIENTS.find(x => x.id === +cid);
    ms.forEach((m, i) => {
      all.push({
        clientId: +cid,
        clientName: c.name,
        industry: c.industry,
        order: i + 1,
        milestone: m.m,
        status: m.s,
        delayDays: m.d,
      });
    });
  });
  res.status(200).json(all);
};

const { computeAllClients } = require('./data.js');

module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');
  const clients = computeAllClients();
  const atRisk = clients
    .filter(c => c.status === 'Delayed' || c.status === 'At Risk')
    .sort((a, b) => a.health - b.health);
  res.status(200).json(atRisk);
};

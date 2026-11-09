const { computeAllClients, apiSummary } = require('./data.js');

module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Content-Type', 'application/json');
  const clients = computeAllClients();
  res.status(200).json(apiSummary(clients));
};

const path = require('path');
const fs = require('fs');

const env = process.env.NODE_ENV || 'development';
const configPath = path.join(__dirname, `../../config/${env}.json`);

let config = {};
if (fs.existsSync(configPath)) {
  config = require(configPath);
} else {
  console.warn(`⚠️ Config file not found: ${configPath}. Using defaults.`);
  config = { apiKey: "dummy-key", apiUrl: "http://localhost:3000" };
}

module.exports = config;

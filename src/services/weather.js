const axios = require('axios');
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

class WeatherService {
  async getWeatherByCity(city) {
    const response = await axios.get(`${config.apiUrl}?q=${city}&appid=${config.apiKey}`);
    return {
      city: city,
      temperature: response.data.main.temp,
      description: response.data.weather[0].description,
    };
  }
}

module.exports = new WeatherService(); // ✅ export instance

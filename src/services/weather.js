const axios = require('axios');
const config = require('../../config/' + (process.env.NODE_ENV || 'development') + '.json');

class WeatherService {
  constructor() {
    this.apiKey = process.env.OPENWEATHER_API_KEY || config.openWeatherApiKey;
    this.baseUrl = 'https://api.openweathermap.org/data/2.5';
  }

  async getWeatherByCity(city) {
    try {
      const response = await axios.get(
        `${this.baseUrl}/weather?q=${city}&appid=${this.apiKey}&units=metric`
      );
      return {
        city: response.data.name,
        temperature: response.data.main.temp,
        description: response.data.weather[0].description,
        humidity: response.data.main.humidity,
        windSpeed: response.data.wind.speed
      };
    } catch (error) {
      throw new Error(`Failed to fetch weather data: ${error.response?.data?.message || error.message}`);
    }
  }
}

module.exports = new WeatherService();
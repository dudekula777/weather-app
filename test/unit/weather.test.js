const weatherService = require('../../src/services/weather');

// Mock axios
jest.mock('axios');
const axios = require('axios');

describe('Weather Service', () => {
  beforeEach(() => {
    process.env.OPENWEATHER_API_KEY = 'test-api-key';
    jest.clearAllMocks();
  });

  it('should fetch weather data by city', async () => {
    const mockResponse = {
      data: {
        name: 'London',
        main: { temp: 15, humidity: 75 },
        weather: [{ description: 'cloudy' }],
        wind: { speed: 3.5 }
      }
    };
    
    axios.get.mockResolvedValue(mockResponse);
    
    const result = await weatherService.getWeatherByCity('London');
    
    expect(result).toEqual({
      city: 'London',
      temperature: 15,
      description: 'cloudy',
      humidity: 75,
      windSpeed: 3.5
    });
    
    expect(axios.get).toHaveBeenCalledWith(
      'https://api.openweathermap.org/data/2.5/weather?q=London&appid=test-api-key&units=metric'
    );
  });
});
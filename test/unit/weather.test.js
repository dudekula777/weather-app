const axios = require('axios');
jest.mock('axios');

const weatherService = require('../../src/services/weather');

describe('Weather Service', () => {
  it('should fetch weather data by city', async () => {
    const mockResponse = {
      data: {
        main: { temp: 25 },
        weather: [{ description: 'clear sky' }],
      },
    };

    axios.get.mockResolvedValue(mockResponse);

    const result = await weatherService.getWeatherByCity('London');

    expect(result).toEqual({
      city: 'London',
      temperature: 25,
      description: 'clear sky',
    });
  });
});

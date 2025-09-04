const express = require('express');
const router = express.Router();
const weatherService = require('../services/weather');

router.get('/:city', async (req, res) => {
  try {
    const weatherData = await weatherService.getWeatherByCity(req.params.city);
    res.json(weatherData);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
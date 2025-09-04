const express = require('express');
const cors = require('cors');
const weatherRoutes = require('./routes/weather');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/weather', weatherRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Weather app is running' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ message: 'Route not found' });
});

module.exports = app;
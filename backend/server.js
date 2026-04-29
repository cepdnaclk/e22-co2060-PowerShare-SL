const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', require('./src/routes/auth'));
app.use('/api/chargers', require('./src/routes/chargers'));
app.use('/api/bookings', require('./src/routes/bookings'));
app.use('/api/earnings', require('./src/routes/earnings'));

// Test route
app.get('/', (req, res) => {
  res.json({ message: 'PowerShare SL API Running! 🚀' });
});

// MongoDB Connect
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('✅ MongoDB Connected!');
    app.listen(process.env.PORT, () => {
      console.log(`🚀 Server running on port ${process.env.PORT}`);
    });
  })
  .catch((err) => {
    console.error('❌ MongoDB Connection Error:', err);
  });
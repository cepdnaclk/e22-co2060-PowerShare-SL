const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  userName: { type: String, required: true },
  userEmail: { type: String, required: true },
  chargerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Charger' },
  chargerName: { type: String, required: true },
  chargerAddress: { type: String, required: true },
  date: { type: String, required: true },
  time: { type: String, required: true },
  durationHours: { type: Number, required: true },
  totalPrice: { type: Number, required: true },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled'],
    default: 'confirmed',
  },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Booking', bookingSchema);
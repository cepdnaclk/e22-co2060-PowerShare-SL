const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  chargerId:      { type: String, required: true },
  chargerName:    { type: String, required: true },
  chargerAddress: { type: String, required: true },
  userId:         { type: String, required: true },
  userName:       { type: String },
  userEmail:      { type: String },
  hostId:         { type: String },

  date:           { type: String, required: true },
  time:           { type: String, required: true },
  durationHours:  { type: Number, required: true },
  totalPrice:     { type: Number, required: true },
  estimatedKwh:   { type: Number, default: 0 },

  // For clash detection — store as actual DateTime
  startDateTime:  { type: Date },
  endDateTime:    { type: Date },

  // Payment & booking status
  // pending_confirmation → confirmed / rejected
  // cancelled → refunded
  status: {
    type: String,
    enum: ['pending_confirmation', 'confirmed', 'rejected', 'cancelled', 'completed'],
    default: 'pending_confirmation',
  },

  // Payment tracking
  paymentStatus: {
    type: String,
    enum: ['held', 'released', 'refunded'],
    default: 'held',
  },
  paymentMethod:  { type: String, default: 'card' },

  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Booking', bookingSchema);
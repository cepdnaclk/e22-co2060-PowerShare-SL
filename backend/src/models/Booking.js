const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  chargerId:      { type: String, required: true },
  chargerName:    { type: String, required: true },
  chargerAddress: { type: String, required: true },
  userId:         { type: String, required: true },
  userName:       { type: String },
  userEmail:      { type: String },
  hostId:         { type: String },           // ← host's userId
  date:           { type: String, required: true },
  time:           { type: String, required: true },
  durationHours:  { type: Number, required: true },
  estimatedKwh:   { type: Number, default: 0 },
  totalPrice:     { type: Number, required: true },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled', 'completed'],
    default: 'pending',
  },
  cancelReason:   { type: String },
  expiresAt:      { type: Date },             // ← auto-cancel time
}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);

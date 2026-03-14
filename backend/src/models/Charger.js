const mongoose = require('mongoose');

const chargerSchema = new mongoose.Schema({
  name: { type: String, required: true },
  address: { type: String, required: true },
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  pricePerHour: { type: Number, required: true },
  isAvailable: { type: Boolean, default: true },
  ownerName: { type: String, required: true },
  ownerId: { type: String },
  rating: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Charger', chargerSchema);
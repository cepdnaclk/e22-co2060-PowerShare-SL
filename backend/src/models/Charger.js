const mongoose = require('mongoose');

const chargerSchema = new mongoose.Schema({
  name:              { type: String, required: true },
  address:           { type: String, required: true },
  latitude:          { type: Number, required: true },
  longitude:         { type: Number, required: true },
  pricePerKwh:       { type: Number, required: true },
  powerKw:           { type: Number, default: 3.3 },
  chargerType:       { type: String, enum: ['Slow','Standard','Fast','Rapid'], default: 'Standard' },
  isAvailable:       { type: Boolean, default: true },
  manualAcceptance:  { type: Boolean, default: false }, // ← NEW
  ownerName:         { type: String, required: true },
  ownerId:           { type: String },
  rating:            { type: Number, default: 0 },
  createdAt:         { type: Date, default: Date.now },
});

module.exports = mongoose.model('Charger', chargerSchema);

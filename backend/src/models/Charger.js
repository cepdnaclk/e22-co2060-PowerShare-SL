const mongoose = require('mongoose');

const chargerSchema = new mongoose.Schema({
  name:         { type: String, required: true },
  address:      { type: String, required: true },
  latitude:     { type: Number, required: true },
  longitude:    { type: Number, required: true },
  pricePerKwh:  { type: Number, required: true }, // Rs. per kWh
  powerKw:      { type: Number, required: true, default: 7.4 }, // charger speed
  // powerKw examples:
  //   3.3  → Slow   (home socket level)
  //   7.4  → Medium (standard home charger)
  //   22.0 → Fast   (AC fast charger)
  //   50.0 → Rapid  (DC rapid charger)
  isAvailable:  { type: Boolean, default: true },
  ownerName:    { type: String, required: true },
  ownerId:      { type: String },
  rating:       { type: Number, default: 0 },
  createdAt:    { type: Date, default: Date.now },
});

module.exports = mongoose.model('Charger', chargerSchema);
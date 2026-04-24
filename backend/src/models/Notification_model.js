const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId:   { type: String, required: true },  // recipient
  title:    { type: String, required: true },
  message:  { type: String, required: true },
  type:     { type: String, enum: ['booking', 'confirmation', 'cancelled', 'reminder', 'earnings', 'system'], default: 'system' },
  isRead:   { type: Boolean, default: false },
  data:     { type: Object, default: {} },      // bookingId etc.
}, { timestamps: true });

module.exports = mongoose.model('Notification', notificationSchema);

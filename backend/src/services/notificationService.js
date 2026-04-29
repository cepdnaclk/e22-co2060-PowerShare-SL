const Notification = require('../models/Notification_model');

// Create notification in DB
async function createNotification({ userId, title, message, type = 'system', data = {} }) {
  try {
    const notif = new Notification({ userId, title, message, type, data });
    await notif.save();
    return notif;
  } catch (e) {
    console.log('Notification error:', e.message);
  }
}

module.exports = { createNotification };

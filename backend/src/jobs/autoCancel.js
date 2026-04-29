// backend/src/jobs/autoCancel.js
// Run every 5 minutes — cancel expired pending bookings
const Booking = require('../models/Booking');
const { createNotification } = require('../services/notificationService');

async function cancelExpiredBookings() {
  try {
    const expired = await Booking.find({
      status: 'pending',
      expiresAt: { $lt: new Date() },
    });

    for (const booking of expired) {
      booking.status = 'cancelled';
      booking.cancelReason = 'Host did not respond within 1 hour';
      await booking.save();

      // Notify driver
      await createNotification({
        userId: booking.userId,
        title: '⏰ Booking Expired',
        message: `Your booking for "${booking.chargerName}" was auto-cancelled (host did not respond within 1 hour).`,
        type: 'cancelled',
        data: { bookingId: booking._id },
      });

      // Notify host
      if (booking.hostId) {
        await createNotification({
          userId: booking.hostId,
          title: '⏰ Booking Request Expired',
          message: `A booking request from ${booking.userName} for ${booking.date} was auto-cancelled (1 hour timeout).`,
          type: 'cancelled',
          data: { bookingId: booking._id },
        });
      }
    }

    if (expired.length > 0) {
      console.log(`Auto-cancelled ${expired.length} expired bookings`);
    }
  } catch (e) {
    console.error('Auto-cancel error:', e.message);
  }
}

module.exports = cancelExpiredBookings;

const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const Charger = require('../models/Charger');
const auth = require('../middleware/auth');
const { createNotification } = require('../services/notificationService');

// Create booking + notify both parties
router.post('/', auth, async (req, res) => {
  try {
    const booking = new Booking({
      ...req.body,
      userId: req.user.userId,
      userName: req.user.name,
      userEmail: req.user.email,
    });
    await booking.save();

    const charger = await Charger.findById(req.body.chargerId);

    // Notify HOST
    if (charger?.ownerId) {
      await createNotification({
        userId: charger.ownerId,
        title: '🔔 New Booking Received!',
        message: `${req.user.name} booked "${charger.name}" — ${req.body.date} at ${req.body.time} for ${req.body.durationHours}hr`,
        type: 'booking',
        data: { bookingId: booking._id },
      });
    }

    // Notify DRIVER (confirmation)
    await createNotification({
      userId: req.user.userId,
      title: '✅ Booking Confirmed!',
      message: `"${charger?.name}" — ${req.body.date} at ${req.body.time} — Rs.${req.body.totalPrice}`,
      type: 'confirmation',
      data: { bookingId: booking._id },
    });

    res.json({ success: true, booking });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// Get my bookings
router.get('/my', auth, async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.user.userId })
      .sort({ createdAt: -1 });
    res.json({ success: true, bookings });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// Get host received bookings
router.get('/received', auth, async (req, res) => {
  try {
    const myChargers = await Charger.find({ ownerId: req.user.userId });
    const ids = myChargers.map(c => c._id.toString());
    const bookings = await Booking.find({ chargerId: { $in: ids } })
      .sort({ createdAt: -1 });
    res.json({ success: true, bookings });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// Cancel booking + notify host
router.patch('/:id/cancel', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ success: false, message: 'Not found' });

    booking.status = 'cancelled';
    await booking.save();

    const charger = await Charger.findById(booking.chargerId);

    // Notify host
    if (charger?.ownerId) {
      await createNotification({
        userId: charger.ownerId,
        title: '❌ Booking Cancelled',
        message: `${booking.userName} cancelled the booking for ${booking.date} at ${booking.time}`,
        type: 'cancelled',
        data: { bookingId: booking._id },
      });
    }

    // Notify driver
    await createNotification({
      userId: booking.userId,
      title: '❌ Booking Cancelled',
      message: `Your booking for "${charger?.name}" on ${booking.date} has been cancelled.`,
      type: 'cancelled',
      data: { bookingId: booking._id },
    });

    res.json({ success: true, booking });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

module.exports = router;

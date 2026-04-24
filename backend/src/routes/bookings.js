const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const Charger = require('../models/Charger');
const auth = require('../middleware/auth');
const { createNotification } = require('../services/notificationService');

// ── Create booking ────────────────────────────────────────────────
router.post('/', auth, async (req, res) => {
  try {
    const charger = await Charger.findById(req.body.chargerId);
    if (!charger) return res.status(404).json({ success: false, message: 'Charger not found' });

    // Host manual mode check
    const isManual = charger.manualAcceptance === true;
    const status = isManual ? 'pending' : 'confirmed';

    const booking = new Booking({
      ...req.body,
      userId: req.user.userId,
      userName: req.user.name,
      userEmail: req.user.email,
      hostId: charger.ownerId,
      status,
      // Auto-cancel after 1 hour if pending
      expiresAt: isManual ? new Date(Date.now() + 60 * 60 * 1000) : null,
    });
    await booking.save();

    if (isManual) {
      // Notify host — action required
      if (charger.ownerId) {
        await createNotification({
          userId: charger.ownerId,
          title: '⏳ New Booking Request!',
          message: `${req.user.name} wants to book "${charger.name}" — ${req.body.date} at ${req.body.time}. Accept or reject within 1 hour.`,
          type: 'booking',
          data: { bookingId: booking._id },
        });
      }
      // Notify driver — pending
      await createNotification({
        userId: req.user.userId,
        title: '⏳ Booking Pending',
        message: `"${charger.name}" booking request sent. Waiting for host approval (up to 1 hour).`,
        type: 'pending',
        data: { bookingId: booking._id },
      });
    } else {
      // Auto confirmed — notify both
      if (charger.ownerId) {
        await createNotification({
          userId: charger.ownerId,
          title: '🔔 New Booking!',
          message: `${req.user.name} booked "${charger.name}" — ${req.body.date} at ${req.body.time}`,
          type: 'booking',
          data: { bookingId: booking._id },
        });
      }
      await createNotification({
        userId: req.user.userId,
        title: '✅ Booking Confirmed!',
        message: `"${charger.name}" — ${req.body.date} at ${req.body.time} — Rs.${req.body.totalPrice}`,
        type: 'confirmation',
        data: { bookingId: booking._id },
      });
    }

    res.json({ success: true, booking, isManual });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// ── Host: Accept booking ──────────────────────────────────────────
router.patch('/:id/accept', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ success: false, message: 'Not found' });
    if (booking.hostId !== req.user.userId) return res.status(403).json({ success: false, message: 'Not your booking' });
    if (booking.status !== 'pending') return res.status(400).json({ success: false, message: 'Booking is not pending' });

    booking.status = 'confirmed';
    booking.expiresAt = null;
    await booking.save();

    // Notify driver
    await createNotification({
      userId: booking.userId,
      title: '✅ Booking Accepted!',
      message: `Your booking for "${booking.chargerName}" on ${booking.date} at ${booking.time} has been accepted!`,
      type: 'confirmation',
      data: { bookingId: booking._id },
    });

    res.json({ success: true, booking });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// ── Host: Reject booking ──────────────────────────────────────────
router.patch('/:id/reject', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ success: false, message: 'Not found' });
    if (booking.hostId !== req.user.userId) return res.status(403).json({ success: false, message: 'Not your booking' });
    if (booking.status !== 'pending') return res.status(400).json({ success: false, message: 'Booking is not pending' });

    booking.status = 'cancelled';
    booking.cancelReason = req.body.reason || 'Rejected by host';
    await booking.save();

    // Notify driver
    await createNotification({
      userId: booking.userId,
      title: '❌ Booking Rejected',
      message: `Sorry, your booking for "${booking.chargerName}" on ${booking.date} was rejected. Try another charger.`,
      type: 'cancelled',
      data: { bookingId: booking._id },
    });

    res.json({ success: true, booking });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// ── Get my bookings (driver) ──────────────────────────────────────
router.get('/my', auth, async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.user.userId }).sort({ createdAt: -1 });
    res.json({ success: true, bookings });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// ── Get received bookings (host) ──────────────────────────────────
router.get('/received', auth, async (req, res) => {
  try {
    const myChargers = await Charger.find({ ownerId: req.user.userId });
    const ids = myChargers.map(c => c._id.toString());
    const bookings = await Booking.find({ chargerId: { $in: ids } }).sort({ createdAt: -1 });
    res.json({ success: true, bookings });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

// ── Driver: Cancel booking ────────────────────────────────────────
router.patch('/:id/cancel', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ success: false, message: 'Not found' });
    if (booking.userId !== req.user.userId) return res.status(403).json({ success: false, message: 'Not your booking' });

    booking.status = 'cancelled';
    await booking.save();

    if (booking.hostId) {
      await createNotification({
        userId: booking.hostId,
        title: '❌ Booking Cancelled',
        message: `${booking.userName} cancelled the booking for ${booking.date} at ${booking.time}`,
        type: 'cancelled',
        data: { bookingId: booking._id },
      });
    }

    res.json({ success: true, booking });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

module.exports = router;

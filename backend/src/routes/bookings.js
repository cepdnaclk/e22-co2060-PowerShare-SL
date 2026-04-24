const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const auth = require('../middleware/auth');

// ── Create booking (EV Driver) ────────────────────────────────────
router.post('/', auth, async (req, res) => {
  try {
    const booking = new Booking({
      ...req.body,
      userId: req.user.userId,
      userName: req.user.name,
      userEmail: req.user.email,
    });
    await booking.save();
    res.json({ success: true, booking });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Get EV Driver's bookings ──────────────────────────────────────
router.get('/my', auth, async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.user.userId })
      .sort({ createdAt: -1 });
    res.json({ success: true, bookings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Get HOST's received bookings ──────────────────────────────────
router.get('/received', auth, async (req, res) => {
  try {
    // Host-ගේ charger IDs ගන්නන්
    const Charger = require('../models/Charger');
    const myChargers = await Charger.find({ ownerId: req.user.userId });
    const myChargerIds = myChargers.map(c => c._id.toString());

    // ඒ chargers-ට ආ bookings
    const bookings = await Booking.find({
      chargerId: { $in: myChargerIds }
    }).sort({ createdAt: -1 });

    res.json({ success: true, bookings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Cancel booking (EV Driver) ────────────────────────────────────
router.patch('/:id/cancel', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }
    if (booking.userId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Not your booking' });
    }
    booking.status = 'cancelled';
    await booking.save();
    res.json({ success: true, booking });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const Charger = require('../models/Charger');
const auth = require('../middleware/auth');

// ── Create booking (EV Driver) ────────────────────────────────────────
router.post('/', auth, async (req, res) => {
  try {
    // Charger find කරලා hostId ගන්නන්
    const charger = await Charger.findById(req.body.chargerId);
    const hostId = charger ? charger.ownerId : null;

    const booking = new Booking({
      ...req.body,
      userId: req.user.userId,
      userName: req.user.name,
      userEmail: req.user.email,
      hostId: hostId, // ← host directly save
    });
    await booking.save();
    res.json({ success: true, booking });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Get EV Driver's bookings ──────────────────────────────────────────
router.get('/my', auth, async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.user.userId })
      .sort({ createdAt: -1 });
    res.json({ success: true, bookings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Get HOST's received bookings ──────────────────────────────────────
router.get('/received', auth, async (req, res) => {
  try {
    // Method 1: hostId direct match
    let bookings = await Booking.find({ hostId: req.user.userId })
      .sort({ createdAt: -1 });

    // Method 2: fallback — charger ownerId match (older bookings)
    if (bookings.length === 0) {
      const myChargers = await Charger.find({ ownerId: req.user.userId });
      const myChargerIds = myChargers.map(c => c._id.toString());
      bookings = await Booking.find({
        chargerId: { $in: myChargerIds }
      }).sort({ createdAt: -1 });
    }

    res.json({ success: true, bookings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Cancel booking (EV Driver) ────────────────────────────────────────
router.patch('/:id/cancel', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }
    if (booking.userId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Not your booking' });
    }
    booking.status = 'cancelled';
    await booking.save();
    res.json({ success: true, booking });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
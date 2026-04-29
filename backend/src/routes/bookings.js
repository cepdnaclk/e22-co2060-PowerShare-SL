const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const Charger = require('../models/Charger');
const auth = require('../middleware/auth');

// ── Helper: parse date/time string → Date object ─────────────────────
// date format: "25/4/2026"  time format: "2:30 PM"
function parseDateTime(dateStr, timeStr) {
  try {
    const [day, month, year] = dateStr.split('/').map(Number);
    const [timePart, meridiem] = timeStr.split(' ');
    let [hours, minutes] = timePart.split(':').map(Number);
    if (meridiem === 'PM' && hours !== 12) hours += 12;
    if (meridiem === 'AM' && hours === 12) hours = 0;
    return new Date(year, month - 1, day, hours, minutes || 0);
  } catch (e) {
    return null;
  }
}

// ── Helper: check clash ───────────────────────────────────────────────
async function hasClash(chargerId, startDT, endDT, excludeBookingId = null) {
  const query = {
    chargerId,
    status: { $in: ['pending_confirmation', 'confirmed'] },
    // overlap condition: existing.start < newEnd AND existing.end > newStart
    startDateTime: { $lt: endDT },
    endDateTime:   { $gt: startDT },
  };
  if (excludeBookingId) query._id = { $ne: excludeBookingId };
  const clash = await Booking.findOne(query);
  return clash;
}

// ── POST / — Create booking (EV Driver) ──────────────────────────────
router.post('/', auth, async (req, res) => {
  try {
    const { chargerId, date, time, durationHours } = req.body;

    // 1. Find charger
    const charger = await Charger.findById(chargerId);
    if (!charger) {
      return res.status(404).json({ success: false, message: 'Charger not found' });
    }
    if (!charger.isAvailable) {
      return res.status(400).json({ success: false, message: 'Charger is not available' });
    }

    // 2. Parse start/end DateTime
    const startDT = parseDateTime(date, time);
    if (!startDT) {
      return res.status(400).json({ success: false, message: 'Invalid date/time format' });
    }
    const endDT = new Date(startDT.getTime() + durationHours * 60 * 60 * 1000);

    // 3. Clash detection — check overlapping bookings
    const clash = await hasClash(chargerId, startDT, endDT);
    if (clash) {
      return res.status(409).json({
        success: false,
        message: `This charger is already booked from ${clash.time} for ${clash.durationHours}hr(s) on ${clash.date}. Please choose a different time.`,
        clash: {
          date: clash.date,
          time: clash.time,
          durationHours: clash.durationHours,
        },
      });
    }

    // 4. Create booking — status: pending_confirmation, payment: held
    const booking = new Booking({
      ...req.body,
      userId:        req.user.userId,
      userName:      req.user.name,
      userEmail:     req.user.email,
      hostId:        charger.ownerId || null,
      startDateTime: startDT,
      endDateTime:   endDT,
      status:        'pending_confirmation',
      paymentStatus: 'held',
    });
    await booking.save();

    res.json({ success: true, booking });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── GET /my — EV Driver's bookings ───────────────────────────────────
router.get('/my', auth, async (req, res) => {
  try {
    const bookings = await Booking.find({ userId: req.user.userId })
      .sort({ createdAt: -1 });
    res.json({ success: true, bookings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── GET /received — Host's received bookings ──────────────────────────
router.get('/received', auth, async (req, res) => {
  try {
    const myChargers = await Charger.find({ ownerId: req.user.userId });
    const myChargerIds = myChargers.map(c => c._id.toString());
    const bookings = await Booking.find({
      chargerId: { $in: myChargerIds }
    }).sort({ createdAt: -1 });
    res.json({ success: true, bookings });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── PATCH /:id/confirm — Host confirms booking ────────────────────────
router.patch('/:id/confirm', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    // Only host can confirm
    if (booking.hostId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Not your charger booking' });
    }

    if (booking.status !== 'pending_confirmation') {
      return res.status(400).json({ success: false, message: `Booking already ${booking.status}` });
    }

    booking.status = 'confirmed';
    booking.paymentStatus = 'released'; // payment released to host
    await booking.save();

    res.json({ success: true, booking, message: 'Booking confirmed! Payment released.' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── PATCH /:id/reject — Host rejects booking (auto refund) ────────────
router.patch('/:id/reject', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }

    if (booking.hostId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Not your charger booking' });
    }

    if (booking.status !== 'pending_confirmation') {
      return res.status(400).json({ success: false, message: `Booking already ${booking.status}` });
    }

    booking.status = 'rejected';
    booking.paymentStatus = 'refunded'; // auto refund to driver
    await booking.save();

    res.json({ success: true, booking, message: 'Booking rejected. Payment refunded to driver.' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── PATCH /:id/cancel — Driver cancels booking ────────────────────────
router.patch('/:id/cancel', auth, async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) {
      return res.status(404).json({ success: false, message: 'Booking not found' });
    }
    if (booking.userId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Not your booking' });
    }
    if (!['pending_confirmation', 'confirmed'].includes(booking.status)) {
      return res.status(400).json({ success: false, message: `Cannot cancel a ${booking.status} booking` });
    }

    // Refund only if not yet started
    const now = new Date();
    const isBeforeStart = booking.startDateTime && booking.startDateTime > now;
    const paymentStatus = isBeforeStart ? 'refunded' : 'released';

    booking.status = 'cancelled';
    booking.paymentStatus = paymentStatus;
    await booking.save();

    res.json({
      success: true,
      booking,
      message: isBeforeStart
        ? 'Booking cancelled. Full refund processed.'
        : 'Booking cancelled. No refund (session already started).',
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
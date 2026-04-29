const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Booking = require('../models/Booking');

// GET /api/earnings/my — Host earnings summary
router.get('/my', auth, async (req, res) => {
  try {
    const bookings = await Booking.find({
      hostId: req.user.userId,
      status: { $in: ['confirmed', 'completed'] },
    }).sort({ createdAt: -1 });

    const PLATFORM_FEE = 0.10; // 10%

    const earningsList = bookings.map((b) => ({
      bookingId: b._id,
      chargerName: b.chargerName,
      chargerAddress: b.chargerAddress,
      date: b.date,
      time: b.time,
      durationHours: b.durationHours,
      totalPaid: b.totalPrice,
      platformFee: parseFloat((b.totalPrice * PLATFORM_FEE).toFixed(2)),
      hostEarning: parseFloat((b.totalPrice * (1 - PLATFORM_FEE)).toFixed(2)),
      status: b.status,
      createdAt: b.createdAt,
    }));

    const totalEarned = earningsList.reduce((sum, e) => sum + e.hostEarning, 0);
    const totalWithdrawn = 0; // mock — future-ේ real withdrawal track
    const availableBalance = parseFloat((totalEarned - totalWithdrawn).toFixed(2));

    res.json({
      success: true,
      totalEarned: parseFloat(totalEarned.toFixed(2)),
      availableBalance,
      totalWithdrawn,
      earningsList,
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// POST /api/earnings/withdraw — Mock withdrawal request
router.post('/withdraw', auth, async (req, res) => {
  try {
    const { amount, bankName, accountNumber, accountName } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ message: 'Invalid amount' });
    }
    if (!bankName || !accountNumber || !accountName) {
      return res.status(400).json({ message: 'Bank details required' });
    }
    if (amount < 500) {
      return res.status(400).json({ message: 'Minimum withdrawal is Rs. 500' });
    }

    // Mock — simulate processing
    res.json({
      success: true,
      message: 'Withdrawal request submitted!',
      reference: 'WD-' + Date.now(),
      amount,
      bankName,
      accountNumber: '****' + accountNumber.slice(-4),
      estimatedDays: '3-5 business days',
    });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;
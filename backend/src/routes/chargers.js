const express = require('express');
const router = express.Router();
const Charger = require('../models/Charger');
const auth = require('../middleware/auth');

// ── Get all chargers (public) ─────────────────────────────────────
router.get('/', async (req, res) => {
  try {
    const chargers = await Charger.find();
    res.json({ success: true, chargers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Get HOST's own chargers (protected) ──────────────────────────
router.get('/my', auth, async (req, res) => {
  try {
    const chargers = await Charger.find({ ownerId: req.user.userId })
      .sort({ createdAt: -1 });
    res.json({ success: true, chargers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Add charger (protected) ───────────────────────────────────────
router.post('/', auth, async (req, res) => {
  try {
    const charger = new Charger({
      ...req.body,
      ownerId: req.user.userId,  // ← save owner
    });
    await charger.save();
    res.json({ success: true, charger });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Toggle availability (protected, owner only) ───────────────────
router.patch('/:id/availability', auth, async (req, res) => {
  try {
    const charger = await Charger.findById(req.params.id);
    if (!charger) {
      return res.status(404).json({ success: false, message: 'Charger not found' });
    }
    if (charger.ownerId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Not your charger' });
    }
    charger.isAvailable = !charger.isAvailable;
    await charger.save();
    res.json({ success: true, charger });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Delete charger (protected, owner only) ────────────────────────
router.delete('/:id', auth, async (req, res) => {
  try {
    const charger = await Charger.findById(req.params.id);
    if (!charger) {
      return res.status(404).json({ success: false, message: 'Charger not found' });
    }
    if (charger.ownerId !== req.user.userId) {
      return res.status(403).json({ success: false, message: 'Not your charger' });
    }
    await Charger.findByIdAndDelete(req.params.id);
    res.json({ success: true, message: 'Charger deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ── Seed (protected) ──────────────────────────────────────────────
router.post('/seed', auth, async (req, res) => {
  try {
    await Charger.deleteMany({});
    const chargers = await Charger.insertMany([
      { name: 'Colombo City Charger', address: 'Galle Face Green, Colombo 03', latitude: 6.9271, longitude: 79.8612, pricePerHour: 250, isAvailable: true, ownerName: 'Kamal Perera', rating: 4.5 },
      { name: 'Kandy Central Charger', address: 'Kandy City Center, Kandy', latitude: 7.2906, longitude: 80.6337, pricePerHour: 200, isAvailable: true, ownerName: 'Nimal Silva', rating: 4.2 },
      { name: 'Galle Fort Charger', address: 'Galle Fort, Galle', latitude: 6.0328, longitude: 80.2170, pricePerHour: 180, isAvailable: false, ownerName: 'Sunil Fernando', rating: 3.9 },
      { name: 'Negombo Beach Charger', address: 'Negombo Beach Road, Negombo', latitude: 7.2081, longitude: 79.8358, pricePerHour: 220, isAvailable: true, ownerName: 'Priya Jayawardena', rating: 4.7 },
      { name: 'Nugegoda Charger', address: 'High Level Road, Nugegoda', latitude: 6.8728, longitude: 79.8997, pricePerHour: 230, isAvailable: true, ownerName: 'Ruwan Dissanayake', rating: 4.3 },
    ]);
    res.json({ success: true, message: '5 chargers seeded!', chargers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;

const express = require('express');
const router = express.Router();
const { OAuth2Client } = require('google-auth-library');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// Google Sign-In
router.post('/google', async (req, res) => {
  try {
    const { idToken, googleId, name, email, photo } = req.body;

    // Find or create user
    let user = await User.findOne({ googleId });

    if (!user) {
      user = new User({ googleId, name, email, photo });
      await user.save();
    }

    // Generate JWT
    const token = jwt.sign(
      { userId: user._id, googleId, name, email },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      success: true,
      token,
      user: { id: user._id, name, email, photo },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
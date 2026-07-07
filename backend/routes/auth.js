const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const { protect, adminOnly } = require('../middleware/auth');

const otpStore = {};

router.post('/send-otp', async (req, res) => {
  try {
    const { phone, countryCode } = req.body;
    if (!phone) {
      return res.status(400).json({ message: 'Phone number is required' });
    }
    const otp = Math.floor(100000 + Math.random() * 900000);
    otpStore[phone] = { otp: otp.toString(), expiresAt: Date.now() + 300000 };
    console.log(`OTP for ${phone}: ${otp}`);

    if (phone === process.env.DEV_PHONE) {
      otpStore[phone] = { otp: '123456', expiresAt: Date.now() + 300000 };
    }

    res.json({
      message: 'OTP sent successfully',
      otp: process.env.NODE_ENV === 'development' ? otp : undefined,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/verify-otp', async (req, res) => {
  try {
    const { phone, otp, username, countryCode, displayName } = req.body;
    if (!phone || !otp) {
      return res.status(400).json({ message: 'Phone and OTP are required' });
    }

    const stored = otpStore[phone];
    if (!stored || stored.expiresAt < Date.now()) {
      return res.status(400).json({ message: 'OTP expired or not found' });
    }

    if (phone !== process.env.DEV_PHONE && stored.otp !== otp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    delete otpStore[phone];

    let user = await User.findOne({ phone });
    if (!user) {
      user = await User.create({
        phone,
        username: username || `user_${Date.now()}`,
        displayName: displayName || username || `user_${Date.now()}`,
        countryCode: countryCode || '+964',
        isPhoneVerified: true,
        authMethod: 'phone',
      });
    } else {
      user.isPhoneVerified = true;
      await user.save();
    }

    const token = generateToken(user._id);
    res.json({
      token,
      user: {
        _id: user._id,
        phone: user.phone,
        username: user.username,
        displayName: user.displayName,
        avatar: user.avatar,
        countryCode: user.countryCode,
        balance: user.balance,
        role: user.role,
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/google', async (req, res) => {
  try {
    const { googleId, email, displayName, photoURL } = req.body;
    if (!googleId) {
      return res.status(400).json({ message: 'Google ID is required' });
    }

    let user = await User.findOne({
      $or: [{ googleId }, { email }],
    });

    if (!user) {
      user = await User.create({
        googleId,
        email,
        username: displayName?.replace(/\s+/g, '_').toLowerCase() || `user_${Date.now()}`,
        displayName: displayName || 'User',
        avatar: photoURL || '',
        isVerified: true,
        authMethod: 'google',
      });
    } else if (!user.googleId) {
      user.googleId = googleId;
      if (!user.avatar && photoURL) user.avatar = photoURL;
      await user.save();
    }

    const token = generateToken(user._id);
    res.json({
      token,
      user: {
        _id: user._id,
        email: user.email,
        username: user.username,
        displayName: user.displayName,
        avatar: user.avatar,
        balance: user.balance,
        role: user.role,
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/me', protect, async (req, res) => {
  res.json(req.user);
});

router.put('/profile', protect, async (req, res) => {
  try {
    const { username, displayName, bio, avatar } = req.body;
    const user = await User.findById(req.user._id);
    if (username) user.username = username;
    if (displayName) user.displayName = displayName;
    if (bio !== undefined) user.bio = bio;
    if (avatar) user.avatar = avatar;
    await user.save();
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { protect } = require('../middleware/auth');

router.get('/profiles', protect, async (req, res) => {
  try {
    const { page = 1, limit = 20, gender, minAge, maxAge, country } = req.query;
    const query = {
      _id: { $ne: req.user._id },
      isPhoneVerified: true,
    };

    const users = await User.find(query)
      .select('username displayName avatar bio countryCode country isOnline gender age')
      .sort({ lastSeen: -1 })
      .skip((page - 1) * limit)
      .limit(Number(limit));

    const total = await User.countDocuments(query);

    res.json({
      users,
      total,
      page: Number(page),
      pages: Math.ceil(total / limit),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/like/:userId', protect, async (req, res) => {
  try {
    const targetUser = await User.findById(req.params.userId);
    if (!targetUser) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({ message: 'Liked', matched: false });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;

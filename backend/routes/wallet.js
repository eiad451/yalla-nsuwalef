const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Transaction = require('../models/Transaction');
const { protect, adminOnly, devOnly } = require('../middleware/auth');

router.get('/balance', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select('balance totalRecharged');
    res.json({ balance: user.balance, totalRecharged: user.totalRecharged });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/transactions', protect, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const transactions = await Transaction.find({ user: req.user._id })
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(Number(limit));

    const total = await Transaction.countDocuments({ user: req.user._id });

    res.json({ transactions, total, page: Number(page), pages: Math.ceil(total / limit) });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/recharge', protect, async (req, res) => {
  try {
    const { amount, paymentMethod, phoneNumber } = req.body;

    if (!amount || amount < 1000) {
      return res.status(400).json({ message: 'Minimum recharge is 1000 IQD' });
    }

    const transaction = await Transaction.create({
      user: req.user._id,
      type: 'recharge',
      amount,
      paymentMethod: paymentMethod || 'zain_cash',
      phoneNumber: phoneNumber || req.user.phone,
      status: 'pending',
      referenceId: `RCH-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
    });

    res.status(201).json({
      message: `Recharge request created. Send ${amount} IQD to developer number 07744572152 via ${paymentMethod}`,
      transaction,
      devNumber: '07744572152',
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/send-gift', protect, async (req, res) => {
  try {
    const { recipientId, amount, giftName } = req.body;
    if (!recipientId || !amount) {
      return res.status(400).json({ message: 'Recipient and amount are required' });
    }

    const sender = await User.findById(req.user._id);
    if (sender.balance < amount) {
      return res.status(400).json({ message: 'Insufficient balance' });
    }

    const recipient = await User.findById(recipientId);
    if (!recipient) {
      return res.status(404).json({ message: 'Recipient not found' });
    }

    sender.balance -= amount;
    recipient.balance += amount;

    await sender.save();
    await recipient.save();

    await Transaction.create({
      user: sender._id,
      type: 'gift',
      amount: -amount,
      description: `Gift: ${giftName || 'Gift'} to ${recipient.username}`,
      status: 'completed',
    });

    await Transaction.create({
      user: recipient._id,
      type: 'gift',
      amount,
      description: `Gift: ${giftName || 'Gift'} from ${sender.username}`,
      status: 'completed',
    });

    res.json({ message: 'Gift sent successfully', balance: sender.balance });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/admin/add-balance', protect, devOnly, async (req, res) => {
  try {
    const { userId, amount, description } = req.body;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.balance += amount;
    if (amount > 0) {
      user.totalRecharged += amount;
    }
    await user.save();

    await Transaction.create({
      user: userId,
      type: 'admin',
      amount,
      description: description || 'Admin adjustment',
      status: 'completed',
      processedBy: req.user._id,
    });

    res.json({ message: 'Balance updated', balance: user.balance });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/pending', protect, adminOnly, async (req, res) => {
  try {
    const pending = await Transaction.find({ status: 'pending', type: 'recharge' })
      .populate('user', 'phone username displayName')
      .sort({ createdAt: -1 });

    res.json(pending);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put('/approve/:transactionId', protect, devOnly, async (req, res) => {
  try {
    const transaction = await Transaction.findById(req.params.transactionId);
    if (!transaction) {
      return res.status(404).json({ message: 'Transaction not found' });
    }

    transaction.status = 'completed';
    transaction.processedBy = req.user._id;
    await transaction.save();

    const user = await User.findById(transaction.user);
    user.balance += transaction.amount;
    user.totalRecharged += transaction.amount;
    await user.save();

    res.json({ message: 'Transaction approved', transaction });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;

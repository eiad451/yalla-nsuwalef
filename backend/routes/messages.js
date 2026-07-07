const express = require('express');
const router = express.Router();
const Message = require('../models/Message');
const Room = require('../models/Room');
const { protect } = require('../middleware/auth');

router.get('/:roomId', protect, async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const room = await Room.findById(req.params.roomId);

    if (!room) {
      return res.status(404).json({ message: 'Room not found' });
    }

    const isMember = room.members.includes(req.user._id) || room.createdBy.toString() === req.user._id.toString();
    if (!isMember) {
      return res.status(403).json({ message: 'Not a member of this room' });
    }

    const messages = await Message.find({ room: req.params.roomId, isDeleted: false })
      .populate('sender', 'username displayName avatar role')
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit)
      .limit(Number(limit));

    const total = await Message.countDocuments({ room: req.params.roomId, isDeleted: false });

    res.json({
      messages: messages.reverse(),
      total,
      page: Number(page),
      pages: Math.ceil(total / limit),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/:roomId', protect, async (req, res) => {
  try {
    const { content, messageType, mediaUrl, gift } = req.body;
    const room = await Room.findById(req.params.roomId);

    if (!room) {
      return res.status(404).json({ message: 'Room not found' });
    }

    if (!content && !mediaUrl && !gift) {
      return res.status(400).json({ message: 'Message content is required' });
    }

    const message = await Message.create({
      room: req.params.roomId,
      sender: req.user._id,
      content: content || '',
      messageType: messageType || 'text',
      mediaUrl: mediaUrl || '',
      gift,
    });

    room.lastMessage = message._id;
    await room.save();

    const populatedMessage = await Message.findById(message._id)
      .populate('sender', 'username displayName avatar role');

    res.status(201).json(populatedMessage);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete('/:roomId/:messageId', protect, async (req, res) => {
  try {
    const message = await Message.findById(req.params.messageId);
    if (!message) {
      return res.status(404).json({ message: 'Message not found' });
    }

    if (message.sender.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    message.isDeleted = true;
    await message.save();

    res.json({ message: 'Message deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/search/:roomId', protect, async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const messages = await Message.find({
      room: req.params.roomId,
      content: { $regex: q, $options: 'i' },
      isDeleted: false,
    })
      .populate('sender', 'username displayName avatar')
      .sort({ createdAt: -1 })
      .limit(50);

    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;

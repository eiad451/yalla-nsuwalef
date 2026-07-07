const express = require('express');
const router = express.Router();
const Room = require('../models/Room');
const Message = require('../models/Message');
const User = require('../models/User');
const { protect, adminOnly } = require('../middleware/auth');

router.get('/', protect, async (req, res) => {
  try {
    const { category, country, type, search, page = 1, limit = 20 } = req.query;
    const query = { isActive: true };

    if (category && category !== 'all') query.category = category;
    if (country && country !== 'all') query.country = country;
    if (type) query.type = type;
    if (search) {
      query.$text = { $search: search };
    }

    const rooms = await Room.find(query)
      .populate('createdBy', 'username displayName avatar')
      .populate('lastMessage')
      .sort({ updatedAt: -1 })
      .skip((page - 1) * limit)
      .limit(Number(limit));

    const total = await Room.countDocuments(query);

    res.json({
      rooms,
      total,
      page: Number(page),
      pages: Math.ceil(total / limit),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/my', protect, async (req, res) => {
  try {
    const rooms = await Room.find({
      $or: [
        { createdBy: req.user._id },
        { members: req.user._id },
        { admins: req.user._id },
      ],
    })
      .populate('createdBy', 'username displayName avatar')
      .populate('lastMessage')
      .sort({ updatedAt: -1 });

    res.json(rooms);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/', protect, async (req, res) => {
  try {
    const { name, description, type, category, password, country, countryCode, maxMembers } = req.body;

    if (!name) {
      return res.status(400).json({ message: 'Room name is required' });
    }

    const room = await Room.create({
      name,
      description,
      type: type || 'public',
      category: category || 'general',
      password,
      country: country || 'all',
      countryCode: countryCode || '+964',
      createdBy: req.user._id,
      admins: [req.user._id],
      members: [req.user._id],
      maxMembers: maxMembers || 500,
    });

    const populatedRoom = await Room.findById(room._id)
      .populate('createdBy', 'username displayName avatar');

    res.status(201).json(populatedRoom);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get('/:id', protect, async (req, res) => {
  try {
    const room = await Room.findById(req.params.id)
      .populate('createdBy', 'username displayName avatar')
      .populate('admins', 'username displayName avatar')
      .populate('members', 'username displayName avatar isOnline');

    if (!room) {
      return res.status(404).json({ message: 'Room not found' });
    }

    res.json(room);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put('/:id', protect, async (req, res) => {
  try {
    const room = await Room.findById(req.params.id);
    if (!room) {
      return res.status(404).json({ message: 'Room not found' });
    }

    const isAdmin = room.admins.includes(req.user._id) || room.createdBy.toString() === req.user._id.toString();
    if (!isAdmin) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const { name, description, image, password, maxMembers, category } = req.body;
    if (name) room.name = name;
    if (description !== undefined) room.description = description;
    if (image) room.image = image;
    if (password !== undefined) room.password = password;
    if (maxMembers) room.maxMembers = maxMembers;
    if (category) room.category = category;

    await room.save();
    res.json(room);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/:id/join', protect, async (req, res) => {
  try {
    const room = await Room.findById(req.params.id);
    if (!room) {
      return res.status(404).json({ message: 'Room not found' });
    }

    if (room.bannedMembers.includes(req.user._id)) {
      return res.status(403).json({ message: 'You are banned from this room' });
    }

    if (room.members.length >= room.maxMembers) {
      return res.status(400).json({ message: 'Room is full' });
    }

    if (room.type === 'private' && req.body.password !== room.password) {
      return res.status(400).json({ message: 'Wrong password' });
    }

    if (!room.members.includes(req.user._id)) {
      room.members.push(req.user._id);
      await room.save();
    }

    res.json(room);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/:id/leave', protect, async (req, res) => {
  try {
    const room = await Room.findById(req.params.id);
    if (!room) {
      return res.status(404).json({ message: 'Room not found' });
    }

    room.members = room.members.filter(m => m.toString() !== req.user._id.toString());
    room.admins = room.admins.filter(a => a.toString() !== req.user._id.toString());
    await room.save();

    res.json({ message: 'Left room successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post('/:id/ban/:userId', protect, async (req, res) => {
  try {
    const room = await Room.findById(req.params.id);
    if (!room) {
      return res.status(404).json({ message: 'Room not found' });
    }

    const isAdmin = room.admins.includes(req.user._id) || room.createdBy.toString() === req.user._id.toString();
    if (!isAdmin) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const userToBan = req.params.userId;
    room.members = room.members.filter(m => m.toString() !== userToBan);
    room.admins = room.admins.filter(a => a.toString() !== userToBan);
    if (!room.bannedMembers.includes(userToBan)) {
      room.bannedMembers.push(userToBan);
    }
    await room.save();

    res.json({ message: 'User banned successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete('/:id', protect, async (req, res) => {
  try {
    const room = await Room.findById(req.params.id);
    if (!room) {
      return res.status(404).json({ message: 'Room not found' });
    }

    if (room.createdBy.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Only the creator can delete the room' });
    }

    await Message.deleteMany({ room: room._id });
    await Room.findByIdAndDelete(req.params.id);

    res.json({ message: 'Room deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;

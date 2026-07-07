const mongoose = require('mongoose');

const roomSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    default: '',
  },
  image: {
    type: String,
    default: '',
  },
  type: {
    type: String,
    enum: ['public', 'private', 'group'],
    default: 'public',
  },
  category: {
    type: String,
    default: 'general',
  },
  password: {
    type: String,
    default: '',
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  admins: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  members: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  bannedMembers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  maxMembers: {
    type: Number,
    default: 500,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  lastMessage: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message',
  },
  country: {
    type: String,
    default: 'all',
  },
  countryCode: {
    type: String,
    default: '+964',
  },
  tags: [{
    type: String,
  }],
}, {
  timestamps: true,
});

roomSchema.index({ name: 'text', description: 'text' });
roomSchema.index({ category: 1, country: 1 });
roomSchema.index({ isActive: 1, type: 1 });

module.exports = mongoose.model('Room', roomSchema);

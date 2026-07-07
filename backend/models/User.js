const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  phone: {
    type: String,
    unique: true,
    sparse: true,
  },
  email: {
    type: String,
    sparse: true,
  },
  googleId: {
    type: String,
    sparse: true,
  },
  username: {
    type: String,
    required: true,
    trim: true,
  },
  displayName: {
    type: String,
    trim: true,
  },
  avatar: {
    type: String,
    default: '',
  },
  bio: {
    type: String,
    default: '',
  },
  countryCode: {
    type: String,
    default: '+964',
  },
  country: {
    type: String,
    default: 'IRQ',
  },
  balance: {
    type: Number,
    default: 0,
  },
  totalRecharged: {
    type: Number,
    default: 0,
  },
  role: {
    type: String,
    enum: ['user', 'admin', 'dev'],
    default: 'user',
  },
  isVerified: {
    type: Boolean,
    default: false,
  },
  isPhoneVerified: {
    type: Boolean,
    default: false,
  },
  isOnline: {
    type: Boolean,
    default: false,
  },
  lastSeen: {
    type: Date,
    default: Date.now,
  },
  fcmToken: {
    type: String,
    default: '',
  },
  deviceId: {
    type: String,
  },
  authMethod: {
    type: String,
    enum: ['phone', 'google', 'email'],
    default: 'phone',
  },
}, {
  timestamps: true,
});

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);

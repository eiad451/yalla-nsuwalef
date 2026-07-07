const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  type: {
    type: String,
    enum: ['recharge', 'gift', 'withdraw', 'bonus', 'refund', 'admin'],
    required: true,
  },
  amount: {
    type: Number,
    required: true,
  },
  currency: {
    type: String,
    default: 'IQD',
  },
  paymentMethod: {
    type: String,
    enum: ['zain_cash', 'asia_cell', 'korek', 'mastercard', 'visa', 'paypal', 'bank_transfer', 'admin'],
  },
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'cancelled'],
    default: 'completed',
  },
  referenceId: {
    type: String,
  },
  phoneNumber: {
    type: String,
  },
  description: {
    type: String,
  },
  processedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
}, {
  timestamps: true,
});

transactionSchema.index({ user: 1, createdAt: -1 });
transactionSchema.index({ status: 1, type: 1 });

module.exports = mongoose.model('Transaction', transactionSchema);

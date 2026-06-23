const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  phone: {
    type: String,
    required: [true, 'Phone number is required'],
    unique: true,
    trim: true,
    match: [/^(\+91)?[0-9]{10}$/, 'Enter a valid phone number']
  },
  password: {
    type: String,
    required: true
  },

  isPhoneVerified: {
    type: Boolean,
    default: false
  },
  otpHash: {
    type: String,
    default: null
  },
  otpEncrypted: {
    type: String,
    default: null
  },
  otpExpiresAt: {
    type: Date,
    default: null
  },
  isAdmin: {
    type: Number,   // 0 = user, 1 = admin
    default: 0
  }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);

require('dotenv').config();
const User = require('../models/User');
const Inspection = require('../models/inspectionForm')
const bcrypt = require('bcryptjs');
const { generateToken } = require('../utils/jwt');
const { successResponse, errorResponse } = require('../utils/response');
const {generateOtp} = require('../utils/otp')
const sendOtpSms = require('../utils/sendOtpSms');

const { encryptOtp, decryptOtp } = require('../utils/otpCrypto');


// Register - send OTP, do NOT send token here
exports.register = async (req, res) => {
  try {
    const { name, phone, password ,secretCode } = req.body;

    if (!name || !phone || !password) {
      return errorResponse(res, 'Name, phone and password are required', 400);
      
    }

   
    if (!secretCode || secretCode !== process.env.SIGNUP_SECRETCODE) {
      return errorResponse(res, 'Your secret code is wrong', 400);
    }

    const existingUser = await User.findOne({ phone });

    // verified user already exists
    if (existingUser && existingUser.isPhoneVerified) {
      return errorResponse(res, 'Phone number already exists', 400);
    }

    // unverified user + old OTP still valid => DON'T generate new OTP
    if (
      existingUser &&
      !existingUser.isPhoneVerified &&
      existingUser.otpHash &&
      existingUser.otpEncrypted &&
      existingUser.otpExpiresAt &&
      new Date(existingUser.otpExpiresAt) > new Date()
    ) {
      const existingOtp = decryptOtp(existingUser.otpEncrypted);

      const remainingSeconds = Math.max(
        Math.floor((new Date(existingUser.otpExpiresAt) - new Date()) / 1000),
        0
      );

      return successResponse(
        res,
        'OTP already sent. Please verify the existing OTP',
        {
          user_id: existingUser._id,
          phone: existingUser.phone,
          isPhoneVerified: existingUser.isPhoneVerified,
          otp: existingOtp, // testing / required by your case
          otpExpiresAt: existingUser.otpExpiresAt,
          remainingSeconds
        },
        200
      );
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const otp = generateOtp();
    const otpHash = await bcrypt.hash(otp, 10);
    const otpEncrypted = encryptOtp(otp);
    const otpExpiresAt = new Date(Date.now() + 5 * 60 * 1000);

    // unverified user exists but OTP expired => generate new OTP
    if (existingUser) {
      existingUser.name = name;
      existingUser.password = hashedPassword;
      existingUser.otpHash = otpHash;
      existingUser.otpEncrypted = otpEncrypted;
      existingUser.otpExpiresAt = otpExpiresAt;
      existingUser.isPhoneVerified = false;

      await existingUser.save();
      await sendOtpSms(phone, otp);

      return successResponse(
        res,
        'New OTP sent to phone number',
        {
          user_id: existingUser._id,
          phone: existingUser.phone,
          isPhoneVerified: existingUser.isPhoneVerified,
          otp: otp,
          otpExpiresAt: existingUser.otpExpiresAt
        },
        200
      );
    }

    // new user
    const user = await User.create({
      name,
      phone,
      password: hashedPassword,
      isPhoneVerified: false,
      otpHash,
      otpEncrypted,
      otpExpiresAt
    });

    await sendOtpSms(phone, otp);

    return successResponse(
      res,
      'OTP sent to phone number',
      {
        user_id: user._id,
        phone: user.phone,
        isPhoneVerified: user.isPhoneVerified,
        otp: otp,
        otpExpiresAt: user.otpExpiresAt
      },
      201
    );

  } catch (err) {
    return errorResponse(res, err.message, 400);
  }
};
// Verify OTP - send token only after success
exports.verifyOtp = async (req, res) => {
  try {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
      return errorResponse(res, 'Phone and OTP are required', 400);
    }

    const user = await User.findOne({ phone });

    if (!user) {
      return errorResponse(res, 'User not found', 404);
    }

    if (!user.otpHash || !user.otpExpiresAt) {
      return errorResponse(res, 'OTP not generated. Please register again', 400);
    }

    if (new Date() > user.otpExpiresAt) {
      return errorResponse(res, 'OTP expired. Please request a new OTP', 400);
    }

    const isOtpValid = await bcrypt.compare(otp, user.otpHash);

    if (!isOtpValid) {
      return errorResponse(res, 'Invalid OTP', 400);
    }

    user.isPhoneVerified = true;
    user.otpHash = null;
    user.otpExpiresAt = null;

    await user.save();

    const token = generateToken(user);

    return successResponse(res, 'OTP verified successfully', {
      user,
      token
    });
  } catch (err) {
    return errorResponse(res, err.message, 400);
  }
};

// Optional - resend OTP
exports.resendOtp = async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return errorResponse(res, 'Phone is required', 400);
    }

    const user = await User.findOne({ phone });

    if (!user) {
      return errorResponse(res, 'User not found', 404);
    }

    if (user.isPhoneVerified) {
      return errorResponse(res, 'Phone number already verified', 400);
    }

    const otp = generateOtp();
    const otpHash = await bcrypt.hash(otp, 10);
    const otpExpiresAt = new Date(Date.now() + 5 * 60 * 1000);

    user.otpHash = otpHash;
    user.otpExpiresAt = otpExpiresAt;

    await user.save();
    await sendOtpSms(phone, otp);

    return successResponse(res, 'OTP resent successfully', {
      phone: user.phone
    });
  } catch (err) {
    return errorResponse(res, err.message, 400);
  }
};



// Login
exports.login = async (req, res) => {
  try {
    const { phone, password } = req.body;

    if (!phone || !password) {
      return errorResponse(res, "Phone number and password are required", null, 400);
    }

    const user = await User.findOne({ phone });
    if (!user) {
      return errorResponse(res, "Invalid phone number", null, 400);
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return errorResponse(res, "Invalid password", null, 400);
    }

    // 🔥 NEW CHECK
    if (!user.isPhoneVerified) {
      return errorResponse(
        res,
        "Phone number is not verified. Please verify OTP before login.",
        null,
        403
      );
    }

    // ✅ Only verified users get token
    const token = generateToken(user);

    return successResponse(res, "Login successful", { user, token });

  } catch (err) {
    return errorResponse(res, err.message, null, 500);
  }
};

exports.getDashboard = async (req, res) => {
  try {

    // Get users (only name & phone, non-admin only)
    const users = await User.find(
      { isAdmin: 0 }, 
      {
        name: 1,
        phone: 1,
        isPhoneVerified: 1,
        _id: 0
      }
    );

    // Count verified users (non-admin)
    const verifiedCount = await User.countDocuments({
      isAdmin: 0,
      isPhoneVerified: true
    });

    // Count unverified users (non-admin)
    const unverifiedCount = await User.countDocuments({
      isAdmin: 0,
      isPhoneVerified: false
    });


     const inspectionTotalCount = await Inspection.countDocuments();

    // Completed inspections (status = 1)
    const inspectionCompletedCount = await Inspection.countDocuments({
      inspection_status: 1
    });

    //  In-progress inspections (status = 0)
    const inspectionInProgressCount = await Inspection.countDocuments({
      inspection_status: 0
    });

    const criticalCount = await Inspection.countDocuments({
      inspection_flag: 'critical'
    });

    const minorIssueCount = await Inspection.countDocuments({
      inspection_flag: 'minor_issue'
    });

    const goodCount = await Inspection.countDocuments({
      inspection_flag: 'good'
    })

    return successResponse(res, "Dashboard data fetched successfully", {
      users,
      verifiedCount,
      unverifiedCount,
      inspectionTotalCount,
      inspectionCompletedCount,
      inspectionInProgressCount,
      criticalCount,
      minorIssueCount,
      goodCount
    });

  } catch (error) {
    return errorResponse(res, "Failed to fetch dashboard data", error.message);
  }
};
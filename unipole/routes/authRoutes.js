const express = require('express');
const router = express.Router();
const {   register,
  verifyOtp,
  resendOtp,
  login,
  getDashboard
 } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');
router.post('/register', register);
router.post('/verify-otp', verifyOtp);
router.post('/resend-otp', resendOtp);
router.post('/login', login);
router.get('/dashboard',protect,getDashboard)

router.get('/me', protect, (req, res) => {
  res.json({
    success: true,
    user: req.user
  });
});


module.exports = router;
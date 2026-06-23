const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { successResponse, errorResponse } = require('../utils/response')
const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];

      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // 🔥 FULL USER FETCH
      const user = await User.findById(decoded.id).select('-password');

      if (!user) {
        return errorResponse(res, 'User not found',  401);
      }

      req.user = user; // full user object set pannuvom

      next();
    } catch (error) {
      return errorResponse(res, 'Usen Not Authorized',  401);
    }
  }

  if (!token) {
     return errorResponse(res, 'Token Not Found',  401);
    
  }
};

module.exports = { protect };
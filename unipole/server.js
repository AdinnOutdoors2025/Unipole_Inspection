const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');
const connectDB = require('./db');
const { startInspectionScheduler, getSchedulerStatus } = require('./utils/schedulerService');

require('./utils/cronjobs');
//demo
dotenv.config();

const app = express();


connectDB();


app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static folders
app.use('/uploads',express.static(path.join(__dirname, '../uploads')));


// Routes
app.use('/api/inspections', require('./routes/InspectionQuestionRoute/inspectionRoutes'));
app.use('/api/admin',       require('./routes/EmailsendRoutes/EmailRoutes'));
app.use('/api/auth', require('./routes/authRoutes'));

// Scheduler status endpoint
app.get('/api/scheduler/status', (req, res) => {
  const status = getSchedulerStatus();
  res.json({ success: true, scheduler: status });
});


app.get('/', (req, res) => {
  res.json({ message: 'Unipole Inspection API is running' });
});



// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: err.message || 'Server Error' });
});

const PORT = process.env.PORT || 5000;
const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  startInspectionScheduler();
});
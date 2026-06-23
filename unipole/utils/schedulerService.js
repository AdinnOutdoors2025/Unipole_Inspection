

const cron = require('node-cron');
const Inspection = require('../models/inspectionForm');
const { generatePDFBilingual } = require('./../utils/pdfGeneratorBilingual');
const { sendTodaysInspectionsEmail } = require('./../utils/emailService');
require('dotenv').config();

let schedulerRunning = false;

const startInspectionScheduler = () => {
    if (schedulerRunning) {
        console.log('Scheduler is already running');
        return;
    }

    cron.schedule('30 23 * * *', async () => {
        try {
            console.log(`[${new Date().toLocaleString('en-IN')}] Running inspection email scheduler...`);


            const today = new Date();

            const formattedDate = today.toLocaleDateString('en-GB', {
                day: '2-digit',
                month: 'long',
                year: 'numeric'
            }).replace(/ /g, '-');

            const inspections = await Inspection.find({
                visiting_date: formattedDate
            });

            if (inspections.length === 0) {
                console.log('No inspections found for today');
                return;
            }

            console.log(`Found ${inspections.length} inspection(s) for today`);

            const recipientEmail = process.env.INSPECTION_EMAIL_RECIPIENT;
            if (!recipientEmail) {
                console.warn('No email configured. Set INSPECTION_EMAIL_RECIPIENT in .env');
                return;
            }

           
            const result = await sendTodaysInspectionsEmail(inspections, recipientEmail);


        } catch (error) {
            console.error('Scheduler error:', error);
        }
    });

    schedulerRunning = true;
    console.log('Inspection email scheduler started - will run daily at 11:30 PM IST');
};

const stopInspectionScheduler = () => {
    if (schedulerRunning) {
        cron.getTasks().forEach(task => task.stop());
        schedulerRunning = false;
        console.log('Inspection email scheduler stopped');
    }
};

const getSchedulerStatus = () => ({
    running: schedulerRunning,
    nextRun: '11:30 PM IST every day'
});

module.exports = {
    startInspectionScheduler,
    stopInspectionScheduler,
    getSchedulerStatus
};
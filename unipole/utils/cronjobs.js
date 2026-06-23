

const cron = require('node-cron');
const dayjs = require('dayjs');
const Inspection = require('../models/inspectionForm');
const deleteFromSpaces = require('../utils/deleteFromSpaces');

const ALLOWED_SECTIONS = [
  'foundation',
  'post', 
  'ad_board_frame',
  'general_inspection'
];

const deleteAllInspectionImages = async (inspection) => {
  const urlsToDelete = [];

  for (const sectionName of ALLOWED_SECTIONS) {
    const sectionData = inspection[sectionName];
    if (!sectionData || typeof sectionData !== 'object') continue;

    const rawSection = sectionData.toObject ? sectionData.toObject() : sectionData;

    for (const itemName of Object.keys(rawSection)) {
      const item = rawSection[itemName];
      if (item && Array.isArray(item.images)) {
        urlsToDelete.push(...item.images);
      }
    }
  }

  
  if (inspection.selfie_image) {
    urlsToDelete.push(inspection.selfie_image);
  }

  for (const url of urlsToDelete) {
    try {
      await deleteFromSpaces(url);
      console.log(`[Cron] Deleted image: ${url}`);
    } catch (err) {
      console.error(`[Cron] Failed to delete image ${url}:`, err.message);
    }
  }
};


const cleanupStaleInspectionsRealtime = async () => {
  console.log(`[Cron-Realtime] Running stale inspection check at ${dayjs().format('DD-MMM-YYYY HH:mm:ss')}`);

  try {
    const threeHoursAgo = dayjs().subtract(3, 'hour').toDate();

    const staleInspections = await Inspection.find({
      inspection_status: 0,
      selfie_image: null,
      createdAt: { $lte: threeHoursAgo }
    });

    if (staleInspections.length === 0) {
      console.log('[Cron-Realtime] No stale inspections found. Nothing to delete.');
      return;
    }

    console.log(`[Cron-Realtime] Found ${staleInspections.length} stale inspection(s) to delete.`);

    let deletedCount = 0;
    let failedCount = 0;

    for (const inspection of staleInspections) {
      try {
        await deleteAllInspectionImages(inspection);
        await Inspection.deleteOne({ _id: inspection._id });
        console.log(`[Cron-Realtime] Deleted inspection: ${inspection.inspection_id}`);
        deletedCount++;
      } catch (err) {
        console.error(`[Cron-Realtime] Failed to delete inspection ${inspection.inspection_id}:`, err.message);
        failedCount++;
      }
    }

    console.log(`[Cron-Realtime] Cleanup done. Deleted: ${deletedCount}, Failed: ${failedCount}`);
  } catch (err) {
    console.error('[Cron-Realtime] Cleanup job error:', err.message);
  }
};


const cleanupAllIncompleteInspections = async () => {
  console.log(`[Cron-Night] Running nightly incomplete inspection cleanup at ${dayjs().format('DD-MMM-YYYY HH:mm:ss')}`);

  try {
    const incompleteInspections = await Inspection.find({
      inspection_status: 0,
      selfie_image: null
     
    });

    if (incompleteInspections.length === 0) {
      console.log('[Cron-Night] No incomplete inspections found. Nothing to delete.');
      return;
    }

    console.log(`[Cron-Night] Found ${incompleteInspections.length} incomplete inspection(s) to delete.`);

    let deletedCount = 0;
    let failedCount = 0;

    for (const inspection of incompleteInspections) {
      try {
        await deleteAllInspectionImages(inspection);
        await Inspection.deleteOne({ _id: inspection._id });
        console.log(`[Cron-Night] Deleted inspection: ${inspection.inspection_id}`);
        deletedCount++;
      } catch (err) {
        console.error(`[Cron-Night] Failed to delete inspection ${inspection.inspection_id}:`, err.message);
        failedCount++;
      }
    }

    console.log(`[Cron-Night] Cleanup done. Deleted: ${deletedCount}, Failed: ${failedCount}`);
  } catch (err) {
    console.error('[Cron-Night] Cleanup job error:', err.message);
  }
};


cron.schedule('*/30 * * * *', cleanupStaleInspectionsRealtime, {
  timezone: 'Asia/Kolkata'
});


cron.schedule('30 23 * * *', cleanupAllIncompleteInspections, {
  timezone: 'Asia/Kolkata'
});

console.log('[Cron] Scheduled:');


module.exports = { 
  cleanupStaleInspectionsRealtime,
  cleanupAllIncompleteInspections 
};
// const Inspection = require('./../../models/InspectionQuestions/inspection');
// const { successResponse, errorResponse } = require('./../../utils/response');
// const path = require('path');
// const fs = require('fs');
// require('dotenv').config();


// const getNestedValue = (obj, dotPath) => {
//   return dotPath.split('.').reduce((acc, key) => acc && acc[key], obj);
// };


// const REQUIRED_FIELDS = [
//   // Foundation
//   'foundation.concrete_crack',
//   'foundation.soil_erosion',
//   'foundation.water_stagnation',
//   'foundation.anchor_bolt_loose',
//   'foundation.anchor_bolt_rust',
//   'foundation.base_plate_seated',
//   'foundation.base_plate_gap',
//   'foundation.grouting_damage',
//   'foundation.foundation_tilt',
//   'foundation.settlement',
//   'foundation.surrounding_soil_loose',

//   // Post
//   'post.post_straight',
//   'post.post_tilt',
//   'post.post_bend',
//   'post.weld_crack',
//   'post.weld_damage',
//   'post.rust',
//   'post.paint_peeled',
//   'post.thickness_reduced',
//   'post.flange_bolt_tight',
//   'post.flange_nut_loose',
//   'post.ladder_safe',
//   'post.platform_strong',

//   // Ad Board Frame
//   'ad_board_frame.frame_straight',
//   'ad_board_frame.frame_bend',
//   'ad_board_frame.angles_pipes_strong',
//   'ad_board_frame.weld_joint_strong',
//   'ad_board_frame.flex_fitted_well',
//   'ad_board_frame.flex_loose',
//   'ad_board_frame.clamp_tight',
//   'ad_board_frame.fastener_loose',
//   'ad_board_frame.wind_vibration',
//   'ad_board_frame.water_seepage',

//   // General Safety
//   'general_safety.surroundings_safe',
//   'general_safety.trees_touching',
//   'general_safety.obstructions',
//   'general_safety.wind_damage',
//   'general_safety.rain_damage',
//   'general_safety.unauthorized_changes',
//   'general_safety.maintenance_done_properly',
// ];

// const PHOTO_REQUIRED_FIELDS = {
//   'foundation.concrete_crack': true,
//   'foundation.soil_erosion': true,
//   'foundation.water_stagnation': true,
//   'foundation.anchor_bolt_loose': true,
//   'foundation.anchor_bolt_rust': true,
//   'foundation.base_plate_seated': true,
//   'foundation.base_plate_gap': true,
//   'foundation.grouting_damage': true,
//   'foundation.foundation_tilt': true,
//   'foundation.settlement': true,
//   'foundation.surrounding_soil_loose': true,

//   'post.post_straight': true,
//   'post.post_tilt': true,
//   'post.post_bend': true,
//   'post.weld_crack': true,
//   'post.weld_damage': true,
//   'post.rust': true,
//   'post.paint_peeled': true,
//   'post.thickness_reduced': true,
//   'post.flange_bolt_tight': true,
//   'post.flange_nut_loose': true,
//   'post.ladder_safe': true,
//   'post.platform_strong': true,

//   'ad_board_frame.frame_straight': true,
//   'ad_board_frame.frame_bend': true,
//   'ad_board_frame.angles_pipes_strong': true,
//   'ad_board_frame.weld_joint_strong': true,
//   'ad_board_frame.flex_fitted_well': true,
//   'ad_board_frame.flex_loose': true,
//   'ad_board_frame.clamp_tight': true,
//   'ad_board_frame.fastener_loose': true,
//   'ad_board_frame.wind_vibration': true,
//   'ad_board_frame.water_seepage': true,

//   'general_safety.surroundings_safe': true,
//   'general_safety.trees_touching': true,
//   'general_safety.obstructions': true,
//   'general_safety.wind_damage': true,
//   'general_safety.rain_damage': true,
//   'general_safety.unauthorized_changes': true,
//   'general_safety.maintenance_done_properly': true,
// };

// const isValidPhoto = (filename) => {
//   if (!filename || typeof filename !== 'string') return false;
//   return /\.(jpg|jpeg|png|webp)$/i.test(filename.trim());
// };


// // Get file paths from req.files (supports multiple files per field)
// const getFilePaths = (files, key) => {
//   if (files && files[key] && files[key].length > 0) {
//     // Return array of file paths
//     return files[key].map(file => `/uploads/${file.filename}`);
//   }
//   return [];
// };

// // Get single file path (for proof_photo)
// const getFilePath = (files, key) => {
//   if (files && files[key] && files[key][0]) {
//     return `/uploads/${files[key][0].filename}`;
//   }
//   return null;
// };


// const buildSection = (sectionJson, sectionName, files) => {
//   if (!sectionJson) return {};
//   let parsed;
//   try {
//     parsed = typeof sectionJson === 'string' ? JSON.parse(sectionJson) : sectionJson;
//   } catch {
//     return {};
//   }

//   const result = {};
//   Object.entries(parsed).forEach(([field, data]) => {
//     const photoKey = `${sectionName}_${field}_photo`;
//     const videoKey = `${sectionName}_${field}_video`; // ✅ NEW

//     result[field] = {
//       answer: data.answer || null,
//       photos: getFilePaths(files, photoKey),
//       visiting_video: getFilePath(files, videoKey) || null, // ✅ NEW
//     };
//   });

//   return result;
// };




// const validatePhotoRequirements = (inspectionData) => {
//   const errors = [];

//   for (const field of REQUIRED_FIELDS) {
//     const fieldData = getNestedValue(inspectionData, field);

//     if (fieldData) {
//       const { answer, photos } = fieldData;

//       // answer === 'yes' → at least one photo MANDATORY
//       if (answer === 'yes' && (!photos || photos.length === 0)) {
//         errors.push(`At least one photo is required for "${field}" when answer is "yes"`);
//       }

//       // Validate each photo format if uploaded
//       if (photos && photos.length > 0) {
//         photos.forEach((photo, index) => {
//           if (!isValidPhoto(photo)) {
//             errors.push(`Invalid photo format for "${field}" photo ${index + 1}: must be jpg, jpeg, png, or webp`);
//           }
//         });
//       }
//     }
//   }

//   return errors;
// };


// const validateRequiredFields = (inspectionData) => {
//   const errors = [];

//   for (const field of REQUIRED_FIELDS) {
//     const fieldData = getNestedValue(inspectionData, field);

//     // Field itself missing
//     if (!fieldData) {
//       errors.push(`"${field}" is required`);
//       continue;
//     }

//     // Answer missing or null
//     if (fieldData.answer === null || fieldData.answer === undefined || fieldData.answer === '') {
//       errors.push(`"${field}.answer" is required`);
//     }
//   }

//   return errors;
// };




// // ─── CREATE ───────────────────────────────────────────────────────────────────
// exports.createInspection_old = async (req, res) => {
//   try {
//     const body = req.body;
//     const files = req.files || {};

//     // ✅ FIX: proof_photo is uploaded as a file, so check req.files not req.body
//     if (!files['proof_photo'] || !files['proof_photo'][0]) {
//       return res.status(400).json({
//         success: false,
//         message: 'proof_photo is required'
//       });
//     }
//     console.log("dsfdsfsd");
//     const proofPhotoFilename = files['proof_photo'][0].filename;

//     if (!isValidPhoto(proofPhotoFilename)) {
//       return res.status(400).json({
//         success: false,
//         message: 'proof_photo must be a valid image file (jpg, jpeg, png, webp)'
//       });
//     }



//     // Parse location
//     let location;
//     try {
//       location = typeof body.location === 'string' ? JSON.parse(body.location) : body.location;
//     } catch {
//       return res.status(400).json({ success: false, message: 'Invalid location JSON' });
//     }

//     if (!location || !Array.isArray(location.coordinates) || location.coordinates.length !== 2) {
//       return res.status(400).json({ success: false, message: 'location.coordinates must be [longitude, latitude]' });
//     }

//     location.coordinates = [
//       parseFloat(location.coordinates[0]),
//       parseFloat(location.coordinates[1]),
//     ];

//     // Build sections (parsed JSON + actual uploaded file paths)
//     const foundation = buildSection(body.foundation, 'foundation', files);
//     const post = buildSection(body.post, 'post', files);
//     const ad_board_frame = buildSection(body.ad_board_frame, 'ad_board_frame', files);
//     const general_safety = buildSection(body.general_safety, 'general_safety', files);

//     // Use parsed sections for validation (not raw req.body which has JSON strings)
//     const parsedData = { foundation, post, ad_board_frame, general_safety };

//     const missingErrors = validateRequiredFields(parsedData);
//     if (missingErrors.length > 0) {
//       return res.status(400).json({
//         success: false,
//         message: 'The following fields are required',
//         errors: missingErrors
//       });
//     }

//     const photoErrors = validatePhotoRequirements(parsedData);
//     if (photoErrors.length > 0) {
//       return res.status(400).json({
//         success: false,
//         message: 'Photo required for all "yes" answers on required fields',
//         errors: photoErrors
//       });
//     }

//     const inspection = await Inspection.create({
//       visited_by: body.visited_by,
//       unipole_height: body.unipole_height,
//       ad_structure_size: body.ad_structure_size,
//       proof_photo: getFilePath(files, 'proof_photo'),

//       location,
//       foundation,
//       post,
//       ad_board_frame,
//       general_safety,
//     });

//     return successResponse(res, 'Inspection created successfully', inspection, 201);

//   } catch (error) {
//     console.error('createInspection error:', error);
//     return errorResponse(res, error.message, 400);
//   }
// };

// exports.createInspection = async (req, res) => {
//   try {
//     const body = req.body;
//     const files = req.files || {};
    
//     if (!files['proof_photo'] || !files['proof_photo'][0]) {
      
//        return errorResponse(res, 'proof_photo is required', 400);
//     }
//   }
//   catch (error) {

//   }

// }

// // ─── GET ALL ──────────────────────────────────────────────────────────────────
// exports.getAllInspections = async (req, res) => {
//   try {
//     const inspections = await Inspection.find().sort({ createdAt: -1 });
//     res.json({ success: true, count: inspections.length, data: inspections });
//   } catch (error) {
//     res.status(500).json({ success: false, message: error.message });
//   }
// };

// // ─── GET ONE ──────────────────────────────────────────────────────────────────
// exports.getInspectionById = async (req, res) => {
//   try {
//     const inspection = await Inspection.findById(req.params.id);
//     if (!inspection) return res.status(404).json({ success: false, message: 'Inspection not found' });
//     res.json({ success: true, data: inspection });
//   } catch (error) {
//     res.status(500).json({ success: false, message: error.message });
//   }
// };

// // ─── UPDATE ───────────────────────────────────────────────────────────────────
// exports.updateInspection = async (req, res) => {
//   try {
//     const body = req.body;
//     const files = req.files || {};

//     if (body.location) {
//       try {
//         body.location = typeof body.location === 'string' ? JSON.parse(body.location) : body.location;
//         body.location.coordinates = [
//           parseFloat(body.location.coordinates[0]),
//           parseFloat(body.location.coordinates[1]),
//         ];
//       } catch {
//         return res.status(400).json({ success: false, message: 'Invalid location JSON' });
//       }
//     }

//     const sections = {};
//     ['foundation', 'post', 'ad_board_frame', 'general_safety'].forEach((sec) => {
//       if (body[sec]) sections[sec] = buildSection(body[sec], sec, files);
//     });

//     const photoErrors = validatePhotoRequirements(sections);
//     if (photoErrors.length > 0) {
//       return res.status(400).json({ success: false, message: 'Photo required for mandatory fields', errors: photoErrors });
//     }

//     const updateData = {
//       ...(body.visited_by && { visited_by: body.visited_by }),
//       ...(body.unipole_height && { unipole_height: body.unipole_height }),
//       ...(body.ad_structure_size && { ad_structure_size: body.ad_structure_size }),
//       ...(body.location && { location: body.location }),
//       ...(files.proof_photo && { proof_photo: getFilePath(files, 'proof_photo') }),
//       ...sections,
//     };

//     const inspection = await Inspection.findByIdAndUpdate(req.params.id, updateData, { new: true, runValidators: true });
//     if (!inspection) return res.status(404).json({ success: false, message: 'Inspection not found' });
//     res.json({ success: true, data: inspection });
//   } catch (error) {
//     res.status(400).json({ success: false, message: error.message });
//   }
// };

// // ─── UPLOAD PHOTO (single field) ──────────────────────────────────────────────
// exports.uploadPhoto = async (req, res) => {
//   try {
//     const { field } = req.body;

//     if (!field || !(field in PHOTO_REQUIRED_FIELDS)) {
//       if (req.file) fs.unlinkSync(req.file.path);
//       return res.status(400).json({ success: false, message: `Invalid field: "${field}"` });
//     }

//     if (!PHOTO_REQUIRED_FIELDS[field]) {
//       if (req.file) fs.unlinkSync(req.file.path);
//       return res.status(400).json({ success: false, message: `Photo not required for field: "${field}"` });
//     }

//     const inspection = await Inspection.findById(req.params.id);
//     if (!inspection) {
//       if (req.file) fs.unlinkSync(req.file.path);
//       return res.status(404).json({ success: false, message: 'Inspection not found' });
//     }

//     const fieldData = getNestedValue(inspection.toObject(), field);
//     if (!fieldData || fieldData.answer !== 'yes') {
//       if (req.file) fs.unlinkSync(req.file.path);
//       return res.status(400).json({ success: false, message: `Answer must be "yes" to upload photo for "${field}"` });
//     }

//     if (!req.file) return res.status(400).json({ success: false, message: 'No photo file uploaded' });

//     if (fieldData.photo) {
//       const oldPath = path.join(__dirname, '../uploads', path.basename(fieldData.photo));
//       if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
//     }

//     const photoUrl = `/uploads/${req.file.filename}`;
//     const updated = await Inspection.findByIdAndUpdate(
//       req.params.id,
//       { $set: { [`${field}.photo`]: photoUrl } },
//       { new: true }
//     );

//     res.json({ success: true, message: `Photo uploaded for ${field}`, photo_url: photoUrl, data: updated });

//   } catch (error) {
//     if (req.file && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
//     res.status(500).json({ success: false, message: error.message });
//   }
// };


// // ─── FILTER ───────────────────────────────────────────────────────────────────
// exports.filterInspections = async (req, res) => {
//   try {
//     const {
//       // Date filters
//       date,
//       from_date,
//       to_date,

//       // Location filters
//       city,
//       state,
//       country,
//       pincode,

//       // Pagination
//       page = 1,
//       limit = 10,
//     } = req.query;

//     const filter = {};

//     // ── Date Filter ───────────────────────────────────────────────────────────
//     if (date) {
//       // Exact single day filter
//       const start = new Date(date);
//       start.setHours(0, 0, 0, 0);
//       const end = new Date(date);
//       end.setHours(23, 59, 59, 999);
//       filter.visiting_date = { $gte: start, $lte: end };

//     } else if (from_date || to_date) {
//       // Date range filter
//       filter.visiting_date = {};
//       if (from_date) {
//         const start = new Date(from_date);
//         start.setHours(0, 0, 0, 0);
//         filter.visiting_date.$gte = start;
//       }
//       if (to_date) {
//         const end = new Date(to_date);
//         end.setHours(23, 59, 59, 999);
//         filter.visiting_date.$lte = end;
//       }
//     }

//     // ── Location Filter ───────────────────────────────────────────────────────
//     if (city) filter['location.city'] = { $regex: city, $options: 'i' };
//     if (state) filter['location.state'] = { $regex: state, $options: 'i' };
//     if (country) filter['location.country'] = { $regex: country, $options: 'i' };
//     if (pincode) filter['location.pincode'] = pincode;

//     // ── Pagination ────────────────────────────────────────────────────────────
//     const skip = (parseInt(page) - 1) * parseInt(limit);
//     const total = await Inspection.countDocuments(filter);

//     const inspections = await Inspection.find(filter)
//       .sort({ visiting_date: -1 })
//       .skip(skip)
//       .limit(parseInt(limit));

//     res.json({
//       success: true,
//       total,
//       page: parseInt(page),
//       total_pages: Math.ceil(total / parseInt(limit)),
//       count: inspections.length,
//       data: inspections,
//     });

//   } catch (error) {
//     res.status(500).json({ success: false, message: error.message });
//   }
// };


// exports.getPhotosStatus = async (req, res) => {
//   try {
//     const inspection = await Inspection.findById(req.params.id);
//     if (!inspection) return res.status(404).json({ success: false, message: 'Inspection not found' });

//     const obj = inspection.toObject();
//     const status = REQUIRED_FIELDS.map((field) => {
//       const fieldData = getNestedValue(obj, field);
//       const answer = fieldData?.answer || null;
//       const photos = fieldData?.photos || [];  // Now an array
//       return {
//         field,
//         answer,
//         photos_count: photos.length,
//         photos_uploaded: photos.length,
//         photos_urls: photos,
//         pending: answer === 'yes' && photos.length === 0,
//       };
//     });

//     res.json({
//       success: true,
//       pending_photos: status.filter(s => s.pending).length,
//       total_photos_uploaded: status.reduce((sum, s) => sum + s.photos_count, 0),
//       data: status
//     });
//   } catch (error) {
//     res.status(500).json({ success: false, message: error.message });
//   }
// };

// // ─── DELETE ───────────────────────────────────────────────────────────────────
// exports.deleteInspection = async (req, res) => {
//   try {
//     const inspection = await Inspection.findByIdAndDelete(req.params.id);
//     if (!inspection) return res.status(404).json({ success: false, message: 'Inspection not found' });
//     res.json({ success: true, message: 'Inspection deleted successfully' });
//   } catch (error) {
//     res.status(500).json({ success: false, message: error.message });
//   }
// };



// exports.deleteVideo = async (req, res) => {
//   try {
//     const inspection = await Inspection.findById(req.params.id);
//     if (!inspection) {
//       return res.status(404).json({ success: false, message: 'Inspection not found' });
//     }

//     if (!inspection.visiting_video) {
//       return res.status(400).json({ success: false, message: 'No video found for this inspection' });
//     }

//     // Delete the video file from server
//     const videoPath = path.join(__dirname, '../uploads', path.basename(inspection.visiting_video));
//     if (fs.existsSync(videoPath)) {
//       fs.unlinkSync(videoPath);
//     }

//     // Remove video reference from database
//     inspection.visiting_video = null;
//     await inspection.save();

//     res.json({ success: true, message: 'Video deleted successfully', data: inspection });
//   } catch (error) {
//     res.status(500).json({ success: false, message: error.message });
//   }
// };
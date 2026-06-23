

// const multer = require('multer');
// const path = require('path');
// const fs = require('fs');

// // ===== ENSURE UPLOADS DIRECTORY EXISTS =====
// const uploadDir = path.join(__dirname, '../uploads');
// if (!fs.existsSync(uploadDir)) {
//   try {
//     fs.mkdirSync(uploadDir, { recursive: true });
//     console.log(`✅ Created uploads directory at: ${uploadDir}`);
//   } catch (err) {
//     console.error(`❌ Failed to create uploads directory:`, err);
//   }
// }



// // ===== STORAGE CONFIGURATION =====
// const storage = multer.diskStorage({
//   destination: (req, file, cb) => {
//     // Make sure the directory exists before saving
//     if (!fs.existsSync(uploadDir)) {
//       fs.mkdirSync(uploadDir, { recursive: true });
//     }
//     cb(null, uploadDir);
//   },
//   filename: (req, file, cb) => {
//     const fieldName = file.fieldname.replace(/[\[\].]/g, '_');
//     const ext = path.extname(file.originalname);
//     const timestamp = Date.now();
//     const random = Math.round(Math.random() * 1E9);
//     const filename = `${fieldName}_${timestamp}_${random}${ext}`;

//     console.log(`📤 Saving file: ${filename}`);
//     cb(null, filename);
//   }
// });

// // ===== FILE FILTER =====
// const fileFilter = (req, file, cb) => {
//   const isVideo = file.fieldname.endsWith('_video');  // Check if field name ends with _video

//   if (isVideo) {
//     const allowedVideoTypes = /mp4|mov|avi|mkv|webm|mpeg|m4v|flv|wmv/i;
//     const isValid = allowedVideoTypes.test(file.originalname.toLowerCase())
//       && allowedVideoTypes.test(file.mimetype);

//     if (isValid) {
//       cb(null, true);
//     } else {
//       console.warn(`⚠️ Invalid video type: ${file.originalname}`);
//       cb(new Error('Only video files (mp4, mov, avi, mkv, webm, mpeg, m4v, flv, wmv) are allowed for video fields'));
//     }
//   } else {
//     // For all other fields, only images
//     const allowedImageTypes = /jpeg|jpg|png|webp/i;
//     const isValid = allowedImageTypes.test(file.originalname.toLowerCase())
//       && allowedImageTypes.test(file.mimetype);

//     if (isValid) {
//       cb(null, true);
//     } else {
//       console.warn(`⚠️ Invalid image type: ${file.originalname}`);
//       cb(new Error('Only image files (jpg, jpeg, png, webp) are allowed'));
//     }
//   }
// };

// // ===== MULTER CONFIGURATION =====
// const upload = multer({
//   storage,
//   fileFilter,
//   limits: {
//     fileSize: 50 * 1024 * 1024,  
//     files: 500,                    
//     fieldSize: 10 * 1024 * 1024,   
//     fields: 200                   
//   }
// });

// module.exports = upload;



const multer = require('multer');
const path = require('path');

const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'video/mp4'
  ];

  const allowedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.mp4'
  ];

  const ext = path.extname(file.originalname).toLowerCase();

  if (
    allowedMimeTypes.includes(file.mimetype) &&
    allowedExtensions.includes(ext)
  ) {
    cb(null, true);
  } else {
    cb(new Error('Only jpg, jpeg, png, webp, and mp4 files are allowed'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 50 * 1024 * 1024, // 50 MB
  },
});

module.exports = upload;
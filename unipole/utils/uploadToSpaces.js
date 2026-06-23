const path = require('path');
const { PutObjectCommand } = require('@aws-sdk/client-s3');
const spacesClient = require('../config/spaces')

const uploadToSpaces = async (file, folder = 'inspection') => {
  const ext = path.extname(file.originalname);
  const fileName = `${folder}/${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;

  const command = new PutObjectCommand({
    Bucket: process.env.DO_SPACES_BUCKET,
    Key: fileName,
    Body: file.buffer,
    ACL: 'public-read',
    ContentType: file.mimetype,
  });

  await spacesClient.send(command);

  return `${process.env.DO_SPACES_CDN_BASE}/${fileName}`;
};

module.exports = uploadToSpaces;
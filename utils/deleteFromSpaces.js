const { DeleteObjectCommand } = require('@aws-sdk/client-s3');
const spacesClient = require('../config/spaces');

const getKeyFromUrl = (fileUrl) => {
  const bucketBase = process.env.DO_SPACES_CDN_BASE;

  if (!fileUrl.startsWith(bucketBase)) {
    throw new Error(`Invalid Spaces URL: ${fileUrl}`);
  }

  return fileUrl.replace(`${bucketBase}/`, '');
};

const deleteFromSpaces = async (fileUrl) => {
  const key = getKeyFromUrl(fileUrl);

  const command = new DeleteObjectCommand({
    Bucket: process.env.DO_SPACES_BUCKET,
    Key: key,
  });

  await spacesClient.send(command);
};

module.exports = deleteFromSpaces;
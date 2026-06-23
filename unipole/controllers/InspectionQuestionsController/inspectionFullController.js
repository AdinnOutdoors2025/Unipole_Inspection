const { successResponse, errorResponse } = require('./../../utils/response');
const path = require('path');
const fs = require('fs');
require('dotenv').config();
const Inspection = require('../../models/inspectionForm')
const dayjs = require('dayjs');
const uploadToSpaces = require('../../utils/uploadToSpaces')
const deleteFromSpaces = require('../../utils/deleteFromSpaces');

exports.createFullInspection = async (req, res) => {
  try {
    const {
      location,
      latitude,
      longitude,
      unipole_height,
      ad_structure_size
    } = req.body;

    // 1) First check if same user already has an incomplete inspection
    const existingIncompleteInspection = await Inspection.findOne({
      user_id: req.user._id,
      inspection_status: 0
    }).sort({ createdAt: -1 });

    if (existingIncompleteInspection) {
      return successResponse(
        res,
        'Incomplete inspection already exists. Returning existing inspection details',
        existingIncompleteInspection,
        200
      );
    }

    // 2) Only if no incomplete inspection found, create new one
    const visiting_date = dayjs().format('DD-MMMM-YYYY');

    const geo_location = {
      latitude: latitude ? Number(latitude) : null,
      longitude: longitude ? Number(longitude) : null
    };

    const inspection_id = await generateInspectionId();

    const inspection = await Inspection.create({
      user_id: req.user._id,
      location,
      geo_location,
      unipole_height,
      ad_structure_size,
      visiting_date,
      visited_by: req.user.name,
      inspection_status: 0,
      inspection_id,
      visited_by_phone: req.user.phone
    });

    return successResponse(
      res,
      'Inspection created successfully',
      inspection,
      201
    );
  } catch (error) {
    console.error(error);
    return res.status(400).json({
      success: false,
      message: error.message || 'Details not added'
    });
  }
};

const CHECKLIST_MAP = {
  foundation: [
    'concrete_cracks',
    'soil_erosion_at_foundation',
    'water_stagnation',
    'anchor_bolt_looseness',
    'anchor_bolts_rusted',
    'base_plate_properly_seated',
    'gap_in_base_plate',
    'grouting_damaged',
    'foundation_tilted',
    'foundation_settlement_occurred',
    'surrounding_soil_loose',
  ],
  post: [
    'post_straight',
    'post_tilted',
    'bend_in_post',
    'crack_in_welded_joint',
    'damage_in_welded_joint',
    'rust_present',
    'paint_peeled_off',
    'post_thickness_reduced',
    'splice_bolts_tight',
    'splice_nuts_looseness',
    'ladder_secure',
    'platform_strong',
  ],
  ad_board_frame: [
    'frame_straight',
    'bend_in_frame',
    'angle_pipe_members_strong',
    'welded_joints_strong',
    'flex_properly_fixed',
    'flex_loose',
    'clamps_tight',
    'support_fasteners_looseness',
    'vibration_due_to_wind',
    'water_runoff_or_seepage_on_structure',
  ],
  general_inspection: [
    'surrounding_area_safe',
    'nearby_trees_touching_structure',
    'obstructions_present',
    'wind_damage',
    'rain_damage',
    'unauthorized_modifications',
    'repairs_carried_out_properly',
  ],
};

const calculateInspectionOutcome = (inspection) => {
  let yesCount = 0;
  let noCount = 0;
  let unansweredCount = 0;

  for (const [sectionName, itemList] of Object.entries(CHECKLIST_MAP)) {
    for (const itemName of itemList) {
      const status = inspection?.[sectionName]?.[itemName]?.status;

      if (status === true) {
        yesCount += 1;
      } else if (status === false) {
        noCount += 1;
      } else {
        unansweredCount += 1;
      }
    }
  }

  const totalQuestions = yesCount + noCount + unansweredCount;
  const answeredCount = yesCount + noCount;

  let inspectionFlag = null;

  // nothing answered yet
  if (answeredCount === 0) {
    inspectionFlag = null;
  } 
  // 0 to 9 YES
  else if (yesCount < 10) {
    inspectionFlag = 'good';
  } 
  // 10 to 19 YES
  else if (yesCount >= 10 && yesCount <= 19) {
    inspectionFlag = 'minor_issue';
  } 
  // 20 and above YES
  else {
    inspectionFlag = 'critical';
  }

  return {
    inspectionFlag,
    inspectionMetrics: {
      total_questions: totalQuestions,
      yes_count: yesCount,
      no_count: noCount,
      unanswered_count: unansweredCount,
    },
  };
};

const buildFullInspectionResponse = (inspectionDoc) => {
  const inspection = inspectionDoc.toObject ? inspectionDoc.toObject() : inspectionDoc;

  const normalizedInspection = {
    _id: inspection._id,
    user_id: inspection.user_id,
    inspection_id: inspection.inspection_id,
    location: inspection.location,
    geo_location: inspection.geo_location,
    unipole_height: inspection.unipole_height,
    ad_structure_size: inspection.ad_structure_size,
    visiting_date: inspection.visiting_date,
    visited_by: inspection.visited_by,
    selfie_image: inspection.selfie_image,
    inspection_status: inspection.inspection_status,
    inspection_flag: inspection.inspection_flag,
    inspection_metrics: inspection.inspection_metrics,
    createdAt: inspection.createdAt,
    updatedAt: inspection.updatedAt,
    __v: inspection.__v,
    foundation: {},
    post: {},
    ad_board_frame: {},
    general_inspection: {}
  };

  for (const [sectionName, itemList] of Object.entries(CHECKLIST_MAP)) {
    normalizedInspection[sectionName] = {};

    for (const itemName of itemList) {
      const existingItem = inspection?.[sectionName]?.[itemName];

      normalizedInspection[sectionName][itemName] = {
        status: existingItem?.status === true,
        images: Array.isArray(existingItem?.images) ? existingItem.images : [],
      };
    }
  }

  return normalizedInspection;
};

exports.updateFullInspection = async (req, res) => {
  const newlyUploadedUrls = [];

  try {
    const { id } = req.params;
    const MAX_IMAGES_PER_ITEM = 7;

    const inspection = await Inspection.findOne({
      inspection_id: id,
      user_id: req.user._id,
    });

    if (!inspection) {
      return errorResponse(res, 'Inspection not found', null, 404);
    }

    const getFilesByField = (fieldName) => {
      if (Array.isArray(req.files)) {
        return req.files.filter((file) => file.fieldname === fieldName);
      }
      return req.files?.[fieldName] || [];
    };

    const parseStatus = (value, oldValue = null) => {
      if (value === 'true' || value === true) return true;
      if (value === 'false' || value === false) return false;
      return oldValue;
    };

    const touchedItems = [];

    for (const [sectionName, itemList] of Object.entries(CHECKLIST_MAP)) {
      if (!inspection[sectionName]) {
        inspection[sectionName] = {};
      }

      for (const itemName of itemList) {
        const statusFieldName = `${sectionName}_${itemName}_status`;
        const imageFieldName = `${sectionName}_${itemName}_images`;

        const hasStatusField = Object.prototype.hasOwnProperty.call(
          req.body,
          statusFieldName
        );

        const files = getFilesByField(imageFieldName);
        const hasFiles = files.length > 0;

        if (!hasStatusField && !hasFiles) {
          continue;
        }

        const existingItem = inspection[sectionName][itemName] || {
          status: null,
          images: [],
        };

        const oldStatus = existingItem.status ?? null;
        const oldImages = Array.isArray(existingItem.images)
          ? existingItem.images
          : [];

        const status = parseStatus(req.body[statusFieldName], oldStatus);

        if (status === false) {
          for (const imageUrl of oldImages) {
            try {
              await deleteFromSpaces(imageUrl);
            } catch (err) {
              console.error(
                `Failed to delete ${sectionName}.${itemName} image from cloud:`,
                err.message
              );
            }
          }

          inspection[sectionName][itemName] = {
            status: false,
            images: [],
          };

          touchedItems.push(`${sectionName}.${itemName}`);
          continue;
        }

        const existingCount = oldImages.length;
        const incomingCount = files.length;
        const totalCount = existingCount + incomingCount;

        if (totalCount > MAX_IMAGES_PER_ITEM) {
          const remaining = Math.max(MAX_IMAGES_PER_ITEM - existingCount, 0);

          if (existingCount > 0) {
            return errorResponse(
              res,
              `Already you uploaded ${existingCount} images for ${sectionName}.${itemName}. Remaining you have ${remaining} only`,
              null,
              400
            );
          }

          return errorResponse(
            res,
            `Maximum ${MAX_IMAGES_PER_ITEM} images allowed for ${sectionName}.${itemName}`,
            null,
            400
          );
        }

        if (status === true && totalCount === 0) {
          return errorResponse(
            res,
            `${sectionName}.${itemName} status is true, so at least one image is required`,
            null,
            400
          );
        }

        const uploadedImageUrls = [];

        for (const file of files) {
          const uploadedUrl = await uploadToSpaces(
            file,
            `inspection/${sectionName}/${itemName}`
          );
          uploadedImageUrls.push(uploadedUrl);
          newlyUploadedUrls.push(uploadedUrl);
        }

        const finalImages = [...oldImages, ...uploadedImageUrls];

        inspection[sectionName][itemName] = {
          status,
          images: finalImages,
        };

        touchedItems.push(`${sectionName}.${itemName}`);
      }
    }

    if (touchedItems.length === 0) {
      return errorResponse(
        res,
        'No valid checklist status or image fields provided',
        null,
        400
      );
    }

    // NEW: calculate overall result
    const { inspectionFlag, inspectionMetrics } =
      calculateInspectionOutcome(inspection);

    inspection.inspection_flag = inspectionFlag;
    inspection.inspection_metrics = inspectionMetrics;

    await inspection.save();

    const normalizedInspection = buildFullInspectionResponse(inspection);

    return successResponse(
      res,
      'Inspection updated successfully',
      {
        inspection: normalizedInspection,
        updated_items: touchedItems,
      },
      200
    );
  } catch (error) {
    console.error(error);

    if (newlyUploadedUrls.length > 0) {
      for (const imageUrl of newlyUploadedUrls) {
        try {
          await deleteFromSpaces(imageUrl);
        } catch (err) {
          console.error('Rollback delete failed:', err.message);
        }
      }
    }

    return errorResponse(
      res,
      'Update failed',
      error.message || error,
      400
    );
  }
};

exports.deleteFullInspection = async (req, res) => {
  try {
    const { id } = req.params;
    const targetUrl = req.body?.url;

    if (!targetUrl) {
      return errorResponse(
        res,
        'url is required',
        null,
        400
      );
    }

    const inspection = await Inspection.findOne({
      inspection_id: id,
      user_id: req.user._id
    });

    if (!inspection) {
      return errorResponse(
        res,
        'Inspection not found',
        null,
        404
      );
    }

    const allowedSections = [
      'foundation',
      'post',
      'ad_board_frame',
      'general_inspection'
    ];

    let foundSection = null;
    let foundItem = null;

    for (const sectionName of allowedSections) {
      const sectionData = inspection[sectionName];

      if (!sectionData || typeof sectionData !== 'object') continue;

      const itemKeys = Object.keys(sectionData.toObject ? sectionData.toObject() : sectionData);

      for (const itemName of itemKeys) {
        const item = sectionData[itemName];

        if (
          item &&
          Array.isArray(item.images) &&
          item.images.includes(targetUrl)
        ) {
          foundSection = sectionName;
          foundItem = itemName;
          break;
        }
      }

      if (foundSection && foundItem) break;
    }

    if (!foundSection || !foundItem) {
      return errorResponse(
        res,
        'Image URL not found in inspection',
        null,
        404
      );
    }

    // delete from cloud
    await deleteFromSpaces(targetUrl);

    // remove from DB
    const existingImages = inspection[foundSection][foundItem].images || [];
    const updatedImages = existingImages.filter((url) => url !== targetUrl);

    inspection[foundSection][foundItem].images = updatedImages;

    // if no images left, set status false
    if (updatedImages.length === 0) {
      inspection[foundSection][foundItem].status = false;
    }

    await inspection.save();

    const normalizedInspection = buildFullInspectionResponse(inspection);

    return successResponse(
      res,
      `${foundSection}.${foundItem} image deleted successfully`,
      {
        inspection: normalizedInspection,
        deleted_item: `${foundSection}.${foundItem}`,
        deleted_url: targetUrl
      },
      200
    );
  } catch (error) {
    console.error(error);

    return errorResponse(
      res,
      'Delete failed',
      error.message || error,
      400
    );
  }
};

exports.submitFullInspection = async (req, res) => {
  try {
    const { id } = req.params;

    const inspection = await Inspection.findOne({
      inspection_id: id,
      user_id: req.user._id
    });

    if (!inspection) {
      return errorResponse(res, 'Inspection not found', null, 404);
    }

    if (!req.file) {
      return errorResponse(res, 'selfie_image is required', null, 400);
    }

    if (inspection.selfie_image) {
      try {
        await deleteFromSpaces(inspection.selfie_image);
      } catch (err) {
        console.error('Failed to delete old selfie image from cloud:', err.message);
      }
    }

    const selfieImageUrl = await uploadToSpaces(
      req.file,
      'inspection/selfie_image'
    );

    inspection.selfie_image = selfieImageUrl;
    inspection.inspection_status = 1;

    let { inspectionFlag, inspectionMetrics } =
      calculateInspectionOutcome(inspection);

    // If user submits directly without answering any checklist question,
    // mark it as good instead of null
    if (
      inspectionMetrics.yes_count === 0 &&
      inspectionMetrics.no_count === 0
    ) {
      inspectionFlag = 'good';
    }

    inspection.inspection_flag = inspectionFlag;
    inspection.inspection_metrics = inspectionMetrics;

    await inspection.save();

    const normalizedInspection = buildFullInspectionResponse(inspection);

    return successResponse(
      res,
      'Inspection submitted successfully',
      normalizedInspection,
      200
    );
  } catch (error) {
    console.error(error);

    return errorResponse(
      res,
      'Submit inspection failed',
      error.message || error,
      400
    );
  }
};

exports.getFullInspectionDetails = async (req, res) => {
  try {

    // taking user_id from token
    const inspection = await Inspection.findOne({
      user_id: req.user._id,
      inspection_status: 0
    }).sort({ createdAt: -1 });

    // if no inspection found OR inspection_status is not 0,

    if (!inspection || Number(inspection.inspection_status) !== 0) {
      return successResponse(
        res,
        'Data is empty',
        {},
        200
      );
    }

    const normalizedInspection = buildFullInspectionResponse(inspection);

    return successResponse(
      res,
      'Inspection details retrieved successfully',
      normalizedInspection,
      200
    );
  } catch (error) {
    console.error(error);

    return errorResponse(
      res,
      'Failed to retrieve inspection details',
      error.message || error,
      400
    );
  }
};



const generateInspectionId = async () => {
  const today = dayjs().format('YYYYMMDD');

  // Find last record for today
  const lastRecord = await Inspection.findOne({
    inspection_id: { $regex: `INS-${today}` }
  })
    .sort({ inspection_id: -1 });

  let sequence = 1;

  if (lastRecord && lastRecord.inspection_id) {
    const lastSequence = parseInt(lastRecord.inspection_id.split('-')[2]);
    sequence = lastSequence + 1;
  }

  const paddedSequence = String(sequence).padStart(3, '0');

  return `INS-${today}-${paddedSequence}`;
};

exports.getAllInspectionDetails = async (req, res) => {
  try {
    const {
      inspection_id,
      inspection_status,
      inspection_flag,
      visited_by,
      visited_by_phone,
      from_date,
      to_date
    } = req.query;

    let filter = {};

    if (inspection_id) {
      filter.inspection_id = inspection_id.trim();
    }

    //  Status Filter
    if (inspection_status !== undefined) {
      filter.inspection_status = Number(inspection_status);
    }

    // inspection_flag Filter
    if (inspection_flag) {
      filter.inspection_flag = inspection_flag.trim();
    }

    //  Name Filter
    if (visited_by) {
      filter.visited_by = { $regex: visited_by, $options: 'i' };
    }


    if (visited_by_phone) {
      filter.visited_by_phone = {
        $regex: visited_by_phone,
        $options: 'i'
      };
    }


    if (from_date && to_date) {
      const startDate = new Date(from_date);
      const endDate = new Date(to_date);


      endDate.setHours(23, 59, 59, 999);

      filter.createdAt = {
        $gte: startDate,
        $lte: endDate
      };
    } else if (from_date) {
      filter.createdAt = {
        $gte: new Date(from_date)
      };
    }

    const inspections = await Inspection.find(filter)
      .sort({ createdAt: -1 });


    if (!inspections || inspections.length === 0) {
      return errorResponse(
        res,
        "No inspection data found",
        null,
        404
      );
    }


    return successResponse(
      res,
      "Inspection Details Fetched Successfully",
      inspections,
      200
    );

  } catch (error) {
    return errorResponse(
      res,
      "Failed to fetch inspection data",
      error.message || error,
      400
    );
  }
};




// developer mode only
const getFlatChecklistItems = () => {
  const flatItems = [];

  for (const [sectionName, itemList] of Object.entries(CHECKLIST_MAP)) {
    for (const itemName of itemList) {
      flatItems.push({ sectionName, itemName });
    }
  }

  return flatItems;
};

const applyDummyInspectionCounts = (inspection, yesCount, noCount) => {
  const flatItems = getFlatChecklistItems();
  const totalQuestions = flatItems.length;

  if (!Number.isInteger(yesCount) || yesCount < 0) {
    throw new Error('yes_count must be a non-negative integer');
  }

  if (!Number.isInteger(noCount) || noCount < 0) {
    throw new Error('no_count must be a non-negative integer');
  }

  if (yesCount + noCount > totalQuestions) {
    throw new Error(
      `yes_count + no_count should not exceed total questions (${totalQuestions})`
    );
  }

  flatItems.forEach(({ sectionName, itemName }, index) => {
    if (!inspection[sectionName]) {
      inspection[sectionName] = {};
    }

    let status = null;

    if (index < yesCount) {
      status = true;
    } else if (index < yesCount + noCount) {
      status = false;
    }

    inspection[sectionName][itemName] = {
      status,
      images: [],
    };
  });

  return inspection;
};

exports.dummyInsertInspectionForDeveloper = async (req, res) => {
  try {
    // strongly recommended: block in production

    const { id } = req.params;
    const { yes_count = 0, no_count = 0 } = req.body;

    const inspection = await Inspection.findOne({
      inspection_id: id,
      user_id: req.user._id,
    });

    if (!inspection) {
      return errorResponse(res, 'Inspection not found', null, 404);
    }

    applyDummyInspectionCounts(
      inspection,
      Number(yes_count),
      Number(no_count)
    );

    const { inspectionFlag, inspectionMetrics } =
      calculateInspectionOutcome(inspection);

    inspection.inspection_flag = inspectionFlag;
    inspection.inspection_metrics = inspectionMetrics;

    await inspection.save();

    const normalizedInspection = buildFullInspectionResponse(inspection);

    return successResponse(
      res,
      'Developer dummy inspection updated successfully',
      {
        inspection: normalizedInspection,
        dummy_payload: {
          yes_count: Number(yes_count),
          no_count: Number(no_count),
        },
      },
      200
    );
  } catch (error) {
    console.error(error);

    return errorResponse(
      res,
      'Developer dummy insert failed',
      error.message || error,
      400
    );
  }
};
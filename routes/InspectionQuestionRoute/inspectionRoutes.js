const express = require('express');
const router = express.Router();
const upload = require('./../../upload');

const {
  createFullInspection,
  updateFullInspection,
  deleteFullInspection,
  submitFullInspection,
  getFullInspectionDetails,
  getAllInspectionDetails,
  dummyInsertInspectionForDeveloper
} = require('../../controllers/InspectionQuestionsController/inspectionFullController');

const { protect } = require('../../middleware/authMiddleware');

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



const allImageFields = [];

for (const [sectionName, itemList] of Object.entries(CHECKLIST_MAP)) {
  for (const itemName of itemList) {
    allImageFields.push({
      name: `${sectionName}_${itemName}_images`,
      maxCount: 20, 
    });
  }
}

router.use(protect);

router.post('/', upload.fields(allImageFields), createFullInspection);

router.post('/:id/update', upload.fields(allImageFields), updateFullInspection);

router.post('/:id/submitinspection', upload.single('selfie_image'), submitFullInspection);

router.post('/:id/delete', deleteFullInspection);

router.get('/', getFullInspectionDetails);
router.get('/getAllInspections', getAllInspectionDetails);
router.put(
  '/:id/dummy-dev',
  dummyInsertInspectionForDeveloper
);
module.exports = router;
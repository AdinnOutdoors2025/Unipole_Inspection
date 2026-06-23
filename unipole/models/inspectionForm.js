const mongoose = require('mongoose');

// Reusable checklist item schema
const checklistItemSchema = new mongoose.Schema(
  {
    status: {
      type: Boolean,
      default: null, // true / false / null
    },
    images: {
      type: [String], // image URLs
      default: [],
      validate: {
        validator: function (arr) {
          return arr.length <= 7;
        },
        message: 'Maximum 7 images allowed per checklist item',
      },
    },
  },
  { _id: false }
);

const inspectionMetricsSchema = new mongoose.Schema(
  {
    total_questions: { type: Number, default: 40 },
    yes_count: { type: Number, default: 0 },
    no_count: { type: Number, default: 0 },
    unanswered_count: { type: Number, default: 40 },
    average_yes_ratio: { type: Number, default: 0 },
  },
  { _id: false }
);

const inspectionSchema = new mongoose.Schema(
  {
    // User Details
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    //Unique inspection Id
    inspection_id: {
      type: String,
      unique: true,
      trim: true
    },

    // Basic Details
    location: { type: String, default: null, trim: true },
    geo_location: {
      latitude: { type: Number, default: null },
      longitude: { type: Number, default: null }
    },
    unipole_height: { type: String, default: null, trim: true },
    ad_structure_size: { type: String, default: null, trim: true },
    visiting_date: { type: String, default: null, trim: true },
    visited_by: { type: String, default: null, trim: true },
    visited_by_phone: {
      type: String,
      default: null,
      trim: true
    },
    selfie_image: { type: String, default: null, trim: true },



    inspection_status: {
      type: Number,
      default: null,
      validate: {
        validator: function (value) {
          return value === null || value === 0 || value === 1;
        },
        message: 'inspection_status must be null, 0, or 1'
      }
    },

    inspection_flag: {
      type: String,
      enum: ['good', 'minor_issue', 'critical'],
      default: null,
      trim: true,
    },

    inspection_metrics: {
      type: inspectionMetricsSchema,
      default: () => ({
        total_questions: 40,
        yes_count: 0,
        no_count: 0,
        unanswered_count: 40,
        average_yes_ratio: 0,
      }),
    },



    // Foundation
    foundation: {
      concrete_cracks: checklistItemSchema,
      soil_erosion_at_foundation: checklistItemSchema,
      water_stagnation: checklistItemSchema,
      anchor_bolt_looseness: checklistItemSchema,
      anchor_bolts_rusted: checklistItemSchema,
      base_plate_properly_seated: checklistItemSchema,
      gap_in_base_plate: checklistItemSchema,
      grouting_damaged: checklistItemSchema,
      foundation_tilted: checklistItemSchema,
      foundation_settlement_occurred: checklistItemSchema,
      surrounding_soil_loose: checklistItemSchema,
    },

    // Post
    post: {
      post_straight: checklistItemSchema,
      post_tilted: checklistItemSchema,
      bend_in_post: checklistItemSchema,
      crack_in_welded_joint: checklistItemSchema,
      damage_in_welded_joint: checklistItemSchema,
      rust_present: checklistItemSchema,
      paint_peeled_off: checklistItemSchema,
      post_thickness_reduced: checklistItemSchema,
      splice_bolts_tight: checklistItemSchema,
      splice_nuts_looseness: checklistItemSchema,
      ladder_secure: checklistItemSchema,
      platform_strong: checklistItemSchema,
    },

    // Ad Board Frame
    ad_board_frame: {
      frame_straight: checklistItemSchema,
      bend_in_frame: checklistItemSchema,
      angle_pipe_members_strong: checklistItemSchema,
      welded_joints_strong: checklistItemSchema,
      flex_properly_fixed: checklistItemSchema,
      flex_loose: checklistItemSchema,
      clamps_tight: checklistItemSchema,
      support_fasteners_looseness: checklistItemSchema,
      vibration_due_to_wind: checklistItemSchema,
      water_runoff_or_seepage_on_structure: checklistItemSchema,
    },

    // General Inspection
    general_inspection: {
      surrounding_area_safe: checklistItemSchema,
      nearby_trees_touching_structure: checklistItemSchema,
      obstructions_present: checklistItemSchema,
      wind_damage: checklistItemSchema,
      rain_damage: checklistItemSchema,
      unauthorized_modifications: checklistItemSchema,
      repairs_carried_out_properly: checklistItemSchema,
    },
  },
  { timestamps: true }
);

module.exports =
  mongoose.models.Inspection ||
  mongoose.model('Inspection', inspectionSchema, 'inspection_form');
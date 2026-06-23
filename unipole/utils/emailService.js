const nodemailer = require('nodemailer');
require('dotenv').config();
const fs = require('fs');
const path = require('path');

// Create email transporter
const transporter = nodemailer.createTransport({
  service: process.env.EMAIL_SERVICE || 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD
  }
});

const BASE_URL = process.env.BASE_URL || 'http://localhost:5000';


const resolveLocation = (location) => {
  if (!location) return 'N/A';
  if (typeof location === 'string') return location;
  if (typeof location === 'object') {
    const loc = (typeof location.toObject === 'function') ? location.toObject() : location;
    return [loc.address, loc.city, loc.state].filter(Boolean).join(', ')
           + (loc.pincode ? ' - ' + loc.pincode : '')
           || 'N/A';
  }
  return 'N/A';
};


const formatVisitingDate = (dateStr) => {
  if (!dateStr) return 'N/A';
  const d = new Date(dateStr);
  if (isNaN(d)) return dateStr;
  return d.toLocaleDateString('en-IN');
};


const hasData = (qData) => {
  if (!qData) return false;
  return qData.status !== null && qData.status !== undefined;
};


const getImages = (qData) => {
  if (!qData) return [];
  return Array.isArray(qData.images) ? qData.images : [];
};


const SECTION_TITLES = {
  foundation:         'Foundation',
  post:               'Post',
  ad_board_frame:     'Ad Board Frame',
  general_inspection: 'General Safety'
};

const QUESTION_LABELS = {
  foundation: {
    concrete_cracks:                'Concrete Crack',
    soil_erosion_at_foundation:     'Soil Erosion',
    water_stagnation:               'Water Stagnation',
    anchor_bolt_looseness:          'Anchor Bolt Loose',
    anchor_bolts_rusted:            'Anchor Bolt Rust',
    base_plate_properly_seated:     'Base Plate Seated',
    gap_in_base_plate:              'Base Plate Gap',
    grouting_damaged:               'Grouting Damage',
    foundation_tilted:              'Foundation Tilt',
    foundation_settlement_occurred: 'Settlement',
    surrounding_soil_loose:         'Surrounding Soil Loose'
  },
  post: {
    post_straight:          'Post Straight',
    post_tilted:            'Post Tilt',
    bend_in_post:           'Post Bend',
    crack_in_welded_joint:  'Weld Crack',
    damage_in_welded_joint: 'Weld Damage',
    rust_present:           'Rust',
    paint_peeled_off:       'Paint Peeled',
    post_thickness_reduced: 'Thickness Reduced',
    splice_bolts_tight:     'Splice Bolt Tight',
    splice_nuts_looseness:  'Splice Nut Loose',
    ladder_secure:          'Ladder Safe',
    platform_strong:        'Platform Strong'
  },
  ad_board_frame: {
    frame_straight:                       'Frame Straight',
    bend_in_frame:                        'Frame Bend',
    angle_pipe_members_strong:            'Angles & Pipes Strong',
    welded_joints_strong:                 'Weld Joint Strong',
    flex_properly_fixed:                  'Flex Fitted Well',
    flex_loose:                           'Flex Loose',
    clamps_tight:                         'Clamp Tight',
    support_fasteners_looseness:          'Fastener Loose',
    vibration_due_to_wind:                'Wind Vibration',
    water_runoff_or_seepage_on_structure: 'Water Seepage'
  },
  general_inspection: {
    surrounding_area_safe:              'Surroundings Safe',
    nearby_trees_touching_structure:    'Trees Touching',
    obstructions_present:               'Obstructions',
    wind_damage:                        'Wind Damage',
    rain_damage:                        'Rain Damage',
    unauthorized_modifications:         'Unauthorized Changes',
    repairs_carried_out_properly:       'Maintenance Done Properly'
  }
};


const buildInspectionDetailHTML = (inspection) => {
  const sections = ['foundation', 'post', 'ad_board_frame', 'general_inspection'];
  const sectionColors = {
    foundation:         '#3498DB',
    post:               '#E74C3C',
    ad_board_frame:     '#F39C12',
    general_inspection: '#27AE60'
  };

  let questionNumber = 1;
  let sectionsHTML = '';

  for (const section of sections) {
    const sectionData = inspection[section];
    if (!sectionData) continue;

    const questionKeys = Object.keys(sectionData).filter(k => hasData(sectionData[k]));
    if (questionKeys.length === 0) continue;

    let rowsHTML = '';

    for (const question of questionKeys) {
      const qData   = sectionData[question];
      const label   = (QUESTION_LABELS[section] && QUESTION_LABELS[section][question]) || question;
    
      const answer      = qData.status === true ? 'Yes' : 'No';
      const answerColor = qData.status === true ? '#27AE60' : '#E74C3C';
      const images      = getImages(qData);

    
      let imageHtml = '<span style="color: #aaa; font-size: 12px;">No Photo</span>';
      if (images.length === 1) {
        imageHtml = `
          <img src="${images[0]}" alt="${label}" width="120" height="90"
               style="object-fit: cover; border-radius: 4px; border: 1px solid #ddd;" />`;
      } else if (images.length > 1) {
      
        imageHtml = `
          <div>
            <img src="${images[0]}" alt="${label}" width="120" height="90"
                 style="object-fit: cover; border-radius: 4px; border: 1px solid #ddd; margin-bottom: 4px;" />
            <div style="font-size: 11px; color: #555; margin-top: 4px;">
              📷 ${images.length} photos — 
              ${images.map((url, i) =>
                `<a href="${url}" target="_blank" style="color:#2980b9; text-decoration:none;">Photo ${i+1}</a>`
              ).join(' | ')}
            </div>
          </div>`;
      }

      rowsHTML += `
        <tr style="background-color: ${questionNumber % 2 === 0 ? '#f9f9f9' : '#ffffff'};">
          <td style="padding: 10px 12px; border-bottom: 1px solid #eee; color: #555; font-size: 13px;">
            ${questionNumber}. ${label}
          </td>
          <td style="padding: 10px 12px; border-bottom: 1px solid #eee; text-align: center;">
            <span style="color: ${answerColor}; font-weight: bold; font-size: 13px;">${answer}</span>
          </td>
          <td style="padding: 10px 12px; border-bottom: 1px solid #eee; text-align: center;">
            ${imageHtml}
          </td>
        </tr>`;

      questionNumber++;
    }

    sectionsHTML += `
      <tr>
        <td colspan="3"
            style="background-color: ${sectionColors[section]}; color: white;
                   font-weight: bold; font-size: 14px; padding: 10px 12px;">
          ${SECTION_TITLES[section]}
        </td>
      </tr>
      ${rowsHTML}`;
  }

  return `
    <table style="width: 100%; border-collapse: collapse; margin-top: 16px;
                  font-family: Arial, sans-serif; font-size: 13px;">
      <thead>
        <tr style="background-color: #2C3E50; color: white;">
          <th style="padding: 10px 12px; text-align: left; width: 45%;">Question</th>
          <th style="padding: 10px 12px; text-align: center; width: 15%;">Answer</th>
          <th style="padding: 10px 12px; text-align: center; width: 40%;">Photo</th>
        </tr>
      </thead>
      <tbody>${sectionsHTML}</tbody>
    </table>`;
};

//
const sendInspectionEmail = async (inspection, pdfFilePath, recipientEmail) => {
  try {
    if (!fs.existsSync(pdfFilePath)) {
      throw new Error('PDF file not found: ' + pdfFilePath);
    }

    const locationStr = resolveLocation(inspection.location);

    const attachments = [{
      filename: `inspection_${inspection._id}.pdf`,
      path: pdfFilePath
    }];

  
    let selfieHtml = '';
    if (inspection.selfie_image) {
      selfieHtml = `
        <tr>
          <td style="padding: 8px 0; color: #666;"><strong>Selfie Photo:</strong></td>
          <td style="padding: 8px 0;">
            <img src="${inspection.selfie_image}" alt="Selfie" width="150"
                 style="border-radius: 4px; border: 1px solid #ddd;" />
          </td>
        </tr>`;
    }

    const inspectionDetailsHTML = buildInspectionDetailHTML(inspection);

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: recipientEmail,
      subject: `Inspection Report - ${locationStr} (${inspection.visiting_date})`,
      html: `
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"><title>Inspection Report</title></head>
        <body style="margin:0;padding:0;font-family:Arial,sans-serif;background:#f4f6f8;">
          <div style="max-width:900px;margin:20px auto;background:#fff;border-radius:8px;overflow:hidden;box-shadow:0 2px 4px rgba(0,0,0,0.1);">

            <div style="background:#2C3E50;color:white;padding:25px 30px;">
              <h2 style="margin:0;font-size:24px;">Unipole Inspection Report</h2>
              <p style="margin:5px 0 0;opacity:0.8;font-size:14px;">Structural Safety Assessment</p>
            </div>

            <div style="padding:25px 30px;background:#f8f9fa;border-bottom:1px solid #e9ecef;">
              <h3 style="margin:0 0 15px;color:#2C3E50;font-size:18px;">Site Details</h3>
              <table style="width:100%;font-size:14px;">
                <tr>
                  <td style="padding:8px 0;width:160px;color:#666;"><strong>Location:</strong></td>
                  <td style="padding:8px 0;color:#333;">${locationStr}</td>
                </tr>
                <tr>
                  <td style="padding:8px 0;color:#666;"><strong>Unipole Height:</strong></td>
                  <td style="padding:8px 0;color:#333;">${inspection.unipole_height || 'N/A'}</td>
                </tr>
                <tr>
                  <td style="padding:8px 0;color:#666;"><strong>Ad Structure Size:</strong></td>
                  <td style="padding:8px 0;color:#333;">${inspection.ad_structure_size || 'N/A'}</td>
                </tr>
                <tr>
                  <td style="padding:8px 0;color:#666;"><strong>Visiting Date:</strong></td>
                  <td style="padding:8px 0;color:#333;">${inspection.visiting_date}</td>
                </tr>
                <tr>
                  <td style="padding:8px 0;color:#666;"><strong>Visited By:</strong></td>
                  <td style="padding:8px 0;color:#333;">${inspection.visited_by || 'N/A'}</td>
                </tr>
                <tr>
                  <td style="padding:8px 0;color:#666;"><strong>Phone:</strong></td>
                  <td style="padding:8px 0;color:#333;">${inspection.visited_by_phone || 'N/A'}</td>
                </tr>
                ${selfieHtml}
              </table>
            </div>

            <div style="padding:25px 30px;">
              <h3 style="margin:0 0 15px;color:#2C3E50;font-size:18px;">Inspection Details</h3>
              ${inspectionDetailsHTML}
            </div>

            <div style="background:#f8f9fa;padding:15px 30px;text-align:center;border-top:1px solid #e9ecef;">
              <p style="margin:0;color:#999;font-size:11px;">PDF report attached | Generated on ${new Date().toLocaleString('en-IN')}</p>
              <p style="margin:5px 0 0;color:#999;font-size:11px;">This is an auto-generated email. Please do not reply.</p>
            </div>

          </div>
        </body>
        </html>`,
      attachments
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('Email sent successfully:', info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Email sending error:', error);
    throw error;
  }
};


const sendTodaysInspectionsEmail = async (inspections, recipientEmail) => {
  try {
    if (!inspections || inspections.length === 0) {
      return { success: false, message: 'No inspections found' };
    }

  
    const groups = {};
    inspections.forEach((inspection) => {
      const city    = typeof inspection.location === 'string'
                        ? inspection.location
                        : (inspection.location && (inspection.location || inspection.location)) || 'Unknown';
      const visitor = inspection.visited_by || 'Unknown';
      const key     = `${city}|||${visitor}`;
      if (!groups[key]) groups[key] = { city, visitor, ids: [] };
      groups[key].ids.push(inspection._id.toString());
    });

      const today = new Date();

            const formattedDate = today.toLocaleDateString('en-GB', {
                day: '2-digit',
                month: 'long',
                year: 'numeric'
            }).replace(/ /g, '-');

    let groupRowsHTML = '';
    let rowIndex = 1;

    Object.values(groups).forEach((group) => {
      const idsParam = encodeURIComponent(group.ids.join(','));
      const bothLink = `${BASE_URL}/api/admin/inspection/zip/both?ids=${idsParam}`;

      groupRowsHTML += `
        <tr style="background: ${rowIndex % 2 === 0 ? '#f9f9f9' : '#ffffff'};">
          <td style="padding:12px 14px;border-bottom:1px solid #e0e0e0;text-align:center;font-family:Arial,sans-serif;font-size:14px;color:#555;">${rowIndex++}</td>
          <td style="padding:12px 14px;border-bottom:1px solid #e0e0e0;font-family:Arial,sans-serif;font-size:14px;color:#2C3E50;font-weight:600;">${group.city}</td>
          <td style="padding:12px 14px;border-bottom:1px solid #e0e0e0;font-family:Arial,sans-serif;font-size:14px;color:#555;">${group.visitor}</td>
          <td style="padding:12px 14px;border-bottom:1px solid #e0e0e0;text-align:center;font-family:Arial,sans-serif;font-size:14px;color:#555;">${group.ids.length}</td>
          <td style="padding:12px 14px;border-bottom:1px solid #e0e0e0;text-align:center;">
            <a href="${bothLink}" target="_blank"
               style="background:linear-gradient(135deg,#e67e22 0%,#27ae60 100%);color:white;padding:8px 18px;text-decoration:none;border-radius:5px;display:inline-block;font-size:13px;font-family:Arial,sans-serif;font-weight:bold;">
              📥 Download ZIP
            </a>
            <div style="margin-top:5px;font-size:11px;color:#888;font-family:Arial,sans-serif;">PDF &amp; Excel</div>
          </td>
        </tr>`;
    });

    const mailOptions = {
      from: process.env.EMAIL_USER,
      to: recipientEmail,
      subject: `Today's Unipole Inspection Reports - ${formattedDate}`,
      html: `
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"><title>Daily Inspection Reports</title></head>
        <body style="font-family:Arial,sans-serif;background:#f4f6f8;margin:0;padding:20px;">
          <div style="max-width:800px;margin:0 auto;background:white;border-radius:10px;overflow:hidden;box-shadow:0 4px 12px rgba(0,0,0,0.1);">
            <div style="background:#2C3E50;color:white;padding:24px 32px;">
              <h2 style="margin:0;font-size:20px;">Daily Inspection Reports</h2>
              <p style="margin:6px 0 0;opacity:0.75;font-size:13px;">
                ${new Date().toLocaleDateString('en-IN', { weekday:'long', year:'numeric', month:'long', day:'numeric' })}
              </p>
            </div>
            <div style="padding:32px;">
              <p style="font-size:14px;color:#333;">Dear Admin,</p>
              <p style="font-size:14px;color:#555;margin-bottom:24px;">
                Please find below today's grouped inspection reports. Click <strong>📥 Download ZIP</strong> to download both PDF and Excel files together.
              </p>
              <table style="width:100%;border-collapse:collapse;font-size:14px;border:1px solid #e0e0e0;">
                <thead>
                  <tr style="background:#34495E;color:white;">
                    <th style="padding:12px 14px;text-align:center;width:50px;">No.</th>
                    <th style="padding:12px 14px;text-align:left;">Location</th>
                    <th style="padding:12px 14px;text-align:left;">Inspector</th>
                    <th style="padding:12px 14px;text-align:center;width:80px;">Reports</th>
                    <th style="padding:12px 14px;text-align:center;width:160px;">Download</th>
                  </tr>
                </thead>
                <tbody>${groupRowsHTML}</tbody>
              </table>
              <div style="background:#f0f7ff;padding:14px 18px;border-left:4px solid #3498db;margin:24px 0;border-radius:0 6px 6px 0;">
                <p style="margin:0;color:#555;font-size:13px;line-height:1.7;">
                  <strong>📄 PDF ZIP</strong> — Inspection reports with photos<br>
                  <strong>📊 Excel ZIP</strong> — Inspection data in spreadsheet format<br>
                  <em style="color:#888;">Both files download automatically when you click the button.</em>
                </p>
              </div>
              <hr style="border:none;border-top:1px solid #eee;margin:20px 0;">
              <p style="color:#aaa;font-size:12px;text-align:center;margin:0;">
                Auto-generated by Unipole Inspection System &nbsp;|&nbsp; ${new Date().toLocaleString('en-IN')}
              </p>
            </div>
          </div>
        </body>
        </html>`
    };

    const info = await transporter.sendMail(mailOptions);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('Summary email sending error:', error);
    throw error;
  }
};

module.exports = { sendInspectionEmail, sendTodaysInspectionsEmail };
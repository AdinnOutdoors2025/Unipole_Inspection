
const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');
require('dotenv').config();


const QUESTIONS = {
  foundation: {
    concrete_cracks: { en: 'Concrete Crack', ta: 'கான்கிரீட்டில் பிளவு இருக்கிறதா' },
    soil_erosion_at_foundation: { en: 'Soil Erosion at Foundation', ta: 'அடித்தளத்தில் மண் சரிவு இருக்கிறதா' },
    water_stagnation: { en: 'Water Stagnation', ta: 'தண்ணீர் தேக்கம் இருக்கிறதா' },
    anchor_bolt_looseness: { en: 'Anchor Bolt Looseness', ta: 'அங்கர் போல்ட் தளர்வு இருக்கிறதா' },
    anchor_bolts_rusted: { en: 'Anchor Bolt Rusted', ta: 'அங்கர் போல்ட் ஜங்க் ஆகி இருக்கிறதா' },
    base_plate_properly_seated: { en: 'Base Plate Properly Seated', ta: 'பேஸ் பிளேட் சரியாக அமர்ந்துள்ளதா' },
    gap_in_base_plate: { en: 'Gap in Base Plate', ta: 'பேஸ் பிளேட்டில் இடைவெளி இருக்கிறதா' },
    grouting_damaged: { en: 'Grouting Damaged', ta: 'கிரௌட்டிங் சேதமடைந்துள்ளதா' },
    foundation_tilted: { en: 'Foundation Tilted', ta: 'அடித்தளம் சாய்வு இருக்கிறதா' },
    foundation_settlement_occurred: { en: 'Foundation Settlement Occurred', ta: 'அடித்தளம் அமர்வு ஏற்பட்டுள்ளதா' },
    surrounding_soil_loose: { en: 'Surrounding Soil Loose', ta: 'சுற்றியுள்ள மண் தளர்ந்துள்ளதா' }
  },
  post: {
    post_straight: { en: 'Post Straight', ta: 'கம்பம் நேராக உள்ளதா' },
    post_tilted: { en: 'Post Tilted', ta: 'கம்பத்தில் சாய்வு இருக்கிறதா' },
    bend_in_post: { en: 'Bend in Post', ta: 'கம்பத்தில் வளைவு இருக்கிறதா' },
    crack_in_welded_joint: { en: 'Crack in Welded Joint', ta: 'வெல்டிங் இணைப்பில் பிளவு இருக்கிறதா' },
    damage_in_welded_joint: { en: 'Damage in Welded Joint', ta: 'வெல்டிங் இணைப்பில் சேதம் இருக்கிறதா' },
    rust_present: { en: 'Rust Present', ta: 'ஜங்க் ஏற்பட்டுள்ளதா' },
    paint_peeled_off: { en: 'Paint Peeled Off', ta: 'பெயிண்ட் உரிந்து போயுள்ளதா' },
    post_thickness_reduced: { en: 'Post Thickness Reduced', ta: 'கம்பத்தின் தடிமன் குறைந்துள்ளதா' },
    flange_bolts_tight: { en: 'Flange Bolts Tight', ta: 'ஃபிளேஞ்ச் போல்ட் இறுக்கமாக உள்ளதா' },
    flange_nuts_loose: { en: 'Flange Nuts Loose', ta: 'ஃபிளேஞ்ச் நட் தளர்வு இருக்கிறதா' },
    ladder_secure: { en: 'Ladder Secure', ta: 'ஏணி பாதுகாப்பாக உள்ளதா' },
    platform_strong: { en: 'Platform Strong', ta: 'மேடை வலுவாக உள்ளதா' }
  },
  ad_board_frame: {
    frame_straight: { en: 'Frame Straight', ta: 'கட்டமைப்பு நேராக உள்ளதா' },
    bend_in_frame: { en: 'Bend in Frame', ta: 'கட்டமைப்பில் வளைவு இருக்கிறதா' },
    angle_pipe_members_strong: { en: 'Angle/Pipe Members Strong', ta: 'ஆங்கிள் / பைப் வலுவாக உள்ளதா' },
    welded_joints_strong: { en: 'Welded Joints Strong', ta: 'வெல்டிங் இணைப்பு வலுவாக உள்ளதா' },
    flex_properly_fixed: { en: 'Flex Properly Fixed', ta: 'ஃப்ளெக்ஸ் நன்றாக பொருத்தப்பட்டுள்ளதா' },
    flex_loose: { en: 'Flex Loose', ta: 'ஃப்ளெக்ஸ் தளர்வு இருக்கிறதா' },
    clamps_tight: { en: 'Clamps Tight', ta: 'கிளாம்ப் இறுக்கமாக உள்ளதா' },
    fasteners_loose: { en: 'Fasteners Loose', ta: 'ஃபாஸ்டனர் தளர்வு இருக்கிறதா' },
    vibration_due_to_wind: { en: 'Vibration Due to Wind', ta: 'காற்றால் அதிர்வு இருக்கிறதா' },
    water_seepage: { en: 'Water Seepage', ta: 'தண்ணீர் சுரந்து வருகிறதா' }
  },
  general_inspection: {
    surrounding_area_safe: { en: 'Surrounding Area Safe', ta: 'சுற்றுப்புறம் பாதுகாப்பாக உள்ளதா' },
    nearby_trees_touching_structure: { en: 'Nearby Trees Touching Structure', ta: 'அருகில் மரங்கள் தொட்டுக்கொள்கிறதா' },
    obstructions_present: { en: 'Obstructions Present', ta: 'தடைகள் இருக்கிறதா' },
    wind_damage: { en: 'Wind Damage', ta: 'காற்று சேதம் இருக்கிறதா' },
    rain_damage: { en: 'Rain Damage', ta: 'மழை சேதம் இருக்கிறதா' },
    unauthorized_modifications: { en: 'Unauthorized Modifications', ta: 'அனுமதியில்லாத மாற்றங்கள் உள்ளதா' },
    repairs_carried_out_properly: { en: 'Repairs Carried Out Properly', ta: 'பழுது பார்த்தல் சரியாக செய்யப்பட்டுள்ளதா' }
  }
};


const SECTIONS = ['foundation', 'post', 'ad_board_frame', 'general_inspection'];

const sectionNames = {
  foundation: 'Foundation',
  post: 'Post',
  ad_board_frame: 'Ad Board Frame',
  general_inspection: 'General Safety'
};

const sectionNamesTa = {
  foundation: 'அடித்தளம்',
  post: 'கம்பம்',
  ad_board_frame: 'விளம்பர பலகை சட்டம்',
  general_inspection: 'பொது பாதுகாப்பு'
};

const sectionColors = {
  foundation: '#3498DB',
  post: '#E74C3C',
  ad_board_frame: '#F39C12',
  general_inspection: '#27AE60'
};


const resolveLocation = (location) => {
  if (!location) return 'N/A';
  if (typeof location === 'string') return location;
  if (typeof location === 'object') {
    const loc = typeof location.toObject === 'function' ? location.toObject() : location;
    return [loc.address, loc.city, loc.state].filter(Boolean).join(', ')
      || (loc.coordinates ? `Lat: ${loc.coordinates[1]}, Lng: ${loc.coordinates[0]}` : 'N/A');
  }
  return 'N/A';
};

const formatVisitingDate = (dateStr) => {
  if (!dateStr) return 'N/A';
  const d = new Date(dateStr);
  if (isNaN(d)) return dateStr;
  return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })
    .toUpperCase().replace(/ /g, '/');
};

const normaliseQuestion = (dbSection, qKey) => {
  const raw = dbSection ? dbSection[qKey] : undefined;
  if (!raw || raw.status === null || raw.status === undefined) {
    return { status: false, images: [] };
  }
  return {
    status: raw.status === true,
    images: Array.isArray(raw.images) ? raw.images : []
  };
};

const buildSummaryRows = (inspection) => {
  let totTotal = 0, totYes = 0, totNo = 0, totPhotos = 0;

  const summaryRows = SECTIONS.map((section) => {
    const masterKeys = Object.keys(QUESTIONS[section]);
    const dbSection = inspection[section] || {};
    const yes = masterKeys.filter(k => normaliseQuestion(dbSection, k).status).length;
    const no = masterKeys.length - yes;
    const photos = masterKeys.reduce((s, k) => s + normaliseQuestion(dbSection, k).images.length, 0);
    totTotal += masterKeys.length;
    totYes += yes;
    totNo += no;
    totPhotos += photos;
    return { section, name: sectionNames[section], nameTa: sectionNamesTa[section], total: masterKeys.length, yes, no, photos };
  });

  return { summaryRows, totTotal, totYes, totNo, totPhotos };
};

const getInspectionStatusDisplay = (inspectionFlag) => {
  if (inspectionFlag === 'good') {
    return {
      text: 'GOOD / நல்ல நிலையில் உள்ளது',
      color: '#27AE60',
      bgColor: '#D5F5E3',
      borderColor: '#27AE60'
    };
  } else if (inspectionFlag === 'minor_issue') {
    return {
      text: 'MINOR ISSUE / சிறிய பிரச்சனை உள்ளது',
      color: '#F39C12',
      bgColor: '#FEF5E7',
      borderColor: '#F39C12'
    };
  } else if (inspectionFlag === 'critical') {
    return {
      text: 'CRITICAL / கடுமையான பிரச்சனை உள்ளது',
      color: '#E74C3C',
      bgColor: '#FDEDEC',
      borderColor: '#E74C3C'
    };
  }
  return {
    text: 'NOT SPECIFIED / குறிப்பிடப்படவில்லை',
    color: '#7F8C8D',
    bgColor: '#F0F0F0',
    borderColor: '#7F8C8D'
  };
};


const generatePDFBilingual = async (inspection) => {
  let browser;
  try {
    const uploadsDir = path.join(__dirname, 'pdf_reports');
    if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });

    const locationStr = resolveLocation(inspection.location);
    const visitingDateStr = inspection.visiting_date;
    const generatedDateStr = new Date()
      .toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })
      .toUpperCase().replace(/ /g, '-');
    const selfieUrl = inspection.selfie_image || null;
    const inspectionFlag = inspection.inspection_flag || 'good';
    const statusDisplay = getInspectionStatusDisplay(inspectionFlag);

    // ── Logo URL (used both in header and watermark) ──────────────────────────
    const logoUrl = 'https://frontend-roadshow-97ae.vercel.app/images/adinnlogo_withoutBackground.png';

    const { summaryRows, totTotal, totYes, totNo, totPhotos } = buildSummaryRows(inspection);

    // ── Q&A HTML ──────────────────────────────────────────────────────────────
    let qaHtml = '';
    let questionNumber = 1;

    for (const section of SECTIONS) {
      const masterKeys = Object.keys(QUESTIONS[section]);
      const dbSection = inspection[section] || {};
      const color = sectionColors[section];

      qaHtml += `
        <div class="section-header-wrap">
          <span class="section-header" style="background:${color};">
            <span class="sec-en">${sectionNames[section]}</span>
            <span class="sec-sep"> / </span>
            <span class="sec-ta">${sectionNamesTa[section]}</span>
          </span>
        </div>`;

      for (const qKey of masterKeys) {
        const qData = normaliseQuestion(dbSection, qKey);
        const qLabels = QUESTIONS[section][qKey];
        const isYes = qData.status;
        const ansColor = isYes ? '#27AE60' : '#E74C3C';
        const ansEn = isYes ? 'Yes' : 'No';
        const ansTa = isYes ? 'ஆம்' : 'இல்லை';
        const images = qData.images;

        let photosHtml = '';
        if (images.length > 0) {
          const boxes = images.map((url, i) =>
            `<div class="photo-box"><img src="${url}" alt="Photo ${i + 1}"></div>`
          );
          const rows = [];
          for (let i = 0; i < boxes.length; i += 5) rows.push(boxes.slice(i, i + 5));
          photosHtml = `
            <div class="photos-section">
              <div class="photos-label"> ${images.length} Photo(s)</div>
              ${rows.map(r => `<div class="photos-row">${r.join('')}</div>`).join('')}
            </div>`;
        }

        qaHtml += `
          <div class="question-box" style="border-left:4px solid ${color};">
            <div class="question-header">
              <span class="q-num" style="color:${color};">Q${questionNumber}.</span>
              <span class="q-title-en">${qLabels.en}</span>
              <span class="q-sep"> / </span>
              <span class="q-title-ta">${qLabels.ta}</span>
            </div>
            <div class="answer-line">
              <span class="answer-label">Answer / விடை :</span>
              <span class="answer-value" style="color:${ansColor};">${ansEn} / ${ansTa}</span>
            </div>
            ${photosHtml}
          </div>`;

        questionNumber++;
      }
    }

    // ── Full HTML ─────────────────────────────────────────────────────────────
    const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Unipole Inspection Report</title>
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    body { font-family:'Segoe UI',Arial,sans-serif; line-height:1.5; color:#333; background:#fff; }

    /* ── WATERMARK ────────────────────────────────────────────────────── */
  /* ── WATERMARK ────────────────────────────────────────────────────── */

.watermark-wrap {
  position: fixed;
  top: 0; left: 0;
  width: 100%; height: 100%;
  pointer-events: none;
  z-index: 0;
}
.watermark-cell {
  position: absolute;
}
.watermark-img {
  width: 180px;
  opacity: 0.05;
  transform: rotate(-30deg);
  filter: grayscale(100%) contrast(2);
}


    /* All body children sit above the watermark */
    body > *:not(.watermark-wrap) {
      position: relative;
      z-index: 1;
    }
    /* ── END WATERMARK ────────────────────────────────────────────────── */

    .logo-container { text-align:end; margin-bottom:16px; padding-top:20px; }
    .logo { max-width:180px; height:auto; }

    .title { background:#2C3E50; color:white; padding:24px 30px; text-align:center; margin-bottom:20px; }
    .title h1 { font-size:24px; letter-spacing:1px; margin-bottom:6px; }
    .title .ta-title { font-size:13px; opacity:0.85; }

    /* ── HEADER STRIP (red + dark) ────────────────────────────────────── */
    .brand-strip {
      display: flex;
      align-items: stretch;
      margin-bottom: 20px;
      border-radius: 4px;
      overflow: hidden;
    }
    .brand-strip .red-bar {
      background: #C0392B;
      width: 8px;
      flex-shrink: 0;
    }
    .brand-strip .title-block {
      background: #2C3E50;
      flex: 1;
      padding: 18px 24px;
      text-align: center;
    }
    .brand-strip .title-block h1 {
      color: #fff;
      font-size: 22px;
      letter-spacing: 1px;
      margin-bottom: 4px;
    }
    .brand-strip .title-block .ta-title {
      color: rgba(255,255,255,0.8);
      font-size: 12px;
    }

    .visiting-details { background:#F0F4F7; border:1px solid #C8D6E5; border-radius:6px; padding:16px 20px; margin-bottom:20px; }
    .vd-heading { font-size:13px; font-weight:bold; color:#2C3E50; border-bottom:1px solid #C8D6E5; padding-bottom:8px; margin-bottom:14px; }
    .vd-heading .ta { font-size:11px; color:#555; font-weight:normal; margin-left:6px; }
    .vd-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px 24px; }
    .vd-item { display:flex; flex-direction:column; gap:2px; }
    .vd-label { font-size:10px; font-weight:bold; color:#7F8C8D; text-transform:uppercase; letter-spacing:0.4px; }
    .vd-value { font-size:12px; color:#2C3E50; font-weight:600; }
    .selfie-img { width:110px; height:80px; object-fit:cover; border:1px solid #ccc; border-radius:4px; margin-top:4px; }

    .summary { margin-bottom:26px; }
    .summary-heading { background:#34495E; color:white; padding:10px 15px; font-size:13px; font-weight:bold; border-radius:4px 4px 0 0; }
    .summary-heading .ta { font-size:11px; font-weight:normal; margin-left:6px; opacity:0.85; }
    .summary table { width:100%; border-collapse:collapse; }
    .summary thead th { background:#4A6278; color:white; padding:8px 10px; font-size:11px; text-align:left; border:1px solid #3d5166; }
    .summary thead th .ta { font-size:10px; font-weight:normal; display:block; margin-top:2px; }
    .summary tbody td { padding:8px 10px; border:1px solid #ddd; font-size:12px; }
    .summary tbody tr:nth-child(even) { background:#f4f8fb; }
    .summary tbody tr.total-row { background:#D5EEF8; font-weight:bold; }

    /* ── STATUS BADGE ─────────────────────────────────────────────────── */


     .status-container { margin-top:15px; display:flex; justify-content:flex-start; }
    .status-badge { display:inline-flex; padding:10px 20px; border-radius:6px; font-weight:bold; font-size:14px; gap:10px; }
    .status-badge .en { }
     .status-badge .ta { font-weight:normal; }

    .section-header-wrap { margin:22px 0 10px 0; }
    .section-header { color:white; padding:10px 14px; border-radius:4px; font-size:14px; font-weight:bold; display:inline-block; }
    .sec-sep { opacity:0.7; margin:0 5px; }
    .sec-ta { font-size:12px; font-weight:normal; opacity:0.9; }

    .question-box { background:#F8F9FA; border:1px solid #E0E0E0; border-radius:4px; padding:12px 14px; margin-bottom:8px; break-inside:avoid; page-break-inside:avoid; }
    .question-header { margin-bottom:6px; line-height:1.4; }
    .q-num { font-weight:bold; font-size:13px; margin-right:4px; }
    .q-title-en { font-weight:bold; font-size:13px; color:#2C3E50; }
    .q-sep { color:#aaa; margin:0 4px; }
    .q-title-ta { font-size:12px; color:#555; }
    .answer-line { display:flex; align-items:center; gap:8px; margin-top:4px; }
    .answer-label { font-size:11px; font-weight:bold; color:#7F8C8D; }
    .answer-value { font-size:13px; font-weight:bold; }

    .photos-section { margin-top:10px; }
    .photos-label { font-size:11px; font-weight:bold; color:#666; margin-bottom:6px; }
    .photos-row { display:grid; grid-template-columns:repeat(5,1fr); gap:6px; margin-bottom:6px; break-inside:avoid; page-break-inside:avoid; }
    .photo-box { width:100%; aspect-ratio:1; background:#e8e8e8; border:1px solid #ccc; border-radius:3px; overflow:hidden; display:flex; align-items:center; justify-content:center; }
    .photo-box img { width:100%; height:100%; object-fit:cover; display:block; }

    /* ── FOOTER ───────────────────────────────────────────────────────── */
    .footer {
      margin-top: 30px;
      padding: 14px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      border-top: 2px solid #C0392B;
      font-size: 10px;
      color: #666;
    }
    .footer .footer-logo { max-width: 80px; height: auto; opacity: 0.7; }
    .footer .footer-right { text-align: right; }
  </style>
</head>
<body>

  <!-- ════════════════════════════════════════════════
       WATERMARK — fixed behind all content on every page
       ════════════════════════════════════════════════ -->




<div class="watermark-wrap">
  <!-- Top Left -->
  <div class="watermark-cell" style="top:1%; left:5%;">
    <img class="watermark-img" src="${logoUrl}" alt="">
  </div>

    <div class="watermark-cell" style="top:3%; right:20%;">
    <img class="watermark-img" src="${logoUrl}" alt="">
  </div>


 

  <!-- Center Middle -->
  <div class="watermark-cell" style="top:50%; left:50%; transform:translate(-50%,-50%);">
    <img class="watermark-img" src="${logoUrl}" alt="">
  </div>



  <!-- Bottom Right -->
  <div class="watermark-cell" style="bottom:5%; right:5%;">
    <img class="watermark-img" src="${logoUrl}" alt="">
  </div>

  <!-- Bottom Left -->
  <div class="watermark-cell" style="bottom:1%; left:5%;">
    <img class="watermark-img" src="${logoUrl}" alt="">
  </div>
</div>



  <!-- Logo -->
  <div class="logo-container">
    <img class="logo" src="${logoUrl}" alt="Ad inn Advertising Services Ltd.">
  </div>

  <!-- Title strip with red accent bar -->
  <div class="brand-strip">
    <div class="red-bar"></div>
    <div class="title-block">
      <h1>UNIPOLE STABILITY INSPECTION REPORT</h1>
      <div class="ta-title">யூனிபோல் நிலைத்தன்மை ஆய்வு அறிக்கை</div>
    </div>
    <div class="red-bar"></div>
  </div>

  <!-- Visiting details -->
  <div class="visiting-details">
    <div class="vd-heading">VISITING DETAILS / <span class="ta">வருகை தகவல்கள்</span></div>
    <div class="vd-grid">
      <div class="vd-item">
        <span class="vd-label">Location / இடம்</span>
        <span class="vd-value">${locationStr}</span>
      </div>
      <div class="vd-item">
        <span class="vd-label">Unipole Height / உயரம்</span>
        <span class="vd-value">${inspection.unipole_height || 'N/A'}</span>
      </div>
      <div class="vd-item">
        <span class="vd-label">Visited By / பார்வையிட்டவர்</span>
        <span class="vd-value">${inspection.visited_by || 'N/A'}</span>
      </div>
      <div class="vd-item">
        <span class="vd-label">Ad Structure Size / அளவு</span>
        <span class="vd-value">${inspection.ad_structure_size || 'N/A'}</span>
      </div>
      <div class="vd-item">
        <span class="vd-label">Visiting Date / வருகை தேதி</span>
        <span class="vd-value">${visitingDateStr}</span>
      </div>
      <div class="vd-item">
        <span class="vd-label">Phone / தொலைபேசி</span>
        <span class="vd-value">${inspection.visited_by_phone || 'N/A'}</span>
      </div>
      ${selfieUrl ? `
      <div class="vd-item">
        <span class="vd-label">Selfie / செல்ஃபி</span>
        <img class="selfie-img" src="${selfieUrl}" alt="Selfie">
      </div>` : ''}
    </div>
  </div>

  <!-- Summary table -->
  <div class="summary">
    <div class="summary-heading">
      INSPECTION SUMMARY / <span class="ta">பரிசோதனை சுருக்கம்</span>
    </div>
    <table>
      <thead>
        <tr>
          <th>Sections <span class="ta">பிரிவுகள்</span></th>
          <th>Total Questions <span class="ta">மொத்த கேள்விகள்</span></th>
          <th>Yes <span class="ta">ஆம்</span></th>
          <th>No <span class="ta">இல்லை</span></th>
          <th>Photos <span class="ta">புகைப்படங்கள்</span></th>
        </tr>
      </thead>
      <tbody>
        ${summaryRows.map(row => `
        <tr>
          <td>${row.name} / ${row.nameTa}</td>
          <td>${row.total}</td>
          <td>${row.yes}</td>
          <td>${row.no}</td>
          <td>${row.photos}</td>
        </tr>`).join('')}
        <tr class="total-row">
          <td>TOTAL / மொத்தம்</td>
          <td>${totTotal}</td>
          <td>${totYes}</td>
          <td>${totNo}</td>
          <td>${totPhotos}</td>
        </tr>
      </tbody>
    </table>

    <!-- Status badge -->
    <div class="status-container">
     <div class="status-badge" style="background:${statusDisplay.bgColor}; border:1px solid ${statusDisplay.color};">
         <span class="en" style="color:${statusDisplay.color};">INSPECTION STATUS: ${statusDisplay.text.split(' / ')[0]}</span> /
         <span class="ta" style="color:${statusDisplay.color};">ஆய்வு நிலை: ${statusDisplay.text.split(' / ')[1]}</span>
      </div>
 </div>
  </div>

  <!-- Q&A sections -->
  ${qaHtml}

  <!-- Footer with logo + date -->
  <div class="footer">
  
    <div class="footer-right">
      Generated on / உருவாக்கப்பட்ட தேதி: ${generatedDateStr}<br>
      Ad inn Advertising Services Ltd.
    </div>
      <img class="footer-logo" src="${logoUrl}" alt="Ad inn">
  </div>

</body>
</html>`;

    // ── Puppeteer render ──────────────────────────────────────────────────────
    browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    await page.setContent(html, { waitUntil: 'networkidle0' });

    const fileName = `inspection_${inspection._id}_${Date.now()}.pdf`;
    const filePath = path.join(uploadsDir, fileName);

    await page.pdf({
      path: filePath,
      format: 'A4',
      margin: { top: '0.5in', right: '0.5in', bottom: '0.5in', left: '0.5in' },
      printBackground: true
    });

    await browser.close();
    console.log(` PDF generated: ${filePath}`);
    return filePath;

  } catch (error) {
    if (browser) await browser.close();
    throw error;
  }
};

module.exports = { generatePDFBilingual };
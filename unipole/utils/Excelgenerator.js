


const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');

const MONTHS = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];

const formatDateForFilename = (dateStr) => {
  const d = new Date(dateStr);
  if (isNaN(d)) return dateStr || 'unknown';
  return `${String(d.getDate()).padStart(2,'0')}-${MONTHS[d.getMonth()]}-${d.getFullYear()}`;
};

const formatDate = formatDateForFilename;

const formatVisitingDate = (dateStr) => {
  if (!dateStr) return 'N/A';
  const d = new Date(dateStr);
  if (isNaN(d)) return dateStr;
  return `${String(d.getDate()).padStart(2,'0')}-${MONTHS[d.getMonth()]}-${d.getFullYear()}`;
};

const resolveLocation = (location) => {
  if (!location) return 'N/A';
  if (typeof location === 'string') return location;
  if (typeof location === 'object') {
    const loc = typeof location.toObject === 'function' ? location.toObject() : location;
    return [loc.address, loc.city, loc.state, loc.country].filter(Boolean).join(', ')
      + (loc.pincode ? ' - ' + loc.pincode : '');
  }
  return 'N/A';
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


const SECTIONS = ['foundation', 'post', 'ad_board_frame', 'general_inspection'];

const SECTION_TITLES = {
  foundation:         'Foundation',
  post:               'Post',
  ad_board_frame:     'Ad Board Frame',
  general_inspection: 'General Safety'
};

const SECTION_TITLES_TAMIL = {
  foundation:         'அடித்தளம்',
  post:               'கம்பம்',
  ad_board_frame:     'விளம்பர பலகை சட்டம்',
  general_inspection: 'பொது பாதுகாப்பு'
};


const QUESTION_LABELS = {
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

const SECTION_COLORS = {
  foundation:         'FF3498DB',
  post:               'FFE74C3C',
  ad_board_frame:     'FFF39C12',
  general_inspection: 'FF27AE60'
};



const applyHeader = (cell, text, bgArgb = 'FF2C3E50', fontSize = 11) => {
  cell.value = text;
  cell.font  = { bold: true, size: fontSize, color: { argb: 'FFFFFFFF' }, name: 'Arial' };
  cell.fill  = { type: 'pattern', pattern: 'solid', fgColor: { argb: bgArgb } };
  cell.alignment = { horizontal: 'center', vertical: 'middle', wrapText: true };
};

const applyLabel = (cell, text) => {
  cell.value = text;
  cell.font  = { bold: true, size: 10, name: 'Arial', color: { argb: 'FF2C3E50' } };
  cell.fill  = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFF0F0F0' } };
  cell.alignment = { vertical: 'middle', indent: 1, wrapText: true };
};

const applyValue = (cell, text) => {
  cell.value = text ?? '';
  cell.font  = { size: 10, name: 'Arial' };
  cell.alignment = { vertical: 'middle', wrapText: true, indent: 1 };
};

const thinBorder = { style: 'thin', color: { argb: 'FFD0D0D0' } };
const allBorders = { top: thinBorder, left: thinBorder, bottom: thinBorder, right: thinBorder };
const setBorders = (row, cols) => cols.forEach(c => { row.getCell(c).border = allBorders; });


const autoFitColumns = (ws) => {
  ws.columns.forEach(column => {
    let maxLength = 0;
    column.eachCell({ includeEmpty: true }, (cell) => {
      const cellValue = cell.value ? cell.value.toString() : '';
      maxLength = Math.max(maxLength, cellValue.length);
    });
    column.width = Math.min(Math.max(maxLength + 2, 10), 60);
  });
};

const getInspectionStatusDisplay = (inspectionFlag) => {
  if (inspectionFlag === 'good') {
    return {
      text: 'GOOD / நல்ல நிலையில் உள்ளது',
      color: 'FF27AE60',
      bgColor: 'FFD5F5E3'
    };
  } else if (inspectionFlag === 'minor_issue') {
    return {
      text: 'MINOR ISSUE / சிறிய பிரச்சனை உள்ளது',
      color: 'FFF39C12',
      bgColor: 'FFFEF5E7'
    };
  } else if (inspectionFlag === 'critical') {
    return {
      text: 'CRITICAL / கடுமையான பிரச்சனை உள்ளது',
      color: 'FFE74C3C',
      bgColor: 'FFFDEDEC'
    };
  }

  return {
    text: 'NOT SPECIFIED / குறிப்பிடப்படவில்லை',
    color: 'FF7F8C8D',
    bgColor: 'FFF0F0F0'
  };
};



const buildSiteAndSummarySheet = (wb, inspection) => {
  const ws = wb.addWorksheet('Site Details');
  
 
  ws.columns = [{ width: 35 }, { width: 55 }];

  ws.mergeCells('A1:B1');
  ws.getRow(1).height = 40;
  applyHeader(ws.getCell('A1'), 'UNIPOLE STABILITY INSPECTION REPORT / யூனிபோல் நிலைத்தன்மை ஆய்வு அறிக்கை', 'FF2C3E50', 12);
  ws.addRow([]);

  ws.mergeCells('A3:B3');
  ws.getRow(3).height = 22;
  applyHeader(
    ws.getCell('A3'),
    'VISITING DETAILS / வருகை தகவல்கள்',
    'FF34495E',
    11
  );
  ws.getCell('A3').alignment = { horizontal: 'left', vertical: 'middle', indent: 1 };

  const siteRows = [
    ['Location / இடம்', resolveLocation(inspection.location)],
    ['Unipole Height / உயரம்', inspection.unipole_height || '—'],
    ['Ad Structure Size / அளவு', inspection.ad_structure_size || '—'],
    ['Visiting Date / வருகை தேதி', formatVisitingDate(inspection.visiting_date)],
    ['Visited By / பார்வையிட்டவர்', inspection.visited_by || '—'],
    ['Phone / தொலைபேசி', inspection.visited_by_phone || '—'],
    ['Selfie Photo / செல்ஃபி', inspection.selfie_image || 'No Photo / புகைப்படம் இல்லை']
  ];

  siteRows.forEach(([label, value]) => {
    const r = ws.addRow([label, value]);
    r.height = 20;
    applyLabel(r.getCell('A'), label);
    applyValue(r.getCell('B'), value);
    setBorders(r, ['A', 'B']);
  });

  ws.addRow([]);
  ws.addRow([]);

  const summaryTitleRow = ws.addRow([]);
  ws.mergeCells(`A${summaryTitleRow.number}:E${summaryTitleRow.number}`);
  summaryTitleRow.height = 22;
  applyHeader(summaryTitleRow.getCell('A'), 'INSPECTION SUMMARY / பரிசோதனை சுருக்கம்', 'FF34495E', 11);
  summaryTitleRow.getCell('A').alignment = { horizontal: 'left', vertical: 'middle', indent: 1 };
  ws.addRow([]);

  // Reset columns for summary table
  ws.columns = [{ width: 35 }, { width: 18 }, { width: 12 }, { width: 12 }, { width: 20 }];

  const hdr = ws.addRow([
    'Sections / பிரிவுகள்',
    'Total Questions / மொத்த கேள்விகள்',
    'Yes / ஆம்',
    'No / இல்லை',
    'Photos / புகைப்படங்கள்'
  ]);
  hdr.height = 22;
  ['A', 'B', 'C', 'D', 'E'].forEach(c => {
    applyHeader(hdr.getCell(c), hdr.getCell(c).value, 'FF34495E', 10);
    hdr.getCell(c).border = allBorders;
  });

  let totTotal = 0, totYes = 0, totNo = 0, totPhotos = 0;

  SECTIONS.forEach((section, i) => {
    const masterKeys = Object.keys(QUESTION_LABELS[section]);
    const dbSection = inspection[section] || {};
    const yes = masterKeys.filter(k => normaliseQuestion(dbSection, k).status).length;
    const no = masterKeys.length - yes;
    const photos = masterKeys.reduce((s, k) => s + normaliseQuestion(dbSection, k).images.length, 0);

    totTotal += masterKeys.length;
    totYes += yes;
    totNo += no;
    totPhotos += photos;

    const bg = i % 2 === 0 ? 'FFFFFFFF' : 'FFF8F9FA';
    const r = ws.addRow([`${SECTION_TITLES[section]} / ${SECTION_TITLES_TAMIL[section]}`, masterKeys.length, yes, no, photos]);
    r.height = 18;
    ['A', 'B', 'C', 'D', 'E'].forEach(c => {
      r.getCell(c).font = { size: 10, name: 'Arial' };
      r.getCell(c).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: bg } };
      r.getCell(c).alignment = { horizontal: c === 'A' ? 'left' : 'center', vertical: 'middle', indent: c === 'A' ? 1 : 0 };
      r.getCell(c).border = allBorders;
    });
    r.getCell('C').font = { bold: true, size: 10, name: 'Arial', color: { argb: 'FF27AE60' } };
    r.getCell('D').font = { bold: true, size: 10, name: 'Arial', color: { argb: 'FFE74C3C' } };
  });

  const tot = ws.addRow(['TOTAL / மொத்தம்', totTotal, totYes, totNo, totPhotos]);
  tot.height = 22;
  ['A', 'B', 'C', 'D', 'E'].forEach(c => {
    tot.getCell(c).font = { bold: true, size: 10, name: 'Arial' };
    tot.getCell(c).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD5EEF8' } };
    tot.getCell(c).alignment = { horizontal: c === 'A' ? 'left' : 'center', vertical: 'middle', indent: c === 'A' ? 1 : 0 };
    tot.getCell(c).border = { top: { style: 'medium', color: { argb: 'FF2C3E50' } }, left: thinBorder, bottom: thinBorder, right: thinBorder };
  });


  const inspectionFlag = inspection.inspection_flag || 'good';
  const statusDisplay = getInspectionStatusDisplay(inspectionFlag);

  ws.addRow([]);
  const statusRow = ws.addRow(['', '', '', '', '']);
  statusRow.height = 30;
  
  
  ws.mergeCells(`A${statusRow.number}:C${statusRow.number}`);
  const statusCell = statusRow.getCell('A');
  statusCell.value = `INSPECTION STATUS: ${statusDisplay.text.split(' / ')[0]} / ஆய்வு நிலை: ${statusDisplay.text.split(' / ')[1]}`;
  statusCell.font = { bold: true, size: 11, name: 'Arial', color: { argb: statusDisplay.color } };
  statusCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: statusDisplay.bgColor } };
  statusCell.alignment = { horizontal: 'center', vertical: 'middle' };
  statusCell.border = allBorders;
  

  statusRow.getCell('D').value = '';
  statusRow.getCell('E').value = '';

  const generatedDateStr = new Date().toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }).toUpperCase().replace(/ /g, '-');

  ws.addRow([]);
  const note = ws.addRow([`Generated on: ${generatedDateStr}`, '', '', '', '']);
  ws.mergeCells(`A${note.number}:E${note.number}`);
  note.getCell('A').font = { size: 9, italic: true, color: { argb: 'FF999999' }, name: 'Arial' };
  note.getCell('A').alignment = { horizontal: 'center' };
  
  
  autoFitColumns(ws);
};



const buildInspectionSheet = (wb, inspection) => {
  const ws = wb.addWorksheet('Inspection Details');
  

  ws.columns = [
    { width: 8 },
    { width: 30 },
    { width: 50 },
    { width: 18 },
    { width: 60 }
  ];

  ws.mergeCells('A1:E1');
  ws.getRow(1).height = 30;
  applyHeader(ws.getCell('A1'), 'INSPECTION DETAILS / ஆய்வு விவரங்கள்', 'FF2C3E50', 13);
  ws.addRow([]);

  const hdr = ws.addRow(['No.', 'Sections / பிரிவுகள்', 'Questions / கேள்விகள்', 'Answers / விடைகள்', 'Photos / புகைப்படங்கள்']);
  hdr.height = 22;
  ['A', 'B', 'C', 'D', 'E'].forEach(c => {
    applyHeader(hdr.getCell(c), hdr.getCell(c).value, 'FF34495E', 10);
    hdr.getCell(c).border = allBorders;
  });

  let qNo = 1;
  SECTIONS.forEach(section => {
    const masterKeys = Object.keys(QUESTION_LABELS[section]);
    const dbSection = inspection[section] || {};

    const secRow = ws.addRow([]);
    ws.mergeCells(`A${secRow.number}:E${secRow.number}`);
    secRow.height = 20;
    const sc = secRow.getCell('A');
    sc.value = `${SECTION_TITLES[section]} / ${SECTION_TITLES_TAMIL[section]}`;
    sc.font = { bold: true, size: 10, color: { argb: 'FFFFFFFF' }, name: 'Arial' };
    sc.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: SECTION_COLORS[section] } };
    sc.alignment = { horizontal: 'left', vertical: 'middle', indent: 1 };

    masterKeys.forEach((qKey, idx) => {
      const qData = normaliseQuestion(dbSection, qKey);
      const qLabels = QUESTION_LABELS[section][qKey];
      const questionText = `${qLabels.en} / ${qLabels.ta}`;
      const answer = qData.status ? 'Yes / ஆம்' : 'No / இல்லை';
      const images = qData.images;
      const imgDisplay = images.length === 0
        ? 'No Photo / புகைப்படம் இல்லை'
        : images.join('\n');

      const r = ws.addRow([qNo, `${SECTION_TITLES[section]} / ${SECTION_TITLES_TAMIL[section]}`, questionText, answer, imgDisplay]);
      r.height = images.length > 1 ? Math.max(18, 16 * images.length) : 18;

      const bgArgb = idx % 2 === 0 ? 'FFFFFFFF' : 'FFF9F9F9';
      ['A', 'B', 'C', 'D', 'E'].forEach(c => {
        r.getCell(c).font = { size: 10, name: 'Arial' };
        r.getCell(c).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: bgArgb } };
        r.getCell(c).alignment = { vertical: 'middle', horizontal: ['A', 'D'].includes(c) ? 'center' : 'left', wrapText: true, indent: c === 'C' ? 1 : 0 };
        r.getCell(c).border = allBorders;
      });
      r.getCell('D').font = { bold: true, size: 10, name: 'Arial', color: { argb: qData.status ? 'FF27AE60' : 'FFE74C3C' } };
      r.getCell('E').font = { size: 10, name: 'Arial', color: { argb: images.length > 0 ? 'FF2980B9' : 'FF95A5A6' } };
      qNo++;
    });
  });
  
 
  autoFitColumns(ws);
};



const generateExcel = async (inspection) => {
  const outputDir = path.join(__dirname, 'excel_reports');
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir, { recursive: true });

  const wb = new ExcelJS.Workbook();
  wb.creator = 'Unipole Inspection System';
  wb.created = new Date();

  buildSiteAndSummarySheet(wb, inspection);
  buildInspectionSheet(wb, inspection);

  const dateStr = formatDateForFilename(inspection.visiting_date);
  const fileName = `inspection_${inspection._id}_${dateStr}.xlsx`;
  const filePath = path.join(outputDir, fileName);
  await wb.xlsx.writeFile(filePath);
  console.log(`Excel generated: ${filePath}`);
  return filePath;
};

module.exports = { generateExcel, formatDate };
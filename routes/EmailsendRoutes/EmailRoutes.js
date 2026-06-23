
const express = require('express');
const router = express.Router();
const archiver = require('archiver');
const path = require('path');
const Inspection = require('../../models/inspectionForm');
const { generatePDFBilingual } = require('./../../utils/pdfGeneratorBilingual');
const { generateExcel, formatDate } = require('../../utils/Excelgenerator');
const { sendInspectionEmail, sendTodaysInspectionsEmail } = require('./../../utils/emailService');

const BASE_URL = process.env.BASE_URL || 'http://localhost:5000';


// Helper: build a clean ZIP filename


const buildZipName = (inspection, suffix) => {
  const city    = inspection.location;
  const visitor = inspection.visited_by;
  // const dateStr = formatDate(inspection.visiting_date);
   const dateStr = inspection.visiting_date;
  return `${city}_${visitor}_${dateStr}_${suffix}.zip`.replace(/\s+/g, '_');
};



const streamZip = (res, zipName, buildFn) => {
  res.setHeader('Content-Type', 'application/zip');
  res.setHeader('Content-Disposition', `attachment; filename="${zipName}"`);

  const archive = archiver('zip', { zlib: { level: 6 } });
  archive.on('error', (err) => {
    console.error('Archiver error:', err);
    res.destroy();
  });
  archive.pipe(res);
  return buildFn(archive).then(() => archive.finalize());
};


// Helper: parse + fetch inspections from ?ids=

const getInspectionsFromQuery = async (ids) => {
  if (!ids) throw Object.assign(new Error('ids query param is required'), { status: 400 });
  const idList = ids.split(',').map(id => id.trim()).filter(Boolean);
  if (!idList.length) throw Object.assign(new Error('No valid IDs provided'), { status: 400 });
  const inspections = await Inspection.find({ _id: { $in: idList } });
  if (!inspections.length) throw Object.assign(new Error('No inspections found'), { status: 404 });
  return inspections;
};


router.post('/send-inspection-email/:id', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ success: false, message: 'Email address is required' });

    const inspection = await Inspection.findById(req.params.id);
    if (!inspection) return res.status(404).json({ success: false, message: 'Inspection not found' });

    const pdfPath = await generatePDFBilingual(inspection);
    await sendInspectionEmail(inspection, pdfPath, email);

    res.json({ success: true, message: `Inspection report sent to ${email}`, data: inspection });
  } catch (error) {
    console.error('Error sending inspection email:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});



router.post('/send-todays-inspections', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email address is required'
      });
    }

    const today = new Date();

    const formattedDate = today.toLocaleDateString('en-GB', {
      day: '2-digit',
      month: 'long',
      year: 'numeric'
    }).replace(/ /g, '-');

    const inspections = await Inspection.find({
      visiting_date: formattedDate
    });

    if (!inspections.length) {
      return res.json({
        success: true,
        message: 'No inspections found for today'
      });
    }

    await sendTodaysInspectionsEmail(inspections, email);

    res.json({
      success: true,
      message: `Email sent to ${email} with ${inspections.length} inspection report(s)`,
      sent: inspections.length
    });

  } catch (error) {
    console.error('Error sending inspections:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});



router.get('/inspection/zip', (req, res) => {
  const ids = req.query.ids || '';
  res.redirect(302, `/api/admin/inspection/zip/both?ids=${encodeURIComponent(ids)}`);
});


router.get('/inspection/zip/both', async (req, res) => {
  try {
    await getInspectionsFromQuery(req.query.ids);

    const idsParam    = encodeURIComponent(req.query.ids);
    const pdfZipUrl   = `${BASE_URL}/api/admin/inspection/zip/pdf?ids=${idsParam}`;
    const excelZipUrl = `${BASE_URL}/api/admin/inspection/zip/excel?ids=${idsParam}`;

    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.send(`<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Downloading Reports...</title>
  <style>
    *{margin:0;padding:0;box-sizing:border-box}
    body{font-family:Arial,sans-serif;background:#f4f6f8;display:flex;
         align-items:center;justify-content:center;min-height:100vh}
    .card{background:#fff;border-radius:10px;box-shadow:0 4px 16px rgba(0,0,0,.12);
          padding:40px 48px;max-width:460px;width:100%;text-align:center}
    .icon{font-size:52px;margin-bottom:16px}
    h2{color:#2C3E50;font-size:20px;margin-bottom:8px}
    p{color:#666;font-size:14px;margin-bottom:24px;line-height:1.6}
    .file-row{display:flex;align-items:center;background:#f8f9fa;border-radius:6px;
              padding:12px 16px;margin-bottom:10px;text-align:left}
    .file-icon{font-size:22px;margin-right:12px}
    .file-label{flex:1}
    .file-name{font-size:13px;font-weight:bold;color:#2C3E50}
    .file-type{font-size:11px;color:#888;margin-top:2px}
    .badge{font-size:12px;font-weight:bold;padding:4px 10px;border-radius:12px;
           background:#fff3cd;color:#856404}
    .badge.done{background:#d1e7dd;color:#0f5132}
    .manual{margin-top:24px;border-top:1px solid #eee;padding-top:20px}
    .manual p{font-size:12px;color:#999;margin-bottom:12px}
    .btn{display:inline-block;padding:9px 20px;border-radius:5px;text-decoration:none;
         font-size:13px;font-weight:bold;margin:4px}
    .btn-pdf{background:#e67e22;color:#fff}
    .btn-excel{background:#27ae60;color:#fff}
  </style>
</head>
<body>
<div class="card">
  <div class="icon"></div>
  <h2>Downloading Your Reports</h2>
  <p>Both files are downloading automatically.<br>Check your browser's download folder.</p>

  <div class="file-row">
    <span class="file-icon"></span>
    <div class="file-label">
      <div class="file-name">PDF Reports ZIP</div>
      <div class="file-type">Inspection reports with photos</div>
    </div>
    <span class="badge" id="s1"> Starting…</span>
  </div>

  <div class="file-row">
    <span class="file-icon"></span>
    <div class="file-label">
      <div class="file-name">Excel Reports ZIP</div>
      <div class="file-type">Inspection data spreadsheet</div>
    </div>
    <span class="badge" id="s2"> Starting…</span>
  </div>

  <div class="manual">
    <p>Downloads not starting? Click manually:</p>
    <a href="${pdfZipUrl}"   class="btn btn-pdf"   download> PDF ZIP</a>
    <a href="${excelZipUrl}" class="btn btn-excel" download> Excel ZIP</a>
  </div>
</div>
<script>
  function dl(url){ const a=document.createElement('a'); a.href=url; a.download=''; document.body.appendChild(a); a.click(); document.body.removeChild(a); }
  window.addEventListener('load',()=>{
    setTimeout(()=>{ dl('${pdfZipUrl}');   document.getElementById('s1').textContent=' Downloaded'; document.getElementById('s1').className='badge done'; }, 600);
    setTimeout(()=>{ dl('${excelZipUrl}'); document.getElementById('s2').textContent=' Downloaded'; document.getElementById('s2').className='badge done'; }, 1900);
  });
</script>
</body>
</html>`);
  } catch (err) {
    res.status(err.status || 500).json({ success: false, message: err.message });
  }
});



router.get('/inspection/zip/pdf', async (req, res) => {
  try {
    const inspections = await getInspectionsFromQuery(req.query.ids);
    const zipName     = buildZipName(inspections[0], 'PDF');

    await streamZip(res, zipName, async (archive) => {
      const usedNames = {};
      for (const inspection of inspections) {
        const pdfPath = await generatePDFBilingual(inspection);
        const city      = inspection.location;
        const base    = `${city}_${inspection.visited_by}_${inspection.visiting_date}`
                          .replace(/\s+/g, '_');
        usedNames[base] = (usedNames[base] || 0) + 1;
       const name = `${base}_#${usedNames[base]}.pdf`;
        archive.file(pdfPath, { name });
      }
    });
  } catch (err) {
    if (!res.headersSent) res.status(err.status || 500).json({ success: false, message: err.message });
  }
});

router.get('/inspection/zip/excel', async (req, res) => {
  try {
    const inspections = await getInspectionsFromQuery(req.query.ids);
    const zipName     = buildZipName(inspections[0], 'Excel');

    await streamZip(res, zipName, async (archive) => {
      const usedNames = {};
      for (const inspection of inspections) {
        const excelPath = await generateExcel(inspection);
        const city      = inspection.location;
        const base      = `${city}_${inspection.visited_by}_${inspection.visiting_date}`
                            .replace(/\s+/g, '_');
        usedNames[base] = (usedNames[base] || 0) + 1;
        const name = `${base}_#${usedNames[base]}.xlsx`;
        archive.file(excelPath, { name });
      }
    });
  } catch (err) {
    if (!res.headersSent) res.status(err.status || 500).json({ success: false, message: err.message });
  }
});






router.get('/inspection/:id/pdf', async (req, res) => {
  try {
    const inspection = await Inspection.findById(req.params.id);
    if (!inspection) return res.status(404).json({ success: false, message: 'Inspection not found' });

    const pdfPath = await generatePDFBilingual(inspection);
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'inline');
    res.sendFile(path.resolve(pdfPath));
  } catch (error) {
    console.error('Error serving PDF:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
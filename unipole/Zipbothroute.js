// =====================================================
// @route   GET /api/admin/inspection/zip/both?ids=id1,id2
// @desc    Returns an HTML page that auto-triggers BOTH zip downloads
//          (PDF ZIP + Excel ZIP) when user clicks the single email button
// =====================================================
router.get('/inspection/zip/both', async (req, res) => {
  try {
    const { ids } = req.query;
    if (!ids) {
      return res.status(400).json({ success: false, message: 'ids query param is required' });
    }

    const idList = ids.split(',').map(id => id.trim()).filter(Boolean);
    if (idList.length === 0) {
      return res.status(400).json({ success: false, message: 'No valid IDs provided' });
    }

    const idsParam     = encodeURIComponent(ids);
    const pdfZipUrl    = `${BASE_URL}/api/admin/inspection/zip/pdf?ids=${idsParam}`;
    const excelZipUrl  = `${BASE_URL}/api/admin/inspection/zip/excel?ids=${idsParam}`;

    // Return a small HTML page that auto-downloads both ZIPs
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.send(`<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Downloading Reports...</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: Arial, sans-serif;
      background: #f4f6f8;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
    }
    .card {
      background: white;
      border-radius: 10px;
      box-shadow: 0 4px 16px rgba(0,0,0,0.12);
      padding: 40px 48px;
      max-width: 460px;
      width: 100%;
      text-align: center;
    }
    .icon { font-size: 52px; margin-bottom: 16px; }
    h2 { color: #2C3E50; font-size: 20px; margin-bottom: 8px; }
    p  { color: #666; font-size: 14px; margin-bottom: 24px; line-height: 1.6; }

    .file-row {
      display: flex;
      align-items: center;
      background: #f8f9fa;
      border-radius: 6px;
      padding: 12px 16px;
      margin-bottom: 10px;
      text-align: left;
    }
    .file-icon { font-size: 22px; margin-right: 12px; }
    .file-label { flex: 1; }
    .file-name  { font-size: 13px; font-weight: bold; color: #2C3E50; }
    .file-type  { font-size: 11px; color: #888; margin-top: 2px; }
    .status {
      font-size: 12px;
      font-weight: bold;
      padding: 4px 10px;
      border-radius: 12px;
      background: #fff3cd;
      color: #856404;
    }
    .status.done {
      background: #d1e7dd;
      color: #0f5132;
    }

    .manual-btns { margin-top: 24px; border-top: 1px solid #eee; padding-top: 20px; }
    .manual-btns p { font-size: 12px; color: #999; margin-bottom: 12px; }
    .btn {
      display: inline-block;
      padding: 9px 20px;
      border-radius: 5px;
      text-decoration: none;
      font-size: 13px;
      font-weight: bold;
      margin: 4px;
    }
    .btn-pdf   { background: #e67e22; color: white; }
    .btn-excel { background: #27ae60; color: white; }
  </style>
</head>
<body>
<div class="card">
  <div class="icon">📦</div>
  <h2>Downloading Your Reports</h2>
  <p>Both files are downloading automatically.<br>Please check your browser's download folder.</p>

  <div class="file-row">
    <span class="file-icon">📄</span>
    <div class="file-label">
      <div class="file-name">PDF Reports ZIP</div>
      <div class="file-type">Inspection reports with photos</div>
    </div>
    <span class="status" id="pdf-status">⏳ Starting...</span>
  </div>

  <div class="file-row">
    <span class="file-icon">📊</span>
    <div class="file-label">
      <div class="file-name">Excel Reports ZIP</div>
      <div class="file-type">Inspection data spreadsheet</div>
    </div>
    <span class="status" id="excel-status">⏳ Starting...</span>
  </div>

  <div class="manual-btns">
    <p>Downloads not starting? Click below:</p>
    <a href="${pdfZipUrl}"   class="btn btn-pdf"   download>📄 Download PDF ZIP</a>
    <a href="${excelZipUrl}" class="btn btn-excel" download>📊 Download Excel ZIP</a>
  </div>
</div>

<script>
  // Trigger PDF download first, Excel after a short delay
  function triggerDownload(url) {
    const a = document.createElement('a');
    a.href = url;
    a.download = '';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }

  window.addEventListener('load', () => {
    // PDF - immediate
    setTimeout(() => {
      triggerDownload('${pdfZipUrl}');
      document.getElementById('pdf-status').textContent = '✅ Downloaded';
      document.getElementById('pdf-status').className   = 'status done';
    }, 500);

    // Excel - after 1.5s gap (avoid browser blocking both)
    setTimeout(() => {
      triggerDownload('${excelZipUrl}');
      document.getElementById('excel-status').textContent = '✅ Downloaded';
      document.getElementById('excel-status').className   = 'status done';
    }, 1800);
  });
</script>
</body>
</html>`);
  } catch (error) {
    console.error('Error in /zip/both:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});
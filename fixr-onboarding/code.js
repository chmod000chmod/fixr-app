// Fixr — Full Onboarding Flow
// 13 screens: Role Select + 5 Client + 7 Fixer
// ES5-SAFE: no spread, no ?., no ??. fontName always set before characters.

(function() {

Promise.all([
  figma.loadFontAsync({ family: 'Inter', style: 'Regular' }),
  figma.loadFontAsync({ family: 'Inter', style: 'Medium' }),
  figma.loadFontAsync({ family: 'Inter', style: 'Semi Bold' }),
  figma.loadFontAsync({ family: 'Inter', style: 'Bold' }),
  figma.loadFontAsync({ family: 'Inter', style: 'Extra Bold' }),
]).then(function() {

  var page = figma.currentPage;
  var W = 375, H = 812, GAP = 48;

  var C = {
    bg:      { r: 0.051, g: 0.059, b: 0.078 },
    deep:    { r: 0.051, g: 0.106, b: 0.243 },
    blue:    { r: 0.145, g: 0.388, b: 0.922 },
    blueL:   { r: 0.231, g: 0.510, b: 0.965 },
    blueDk:  { r: 0.114, g: 0.306, b: 0.847 },
    orange:  { r: 0.976, g: 0.451, b: 0.086 },
    orangeL: { r: 0.984, g: 0.573, b: 0.235 },
    green:   { r: 0.133, g: 0.773, b: 0.369 },
    greenL:  { r: 0.525, g: 0.937, b: 0.671 },
    amber:   { r: 0.984, g: 0.749, b: 0.141 },
    text:    { r: 0.973, g: 0.980, b: 0.988 },
    muted:   { r: 0.420, g: 0.447, b: 0.502 },
    white:   { r: 1, g: 1, b: 1 },
  };

  function sl(c, o) { return [{ type: 'SOLID', color: c, opacity: o === undefined ? 1 : o }]; }

  function stp(pos, c, o) {
    return { position: pos, color: { r: c.r, g: c.g, b: c.b, a: o === undefined ? 1 : o } };
  }

  function lG(angle, stops) {
    var rad = (angle * Math.PI) / 180;
    var cos = Math.cos(rad), sin = Math.sin(rad);
    return [{ type: 'GRADIENT_LINEAR',
      gradientTransform: [[cos, sin, (1-cos)/2 - sin/2], [-sin, cos, sin/2 + (1-cos)/2]],
      gradientStops: stops }];
  }

  function rG(cx, cy, stops) {
    return [{ type: 'GRADIENT_RADIAL',
      gradientTransform: [[0.5, 0, cx], [0, 0.5, cy]],
      gradientStops: stops }];
  }

  function bdr(n, c, o, w) {
    n.strokes = [{ type: 'SOLID', color: c, opacity: o === undefined ? 0.15 : o }];
    n.strokeWeight = w === undefined ? 1 : w;
    n.strokeAlign = 'INSIDE';
  }

  function R(p, x, y, w, h, fills, cr) {
    var n = figma.createRectangle();
    n.x = x; n.y = y; n.resize(Math.max(w, 1), Math.max(h, 1));
    n.fills = fills; n.cornerRadius = cr || 0; n.strokes = [];
    p.appendChild(n); return n;
  }

  function E(p, x, y, d, fills) {
    var n = figma.createEllipse();
    n.x = x; n.y = y; n.resize(d, d); n.fills = fills; n.strokes = [];
    p.appendChild(n); return n;
  }

  function F(p, name, x, y, w, h, fills) {
    var n = figma.createFrame(); n.name = name;
    n.x = x; n.y = y; n.resize(Math.max(w, 1), Math.max(h, 1));
    n.fills = fills || sl(C.bg); n.clipsContent = true;
    if (p) p.appendChild(n); return n;
  }

  // CRITICAL: fontName BEFORE characters
  function T(p, str, x, y, sz, wt, col, o, mw) {
    var n = figma.createText();
    var st = wt >= 800 ? 'Extra Bold' : wt >= 700 ? 'Bold' : wt >= 600 ? 'Semi Bold' : wt >= 500 ? 'Medium' : 'Regular';
    n.fontName = { family: 'Inter', style: st };
    n.characters = String(str);
    n.fontSize = sz;
    n.fills = [{ type: 'SOLID', color: col || C.text, opacity: o === undefined ? 1 : o }];
    n.x = x; n.y = y;
    if (mw) { n.textAutoResize = 'HEIGHT'; n.resize(mw, 20); }
    p.appendChild(n); return n;
  }

  // ── Components ───────────────────────────────────────────────

  function statusBar(p) {
    var b = F(p, 'Status Bar', 0, 0, 375, 48, sl(C.bg, 0));
    T(b, '9:41', 28, 16, 15, 600, C.text);
    T(b, 'WiFi', 290, 18, 11, 400, C.text, 0.6);
  }

  function backBtn(p, y) {
    var r = R(p, 20, y, 36, 36, sl(C.white, 0.08), 10);
    bdr(r, C.white, 0.1);
    T(p, '<', 30, y + 9, 16, 400, C.text, 0.7);
  }

  function stepBar(p, cur, total, col) {
    var bW = W - 48;
    R(p, 24, 64, bW, 4, sl(C.white, 0.08), 2);
    R(p, 24, 64, Math.round(bW * (cur / total)), 4, lG(90, [stp(0, col), stp(1, col)]), 2);
    T(p, 'Step ' + cur + ' of ' + total, 24, 76, 11, 500, C.text, 0.4);
  }

  function inp(p, x, y, w, label, ph, col) {
    T(p, label, x, y, 11, 600, C.text, 0.45);
    var box = F(p, 'Input ' + label, x, y + 18, w, 50, sl(C.white, 0.06));
    box.cornerRadius = 14; bdr(box, col || C.white, col ? 0.4 : 0.1);
    T(box, ph, 16, 16, 13, 400, C.text, 0.28, w - 32);
    return box;
  }

  function cta(p, x, y, w, label, fills) {
    R(p, x, y, w, 52, fills || lG(135, [stp(0, C.blue), stp(1, C.blueL)]), 15);
    T(p, label, x + Math.round(w / 2 - label.length * 4.6), y + 17, 15, 700, C.white);
  }

  function ghost(p, x, y, w, label) {
    var r = R(p, x, y, w, 52, sl(C.white, 0.06), 15); bdr(r, C.white, 0.12);
    T(p, label, x + Math.round(w / 2 - label.length * 4.0), y + 17, 14, 600, C.text, 0.6);
  }

  function upload(p, x, y, w, h, label, sub, col) {
    var box = F(p, 'Upload ' + label, x, y, w, h, sl(col || C.blue, 0.05));
    box.cornerRadius = 16; bdr(box, col || C.blue, 0.3);
    var ring = E(box, w / 2 - 22, h / 2 - 36, 44, sl(col || C.blue, 0.1));
    bdr(ring, col || C.blue, 0.25);
    T(box, '+', w / 2 - 8, h / 2 - 28, 22, 300, col || C.blue, 0.8);
    T(box, label, 16, h / 2 + 6, 13, 600, C.text, 0.85, w - 32);
    if (sub) { T(box, sub, 16, h / 2 + 24, 11, 400, C.text, 0.35, w - 32); }
    return box;
  }

  function secLbl(p, x, y, label, col) {
    T(p, label, x, y, 10, 700, col || C.text, col ? 0.7 : 0.35);
    R(p, x, y + 16, W - 48, 1, sl(col || C.white, col ? 0.2 : 0.08));
  }

  function reviewRow(p, y, label, value, col) {
    var card = F(p, 'Row ' + label, 24, y, W - 48, 54, sl(C.white, 0.05));
    card.cornerRadius = 13; bdr(card, C.white, 0.08);
    T(card, label, 16, 6, 10, 600, C.text, 0.4);
    T(card, value, 16, 24, 13, 500, C.text, 0.88, W - 100);
    T(card, 'Edit', W - 80, 18, 12, 600, col || C.blue);
    return card;
  }

  function pendingScreen(p, col, title, steps, email) {
    statusBar(p);
    R(p, 60, -40, 280, 280, rG(0.5, 0.5, [stp(0, col, 0.12), stp(1, col, 0)]), 140);
    var r1 = E(p, W/2 - 48, 170, 96, sl(col, 0.08)); bdr(r1, col, 0.2);
    var r2 = E(p, W/2 - 34, 184, 68, sl(col, 0.06)); bdr(r2, col, 0.12);
    T(p, '?', W/2 - 12, 192, 36, 700, col, 0.9);
    T(p, title, 44, 286, 20, 800, C.text, 1, W - 88);
    T(p, 'Verification takes 24-48 hours. You will be emailed when ready.', 40, 316, 12, 400, C.text, 0.45, W - 80);

    var sy = 376;
    for (var i = 0; i < steps.length; i++) {
      var sc = steps[i][2];
      var done = steps[i][1] === 'Done';
      var dot = E(p, 32, sy + i * 60, 16, sl(sc, done ? 0.25 : 0.1));
      bdr(dot, sc, 0.4);
      if (done) { T(p, 'v', 36, sy + i * 60 + 1, 10, 700, sc); }
      if (i < steps.length - 1) {
        R(p, 39, sy + i * 60 + 16, 2, 44, sl(sc, done ? 0.5 : 0.1));
      }
      T(p, steps[i][0], 58, sy + i * 60 + 1, 13, 600, C.text, done ? 0.9 : 0.4, 220);
      T(p, steps[i][1], 58, sy + i * 60 + 18, 11, 500, sc, done ? 0.8 : 0.35);
    }

    // Email confirmation card
    var ey = sy + steps.length * 60 + 12;
    var eCard = F(p, 'Email Card', 24, ey, W - 48, 68, sl(col, 0.08));
    eCard.cornerRadius = 16; bdr(eCard, col, 0.25);
    R(eCard, 0, 0, 4, 68, sl(col, 0.7));
    T(eCard, 'Email sent to:', 16, 8, 10, 600, C.text, 0.4);
    T(eCard, email, 16, 24, 14, 600, col);
    T(eCard, 'Check your inbox to verify and track your review.', 16, 46, 11, 400, C.text, 0.35, W - 80);

    // Lock notice + greyed tab bar
    var lockY = H - 112;
    var lock = F(p, 'Lock Notice', 0, lockY, W, 34, sl(col, 0.07));
    R(lock, 0, 0, W, 1, sl(col, 0.2));
    T(lock, 'Features unlock once your account is verified', 20, 8, 11, 500, col, 0.75, W - 40);

    var tb = F(p, 'Tab Bar Locked', 0, lockY + 34, W, 78, sl(C.bg, 0.96));
    R(tb, 0, 0, W, 1, sl(C.white, 0.08));
    var tl = ['Home', 'Jobs', 'Post', 'Msgs', 'Me'];
    for (var ti = 0; ti < tl.length; ti++) {
      T(tb, tl[ti], ti * (W / 5) + 10, 38, 10, 400, C.text, 0.18, 60);
    }

    ghost(p, 24, lockY - 64, W - 48, 'Check Verification Status');
  }

  // ── Find rightmost X ─────────────────────────────────────────
  var maxX = 0;
  for (var ci = 0; ci < page.children.length; ci++) {
    var ch = page.children[ci];
    if (ch.x !== undefined) { maxX = Math.max(maxX, ch.x + (ch.width || W)); }
  }
  var X = maxX + 100;

  // Remove any old onboarding frames
  var toRemove = [];
  for (var ri = 0; ri < page.children.length; ri++) {
    var rc = page.children[ri];
    if (rc.name && rc.name.indexOf('OB-') === 0) { toRemove.push(rc); }
  }
  for (var di = 0; di < toRemove.length; di++) { toRemove[di].remove(); }

  // Recalculate after removal
  maxX = 0;
  for (var ci2 = 0; ci2 < page.children.length; ci2++) {
    var ch2 = page.children[ci2];
    if (ch2.x !== undefined) { maxX = Math.max(maxX, ch2.x + (ch2.width || W)); }
  }
  X = maxX + 100;

  var allNew = [];

  // ══════════════════════════════════════════════════════════
  // OB-0: ROLE SELECTION
  // ══════════════════════════════════════════════════════════
  var s0 = F(null, 'OB-0 — Choose Role', X, 0, W, H, sl(C.bg));
  page.appendChild(s0); allNew.push(s0);
  statusBar(s0);
  R(s0, 40, -40, 295, 295, rG(0.5, 0.5, [stp(0, C.blue, 0.14), stp(1, C.blue, 0)]), 148);
  R(s0, 148, 52, 64, 64, lG(135, [stp(0, C.blue), stp(1, C.blueDk)]), 18);
  T(s0, 'Fixr', 154, 124, 26, 800, C.text);
  T(s0, 'Welcome! How will you use Fixr?', 28, 168, 16, 700, C.text, 0.85, W - 56);
  T(s0, 'You can switch roles anytime in Settings.', 28, 192, 12, 400, C.text, 0.38, W - 56);

  // Client card (active)
  var cc = F(s0, 'Card Client', 24, 228, W - 48, 92, sl(C.blue, 0.1));
  cc.cornerRadius = 18; bdr(cc, C.blue, 0.45, 2);
  var cRing = E(cc, 16, 26, 40, sl(C.blue, 0.15)); bdr(cRing, C.blue, 0.25);
  T(cc, 'H', 28, 34, 20, 700, C.blue, 0.7);
  T(cc, 'I am a Client', 68, 20, 15, 700, C.text);
  T(cc, 'I need repairs done at home', 68, 42, 12, 400, C.text, 0.45, W - 130);
  var ck1 = E(cc, W - 84, 34, 24, lG(135, [stp(0, C.blue), stp(1, C.blueL)]));
  T(cc, 'v', W - 78, 36, 12, 700, C.white);

  // Fixer card
  var fc = F(s0, 'Card Fixer', 24, 332, W - 48, 92, sl(C.white, 0.05));
  fc.cornerRadius = 18; bdr(fc, C.white, 0.1);
  var fRing = E(fc, 16, 26, 40, sl(C.orange, 0.1)); bdr(fRing, C.orange, 0.2);
  T(fc, 'W', 27, 34, 20, 700, C.orange, 0.7);
  T(fc, 'I am a Fixer', 68, 20, 15, 700, C.text);
  T(fc, 'I repair and build my trade career', 68, 42, 12, 400, C.text, 0.45, W - 130);
  var ck2 = E(fc, W - 84, 34, 24, sl(C.white, 0.06)); bdr(ck2, C.white, 0.15);

  cta(s0, 24, 452, W - 48, 'Continue as Client');
  ghost(s0, 24, 516, W - 48, 'Continue as Fixer');
  T(s0, 'Already have an account?  Sign In', 88, 588, 13, 400, C.text, 0.4, 200);

  // ══════════════════════════════════════════════════════════
  // CLIENT FLOW
  // ══════════════════════════════════════════════════════════
  var CX = X + W + GAP;

  // OB-C1: Account
  var c1 = F(null, 'OB-C1 — Client Account', CX, 0, W, H, sl(C.bg));
  page.appendChild(c1); allNew.push(c1);
  statusBar(c1); backBtn(c1, 56); stepBar(c1, 1, 5, C.blue);
  T(c1, 'Create your account', 24, 96, 22, 800, C.text, 1, 280);
  T(c1, 'Tell us who you are.', 24, 124, 13, 400, C.text, 0.45, 240);
  inp(c1, 24, 156, W-48, 'First Name', 'e.g. Marcus', C.blue);
  inp(c1, 24, 232, W-48, 'Last Name', 'e.g. Thompson', C.blue);
  inp(c1, 24, 308, W-48, 'Email Address', 'your@email.com', C.blue);
  inp(c1, 24, 384, W-48, 'Password', 'Min. 8 characters', C.blue);
  inp(c1, 24, 460, W-48, 'Confirm Password', 'Re-enter password', C.blue);
  T(c1, 'Password strength:', 24, 526, 10, 500, C.text, 0.35);
  R(c1, 24, 542, W-48, 4, sl(C.white, 0.08), 2);
  R(c1, 24, 542, 180, 4, lG(90, [stp(0, C.amber), stp(1, C.green)]), 2);
  T(c1, 'Medium', 216, 538, 10, 600, C.amber);
  cta(c1, 24, 700, W-48, 'Continue');
  T(c1, 'By continuing you agree to our Terms & Privacy Policy', 44, 762, 10, 400, C.text, 0.3, W - 88);

  // OB-C2: Personal Info
  var c2 = F(null, 'OB-C2 — Personal Info', CX + (W+GAP), 0, W, H, sl(C.bg));
  page.appendChild(c2); allNew.push(c2);
  statusBar(c2); backBtn(c2, 56); stepBar(c2, 2, 5, C.blue);
  T(c2, 'Personal information', 24, 96, 22, 800, C.text, 1, 280);
  T(c2, 'We need this to confirm your identity and age.', 24, 124, 13, 400, C.text, 0.45, W-48);
  secLbl(c2, 24, 156, 'DATE OF BIRTH', C.blue);
  // DOB — 3 columns
  inp(c2, 24, 184, 92, 'Day', 'DD', C.blue);
  inp(c2, 128, 184, 92, 'Month', 'MM', C.blue);
  inp(c2, 232, 184, W-256, 'Year', 'YYYY', C.blue);
  var ageNote = F(c2, 'Age Note', 24, 256, W-48, 36, sl(C.amber, 0.08));
  ageNote.cornerRadius = 10; bdr(ageNote, C.amber, 0.2);
  T(ageNote, 'You must be 18 or older to use Fixr.', 12, 10, 11, 500, C.amber, 0.85, W-80);
  secLbl(c2, 24, 308, 'HOME ADDRESS', C.blue);
  inp(c2, 24, 336, W-48, 'Street Address', '123 Rue Principale', C.blue);
  inp(c2, 24, 412, W-48, 'City', 'e.g. Saint-Jerome, QC', C.blue);
  inp(c2, 24, 488, 145, 'Province', 'QC', C.blue);
  inp(c2, 181, 488, W-205, 'Postal Code', 'J7Z 1A1', C.blue);
  inp(c2, 24, 564, W-48, 'Phone (optional)', '+1 (514) 555-0000', C.blue);
  cta(c2, 24, 700, W-48, 'Continue');

  // OB-C3: Government ID
  var c3 = F(null, 'OB-C3 — Identity Verification', CX + (W+GAP)*2, 0, W, H, sl(C.bg));
  page.appendChild(c3); allNew.push(c3);
  statusBar(c3); backBtn(c3, 56); stepBar(c3, 3, 5, C.blue);
  T(c3, 'Verify your identity', 24, 96, 22, 800, C.text, 1, 280);
  T(c3, 'Upload a government-issued photo ID.', 24, 124, 13, 400, C.text, 0.45, W-48);
  // Why card
  var whyC = F(c3, 'Why Card', 24, 152, W-48, 64, sl(C.blue, 0.07));
  whyC.cornerRadius = 14; bdr(whyC, C.blue, 0.2);
  R(whyC, 0, 0, 4, 64, sl(C.blue, 0.7));
  T(whyC, 'Why do we need this?', 16, 8, 12, 600, C.blueL);
  T(whyC, 'To confirm you are real, of legal age, and protect our community.', 16, 28, 11, 400, C.text, 0.45, W - 80);
  // Doc chips
  T(c3, 'ACCEPTED DOCUMENTS', 24, 232, 10, 700, C.text, 0.35);
  var docTypes = ["Driver's Licence", 'Passport', 'National ID', 'Health Card'];
  var dcx = 24;
  for (var dci = 0; dci < docTypes.length; dci++) {
    var dcw = docTypes[dci].length * 7 + 22;
    var dca = dci === 0;
    R(c3, dcx, 252, dcw, 28, dca ? sl(C.blue, 0.2) : sl(C.white, 0.06), 14);
    T(c3, docTypes[dci], dcx + 11, 258, 11, dca ? 600 : 400, dca ? C.blueL : C.text, 1);
    dcx += dcw + 8;
    if (dcx > 320) { dcx = 24; }
  }
  upload(c3, 24, 296, W-48, 140, 'Tap to upload FRONT of ID', 'JPG, PNG or PDF  Max 10MB', C.blue);
  upload(c3, 24, 448, W-48, 96, 'Tap to upload BACK of ID', 'Optional for passport', C.blue);
  T(c3, 'Your ID is encrypted. Only used for verification. Never shared or sold.', 24, 556, 11, 400, C.text, 0.3, W-48);
  cta(c3, 24, 700, W-48, 'Submit for Review');

  // OB-C4: Review
  var c4 = F(null, 'OB-C4 — Review', CX + (W+GAP)*3, 0, W, H, sl(C.bg));
  page.appendChild(c4); allNew.push(c4);
  statusBar(c4); backBtn(c4, 56); stepBar(c4, 4, 5, C.blue);
  T(c4, 'Review your info', 24, 96, 22, 800, C.text, 1, 280);
  T(c4, 'Everything look correct?', 24, 124, 13, 400, C.text, 0.45, 240);
  var cRows = [
    ['Name','Marcus Thompson'],['Email','marcus.t@email.com'],
    ['Date of Birth','April 15, 1990'],['Address','123 Rue Principale, QC'],
    ['Phone','+1 (514) 555-0192'],['Government ID','Uploaded'],
  ];
  var cry = 152;
  for (var cri = 0; cri < cRows.length; cri++) {
    reviewRow(c4, cry, cRows[cri][0], cRows[cri][1], C.blue);
    cry += 62;
  }
  // Terms checkbox
  var tc = F(c4, 'Terms', 24, cry + 8, W-48, 40, sl(C.white, 0));
  R(tc, 0, 10, 20, 20, sl(C.blue, 0.15), 6); bdr(R(tc, 0, 10, 20, 20, sl(C.blue, 0), 6), C.blue, 0.4);
  R(tc, 4, 14, 12, 12, sl(C.blue), 4);
  T(tc, 'I confirm all info is accurate and agree to the Terms of Service.', 28, 10, 11, 400, C.text, 0.45, W-80);
  cta(c4, 24, 742, W-48, 'Submit Application');

  // OB-C5: Pending
  var c5 = F(null, 'OB-C5 — Client Pending', CX + (W+GAP)*4, 0, W, H, sl(C.bg));
  page.appendChild(c5); allNew.push(c5);
  pendingScreen(c5, C.blue, 'Account Under Review', [
    ['Application submitted', 'Done', C.green],
    ['ID under review', 'In progress', C.amber],
    ['Account activated', 'Pending', C.muted],
  ], 'marcus.t@email.com');

  // ══════════════════════════════════════════════════════════
  // FIXER FLOW
  // ══════════════════════════════════════════════════════════
  var FX = CX + (W+GAP)*5 + 80;

  // OB-F1: Fixer Account
  var f1 = F(null, 'OB-F1 — Fixer Account', FX, 0, W, H, sl(C.bg));
  page.appendChild(f1); allNew.push(f1);
  statusBar(f1); backBtn(f1, 56); stepBar(f1, 1, 7, C.orange);
  T(f1, 'Create your Fixer account', 24, 96, 21, 800, C.text, 1, 280);
  T(f1, 'Start building your trade career on Fixr.', 24, 124, 13, 400, C.text, 0.45, W-48);
  inp(f1, 24, 156, W-48, 'First Name', 'e.g. Jake', C.orange);
  inp(f1, 24, 232, W-48, 'Last Name', 'e.g. Sullivan', C.orange);
  inp(f1, 24, 308, W-48, 'Email Address', 'your@email.com', C.orange);
  inp(f1, 24, 384, W-48, 'Phone Number', '+1 (514) 555-0000', C.orange);
  inp(f1, 24, 460, W-48, 'Password', 'Min. 8 characters', C.orange);
  inp(f1, 24, 536, W-48, 'Confirm Password', 'Re-enter password', C.orange);
  cta(f1, 24, 700, W-48, 'Continue', lG(135, [stp(0, C.orange), stp(1, C.orangeL)]));
  T(f1, 'By continuing you agree to our Terms & Privacy Policy', 44, 762, 10, 400, C.text, 0.3, W-88);

  // OB-F2: Trade
  var f2 = F(null, 'OB-F2 — Trade & Expertise', FX + (W+GAP), 0, W, H, sl(C.bg));
  page.appendChild(f2); allNew.push(f2);
  statusBar(f2); backBtn(f2, 56); stepBar(f2, 2, 7, C.orange);
  T(f2, 'What is your trade?', 24, 96, 22, 800, C.text, 1, 280);
  T(f2, 'Select all that apply to your expertise.', 24, 124, 13, 400, C.text, 0.45, W-48);
  var trades = ['Plumbing', 'Electrical', 'Carpentry', 'HVAC', 'Windows & Doors', 'Painting'];
  var tradeSubs = ['Pipes, fixtures, drains', 'Wiring, panels, outlets', 'Framing, finishing, wood', 'Heating & cooling', 'Install, repair, seal', 'Interior & exterior'];
  for (var ti = 0; ti < trades.length; ti++) {
    var active = ti === 0;
    var tCard = F(f2, 'Trade ' + trades[ti], 24, 152 + ti * 82, W-48, 70, active ? sl(C.orange, 0.08) : sl(C.white, 0.05));
    tCard.cornerRadius = 16; bdr(tCard, active ? C.orange : C.white, active ? 0.4 : 0.08);
    var tRing = E(tCard, 14, 15, 40, sl(active ? C.orange : C.white, 0.1)); bdr(tRing, active ? C.orange : C.white, 0.15);
    T(tCard, String(ti + 1), 28, 23, 14, 700, active ? C.orange : C.text, active ? 0.8 : 0.2);
    T(tCard, trades[ti], 66, 12, 14, active ? 700 : 600, C.text, active ? 1 : 0.8);
    T(tCard, tradeSubs[ti], 66, 32, 11, 400, C.text, 0.38, W-130);
    if (active) {
      var tck = E(tCard, W-82, 23, 24, lG(135, [stp(0, C.orange), stp(1, C.orangeL)]));
      T(tCard, 'v', W-76, 25, 12, 700, C.white);
    } else {
      var tck2 = E(tCard, W-82, 23, 24, sl(C.white, 0.06)); bdr(tck2, C.white, 0.15);
    }
  }
  cta(f2, 24, 660, W-48, 'Continue', lG(135, [stp(0, C.orange), stp(1, C.orangeL)]));

  // OB-F3: Experience
  var f3 = F(null, 'OB-F3 — Experience', FX + (W+GAP)*2, 0, W, H, sl(C.bg));
  page.appendChild(f3); allNew.push(f3);
  statusBar(f3); backBtn(f3, 56); stepBar(f3, 3, 7, C.orange);
  T(f3, 'Your experience', 24, 96, 22, 800, C.text, 1, 280);
  T(f3, 'Help clients find the right expertise level.', 24, 124, 13, 400, C.text, 0.45, W-48);
  secLbl(f3, 24, 156, 'YEARS OF EXPERIENCE', C.orange);
  var levels = ['0-1 years  (Apprentice)', '2-4 years  (Junior)', '5-9 years  (Senior)', '10+ years  (Master)'];
  var levelCols = [C.muted, C.blue, C.orange, C.green];
  for (var li = 0; li < levels.length; li++) {
    var sel = li === 2;
    var lCard = F(f3, 'Level ' + li, 24, 184 + li * 72, W-48, 60, sel ? sl(C.orange, 0.08) : sl(C.white, 0.05));
    lCard.cornerRadius = 14; bdr(lCard, sel ? C.orange : C.white, sel ? 0.4 : 0.08);
    var lDot = E(lCard, 16, 18, 24, sl(levelCols[li], sel ? 0.25 : 0.08)); bdr(lDot, levelCols[li], sel ? 0.5 : 0.15);
    if (sel) { T(lCard, 'v', 21, 20, 12, 700, C.orange); }
    T(lCard, levels[li], 52, 18, 13, sel ? 600 : 400, C.text, sel ? 0.95 : 0.55, W-100);
    var badges = ['Apprentice', 'Junior', 'Senior', 'Master'];
    T(lCard, badges[li], W-80, 22, 10, 700, levelCols[li], sel ? 1 : 0.25);
  }
  secLbl(f3, 24, 480, 'CERTIFICATIONS (optional)', C.orange);
  inp(f3, 24, 508, W-48, 'Certification Name', 'e.g. Journeyman Plumber - Red Seal', C.orange);
  inp(f3, 24, 584, W-48, 'Issuing Body', 'e.g. Compagnons du Quebec', C.orange);
  T(f3, '+ Add another certification', 24, 648, 12, 600, C.orange, 0.7);
  cta(f3, 24, 700, W-48, 'Continue', lG(135, [stp(0, C.orange), stp(1, C.orangeL)]));

  // OB-F4: Government ID
  var f4 = F(null, 'OB-F4 — Government ID', FX + (W+GAP)*3, 0, W, H, sl(C.bg));
  page.appendChild(f4); allNew.push(f4);
  statusBar(f4); backBtn(f4, 56); stepBar(f4, 4, 7, C.orange);
  T(f4, 'Verify your identity', 24, 96, 22, 800, C.text, 1, 280);
  T(f4, 'We verify every Fixer to protect homeowners.', 24, 124, 13, 400, C.text, 0.45, W-48);
  var whyF = F(f4, 'Why Card', 24, 152, W-48, 64, sl(C.orange, 0.07));
  whyF.cornerRadius = 14; bdr(whyF, C.orange, 0.2);
  R(whyF, 0, 0, 4, 64, sl(C.orange, 0.7));
  T(whyF, 'Why is this required?', 16, 8, 12, 600, C.orangeL);
  T(whyF, 'Homeowners trust verified Fixers. ID check is mandatory for all tradespeople.', 16, 28, 11, 400, C.text, 0.45, W-80);
  T(f4, 'GOVERNMENT PHOTO ID', 24, 232, 10, 700, C.text, 0.35);
  upload(f4, 24, 254, W-48, 140, 'Upload FRONT of your ID', 'Passport, Drivers Licence, or National ID', C.orange);
  upload(f4, 24, 406, W-48, 96, 'Upload BACK of ID (if applicable)', 'Optional for passport holders', C.orange);
  T(f4, 'Your ID is encrypted. Only used for verification. Never shared or sold.', 24, 514, 11, 400, C.text, 0.3, W-48);
  cta(f4, 24, 700, W-48, 'Continue', lG(135, [stp(0, C.orange), stp(1, C.orangeL)]));

  // OB-F5: Licence
  var f5 = F(null, 'OB-F5 — Licence Number', FX + (W+GAP)*4, 0, W, H, sl(C.bg));
  page.appendChild(f5); allNew.push(f5);
  statusBar(f5); backBtn(f5, 56); stepBar(f5, 5, 7, C.orange);
  T(f5, 'Your trade licence', 24, 96, 22, 800, C.text, 1, 280);
  T(f5, 'Enter your RBQ licence for Quebec jobs.', 24, 124, 13, 400, C.text, 0.45, W-48);
  // RBQ card
  var rbq = F(f5, 'RBQ Card', 24, 152, W-48, 156, sl(C.green, 0.06));
  rbq.cornerRadius = 18; bdr(rbq, C.green, 0.25);
  R(rbq, 0, 0, W-48, 4, sl(C.green, 0.55));
  T(rbq, 'LICENCE RBQ', 16, 16, 10, 700, C.greenL, 0.7);
  T(rbq, 'Regie du Batiment du Quebec', 16, 32, 12, 600, C.text, 0.5, W-80);
  var licIn = F(rbq, 'Licence Input', 16, 60, W-80, 46, sl(C.white, 0.06));
  licIn.cornerRadius = 13; bdr(licIn, C.green, 0.4);
  T(licIn, 'e.g. 5678-4321-01', 14, 14, 14, 400, C.text, 0.28, W-112);
  var vBadge = R(rbq, 16, 116, W-80, 28, sl(C.green, 0.1), 10); bdr(vBadge, C.green, 0.25);
  T(rbq, 'Will be verified against the official RBQ registry', 28, 122, 10, 400, C.greenL, 0.65, W-112);
  // No licence note
  var noLic = F(f5, 'No Licence Note', 24, 320, W-48, 52, sl(C.orange, 0.07));
  noLic.cornerRadius = 14; bdr(noLic, C.orange, 0.2);
  T(noLic, 'No licence yet? Apply as Junior Fixer', 16, 8, 12, 600, C.orangeL);
  T(noLic, 'Work under a licensed Senior and build your hours toward certification.', 16, 28, 11, 400, C.text, 0.4, W-80);
  secLbl(f5, 24, 388, 'SERVICE AREA', C.orange);
  inp(f5, 24, 416, W-48, 'Primary City / Region', 'e.g. Saint-Jerome, QC', C.orange);
  inp(f5, 24, 492, W-48, 'Max Travel Distance', 'e.g. 30 km', C.orange);
  secLbl(f5, 24, 568, 'PROFESSIONAL INSURANCE (optional)', C.orange);
  inp(f5, 24, 596, W-48, 'Insurance Provider', 'e.g. Intact, Aviva', C.orange);
  inp(f5, 24, 672, W-48, 'Policy Number', 'e.g. POL-1234567', C.orange);
  cta(f5, 24, 748, W-48, 'Continue', lG(135, [stp(0, C.orange), stp(1, C.orangeL)]));

  // OB-F6: Review
  var f6 = F(null, 'OB-F6 — Fixer Review', FX + (W+GAP)*5, 0, W, H, sl(C.bg));
  page.appendChild(f6); allNew.push(f6);
  statusBar(f6); backBtn(f6, 56); stepBar(f6, 6, 7, C.orange);
  T(f6, 'Review your profile', 24, 96, 22, 800, C.text, 1, 280);
  T(f6, 'Everything look correct before submitting?', 24, 124, 13, 400, C.text, 0.45, W-48);
  var fRows = [
    ['Name','Jake Sullivan'],['Email','jake.s@email.com'],
    ['Phone','+1 (514) 555-0001'],['Trade','Plumbing, Electrical'],
    ['Experience','5-9 years (Senior)'],['Certification','Journeyman - Red Seal'],
    ['Government ID','Uploaded'],['RBQ Licence','5678-4321-01'],
    ['Service Area','Saint-Jerome + 30 km'],
  ];
  var fry = 148;
  for (var fri = 0; fri < fRows.length; fri++) {
    reviewRow(f6, fry, fRows[fri][0], fRows[fri][1], C.orange);
    fry += 60;
  }
  var tcF = F(f6, 'Terms', 24, fry + 4, W-48, 40, sl(C.white, 0));
  R(tcF, 0, 10, 20, 20, sl(C.orange, 0.15), 6); bdr(R(tcF, 0, 10, 20, 20, sl(C.orange, 0), 6), C.orange, 0.4);
  R(tcF, 4, 14, 12, 12, sl(C.orange), 4);
  T(tcF, 'I confirm all info is accurate and agree to the Terms of Service.', 28, 10, 11, 400, C.text, 0.45, W-80);
  cta(f6, 24, fry + 52, W-48, 'Submit Application', lG(135, [stp(0, C.orange), stp(1, C.orangeL)]));

  // OB-F7: Pending
  var f7 = F(null, 'OB-F7 — Fixer Pending', FX + (W+GAP)*6, 0, W, H, sl(C.bg));
  page.appendChild(f7); allNew.push(f7);
  pendingScreen(f7, C.orange, 'Profile Under Review', [
    ['Application submitted', 'Done', C.green],
    ['Identity verification', 'In progress', C.amber],
    ['RBQ Licence check', 'Queued', C.amber],
    ['Profile activated', 'Pending', C.muted],
  ], 'jake.s@email.com');

  figma.viewport.scrollAndZoomIntoView(allNew);
  figma.notify('Done! 13 onboarding screens created.', { timeout: 4000 });
  figma.closePlugin();

}).catch(function(err) {
  figma.closePlugin('Error: ' + err.message);
});

})();

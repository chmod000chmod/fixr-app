// Fixr V2 Design Screens Plugin — Full Screen Set (12 screens)
// Creates/replaces "V2 — Improved Design" page

const C = {
  bg:          { r: 0.051, g: 0.059, b: 0.078 },
  bgDark:      { r: 0.039, g: 0.047, b: 0.063 },
  blue:        { r: 0.145, g: 0.388, b: 0.922 },
  blueLight:   { r: 0.231, g: 0.510, b: 0.965 },
  blueDark:    { r: 0.114, g: 0.306, b: 0.847 },
  blueDeep:    { r: 0.051, g: 0.106, b: 0.243 },
  orange:      { r: 0.976, g: 0.451, b: 0.086 },
  orangeLight: { r: 0.984, g: 0.573, b: 0.235 },
  green:       { r: 0.133, g: 0.773, b: 0.369 },
  greenLight:  { r: 0.525, g: 0.937, b: 0.671 },
  amber:       { r: 0.984, g: 0.749, b: 0.141 },
  red:         { r: 0.937, g: 0.267, b: 0.267 },
  juniorText:  { r: 0.988, g: 0.827, b: 0.302 },
  seniorText:  { r: 0.576, g: 0.773, b: 0.992 },
  text:        { r: 0.973, g: 0.980, b: 0.988 },
  white:       { r: 1, g: 1, b: 1 },
  black:       { r: 0, g: 0, b: 0 },
};

// ─── Helpers ─────────────────────────────────────────────────

function rgb(color, opacity = 1) {
  return [{ type: 'SOLID', color, opacity }];
}

function linearGrad(angle, stops) {
  const rad = (angle * Math.PI) / 180;
  const cos = Math.cos(rad), sin = Math.sin(rad);
  return [{
    type: 'GRADIENT_LINEAR',
    gradientTransform: [[cos, sin, (1 - cos) / 2 - sin / 2], [-sin, cos, sin / 2 + (1 - cos) / 2]],
    gradientStops: stops,
  }];
}

function radialGrad(cx, cy, stops) {
  return [{
    type: 'GRADIENT_RADIAL',
    gradientTransform: [[0.5, 0, cx], [0, 0.5, cy]],
    gradientStops: stops,
  }];
}

function stop(position, color, opacity = 1) {
  return { position, color: { ...color, a: opacity } };
}

function rect(parent, x, y, w, h, fills, cornerRadius = 0) {
  const r = figma.createRectangle();
  r.x = x; r.y = y; r.resize(w, h);
  r.fills = fills;
  if (cornerRadius) r.cornerRadius = cornerRadius;
  r.strokes = [];
  parent.appendChild(r);
  return r;
}

function stroke(node, color, opacity = 0.1, weight = 1) {
  node.strokes = [{ type: 'SOLID', color, opacity }];
  node.strokeWeight = weight;
  node.strokeAlign = 'INSIDE';
}

function text(parent, content, x, y, size, weight, color, opacity = 1, w = 0) {
  const t = figma.createText();
  t.characters = content;
  t.fontSize = size;
  const style = weight >= 800 ? 'Extra Bold' : weight >= 700 ? 'Bold' : weight >= 600 ? 'Semi Bold' : 'Regular';
  t.fontName = { family: 'Inter', style };
  t.fills = [{ type: 'SOLID', color, opacity }];
  t.x = x; t.y = y;
  if (w) { t.textAutoResize = 'HEIGHT'; t.resize(w, 20); }
  parent.appendChild(t);
  return t;
}

function frame(parent, name, x, y, w, h, fills = []) {
  const f = figma.createFrame();
  f.name = name;
  f.x = x; f.y = y;
  f.resize(w, h);
  f.fills = fills.length ? fills : rgb(C.bg);
  f.clipsContent = true;
  parent.appendChild(f);
  return f;
}

function card(parent, x, y, w, h, cornerRadius = 20) {
  const c = frame(parent, 'Card', x, y, w, h, rgb(C.white, 0.06));
  stroke(c, C.white, 0.1);
  c.cornerRadius = cornerRadius;
  return c;
}

function badge(parent, label, x, y, type = 'junior') {
  const cfg = {
    junior: { bg: C.amber,      text: C.juniorText, bdr: C.amber },
    senior: { bg: C.blueLight,  text: C.seniorText, bdr: C.blueLight },
    new:    { bg: C.green,      text: C.greenLight, bdr: C.green },
    locked: { bg: C.white,      text: C.text,       bdr: C.white },
  };
  const col = cfg[type] || cfg.junior;
  const w = label.length * 7 + 20;
  const bg = rect(parent, x, y, w, 22, [{ type: 'SOLID', color: col.bg, opacity: 0.15 }], 8);
  stroke(bg, col.bdr, 0.2);
  text(parent, label, x + 8, y + 4, 11, 700, col.text, type === 'locked' ? 0.5 : 1);
  return bg;
}

function avatar(parent, initials, x, y, size = 40, bgColor = null) {
  const bg = bgColor || C.blue;
  rect(parent, x, y, size, size, rgb(bg), size / 2);
  text(parent, initials, x + size * 0.22, y + size * 0.24, size / 2.8, 700, C.white);
}

function progressBar(parent, x, y, w, fill, color = C.blue) {
  rect(parent, x, y, w, 6, [{ type: 'SOLID', color: C.white, opacity: 0.08 }], 3);
  rect(parent, x, y, Math.max(4, Math.round(w * fill)), 6, rgb(color), 3);
}

function statusBar(parent) {
  const bar = frame(parent, 'Status Bar', 0, 0, 375, 48, rgb(C.bg, 0));
  text(bar, '9:41', 28, 16, 15, 600, C.text);
  text(bar, '●●● ▲ 🔋', 284, 16, 11, 400, C.text, 0.7);
  return bar;
}

function tabBar(parent, active = 0) {
  const tb = frame(parent, 'Tab Bar', 0, 734, 375, 78, rgb(C.bg, 0.92));
  rect(tb, 0, 0, 375, 1, [{ type: 'SOLID', color: C.white, opacity: 0.1 }]);
  const tabs = ['⌂ Home', '⋯ Jobs', '+ Post', '💬 Msgs', '◉ Me'];
  const tabW = 375 / tabs.length;
  tabs.forEach((t, i) => {
    const isActive = i === active;
    const parts = t.split(' ');
    const tx = i * tabW + tabW / 2 - 11;
    text(tb, parts[0], tx, 10, 20, 400, isActive ? C.blueLight : C.text, isActive ? 1 : 0.4);
    text(tb, parts.slice(1).join(' '), tx - 8, 36, 10, 600, isActive ? C.blueLight : C.text, isActive ? 1 : 0.4, 40);
  });
  return tb;
}

// Input field helper (dark glass style)
function inputField(parent, x, y, w, placeholder, icon = '') {
  const f = frame(parent, 'Input', x, y, w, 52, rgb(C.white, 0.06));
  f.cornerRadius = 14;
  stroke(f, C.white, 0.1);
  if (icon) text(f, icon, 16, 16, 18, 400, C.text, 0.35);
  text(f, placeholder, icon ? 44 : 16, 17, 14, 400, C.text, 0.3, w - (icon ? 60 : 32));
  return f;
}

// Section header for settings rows
function sectionLabel(parent, x, y, label) {
  text(parent, label, x, y, 11, 700, C.text, 0.3);
}

// Settings row
function settingsRow(parent, x, y, w, icon, label, sublabel = '', rightContent = '›', accentColor = null) {
  const row = frame(parent, label, x, y, w, sublabel ? 64 : 52, rgb(C.white, 0.06));
  row.cornerRadius = 14;
  stroke(row, C.white, 0.08);

  // Icon circle
  const iconColor = accentColor || C.blue;
  rect(row, 12, sublabel ? 16 : 12, 32, 32, rgb(iconColor, 0.15), 10);
  text(row, icon, 18, sublabel ? 18 : 14, 18, 400, accentColor || C.blueLight);

  // Labels
  text(row, label, 56, sublabel ? 12 : 16, 14, 600, C.text, 1, w - 90);
  if (sublabel) text(row, sublabel, 56, 34, 12, 400, C.text, 0.4, w - 90);

  // Right content
  if (rightContent === '›') {
    text(row, '›', w - 24, sublabel ? 20 : 16, 18, 400, C.text, 0.25);
  } else if (rightContent) {
    text(row, rightContent, w - rightContent.length * 8 - 16, sublabel ? 20 : 16, 13, 500, C.text, 0.45);
  }
  return row;
}

// ─── SCREEN 1: WELCOME ───────────────────────────────────────

async function buildWelcome(page, offsetX) {
  const f = frame(page, 'S1 — Welcome', offsetX, 0, 375, 812);
  const hero = frame(f, 'Hero', 0, 0, 375, 420, linearGrad(160, [stop(0, C.blueDeep), stop(1, C.bg)]));
  rect(hero, 37, -80, 280, 280, radialGrad(0.5, 0.5, [stop(0, C.blue, 0.2), stop(1, C.blue, 0)]), 140);
  rect(hero, 147.5, 140, 80, 80, linearGrad(135, [stop(0, C.blue), stop(1, C.blueDark)]), 24);
  text(hero, '🔧', 163, 154, 36, 400, C.white);
  text(hero, 'Fixr', 155, 234, 32, 800, C.text);
  text(hero, 'Find help. Build skills.', 102, 272, 14, 500, C.text, 0.55, 170);

  const bottom = frame(f, 'CTA', 0, 380, 375, 432, linearGrad(180, [stop(0, C.bg, 0), stop(0.3, C.bg)]));
  rect(bottom, 28, 80, 319, 56, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 16);
  text(bottom, 'I Need Help', 118, 96, 16, 700, C.white);
  const r2 = rect(bottom, 28, 152, 319, 56, rgb(C.white, 0.06), 16);
  stroke(r2, C.white, 0.1);
  text(bottom, 'I Want to Repair', 104, 168, 16, 700, C.text);
  text(bottom, 'or continue as guest', 118, 225, 13, 400, C.text, 0.35, 140);
  text(bottom, 'v2.0 · Terms · Privacy', 132, 382, 11, 400, C.text, 0.2, 112);
}

// ─── SCREEN 2: SIGN IN ───────────────────────────────────────

async function buildSignIn(page, offsetX) {
  const f = frame(page, 'S2 — Sign In', offsetX, 0, 375, 812);

  // Full-bleed gradient header
  const header = frame(f, 'Header', 0, 0, 375, 320, linearGrad(160, [stop(0, C.blueDeep), stop(0.7, C.bg)]));
  rect(header, 40, -80, 320, 320, radialGrad(0.5, 0.5, [stop(0, C.blue, 0.3), stop(1, C.blue, 0)]), 160);
  // Logo mark
  rect(header, 147.5, 56, 64, 64, linearGrad(135, [stop(0, C.blue), stop(1, C.blueDark)]), 20);
  text(header, '🔧', 163, 70, 30, 400, C.white);
  text(header, 'Fixr', 152, 132, 28, 800, C.text);
  text(header, 'Welcome back', 105, 168, 20, 700, C.text);
  text(header, 'Sign in to continue', 120, 193, 13, 400, C.text, 0.5, 136);

  // ── Role selector: Client | Fixr ──
  sectionLabel(f, 24, 238, 'SIGN IN AS');
  const roleBg = rect(f, 24, 256, 327, 52, rgb(C.white, 0.06), 26);
  stroke(roleBg, C.white, 0.1);
  // Client pill (active)
  rect(f, 28, 260, 157, 44, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 22);
  text(f, '🏠  Client', 68, 274, 14, 700, C.white);
  // Fixr pill (inactive)
  text(f, '🔧  Fixr', 231, 274, 14, 600, C.text, 0.45);

  // Form fields
  inputField(f, 24, 328, 327, 'Email address', '✉');
  inputField(f, 24, 392, 327, 'Password', '🔒');

  // Forgot password
  text(f, 'Forgot password?', 246, 458, 13, 500, C.blueLight, 1, 130);

  // Sign In CTA
  rect(f, 24, 484, 327, 56, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 16);
  text(f, 'Sign In  →', 155, 500, 16, 700, C.white);

  // Divider
  rect(f, 24, 556, 130, 1, rgb(C.white, 0.12));
  text(f, 'or continue with', 156, 548, 12, 400, C.text, 0.35, 64);
  rect(f, 222, 556, 129, 1, rgb(C.white, 0.12));

  // Social buttons
  const appleBtn = frame(f, 'Apple', 24, 576, 155, 52, rgb(C.white, 0.06));
  appleBtn.cornerRadius = 14; stroke(appleBtn, C.white, 0.1);
  text(appleBtn, '  Apple', 38, 16, 15, 600, C.text);

  const googleBtn = frame(f, 'Google', 196, 576, 155, 52, rgb(C.white, 0.06));
  googleBtn.cornerRadius = 14; stroke(googleBtn, C.white, 0.1);
  text(googleBtn, 'G  Google', 34, 16, 15, 600, C.text);

  text(f, "Don't have an account?  Sign Up", 83, 648, 13, 400, C.text, 0.45, 210);
  text(f, 'v2.0 · Terms · Privacy', 132, 672, 11, 400, C.text, 0.2, 112);
}

// ─── SCREEN 13: CLIENT PROFILE ───────────────────────────────

async function buildClientProfile(page, offsetX) {
  const f = frame(page, 'S13 — Client Profile', offsetX, 0, 375, 812);
  rect(f, -40, 580, 200, 200, radialGrad(0.5, 0.5, [stop(0, C.blue, 0.12), stop(1, C.blue, 0)]), 100);
  statusBar(f);

  // Header
  text(f, 'My Profile', 140, 62, 18, 700, C.text);
  const editBtnC = frame(f, 'Edit', 308, 58, 50, 28, rgb(C.white, 0.08));
  editBtnC.cornerRadius = 14; stroke(editBtnC, C.white, 0.1);
  text(editBtnC, 'Edit', 10, 6, 13, 600, C.text, 0.7);

  // Avatar + verified badge
  avatar(f, 'MT', 167.5, 96, 64, C.blue);
  rect(f, 215, 140, 20, 20, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 10);
  text(f, '✓', 219, 142, 11, 700, C.white);

  text(f, 'Marcus Thompson', 112, 172, 20, 700, C.text);
  badge(f, 'Verified Client', 143, 198, 'senior');
  text(f, '📍 Montréal, QC', 138, 222, 12, 400, C.text, 0.45, 100);

  // Stats row
  const sc = card(f, 24, 248, 327, 68, 18);
  [['12', 'Jobs Posted'], ['$2,450', 'Spent'], ['4.9★', 'Given']].forEach(([v, l], i) => {
    const sx = 54 + i * 110;
    text(f, v, sx, 264, 18, 800, C.text);
    text(f, l, sx - 4, 288, 11, 500, C.text, 0.45, 88);
    if (i < 2) rect(f, 36 + (i + 1) * 110 - 8, 268, 1, 28, rgb(C.white, 0.1));
  });

  // Contact information
  sectionLabel(f, 24, 334, 'CONTACT INFORMATION');
  const contactCard = card(f, 24, 352, 327, 120, 18);
  text(contactCard, '✉', 16, 14, 16, 400, C.blueLight);
  text(contactCard, 'marcus.t@gmail.com', 40, 16, 13, 500, C.text, 0.85, 250);
  rect(contactCard, 16, 42, 295, 1, rgb(C.white, 0.08));
  text(contactCard, '📞', 16, 52, 16, 400, C.blueLight);
  text(contactCard, '+1 (514) 555-0192', 40, 54, 13, 500, C.text, 0.85, 250);
  rect(contactCard, 16, 80, 295, 1, rgb(C.white, 0.08));
  text(contactCard, '🏠', 16, 90, 16, 400, C.blueLight);
  text(contactCard, '123 Rue Sainte-Catherine, Montréal, QC  H3B 1A1', 40, 90, 12, 400, C.text, 0.65, 270);

  // Active jobs
  sectionLabel(f, 24, 488, 'ACTIVE JOBS');
  const jCard = card(f, 24, 506, 327, 60, 16);
  rect(jCard, 16, 24, 8, 8, rgb(C.amber), 4);
  text(jCard, 'Broken circuit breaker', 32, 14, 14, 600, C.text, 1, 190);
  text(jCard, 'Electrical · In progress', 32, 34, 12, 400, C.text, 0.45, 170);
  badge(f, 'In Progress', 260, 522, 'new');

  // Reviews given
  sectionLabel(f, 24, 582, 'REVIEWS GIVEN');
  const rv1 = card(f, 24, 600, 327, 72, 16);
  avatar(f, 'JL', 40, 616, 36, C.orange);
  text(f, 'Jordan L.', 84, 608, 14, 600, C.text, 1, 160);
  text(f, '★★★★★', 84, 628, 13, 400, C.amber);
  text(f, '"Very professional and punctual!"', 84, 646, 11, 400, C.text, 0.5, 225);
  text(f, 'Apr 3', 316, 608, 11, 400, C.text, 0.3);

  // Payment method
  sectionLabel(f, 24, 690, 'PAYMENT METHOD');
  const pmCard = card(f, 24, 708, 327, 52, 14);
  text(pmCard, '💳  Visa ending in 4242', 16, 16, 14, 500, C.text, 0.85, 200);
  text(pmCard, 'Change ›', 244, 18, 12, 600, C.blueLight, 1, 60);

  tabBar(f, 4);
}

// ─── SCREEN 14: FIXR PROFILE ─────────────────────────────────

async function buildFixrProfile(page, offsetX) {
  const f = frame(page, 'S14 — Fixr Profile', offsetX, 0, 375, 812);
  rect(f, -40, 580, 200, 200, radialGrad(0.5, 0.5, [stop(0, C.orange, 0.15), stop(1, C.orange, 0)]), 100);
  statusBar(f);

  // Header
  text(f, 'My Profile', 140, 62, 18, 700, C.text);
  const editBtnF = frame(f, 'Edit', 308, 58, 50, 28, rgb(C.white, 0.08));
  editBtnF.cornerRadius = 14; stroke(editBtnF, C.white, 0.1);
  text(editBtnF, 'Edit', 10, 6, 13, 600, C.text, 0.7);

  // Avatar + verified badge
  avatar(f, 'JS', 167.5, 96, 64, C.orange);
  rect(f, 215, 140, 20, 20, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 10);
  text(f, '✓', 219, 142, 11, 700, C.white);

  text(f, 'Jake Sullivan', 128, 172, 20, 700, C.text);
  badge(f, 'Senior Plumber', 143, 198, 'senior');
  text(f, '📍 Saint-Jérôme, QC', 128, 222, 12, 400, C.text, 0.45, 120);

  // Stats row — 4 stats unique to fixr
  const sc = card(f, 24, 248, 327, 68, 18);
  [['47', 'Jobs Done'], ['312h', 'Hours'], ['4.8★', 'Rating'], ['8 yrs', 'Exp.']].forEach(([v, l], i) => {
    const sx = 32 + i * 82;
    text(f, v, sx, 264, 16, 800, C.text);
    text(f, l, sx - 2, 288, 10, 500, C.text, 0.45, 76);
    if (i < 3) rect(f, 24 + (i + 1) * 82 - 4, 268, 1, 28, rgb(C.white, 0.1));
  });

  // ── Quebec RBQ Licence ──
  sectionLabel(f, 24, 334, 'LICENCE RBQ — RÉGIE DU BÂTIMENT DU QUÉBEC');
  const licCard = card(f, 24, 352, 327, 112, 18);
  // Licence number row
  const licField = frame(licCard, 'Licence', 12, 12, 303, 44, rgb(C.blue, 0.08));
  licField.cornerRadius = 12;
  stroke(licField, C.blue, 0.25);
  text(licCard, '🪪', 20, 20, 18, 400, C.blueLight);
  text(licCard, '5678-4321-01', 46, 24, 16, 700, C.text);
  // Verified badge on the right
  const vBadge = rect(licCard, 224, 22, 79, 24, rgb(C.green, 0.15), 12);
  stroke(vBadge, C.green, 0.2);
  text(licCard, '✓ Vérifié', 234, 28, 11, 700, C.greenLight);
  // Divider + details row
  rect(licCard, 12, 60, 303, 1, rgb(C.white, 0.08));
  text(licCard, 'Catégorie :', 16, 70, 11, 600, C.text, 0.4);
  text(licCard, '3.1 — Plomberie-chauffage', 88, 70, 11, 500, C.text, 0.8, 140);
  rect(licCard, 12, 88, 303, 1, rgb(C.white, 0.08));
  text(licCard, 'Expiration :', 16, 96, 11, 600, C.text, 0.4);
  text(licCard, '2027-06-30', 88, 96, 11, 500, C.text, 0.8);

  // Specialties chips
  sectionLabel(f, 24, 482, 'SPECIALTIES');
  const specs = ['🔧 Plumbing', '🚿 Fixtures', '🪠 Drains', '🏗️ Reno'];
  let cx = 24;
  specs.forEach((s, i) => {
    const sw = s.length * 7.8 + 18;
    const sb = rect(f, cx, 500, sw, 32,
      i === 0 ? linearGrad(135, [stop(0, C.blue, 0.25), stop(1, C.blueLight, 0.12)]) : rgb(C.white, 0.06), 16);
    if (i !== 0) stroke(sb, C.white, 0.1);
    text(f, s, cx + 9, 508, 12, 600, C.text, i === 0 ? 1 : 0.65);
    cx += sw + 8;
  });

  // Availability, area & rate
  sectionLabel(f, 24, 548, 'AVAILABILITY & RATE');
  const avCard = card(f, 24, 566, 327, 76, 16);
  text(avCard, '📍', 16, 14, 15, 400, C.blueLight);
  text(avCard, 'Zone de service :', 36, 15, 12, 600, C.text, 0.5, 120);
  text(avCard, 'Saint-Jérôme + 30 km', 160, 15, 12, 500, C.text, 0.9, 145);
  rect(avCard, 16, 38, 295, 1, rgb(C.white, 0.08));
  text(avCard, '💰', 16, 48, 15, 400, C.blueLight);
  text(avCard, 'Taux horaire :', 36, 49, 12, 600, C.text, 0.5, 110);
  text(avCard, '$85 / heure', 152, 49, 12, 700, C.text, 1);
  // Available toggle
  const avBg2 = rect(avCard, 230, 44, 85, 24, rgb(C.green, 0.15), 12);
  stroke(avBg2, C.green, 0.2);
  text(avCard, '● Disponible', 238, 50, 11, 600, C.greenLight);

  // Certification progress
  sectionLabel(f, 24, 658, 'CERTIFICATION PROGRESS');
  const cc = card(f, 24, 676, 327, 96, 18);
  [['Plumbing Fundamentals', 0.78, C.blue], ['Pipefitting', 0.52, C.orange]].forEach(([n, p, col], i) => {
    const sy = 692 + i * 44;
    text(f, n, 40, sy, 12, 600, C.text, 1, 200);
    text(f, Math.round(p * 100) + '%', 307, sy, 11, 700, col);
    progressBar(f, 40, sy + 18, 287, p, col);
  });

  tabBar(f, 4);
}

// ─── SCREEN 3: SIGN UP ───────────────────────────────────────

async function buildSignUp(page, offsetX) {
  const f = frame(page, 'S3 — Sign Up', offsetX, 0, 375, 812);

  const header = frame(f, 'Header', 0, 0, 375, 260, linearGrad(160, [stop(0, C.blueDeep), stop(1, C.bg)]));
  rect(header, 55, -80, 280, 280, radialGrad(0.5, 0.5, [stop(0, C.blue, 0.2), stop(1, C.blue, 0)]), 140);
  rect(header, 147.5, 48, 56, 56, linearGrad(135, [stop(0, C.blue), stop(1, C.blueDark)]), 16);
  text(header, '🔧', 161, 60, 28, 400, C.white);
  text(header, 'Create Account', 100, 120, 22, 700, C.text);
  text(header, 'Ready to get started with Fixr?', 80, 148, 13, 400, C.text, 0.5, 215);

  // Toggle tabs
  const tabsBg = rect(f, 24, 180, 327, 48, rgb(C.white, 0.06), 24);
  stroke(tabsBg, C.white, 0.1);
  text(f, 'Sign In', 78, 194, 14, 600, C.text, 0.45);
  rect(f, 192, 184, 155, 40, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 20);
  text(f, 'Sign Up', 239, 198, 14, 700, C.white);

  // Form fields
  inputField(f, 24, 252, 327, 'Full name', '👤');
  inputField(f, 24, 316, 327, 'Email address', '✉');
  inputField(f, 24, 380, 327, 'Password (min. 8 characters)', '🔒');

  // Role picker (Fixr-specific addition)
  text(f, 'I AM A', 24, 448, 11, 700, C.text, 0.3);
  const homeBtn = frame(f, 'Role-Home', 24, 468, 156, 60, rgb(C.white, 0.06));
  homeBtn.cornerRadius = 14; stroke(homeBtn, C.white, 0.1);
  text(homeBtn, '🏠', 12, 8, 28, 400, C.white);
  text(homeBtn, 'Homeowner', 56, 10, 13, 600, C.text, 1, 95);
  text(homeBtn, 'I need help', 56, 30, 11, 400, C.text, 0.4, 95);

  const workerBtn = frame(f, 'Role-Worker', 195, 468, 156, 60, linearGrad(135, [stop(0, C.blue, 0.15), stop(1, C.blueLight, 0.1)]));
  workerBtn.cornerRadius = 14; stroke(workerBtn, C.blue, 0.4);
  text(workerBtn, '🔧', 12, 8, 28, 400, C.white);
  text(workerBtn, 'Tradesperson', 56, 10, 13, 700, C.text);
  text(workerBtn, 'I want to repair', 56, 30, 11, 400, C.text, 0.5, 95);

  // CTA
  rect(f, 24, 552, 327, 56, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 16);
  text(f, 'Create Account', 128, 568, 16, 700, C.white);

  text(f, 'By signing up, you agree to our Terms & Privacy Policy', 52, 624, 11, 400, C.text, 0.3, 272);
}

// ─── SCREEN 4: ONBOARDING ────────────────────────────────────

async function buildOnboarding(page, offsetX) {
  const f = frame(page, 'S4 — Onboarding', offsetX, 0, 375, 812);

  // Purple-to-dark header (FitCommit pattern)
  const header = frame(f, 'Header', 0, 0, 375, 180, linearGrad(160, [stop(0, C.blueDeep), stop(1, C.bg)]));
  rect(header, 24, 56, 24, 24, rgb(C.white, 0.1), 12);
  text(header, '←', 29, 58, 16, 400, C.text, 0.7);
  text(header, 'Welcome to Fixr', 105, 56, 16, 700, C.text);

  // Step progress bar (thin, FitCommit style)
  rect(f, 24, 100, 327, 3, rgb(C.white, 0.1), 2);
  rect(f, 24, 100, 100, 3, linearGrad(90, [stop(0, C.blue), stop(1, C.blueLight)]), 2);
  text(f, 'Step 1 of 3', 24, 112, 11, 500, C.text, 0.35);

  // Content
  text(f, 'Tell Us About You', 24, 148, 26, 800, C.text);
  text(f, 'This helps us personalize your experience', 24, 182, 13, 400, C.text, 0.5, 300);

  // Trade specialty
  text(f, 'YOUR TRADE', 24, 220, 11, 700, C.text, 0.3);

  const trades = [
    { icon: '🔧', name: 'Plumbing', desc: 'Pipes, faucets, drains' },
    { icon: '⚡', name: 'Electrical', desc: 'Wiring, panels, outlets' },
    { icon: '🏗️', name: 'Carpentry', desc: 'Wood, framing, finishing' },
    { icon: '❄️', name: 'HVAC', desc: 'Heating & cooling systems' },
  ];

  trades.forEach((trade, i) => {
    const isActive = i === 0;
    const ty = 244 + i * 72;
    const tradeCard = frame(f, trade.name, 24, ty, 327, 60,
      isActive ? linearGrad(135, [stop(0, C.blue, 0.15), stop(1, C.blueLight, 0.08)]) : rgb(C.white, 0.05));
    tradeCard.cornerRadius = 16;
    stroke(tradeCard, isActive ? C.blue : C.white, isActive ? 0.4 : 0.08);

    text(f, trade.icon, 40, ty + 16, 24, 400, C.white);
    text(f, trade.name, 80, ty + 10, 15, 600, C.text, 1, 200);
    text(f, trade.desc, 80, ty + 32, 12, 400, C.text, 0.4, 200);

    // Radio circle
    if (isActive) {
      rect(f, 320, ty + 20, 20, 20, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 10);
      text(f, '✓', 324, ty + 22, 12, 700, C.white);
    } else {
      const radio = rect(f, 320, ty + 20, 20, 20, rgb(C.white, 0.06), 10);
      stroke(radio, C.white, 0.2);
    }
  });

  // Continue button
  rect(f, 24, 548, 327, 56, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 16);
  text(f, 'Continue  →', 148, 564, 16, 700, C.white);
}

// ─── SCREEN 5: OWNER HOME ─────────────────────────────────────

async function buildOwnerHome(page, offsetX) {
  const f = frame(page, 'S5 — Owner Home', offsetX, 0, 375, 812);
  rect(f, 75, -80, 280, 280, radialGrad(0.5, 0.5, [stop(0, C.blue, 0.2), stop(1, C.blue, 0)]), 140);
  rect(f, -40, 560, 200, 200, radialGrad(0.5, 0.5, [stop(0, C.orange, 0.15), stop(1, C.orange, 0)]), 100);
  statusBar(f);
  text(f, 'Good morning 👋', 24, 60, 13, 600, C.text, 0.55);
  text(f, 'Marcus', 24, 80, 28, 800, C.text);
  avatar(f, 'MT', 315, 60, 40, C.blue);

  const ctaCard = card(f, 24, 128, 327, 100, 20);
  ctaCard.fills = [{ type: 'SOLID', color: C.white, opacity: 0.05 }];
  stroke(ctaCard, C.blue, 0.15);
  text(ctaCard, 'Got a repair job?', 20, 16, 17, 700, C.text);
  text(ctaCard, 'Post it and get quotes in minutes', 20, 38, 13, 400, C.text, 0.5, 180);
  rect(ctaCard, 195, 28, 112, 40, linearGrad(135, [stop(0, C.orange), stop(1, C.orangeLight)]), 12);
  text(ctaCard, 'Post a Job →', 208, 40, 13, 700, C.white);

  text(f, 'BROWSE BY TRADE', 24, 252, 11, 700, C.text, 0.3);
  const cats = ['🔧 Plumbing', '⚡ Electrical', '🏗️ Carpentry', '❄️ HVAC', '🪟 Windows', '⋯ More'];
  cats.forEach((cat, i) => {
    const col = i % 3, row = Math.floor(i / 3);
    const cx = 24 + col * 106, cy = 276 + row * 87;
    const cc = card(f, cx, cy, 99, 80, 16);
    const parts = cat.split(' ');
    text(f, parts[0], cx + 12, cy + 12, 24, 400, C.white);
    text(f, parts.slice(1).join(' '), cx + 8, cy + 50, 11, 600, C.text, 0.8, 83);
  });

  text(f, 'RECENT ACTIVITY', 24, 464, 11, 700, C.text, 0.3);
  const jobs = [
    { title: 'Leaky kitchen faucet', trade: 'Plumbing', status: 'Quotes in', color: C.blue },
    { title: 'Broken circuit breaker', trade: 'Electrical', status: 'In progress', color: C.amber },
  ];
  jobs.forEach((job, i) => {
    const jy = 488 + i * 92;
    card(f, 24, jy, 327, 80, 16);
    rect(f, 40, jy + 28, 8, 8, rgb(job.color), 4);
    text(f, job.title, 60, jy + 16, 15, 600, C.text, 1, 220);
    text(f, job.trade, 60, jy + 38, 12, 500, C.text, 0.45, 140);
    badge(f, job.status, 248, jy + 24, i === 0 ? 'senior' : 'new');
  });
  tabBar(f, 0);
}

// ─── SCREEN 6: POST A JOB ─────────────────────────────────────

async function buildPostJob(page, offsetX) {
  const f = frame(page, 'S6 — Post a Job', offsetX, 0, 375, 812);
  statusBar(f);
  text(f, '←', 24, 58, 20, 400, C.text);
  text(f, 'Post a Job', 130, 58, 18, 700, C.text);

  const photoZone = card(f, 24, 96, 327, 160, 20);
  photoZone.fills = rgb(C.white, 0.04);
  rect(f, 163, 148, 48, 48, rgb(C.white, 0.1), 24);
  text(f, '+', 180, 152, 28, 300, C.text, 0.4);
  text(f, 'Tap to add photos', 130, 204, 13, 500, C.text, 0.35, 115);
  text(f, 'Up to 5 photos', 142, 222, 11, 400, C.text, 0.25, 90);

  text(f, 'CATEGORY', 24, 278, 11, 700, C.text, 0.3);
  const chips = ['Plumbing', 'Electrical', 'Carpentry', 'HVAC'];
  let cx = 24;
  chips.forEach((chip, i) => {
    const isActive = i === 0;
    const cw = chip.length * 8 + 24;
    const cb = rect(f, cx, 298, cw, 36,
      isActive ? linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]) : rgb(C.white, 0.08), 18);
    if (!isActive) stroke(cb, C.white, 0.1);
    text(f, chip, cx + 12, 306, 13, 600, C.text, isActive ? 1 : 0.6);
    cx += cw + 8;
  });

  text(f, 'DESCRIBE THE PROBLEM', 24, 356, 11, 700, C.text, 0.3);
  card(f, 24, 376, 327, 88, 16);
  text(f, 'e.g. My kitchen faucet has been dripping...', 40, 392, 13, 400, C.text, 0.3, 295);

  text(f, 'SKILL LEVEL', 24, 480, 11, 700, C.text, 0.3);
  rect(f, 24, 500, 155, 44, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 14);
  text(f, '⭐ Junior', 54, 514, 14, 600, C.white);
  const sb = rect(f, 187, 500, 164, 44, rgb(C.white, 0.06), 14);
  stroke(sb, C.white, 0.1);
  text(f, 'Senior Pro', 228, 514, 14, 600, C.text, 0.5);

  text(f, 'LOCATION', 24, 564, 11, 700, C.text, 0.3);
  card(f, 24, 584, 327, 52, 14);
  text(f, '📍  Saint-Jérôme, QC', 40, 600, 14, 500, C.text, 0.7);

  rect(f, 24, 660, 327, 56, linearGrad(135, [stop(0, C.orange), stop(1, C.orangeLight)]), 16);
  text(f, 'Post Job & Get Quotes', 88, 676, 16, 700, C.white);
}

// ─── SCREEN 7: QUOTES RECEIVED ───────────────────────────────

async function buildQuotes(page, offsetX) {
  const f = frame(page, 'S7 — Quotes Received', offsetX, 0, 375, 812);
  statusBar(f);
  text(f, '←', 24, 58, 20, 400, C.text);
  text(f, 'Quotes Received', 112, 58, 18, 700, C.text);

  const pill = rect(f, 24, 94, 327, 48, rgb(C.white, 0.06), 24);
  stroke(pill, C.white, 0.08);
  text(f, '🔧  Leaky kitchen faucet · 3 quotes', 56, 110, 13, 500, C.text, 0.7);

  const workers = [
    { name: 'Jordan L.', rating: '4.9', jobs: '42 jobs', type: 'junior', price: '$75', initials: 'JL', color: C.orange },
    { name: 'Sara M.',   rating: '5.0', jobs: '128 jobs', type: 'senior', price: '$120', initials: 'SM', color: C.blue },
    { name: 'Carlos R.', rating: '4.7', jobs: '67 jobs',  type: 'junior', price: '$85',  initials: 'CR', color: C.green },
  ];
  workers.forEach((w, i) => {
    const wy = 162 + i * 180;
    card(f, 24, wy, 327, 168, 20);
    avatar(f, w.initials, 40, wy + 20, 48, w.color);
    text(f, w.name, 100, wy + 20, 17, 700, C.text);
    badge(f, w.type === 'senior' ? 'Senior Pro' : 'Junior', 100, wy + 44, w.type);
    text(f, '★ ' + w.rating, 100, wy + 72, 13, 600, C.amber);
    text(f, '  ' + w.jobs, 138, wy + 72, 13, 400, C.text, 0.45);
    text(f, w.price, 282, wy + 24, 22, 800, C.text);
    text(f, '/hr', 282, wy + 50, 12, 400, C.text, 0.45);
    rect(f, 40, wy + 120, 143, 36, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 12);
    text(f, 'Accept', 87, wy + 130, 14, 700, C.white);
    const mb = rect(f, 196, wy + 120, 143, 36, rgb(C.white, 0.06), 12);
    stroke(mb, C.white, 0.1);
    text(f, 'Message', 236, wy + 130, 14, 600, C.text, 0.8);
  });
  tabBar(f, 0);
}

// ─── SCREEN 8: WORKER FEED ───────────────────────────────────

async function buildWorkerFeed(page, offsetX) {
  const f = frame(page, 'S8 — Worker Feed', offsetX, 0, 375, 812);
  rect(f, 135, -80, 280, 280, radialGrad(0.5, 0.5, [stop(0, C.blue, 0.2), stop(1, C.blue, 0)]), 140);
  statusBar(f);
  text(f, 'Available Jobs', 24, 60, 22, 700, C.text);
  text(f, 'Near Saint-Jérôme', 24, 86, 13, 500, C.text, 0.45);
  avatar(f, 'JS', 315, 60, 40, C.orange);

  const ec = card(f, 24, 116, 327, 72, 18);
  text(f, "Today's Earnings", 40, 128, 12, 600, C.text, 0.45);
  text(f, '$0.00', 40, 148, 22, 800, C.text);
  const avBg = rect(f, 220, 144, 115, 28, rgb(C.green, 0.15), 14);
  text(f, '● Available', 240, 150, 12, 600, C.greenLight);

  text(f, 'NEARBY JOBS', 24, 208, 11, 700, C.text, 0.3);
  const jobs = [
    { title: 'Leaky kitchen faucet', trade: 'Plumbing', dist: '2.1km', price: '$75/hr', type: 'junior', color: C.blue },
    { title: 'Panel upgrade', trade: 'Electrical', dist: '5.8km', price: '$120/hr', type: 'senior', color: C.amber, locked: true },
    { title: 'Bathroom tile repair', trade: 'Carpentry', dist: '3.4km', price: '$65/hr', type: 'junior', color: C.orange },
  ];
  jobs.forEach((job, i) => {
    const jy = 228 + i * 152;
    card(f, 24, jy, 327, 140, 20);
    rect(f, 40, jy + 16, 80, 80, linearGrad(135, [stop(0, job.color, 0.6), stop(1, C.bgDark)]), 12);
    text(f, job.title, 136, jy + 16, 15, 600, C.text, 1, 195);
    text(f, job.trade, 136, jy + 38, 12, 500, C.text, 0.45, 120);
    text(f, '📍 ' + job.dist, 136, jy + 56, 11, 400, C.text, 0.4);
    badge(f, job.type === 'senior' ? 'Senior Only' : 'Junior OK', 136, jy + 78, job.type);
    text(f, job.price, 136, jy + 108, 15, 700, C.text);
    if (job.locked) {
      rect(f, 24, jy, 327, 140, rgb(C.bg, 0.7), 20);
      const lb = rect(f, 245, jy + 104, 90, 28, rgb(C.white, 0.08), 14);
      stroke(lb, C.white, 0.1);
      text(f, '🔒 Locked', 255, jy + 110, 12, 600, C.text, 0.4);
    } else {
      rect(f, 245, jy + 100, 90, 32, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 12);
      text(f, 'Bid Now', 264, jy + 109, 13, 700, C.white);
    }
  });
  tabBar(f, 1);
}

// ─── SCREEN 9: WORKER PROFILE & HOURS ───────────────────────

async function buildWorkerProfile(page, offsetX) {
  const f = frame(page, 'S9 — Worker Profile', offsetX, 0, 375, 812);
  rect(f, -40, 560, 200, 200, radialGrad(0.5, 0.5, [stop(0, C.orange, 0.15), stop(1, C.orange, 0)]), 100);
  statusBar(f);
  text(f, 'My Profile', 148, 62, 18, 700, C.text);
  avatar(f, 'JS', 167.5, 96, 64, C.orange);
  rect(f, 215, 140, 18, 18, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 9);
  text(f, '✓', 218, 142, 11, 700, C.white);
  text(f, 'Jake Sullivan', 128, 172, 20, 700, C.text);
  badge(f, 'Junior Plumber', 140, 198, 'junior');
  text(f, '📍 Saint-Jérôme, QC', 132, 226, 12, 400, C.text, 0.45, 112);

  const sc = card(f, 24, 256, 327, 68, 18);
  [['47', 'Jobs Done'], ['312h', 'Hours'], ['4.8★', 'Rating']].forEach(([v, l], i) => {
    const sx = 58 + i * 110;
    text(f, v, sx, 272, 18, 800, C.text);
    text(f, l, sx - 6, 296, 11, 500, C.text, 0.45, 90);
    if (i < 2) rect(f, 40 + (i + 1) * 110 - 8, 270, 1, 28, rgb(C.white, 0.1));
  });

  text(f, 'CERTIFICATION PROGRESS', 24, 344, 11, 700, C.text, 0.3);
  const cc = card(f, 24, 364, 327, 164, 20);
  [['Plumbing Fundamentals', 0.78, C.blue], ['Pipefitting', 0.52, C.orange], ['Fixture Installation', 0.35, C.blueLight]].forEach(([n, p, col], i) => {
    const sy = 380 + i * 48;
    text(f, n, 40, sy, 13, 600, C.text, 1, 200);
    text(f, Math.round(p * 100) + '%', 307, sy, 12, 700, col);
    progressBar(f, 40, sy + 20, 295, p, col);
  });

  text(f, '750 of 1000 hours to Journeyman', 40, 520, 12, 500, C.text, 0.4, 280);
  progressBar(f, 40, 538, 295, 0.75, C.orange);

  text(f, 'VERIFIED HOURS', 24, 568, 11, 700, C.text, 0.3);
  [['Pipe replacement', 'Apr 4 · Marc D. (Senior)', '+6h'], ['Faucet install', 'Apr 2 · Lisa P. (Client)', '+4h']].forEach(([j, d, h], i) => {
    const ly = 588 + i * 68;
    card(f, 24, ly, 327, 60, 14);
    text(f, j, 40, ly + 10, 14, 600, C.text, 1, 200);
    text(f, d, 40, ly + 32, 11, 400, C.text, 0.45, 200);
    text(f, h, 298, ly + 18, 15, 700, C.green);
  });
  tabBar(f, 4);
}

// ─── SCREEN 10: MESSAGES ─────────────────────────────────────

async function buildMessages(page, offsetX) {
  const f = frame(page, 'S10 — Messages', offsetX, 0, 375, 812);
  statusBar(f);
  text(f, 'Messages', 138, 60, 20, 700, C.text);

  // Search bar
  const search = frame(f, 'Search', 24, 96, 327, 44, rgb(C.white, 0.06));
  search.cornerRadius = 22; stroke(search, C.white, 0.1);
  text(search, '🔍  Search conversations...', 16, 12, 14, 400, C.text, 0.3, 280);

  text(f, 'RECENT', 24, 160, 11, 700, C.text, 0.3);

  const convos = [
    { name: 'Jordan L.',  preview: 'Sounds good, I can be there at 9am',  time: '2m ago',  unread: 2,  color: C.orange, initials: 'JL' },
    { name: 'Sara M.',    preview: 'The job is complete! Please confirm.',  time: '1h ago',  unread: 1,  color: C.blue,   initials: 'SM' },
    { name: 'Carlos R.',  preview: 'Thanks for the opportunity!',          time: 'Yesterday', unread: 0, color: C.green,  initials: 'CR' },
    { name: 'Support',    preview: 'Your payment of $75 has been released', time: 'Mon',     unread: 0,  color: C.blueLight, initials: '?' },
    { name: 'Mike T.',    preview: 'Can you do Tuesday afternoon?',         time: 'Sun',     unread: 0,  color: C.amber,  initials: 'MT' },
  ];

  convos.forEach((c, i) => {
    const cy = 180 + i * 80;
    if (i > 0) rect(f, 76, cy, 275, 1, rgb(C.white, 0.06));
    avatar(f, c.initials, 24, cy + 12, 48, c.color);
    text(f, c.name, 84, cy + 12, 15, 600, C.text, 1, 190);
    text(f, c.preview, 84, cy + 34, 12, 400, C.text, 0.45, 200);
    text(f, c.time, 302, cy + 12, 11, 400, C.text, 0.35);
    if (c.unread > 0) {
      rect(f, 336, cy + 34, 20, 20, linearGrad(135, [stop(0, C.blue), stop(1, C.blueLight)]), 10);
      text(f, String(c.unread), 341, cy + 38, 11, 700, C.white);
    }
  });
  tabBar(f, 3);
}

// ─── SCREEN 11: NOTIFICATIONS ────────────────────────────────

async function buildNotifications(page, offsetX) {
  const f = frame(page, 'S11 — Notifications', offsetX, 0, 375, 812);
  statusBar(f);
  text(f, 'Notifications', 128, 60, 20, 700, C.text);

  text(f, 'TODAY', 24, 100, 11, 700, C.text, 0.3);

  const notes = [
    { icon: '💰', color: C.green,     title: 'Payment Released',       body: '$75 from Leaky faucet job has been released to your wallet',       time: '2m ago',  unread: true },
    { icon: '🔧', color: C.blue,      title: 'New Quote on Your Job',  body: 'Jordan L. submitted a quote of $75/hr for Leaky kitchen faucet',  time: '18m ago', unread: true },
    { icon: '⭐', color: C.amber,     title: 'New Review',             body: 'Lisa P. left you a 5-star review for Faucet installation',         time: '1h ago',  unread: true },
    { icon: '📋', color: C.blueLight, title: 'Job Update',             body: 'Carlos R. marked your Bathroom tile job as complete',              time: '3h ago',  unread: false },
  ];

  let yPos = 120;
  notes.forEach((n, i) => {
    const noteH = 80;
    const noteBg = frame(f, n.title, 24, yPos, 327, noteH, rgb(C.white, n.unread ? 0.07 : 0.04));
    noteBg.cornerRadius = 16;
    if (n.unread) stroke(noteBg, n.color, 0.2);

    rect(f, 40, yPos + (noteH - 36) / 2, 36, 36, rgb(n.color, 0.15), 10);
    text(f, n.icon, 44, yPos + (noteH - 28) / 2, 20, 400, C.white);
    text(f, n.title, 88, yPos + 12, 14, 600, C.text, 1, 215);
    text(f, n.body, 88, yPos + 32, 11, 400, C.text, 0.45, 215);
    text(f, n.time, 298, yPos + 12, 10, 400, C.text, 0.3);
    if (n.unread) rect(f, 343, yPos + 16, 8, 8, rgb(C.blue), 4);

    yPos += noteH + 8;
  });

  text(f, 'EARLIER', 24, yPos + 8, 11, 700, C.text, 0.3);
  yPos += 28;

  const older = [
    { icon: '✅', color: C.green,  title: 'Job Completed',    body: 'Pipe replacement with Marc D. confirmed — 6hrs logged', time: 'Apr 4' },
    { icon: '🎯', color: C.orange, title: 'Hours Milestone',   body: 'You hit 300 certified hours! Keep going to Journeyman',  time: 'Apr 2' },
  ];
  older.forEach((n) => {
    const nb = frame(f, n.title, 24, yPos, 327, 68, rgb(C.white, 0.04));
    nb.cornerRadius = 16;
    rect(f, 40, yPos + 16, 36, 36, rgb(n.color, 0.12), 10);
    text(f, n.icon, 44, yPos + 18, 20, 400, C.white);
    text(f, n.title, 88, yPos + 10, 14, 600, C.text, 0.7, 215);
    text(f, n.body, 88, yPos + 30, 11, 400, C.text, 0.35, 215);
    text(f, n.time, 298, yPos + 10, 10, 400, C.text, 0.25);
    yPos += 76;
  });

  tabBar(f, 0);
}

// ─── SCREEN 12: SETTINGS ─────────────────────────────────────

async function buildSettings(page, offsetX) {
  const f = frame(page, 'S12 — Settings', offsetX, 0, 375, 812);
  rect(f, -40, 560, 200, 200, radialGrad(0.5, 0.5, [stop(0, C.blue, 0.12), stop(1, C.blue, 0)]), 100);
  statusBar(f);
  text(f, 'Settings', 151, 60, 20, 700, C.text);

  // Profile banner
  const profileCard = card(f, 24, 96, 327, 88, 20);
  avatar(f, 'MT', 36, 120, 56, C.blue);
  text(f, 'Marcus Thompson', 104, 108, 17, 700, C.text);
  badge(f, 'Homeowner', 104, 132, 'senior');
  text(f, 'marcus.t@email.com', 104, 158, 12, 400, C.text, 0.45, 190);
  const editBtn = rect(f, 294, 108, 44, 28, rgb(C.white, 0.08), 14);
  stroke(editBtn, C.white, 0.1);
  text(f, 'Edit', 302, 114, 12, 600, C.text, 0.6);

  // Account section
  sectionLabel(f, 24, 200, 'ACCOUNT');
  settingsRow(f, 24, 218, 327, '👤', 'Edit Profile', 'Name, photo, bio');
  settingsRow(f, 24, 290, 327, '🔔', 'Notifications', 'Manage alerts');
  settingsRow(f, 24, 350, 327, '🔒', 'Privacy & Security', '2FA, data settings');

  // Payment section
  sectionLabel(f, 24, 420, 'PAYMENT');
  settingsRow(f, 24, 438, 327, '💳', 'Payment Methods', 'Cards, wallet');
  settingsRow(f, 24, 498, 327, '📋', 'Transaction History', 'Past payments');
  settingsRow(f, 24, 558, 327, '⭐', 'Subscription', 'Worker Pro plan', 'Active');

  // Support section
  sectionLabel(f, 24, 628, 'SUPPORT');
  settingsRow(f, 24, 646, 327, '❓', 'Help Center', '');
  settingsRow(f, 24, 706, 327, '💬', 'Contact Us', '');

  // Sign out — danger row
  const signOutRow = frame(f, 'Sign Out', 24, 760, 327, 44, rgb(C.red, 0.08));
  signOutRow.cornerRadius = 14;
  stroke(signOutRow, C.red, 0.2);
  text(signOutRow, '⬡ Sign Out', 120, 12, 15, 600, C.red, 0.9);

  tabBar(f, 4);
}

// ─── MAIN ────────────────────────────────────────────────────

(async () => {
  await Promise.all([
    figma.loadFontAsync({ family: 'Inter', style: 'Regular' }),
    figma.loadFontAsync({ family: 'Inter', style: 'Semi Bold' }),
    figma.loadFontAsync({ family: 'Inter', style: 'Bold' }),
    figma.loadFontAsync({ family: 'Inter', style: 'Extra Bold' }),
  ]);

  let page = figma.root.children.find(p => p.name === 'V2 — Improved Design');
  if (page) {
    for (const child of [...page.children]) child.remove();
  } else {
    page = figma.createPage();
    page.name = 'V2 — Improved Design';
  }
  figma.currentPage = page;

  const GAP = 48;
  const W = 375;

  // Row 1: Auth + Onboarding (0–3)
  await buildWelcome(page,       0 * (W + GAP));
  await buildSignIn(page,        1 * (W + GAP));
  await buildSignUp(page,        2 * (W + GAP));
  await buildOnboarding(page,    3 * (W + GAP));

  // Row 2: Core flows (4–7)
  await buildOwnerHome(page,     4 * (W + GAP));
  await buildPostJob(page,       5 * (W + GAP));
  await buildQuotes(page,        6 * (W + GAP));
  await buildWorkerFeed(page,    7 * (W + GAP));

  // Row 3: Profile + Social + Settings (8–11)
  await buildWorkerProfile(page, 8  * (W + GAP));
  await buildMessages(page,      9  * (W + GAP));
  await buildNotifications(page, 10 * (W + GAP));
  await buildSettings(page,      11 * (W + GAP));

  // Row 4: Auth redesign + new profiles (12–13)
  await buildClientProfile(page, 12 * (W + GAP));
  await buildFixrProfile(page,   13 * (W + GAP));

  figma.viewport.scrollAndZoomIntoView(page.children);
  figma.notify('✅ Fixr V2 — 14 screens created on "V2 — Improved Design"!');
  figma.closePlugin();
})();

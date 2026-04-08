// Fixr — OB-0b: Role Selection (Fixer Active)
// Mirrors the Client screen but with Fixer card selected + orange theme

(function() {
Promise.all([
  figma.loadFontAsync({ family: 'Inter', style: 'Regular' }),
  figma.loadFontAsync({ family: 'Inter', style: 'Semi Bold' }),
  figma.loadFontAsync({ family: 'Inter', style: 'Bold' }),
  figma.loadFontAsync({ family: 'Inter', style: 'Extra Bold' }),
]).then(function() {

  var page = figma.currentPage;
  var W = 375, H = 812;

  var C = {
    bg:      { r: 0.051, g: 0.059, b: 0.078 },
    blue:    { r: 0.145, g: 0.388, b: 0.922 },
    blueL:   { r: 0.231, g: 0.510, b: 0.965 },
    orange:  { r: 0.976, g: 0.451, b: 0.086 },
    orangeL: { r: 0.984, g: 0.573, b: 0.235 },
    text:    { r: 0.973, g: 0.980, b: 0.988 },
    white:   { r: 1, g: 1, b: 1 },
  };

  function sl(c, o) { return [{ type: 'SOLID', color: c, opacity: o === undefined ? 1 : o }]; }
  function stp(pos, c, o) { return { position: pos, color: { r: c.r, g: c.g, b: c.b, a: o === undefined ? 1 : o } }; }
  function lG(angle, stops) {
    var rad = (angle * Math.PI) / 180, cos = Math.cos(rad), sin = Math.sin(rad);
    return [{ type: 'GRADIENT_LINEAR',
      gradientTransform: [[cos, sin, (1-cos)/2-sin/2], [-sin, cos, sin/2+(1-cos)/2]],
      gradientStops: stops }];
  }
  function rG(cx, cy, stops) {
    return [{ type: 'GRADIENT_RADIAL',
      gradientTransform: [[0.5,0,cx],[0,0.5,cy]],
      gradientStops: stops }];
  }
  function bdr(n, c, o, w) {
    n.strokes = [{ type: 'SOLID', color: c, opacity: o === undefined ? 0.15 : o }];
    n.strokeWeight = w === undefined ? 1 : w;
    n.strokeAlign = 'INSIDE';
  }
  function R(p, x, y, w, h, fills, cr) {
    var n = figma.createRectangle(); n.x=x; n.y=y;
    n.resize(Math.max(w,1), Math.max(h,1));
    n.fills=fills; n.cornerRadius=cr||0; n.strokes=[];
    p.appendChild(n); return n;
  }
  function E(p, x, y, d, fills) {
    var n = figma.createEllipse(); n.x=x; n.y=y; n.resize(d,d);
    n.fills=fills; n.strokes=[]; p.appendChild(n); return n;
  }
  function F(p, name, x, y, w, h, fills) {
    var n = figma.createFrame(); n.name=name; n.x=x; n.y=y;
    n.resize(Math.max(w,1), Math.max(h,1));
    n.fills=fills||sl(C.bg); n.clipsContent=true;
    if(p) p.appendChild(n); return n;
  }
  function T(p, str, x, y, sz, wt, col, o, mw) {
    var n = figma.createText();
    var st = wt>=800?'Extra Bold':wt>=700?'Bold':wt>=600?'Semi Bold':'Regular';
    n.fontName = { family: 'Inter', style: st };
    n.characters = String(str);
    n.fontSize = sz;
    n.fills = [{ type: 'SOLID', color: col||C.text, opacity: o===undefined?1:o }];
    n.x=x; n.y=y;
    if(mw){ n.textAutoResize='HEIGHT'; n.resize(mw, 20); }
    p.appendChild(n); return n;
  }

  // Remove old if exists
  for (var ri = 0; ri < page.children.length; ri++) {
    if (page.children[ri].name === 'OB-0b — Choose Role (Fixer)') {
      page.children[ri].remove(); break;
    }
  }

  // Position: find OB-0 and sit right next to it
  var ob0 = null;
  for (var fi = 0; fi < page.children.length; fi++) {
    if (page.children[fi].name === 'OB-0 — Choose Role') { ob0 = page.children[fi]; break; }
  }

  var ox = ob0 ? ob0.x + W + 48 : 800;
  var oy = ob0 ? ob0.y : 0;

  // Shift everything that was already at that x position
  for (var si = 0; si < page.children.length; si++) {
    var sc = page.children[si];
    if (sc.name !== 'OB-0 — Choose Role' && sc.x >= ox) { sc.x += W + 48; }
  }

  // ── Build the frame ─────────────────────────────────────────
  var s = F(null, 'OB-0b — Choose Role (Fixer)', ox, oy, W, H, sl(C.bg));
  page.appendChild(s);

  // Status bar
  var sb = F(s, 'Status Bar', 0, 0, W, 48, sl(C.bg, 0));
  T(sb, '9:41', 28, 16, 15, 600, C.text);
  T(sb, 'WiFi', 290, 18, 11, 400, C.text, 0.6);

  // Orange ambient glow (vs blue on client screen)
  R(s, 40, -40, 295, 295, rG(0.5, 0.5, [stp(0, C.orange, 0.14), stp(1, C.orange, 0)]), 148);

  // Logo icon — orange gradient
  R(s, 148, 52, 64, 64, lG(135, [stp(0, C.orange), stp(1, C.blue)]), 18);
  T(s, 'Fixr', 154, 124, 26, 800, C.text);

  T(s, 'Welcome! How will you use Fixr?', 28, 168, 16, 700, C.text, 0.88, W-56);
  T(s, 'You can switch roles anytime in Settings.', 28, 192, 12, 400, C.text, 0.38, W-56);

  // ── CLIENT card — INACTIVE ───────────────────────────────────
  var cc = F(s, 'Card Client (inactive)', 24, 228, W-48, 92, sl(C.white, 0.04));
  cc.cornerRadius = 18;
  bdr(cc, C.white, 0.08);
  var cRing = E(cc, 16, 26, 40, sl(C.blue, 0.08));
  bdr(cRing, C.blue, 0.15);
  T(cc, 'H', 28, 34, 20, 700, C.blue, 0.45);
  T(cc, 'I am a Client', 68, 20, 15, 600, C.text, 0.5);
  T(cc, 'I need repairs done at home', 68, 42, 12, 400, C.text, 0.28, W-130);
  // Empty radio circle
  var offDot = E(cc, W-84, 34, 24, sl(C.white, 0.05));
  bdr(offDot, C.white, 0.12);

  // ── FIXER card — ACTIVE ──────────────────────────────────────
  var fc = F(s, 'Card Fixer (active)', 24, 332, W-48, 92, sl(C.orange, 0.1));
  fc.cornerRadius = 18;
  bdr(fc, C.orange, 0.5, 2);
  // Subtle inner glow
  R(fc, 0, 0, W-48, 92, rG(0, 0.5, [stp(0, C.orange, 0.07), stp(1, C.orange, 0)]), 18);
  var fRing = E(fc, 16, 26, 40, sl(C.orange, 0.18));
  bdr(fRing, C.orange, 0.3);
  T(fc, 'W', 27, 33, 20, 700, C.orange, 0.9);
  T(fc, 'I am a Fixer', 68, 20, 15, 700, C.text);
  T(fc, 'I repair and build my trade career', 68, 42, 12, 400, C.text, 0.55, W-130);
  // Filled orange checkmark
  E(fc, W-84, 34, 24, lG(135, [stp(0, C.orange), stp(1, C.orangeL)]));
  T(fc, 'v', W-78, 36, 12, 700, C.white);

  // ── Primary CTA — orange for Fixer ───────────────────────────
  R(s, 24, 452, W-48, 52, lG(135, [stp(0, C.orange), stp(1, C.orangeL)]), 15);
  T(s, 'Continue as Fixer', 105, 467, 15, 700, C.white);

  // ── Ghost CTA — client (secondary) ───────────────────────────
  var ghost = R(s, 24, 516, W-48, 52, sl(C.white, 0.06), 15);
  bdr(ghost, C.white, 0.12);
  T(s, 'Continue as Client', 107, 531, 14, 600, C.text, 0.55);

  T(s, 'Already have an account?  Sign In', 88, 590, 13, 400, C.text, 0.4, 200);

  figma.viewport.scrollAndZoomIntoView([s]);
  figma.notify('Done — Fixer role selection screen created!', { timeout: 3000 });
  figma.closePlugin();

}).catch(function(e) { figma.closePlugin('Error: ' + e.message); });
})();

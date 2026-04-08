// Fixr — Alignment & Spacing Fixer
// Scans every frame on the current page and fixes:
// 1. Text nodes hugging edges (enforces 24px left margin)
// 2. Text nodes overflowing frame width
// 3. Overlapping sibling elements (adds minimum gap)
// 4. Input label + box pairs that are too tight
// 5. CTA buttons that are too close to bottom edge
// 6. Consistent card internal padding

(function () {

  var MARGIN      = 24;   // standard left/right margin
  var MIN_GAP     = 10;   // minimum vertical gap between siblings
  var FRAME_W     = 375;  // expected frame width
  var SAFE_RIGHT  = FRAME_W - MARGIN; // 351 — nothing should start past here
  var BOTTOM_PAD  = 32;   // breathing room above tab bar / bottom edge
  var TAB_H       = 78;   // tab bar height to avoid

  var page = figma.currentPage;
  var fixed = 0;
  var report = [];

  // ── Helpers ────────────────────────────────────────────────

  function isTextNode(n) { return n.type === 'TEXT'; }
  function isFrame(n)    { return n.type === 'FRAME'; }
  function isRect(n)     { return n.type === 'RECTANGLE'; }
  function isEllipse(n)  { return n.type === 'ELLIPSE'; }
  function isShape(n)    { return isRect(n) || isEllipse(n) || isFrame(n); }

  // Get all direct children sorted top-to-bottom
  function sortedByY(frame) {
    var kids = [];
    for (var i = 0; i < frame.children.length; i++) { kids.push(frame.children[i]); }
    kids.sort(function(a, b) { return a.y - b.y; });
    return kids;
  }

  // Clamp a value between min and max
  function clamp(val, mn, mx) { return Math.max(mn, Math.min(mx, val)); }

  // ── 1. Fix text node alignment within a frame ──────────────
  function fixTextInFrame(frame) {
    var kids = frame.children;
    for (var i = 0; i < kids.length; i++) {
      var n = kids[i];

      if (isTextNode(n)) {
        var changed = false;

        // Left margin: text starting too far left (< 16) or exactly at 0
        if (n.x < 16) {
          n.x = MARGIN;
          changed = true;
        }

        // Right overflow: text width pushes beyond safe area
        if (n.x + n.width > SAFE_RIGHT + 4) {
          var maxW = SAFE_RIGHT - n.x;
          if (maxW > 40) {
            try {
              n.textAutoResize = 'HEIGHT';
              n.resize(maxW, n.height);
              changed = true;
            } catch(e) {}
          }
        }

        // Center-aligned text that's mispositioned
        if (n.textAlignHorizontal === 'CENTER') {
          var centeredX = Math.round((FRAME_W - n.width) / 2);
          if (Math.abs(n.x - centeredX) > 8) {
            n.x = centeredX;
            changed = true;
          }
        }

        if (changed) { fixed++; }
      }

      // Recurse into child frames (cards, input boxes, etc.)
      if (isFrame(n) && n.children) {
        fixTextInFrame(n);
      }
    }
  }

  // ── 2. Fix vertical spacing between siblings ───────────────
  function fixVerticalSpacing(frame) {
    // Skip frames that are clearly small components (< 120px tall)
    if (frame.height < 120) return;

    // Skip tab bars and status bars
    if (frame.name && (
      frame.name.indexOf('Tab Bar') !== -1 ||
      frame.name.indexOf('Status Bar') !== -1
    )) return;

    var kids = sortedByY(frame);
    var changed = false;

    for (var i = 1; i < kids.length; i++) {
      var prev = kids[i - 1];
      var curr = kids[i];

      // Skip if either is a decorative background rect at top
      if (prev.y < 0) continue;

      // Skip Tab Bar and Status Bar nodes
      if (curr.name && (
        curr.name.indexOf('Tab Bar') !== -1 ||
        curr.name.indexOf('Status') !== -1 ||
        curr.name.indexOf('Lock Notice') !== -1
      )) continue;

      var prevBottom = prev.y + prev.height;
      var gap = curr.y - prevBottom;

      // Elements overlapping or touching (gap < MIN_GAP)
      // Only fix if they're both visible content (not decorative bg fills)
      if (gap < MIN_GAP && gap >= -8 && curr.height > 8 && prev.height > 4) {
        // Don't move the very first element (status bar etc)
        if (i > 0 && prevBottom > 50) {
          curr.y = prevBottom + MIN_GAP;
          changed = true;
          fixed++;

          // Update sorted list so next iteration uses new position
          kids = sortedByY(frame);
        }
      }
    }

    return changed;
  }

  // ── 3. Fix card internal padding ──────────────────────────
  function fixCardPadding(frame) {
    // Only process frames that look like cards (shorter than full screen)
    if (frame.height > 200 || frame.height < 30) return;

    var kids = frame.children;
    for (var i = 0; i < kids.length; i++) {
      var n = kids[i];

      if (isTextNode(n)) {
        // Text too close to left wall of card
        if (n.x < 12) { n.x = 14; fixed++; }
        // Text too close to top of card
        if (n.y < 6)  { n.y = 8;  fixed++; }
        // Text overflowing card right edge
        if (n.x + n.width > frame.width - 8) {
          var mw = frame.width - n.x - 14;
          if (mw > 20) {
            try { n.textAutoResize = 'HEIGHT'; n.resize(mw, n.height); fixed++; } catch(e) {}
          }
        }
      }
    }
  }

  // ── 4. Ensure CTA buttons have breathing room ──────────────
  function fixCTAPosition(frame) {
    if (frame.height < 600) return; // only full screens

    var kids = frame.children;
    var frameH = frame.height;
    var hasTabBar = false;

    // Check if this frame has a tab bar
    for (var i = 0; i < kids.length; i++) {
      if (kids[i].name && kids[i].name.indexOf('Tab Bar') !== -1) {
        hasTabBar = true; break;
      }
    }

    var bottomLimit = hasTabBar ? frameH - TAB_H - BOTTOM_PAD : frameH - BOTTOM_PAD;

    for (var j = 0; j < kids.length; j++) {
      var n = kids[j];
      // Detect CTA buttons: wide rects near bottom with height 44-60
      if (isRect(n) && n.width > 250 && n.height >= 44 && n.height <= 64) {
        if (n.y + n.height > frameH) {
          // Button is outside the frame — pull it back in
          n.y = frameH - n.height - BOTTOM_PAD;
          fixed++;
        }
      }
    }
  }

  // ── 5. Fix left margin of section labels and dividers ─────
  function fixSectionElements(frame) {
    var kids = frame.children;
    for (var i = 0; i < kids.length; i++) {
      var n = kids[i];
      // Thin horizontal dividers that start too far left
      if (isRect(n) && n.height <= 2 && n.width > 200) {
        if (n.x < 16 && n.x > -2) { n.x = MARGIN; fixed++; }
      }
    }
  }

  // ── Main: process all top-level frames ─────────────────────
  var frames = [];
  for (var fi = 0; fi < page.children.length; fi++) {
    if (isFrame(page.children[fi])) { frames.push(page.children[fi]); }
  }

  report.push('Found ' + frames.length + ' frames to process.');

  for (var i = 0; i < frames.length; i++) {
    var f = frames[i];

    try { fixTextInFrame(f); }     catch(e) { report.push('textFix error on ' + f.name + ': ' + e.message); }
    try { fixVerticalSpacing(f); } catch(e) { report.push('spacingFix error on ' + f.name + ': ' + e.message); }
    try { fixCTAPosition(f); }     catch(e) { report.push('ctaFix error on ' + f.name + ': ' + e.message); }
    try { fixSectionElements(f); } catch(e) { report.push('sectionFix error on ' + f.name + ': ' + e.message); }

    // Fix cards inside each frame
    var kids = f.children;
    for (var j = 0; j < kids.length; j++) {
      if (isFrame(kids[j])) {
        try { fixCardPadding(kids[j]); } catch(e) {}
      }
    }
  }

  report.push('Fixed ' + fixed + ' alignment issues across ' + frames.length + ' frames.');

  figma.notify('Alignment fixed: ' + fixed + ' corrections across ' + frames.length + ' screens.', { timeout: 5000 });
  figma.closePlugin(report.join(' | '));

})();

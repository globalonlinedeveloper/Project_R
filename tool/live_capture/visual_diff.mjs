// OPTIONAL stretch: rough design-vs-live visual diff.
//
// Usage: node visual_diff.mjs --shots screenshots --design design_screens --out screenshots/diff
//
// Best-effort ONLY. The design shots and the live captures are different app
// states at different pixel sizes, so this is a visual-overlay AID (heatmap +
// side-by-side), not a pass/fail gate. Never throws the run: any bad pair is
// skipped. Skips cleanly if the design dir is absent (design_screens is not in
// the repo — see README). No native deps: nearest-neighbour resample in JS.

import fs from 'node:fs';
import path from 'node:path';
import { PNG } from 'pngjs';
import pixelmatch from 'pixelmatch';

const arg = (name, def) => {
  const i = process.argv.indexOf('--' + name);
  return i >= 0 && process.argv[i + 1] ? process.argv[i + 1] : def;
};
const SHOTS = arg('shots', 'screenshots');
const DESIGN = arg('design', 'design_screens');
const OUT = arg('out', path.join(SHOTS, 'diff'));
const WIDTH = parseInt(arg('width', '360'), 10);

if (!fs.existsSync(DESIGN)) {
  console.log(`[diff] design dir '${DESIGN}' not found — skipping visual diff (this is expected in CI unless the design set is provided).`);
  process.exit(0);
}
fs.mkdirSync(OUT, { recursive: true });

// SCREEN_MAP order == design files sorted by name (the owner's timestamped shots).
const designFiles = fs.readdirSync(DESIGN).filter((f) => /\.png$/i.test(f)).sort();
const designByNumber = (num) => (num >= 1 && num <= designFiles.length ? path.join(DESIGN, designFiles[num - 1]) : null);

function readPNG(p) { return PNG.sync.read(fs.readFileSync(p)); }

// Nearest-neighbour resample to a fixed width, height scaled to preserve aspect.
function resizeToWidth(src, w) {
  const h = Math.max(1, Math.round((src.height / src.width) * w));
  const dst = new PNG({ width: w, height: h });
  for (let y = 0; y < h; y++) {
    const sy = Math.min(src.height - 1, Math.floor((y / h) * src.height));
    for (let x = 0; x < w; x++) {
      const sx = Math.min(src.width - 1, Math.floor((x / w) * src.width));
      const si = (sy * src.width + sx) * 4;
      const di = (y * w + x) * 4;
      dst.data[di] = src.data[si];
      dst.data[di + 1] = src.data[si + 1];
      dst.data[di + 2] = src.data[si + 2];
      dst.data[di + 3] = src.data[si + 3];
    }
  }
  return dst;
}

function cropHeight(img, h) {
  if (img.height === h) return img;
  const dst = new PNG({ width: img.width, height: h });
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < img.width; x++) {
      const si = (y * img.width + x) * 4;
      const di = (y * img.width + x) * 4;
      if (y < img.height) {
        dst.data[di] = img.data[si]; dst.data[di + 1] = img.data[si + 1];
        dst.data[di + 2] = img.data[si + 2]; dst.data[di + 3] = img.data[si + 3];
      } else { dst.data[di + 3] = 255; }
    }
  }
  return dst;
}

const manifestPath = path.join(SHOTS, 'manifest.json');
if (!fs.existsSync(manifestPath)) { console.log('[diff] no manifest.json in shots dir — run capture.mjs first.'); process.exit(0); }
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

const rows = [];
for (const m of manifest.routes) {
  if (!m.design || !m.design.length || !m.frames || !m.frames.length) continue;
  const livePath = path.join(SHOTS, m.frames[0]);
  const designPath = designByNumber(m.design[0]);
  if (!designPath || !fs.existsSync(livePath)) continue;
  try {
    let a = resizeToWidth(readPNG(designPath), WIDTH);   // design
    let b = resizeToWidth(readPNG(livePath), WIDTH);     // live
    const h = Math.min(a.height, b.height);
    a = cropHeight(a, h); b = cropHeight(b, h);
    const diff = new PNG({ width: WIDTH, height: h });
    const mismatch = pixelmatch(a.data, b.data, diff.data, WIDTH, h, { threshold: 0.15 });
    const pct = ((mismatch / (WIDTH * h)) * 100).toFixed(1);

    // Composite: design | live | diff
    const comp = new PNG({ width: WIDTH * 3 + 8, height: h });
    const blit = (img, ox) => {
      for (let y = 0; y < h; y++) for (let x = 0; x < WIDTH; x++) {
        const si = (y * WIDTH + x) * 4, di = (y * comp.width + (x + ox)) * 4;
        comp.data[di] = img.data[si]; comp.data[di + 1] = img.data[si + 1];
        comp.data[di + 2] = img.data[si + 2]; comp.data[di + 3] = 255;
      }
    };
    blit(a, 0); blit(b, WIDTH + 4); blit(diff, WIDTH * 2 + 8);
    const compName = `diff_${m.n}_${path.basename(m.frames[0], '.png')}.png`;
    fs.writeFileSync(path.join(OUT, compName), PNG.sync.write(comp));
    rows.push({ n: m.n, route: m.route, design: m.design[0], pct: parseFloat(pct), comp: compName });
    console.log(`[diff] ${m.n} ${m.route} vs design #${m.design[0]} -> ${pct}% mismatch`);
  } catch (e) { console.log(`[diff] skip ${m.n} (${e.message})`); }
}

rows.sort((x, y) => y.pct - x.pct);
let md = `# Design-vs-live visual diff (rough overlay)\n\nComposite = **design | live | diff-heatmap**, each resized to ${WIDTH}px wide. `;
md += `Higher % = more different (expect high values: different states/sizes). Aid only, not a gate.\n\n`;
md += `| # | Route | Design shot | Mismatch % | Composite |\n|---|---|---|---|---|\n`;
for (const r of rows) md += `| ${r.n} | \`${r.route}\` | #${r.design} | ${r.pct}% | ${r.comp} |\n`;
fs.writeFileSync(path.join(OUT, 'DIFF_INDEX.md'), md);
console.log(`[diff] wrote ${rows.length} composites -> ${OUT}`);

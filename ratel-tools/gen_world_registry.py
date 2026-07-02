#!/usr/bin/env python3
"""Generate lib/core/theme/world_registry.dart from the authoritative design
THEMES() registry. The design bundle lives OUTSIDE the repo (owner's
`Ratel App.dc.html`), so this runs locally when the design changes — not in CI.

Usage: python3 ratel-tools/gen_world_registry.py "/path/to/Ratel App.dc.html"
"""
import re, sys, pathlib
DESIGN = sys.argv[1] if len(sys.argv) > 1 else \
    "Apps/Ratel Learning App Development/Ratel App.dc.html"
OUT = pathlib.Path(__file__).resolve().parents[1] / "lib/core/theme/world_registry.dart"
ORDER = ['--page','--bg','--bg2','--surface','--surface2','--text','--muted',
  '--accent','--accent2','--ink','--border','--good','--bad','--gold','--shadow']
FIELD = {t: t.lstrip('-').replace('-', '') if t not in ('--bg2','--surface2') else
         ('bg2' if t=='--bg2' else 'surface2') for t in ORDER}
FIELD.update({'--page':'page','--bg':'bg','--bg2':'bg2','--surface':'surface',
  '--surface2':'surface2','--text':'text','--muted':'muted','--accent':'accent',
  '--accent2':'accent2','--ink':'ink','--border':'border','--good':'good',
  '--bad':'bad','--gold':'gold','--shadow':'shadow'})
FREE = {'light', 'savanna'}

def to_argb(v):
    v = v.strip()
    mh = re.fullmatch(r'#([0-9A-Fa-f]{3,8})', v)
    if mh:
        h = mh.group(1)
        if len(h) == 3: h = ''.join(c*2 for c in h); return ('FF'+h).upper()
        if len(h) == 6: return ('FF'+h).upper()
        if len(h) == 8: return (h[6:8]+h[0:6]).upper()
        raise ValueError(v)
    mr = re.fullmatch(r'rgba?\(([^)]*)\)', v)
    if mr:
        p = [x.strip() for x in mr.group(1).split(',')]
        r, g, b = (int(round(float(x))) for x in p[0:3])
        a = float(p[3]) if len(p) >= 4 else 1.0
        return '%02X%02X%02X%02X' % (int(round(a*255)), r, g, b)
    raise ValueError("unparseable color: " + v)

def luminance(argb):
    r, g, b = int(argb[2:4],16)/255, int(argb[4:6],16)/255, int(argb[6:8],16)/255
    return 0.2126*r + 0.7152*g + 0.0722*b

def main():
    src = open(DESIGN, encoding='utf-8', errors='replace').read()
    block = re.search(r'THEMES\(\)\{\s*return\s*\{(.*?)\}\s*;\s*\}', src, re.S).group(1)
    entries = re.findall(
        r'(\w+)\s*:\s*\{\s*label:\'([^\']*)\',\s*vehicle:\'([^\']*)\','
        r'\s*backdrop:\'([^\']*)\',\s*vars:\{([^}]*)\}\s*\}', block)
    L = ["// GENERATED — do not edit by hand. Source of truth: the design",
         "// `THEMES()` registry in Apps/Ratel Learning App Development/Ratel App.dc.html",
         "// (L2178-2242). Regenerate: ratel-tools/gen_world_registry.py.",
         "//", "// The 31 selectable theme worlds (2 free: light, savanna; 29 Pro).",
         "import 'package:flutter/widgets.dart';", "", "import 'world_theme.dart';", "",
         "/// Ids of the FREE worlds (design `FREE=['light','savanna']`, L3248).",
         "const Set<String> kFreeWorldIds = <String>{'light', 'savanna'};", "",
         "/// All 31 theme worlds, keyed by id, in design order.",
         "const Map<String, ThemeWorld> kThemeWorlds = <String, ThemeWorld>{"]
    for tid, label, vehicle, backdrop, blob in entries:
        pairs = dict(re.findall(r'\'(--[\w-]+)\':\'([^\']*)\'', blob))
        argb = {t: to_argb(pairs[t]) for t in ORDER}
        L.append(f"  '{tid}': ThemeWorld(")
        L.append(f"    id: '{tid}', label: {label!r}, vehicle: {vehicle!r}, backdrop: '{backdrop}',")
        L.append(f"    isFree: {str(tid in FREE).lower()}, isDark: {str(luminance(argb['--bg'])<0.5).lower()},")
        L.append("    palette: WorldPalette(")
        L.append("      " + " ".join(f"{FIELD[t]}: Color(0x{argb[t]})," for t in ORDER))
        L.append("    ),"); L.append("  ),")
    L.append("};"); L.append("")
    OUT.write_text("\n".join(L))
    print(f"wrote {OUT} — {len(entries)} worlds")

if __name__ == "__main__":
    main()

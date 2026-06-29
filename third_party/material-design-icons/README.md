# Material Design Icons (vendored)

Source: https://github.com/google/material-design-icons @ `30f8fddd293b1f0189896dc4aaecdfaba1d37ae0`
License: Apache-2.0 (see `LICENSE` in this folder).

## What ships in the app
`assets/fonts/MaterialIcons-Regular.ttf` (classic filled set, ~349 KB) is bundled
and declared in `pubspec.yaml` as the **`RatelMaterialIcons`** font family. The app
references it ONLY through `RatelIcons` (`lib/core/theme/ratel_icons.dart`) so every
glyph the UI uses comes from this repo-controlled asset — no CDN, no implicit source.
`flutter build web --tree-shake-icons` subsets the font to just the used glyphs.

## The full index (use any icon, whenever required)
The `*.codepoints` files here are the complete **name → hex codepoint** maps for every
Material icon style (Regular/Outlined/Round/Sharp/TwoTone). To adopt a new icon:

1. Find its codepoint, e.g. `grep '^settings ' MaterialIcons-Regular.codepoints` → `e8b8`.
2. If it's in the filled set (MaterialIcons-Regular), just add a const to `RatelIcons`:
   `static const IconData settings = IconData(0xe8b8, fontFamily: 'RatelMaterialIcons');`
3. For a different *style* (outlined / rounded / sharp), fetch that variable font once
   (kept OUT of git history to avoid permanent bloat — ~9–15 MB each):

   ```bash
   git clone --depth 1 --filter=blob:none --sparse https://github.com/google/material-design-icons.git mdi
   git -C mdi checkout HEAD -- "variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf"
   cp "mdi/variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf" assets/fonts/MaterialSymbolsRounded.ttf
   ```
   then declare it in `pubspec.yaml` (`family: MaterialSymbolsRounded`) and add the
   `RatelIcons` const with that family + the codepoint from `MaterialIconsRound-Regular.codepoints`.


## Glyphs currently promoted into `RatelIcons`

The app draws these via `lib/core/theme/ratel_icons.dart`, all from the bundled
filled `MaterialIcons-Regular.ttf` (no extra font data shipped):

| `RatelIcons` member | Material name | Codepoint |
|---|---|---|
| `arrowBack` | `arrow_back` | U+E5C4 |
| `close` | `close` | U+E5CD |
| `markEmailUnread` | `mark_email_unread` | U+F18A |
| `notifications` | `notifications` | U+E7F4 |
| `palette` | `palette` | U+E40A |
| `arrowDropDown` | `arrow_drop_down` | U+E5C5 |

Stat / gamification (🔥 💎 🏆 ⚡), brand (🦡) and lesson-content emoji are
intentionally NOT icon-font glyphs — they stay colourful.

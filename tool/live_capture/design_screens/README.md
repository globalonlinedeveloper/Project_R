# Owner design_screens (source of truth for the design-vs-live diff)

The 68 owner design shots, mapped 1..68 by filename order in
`Apps/RATEL/design_conformance/SCREEN_MAP.md`. `visual_diff.mjs` sorts these by
name and 1-indexes them, so file order == SCREEN_MAP number. Committed here so
the `screenshots-live` workflow can generate design|live|diff heatmaps in CI.

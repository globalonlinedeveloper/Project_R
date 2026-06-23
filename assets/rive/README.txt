Rive mascot rig (R-L18 / C24) — asset contract.

Drop the real mascot rig here as `mascot.riv`. It MUST be a pure-VECTOR Rive
file: valid "RIVE" header, <= 256 KB, and NO embedded raster images (PNG/JPEG).
The build-time test `test/features/mascot/riv_contract_test.dart` enforces this
on every `.riv` in this folder. Until then, lib/features/mascot/MascotView ships
a programmatic placeholder mascot (MotionTier-aware). When the real rig lands,
declare `assets/rive/mascot.riv` in pubspec.yaml and render it via RiveAnimation
inside MascotView (behind the same MotionTier gate; verify rive web support in CI).

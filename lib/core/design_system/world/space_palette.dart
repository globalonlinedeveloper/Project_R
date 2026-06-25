import 'package:flutter/material.dart';
import '../tokens/ratel_color_tokens.dart';

/// Deep-space "Galaxy" palette — the LOCKED Space-world look (galaxy_home_v9).
///
/// design_system is the sanctioned home for raw `Color(0x..)` literals (R-N6);
/// feature widgets read these named colors through the active [WorldTheme],
/// never as literals, so the token-lint stays green. Every value here is copied
/// from the approved prototype spec (`galaxy_home_flutter_spec.md` §1).
@immutable
class SpacePalette {
  const SpacePalette._();

  // ---- Core surfaces ----
  static const Color phoneBg = Color(0xFF05060F); // deep-space base
  static const Color bottomBar = Color(0xB3080A1A); // rgba(8,10,26,.70)
  static const Color sheetTop = Color(0xFF0C1330);
  static const Color sheetBottom = Color(0xFF070A1C);
  static const Color skeleton = Color(0xFF070A18);
  static const Color scrim = Color(0x8C04050C); // rgba(4,5,12,.55)

  // ---- Teal pod / HUD accent family ----
  static const Color teal = Color(0xFF8FF0D6); // primary mint
  static const Color tealDeep = Color(0xFF16A085);
  static const Color tealDarker = Color(0xFF0A5E4E);
  static const Color tealText = Color(0xFFBFF7E4);
  static const Color tealInk = Color(0xFF06241D);

  // ---- HUD text / labels ----
  static const Color hudText = Color(0xFFEEF3FF);
  static const Color hudMuted = Color(0xFF9AB0FF);
  static const Color langText = Color(0xFFDBE5FF);

  // ---- Path / planet / nav ----
  static const Color pathIdle = Color(0x38A0B4FF); // rgba(160,180,255,.22)
  static const Color pathDone = Color(0x8C7FF0D6); // rgba(127,240,214,.55)
  static const Color navInactive = Color(0xFF7E88A6);

  // ---- Accents ----
  static const Color streakAtRisk = Color(0xFFFFB14A);
  static const Color energyGlow = Color(0xFF15C8FF);
  static const Color energyCore = Color(0xFFEAFDFF);
  static const Color bellBadge = Color(0xFFD85A30);
  static const Color crownGold = Color(0xFFFFE08A);
  static const Color checkpoint = Color(0xFFEF9F27);
  static const Color star = Color(0xFFEAF2FF);
  static const Color gemA = Color(0xFFDCC6FF);
  static const Color gemB = Color(0xFF7FD6FF);
  static const Color gemC = Color(0xFF6F7BFF);

  /// Whole-app semantic token set for the Space world (dark-space tuned). Used
  /// app-wide so every screen re-skins consistently when Space is selected.
  static const RatelColorTokens tokens = RatelColorTokens(
    brightness: Brightness.dark,
    primary: teal,
    onPrimary: tealInk,
    accent: Color(0xFFFFC74D),
    onAccent: Color(0xFF211400),
    surface: phoneBg,
    surfaceVariant: Color(0xFF101633),
    onSurface: hudText,
    onSurfaceVariant: hudMuted,
    outline: Color(0xFF6E7BB0),
    success: Color(0xFF6FD68A),
    onSuccess: Color(0xFF00210A),
    danger: Color(0xFFFFB4AB),
    onDanger: Color(0xFF410002),
  );
}
// Traceability: R-WT2 R-WT4

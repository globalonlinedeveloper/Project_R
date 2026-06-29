import 'package:flutter/widgets.dart';

/// Self-hosted Material icon glyphs for Ratel.
///
/// These [IconData] constants point at the **vendored** `MaterialIcons-Regular`
/// font (Apache-2.0, from github.com/google/material-design-icons), bundled at
/// `assets/fonts/MaterialIcons-Regular.ttf` and declared in `pubspec.yaml` as
/// the `RatelMaterialIcons` family — so the app's own iconography ships from a
/// repo-controlled asset, never an external/CDN source (charter: independent).
///
/// Codepoints are the official values from the font's `.codepoints` index (see
/// `third_party/material-design-icons/`). `const` IconData lets
/// `flutter build web --tree-shake-icons` subset the font to only used glyphs.
///
/// `uses-material-design: true` stays enabled in pubspec for Flutter's own
/// framework-internal glyphs (e.g. default scrollbars/dialog affordances); these
/// constants govern the glyphs RATEL'S OWN widgets draw.
class RatelIcons {
  const RatelIcons._();

  static const String fontFamily = 'RatelMaterialIcons';

  /// Back / up navigation. Mirrors in RTL like Material `arrow_back` (U+E5C4).
  static const IconData arrowBack =
      IconData(0xe5c4, fontFamily: fontFamily, matchTextDirection: true);

  /// Dismiss / close. Material `close` (U+E5CD).
  static const IconData close = IconData(0xe5cd, fontFamily: fontFamily);

  /// Unread-mail glyph for the auth "check your inbox" surfaces.
  /// Material `mark_email_unread` (U+F18A).
  static const IconData markEmailUnread =
      IconData(0xf18a, fontFamily: fontFamily);
}

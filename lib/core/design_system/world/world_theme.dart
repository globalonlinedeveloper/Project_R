import 'package:flutter/material.dart';
import '../tokens/ratel_color_tokens.dart';
import 'space_palette.dart';

/// The selectable "worlds". Classic = the default teal/honey look used for
/// Login/Welcome and shipped today; Space = the galaxy look (theme #1 of the
/// additive-pack roadmap: Ocean/Nature land later as more [WorldThemeId]s).
enum WorldThemeId { classic, space }

/// Display vocabulary that re-skins copy per world (so the same screen reads
/// naturally in either skin). Kept tiny for now; grows as packs are added.
@immutable
class WorldVocabulary {
  const WorldVocabulary({
    required this.travellerName,
    required this.journeyWord,
    required this.continueWord,
  });

  /// The avatar/traveller noun: "Ratel" (classic) / "Ratel pod" (space).
  final String travellerName;

  /// The map/journey noun: "lessons" (classic) / "galaxy" (space).
  final String journeyWord;

  /// CTA verb for resuming: "Continue" / "Locate".
  final String continueWord;
}

/// One selectable world = an app-wide semantic token set + vocabulary + a
/// traveller skin id. This is the template seam: adding a world is adding a
/// [WorldTheme] entry (palette + painters keyed off [id] + vocabulary).
@immutable
class WorldTheme {
  const WorldTheme({
    required this.id,
    required this.label,
    required this.tokens,
    required this.vocabulary,
  });

  final WorldThemeId id;
  final String label;
  final RatelColorTokens tokens;
  final WorldVocabulary vocabulary;

  bool get isSpace => id == WorldThemeId.space;

  static const WorldTheme classic = WorldTheme(
    id: WorldThemeId.classic,
    label: 'Classic',
    tokens: RatelColorTokens.light,
    vocabulary: WorldVocabulary(
      travellerName: 'Ratel',
      journeyWord: 'lessons',
      continueWord: 'Continue',
    ),
  );

  static const WorldTheme space = WorldTheme(
    id: WorldThemeId.space,
    label: 'Space',
    tokens: SpacePalette.tokens,
    vocabulary: WorldVocabulary(
      travellerName: 'Ratel pod',
      journeyWord: 'galaxy',
      continueWord: 'Locate',
    ),
  );

  static const List<WorldTheme> all = <WorldTheme>[classic, space];

  static WorldTheme of(WorldThemeId id) =>
      id == WorldThemeId.space ? space : classic;
}
// Traceability: R-WT1 R-WT2 R-WT3

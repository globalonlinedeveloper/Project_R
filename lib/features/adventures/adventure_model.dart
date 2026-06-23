import 'package:flutter/foundation.dart';

/// Adventures (R-L4a) — themed districts with scripted-roleplay scenes. Pure
/// data (no Flutter widgets); local + NO DB. Art is programmatic (token-driven)
/// and the catalog is a PLACEHOLDER — the owner authors real Adventures content
/// + art later. Scenes run "on rails" (scripted), never live AI.
enum DistrictKind { cafe, market }

@immutable
class SceneStep {
  const SceneStep({
    required this.speaker,
    required this.line,
    required this.choices,
    required this.bestIndex,
    required this.reply,
  });

  final String speaker; // who is speaking the [line]
  final String line; // the NPC prompt
  final List<String> choices; // learner response options
  final int bestIndex; // the most natural response (highlighted); -1 = none
  final String reply; // the NPC's reaction after any choice
}

@immutable
class Scene {
  const Scene({required this.id, required this.title, required this.steps});
  final String id;
  final String title;
  final List<SceneStep> steps;
}

@immutable
class Adventure {
  const Adventure({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.scenes,
  });
  final String id;
  final String title;
  final String subtitle;
  final DistrictKind kind;
  final List<Scene> scenes;

  Scene get firstScene => scenes.first;
}

/// PLACEHOLDER catalog — 2 districts, one short scene each.
const List<Adventure> adventuresCatalog = [
  Adventure(
    id: 'cafe',
    title: 'Café Corner',
    subtitle: 'Order a coffee and make small talk',
    kind: DistrictKind.cafe,
    scenes: [
      Scene(id: 'cafe_order', title: 'Ordering coffee', steps: [
        SceneStep(
          speaker: 'Barista',
          line: 'Hi! What can I get you?',
          choices: ['A coffee, please.', 'Where is the bus?', 'Goodbye.'],
          bestIndex: 0,
          reply: 'Coming right up!',
        ),
        SceneStep(
          speaker: 'Barista',
          line: 'Milk or sugar?',
          choices: ['Just milk, thanks.', 'I love trains.'],
          bestIndex: 0,
          reply: 'Great choice.',
        ),
        SceneStep(
          speaker: 'Barista',
          line: 'That will be three dollars.',
          choices: ['Here you go.', 'No thanks.'],
          bestIndex: 0,
          reply: 'Enjoy your coffee!',
        ),
      ]),
    ],
  ),
  Adventure(
    id: 'market',
    title: 'Market Street',
    subtitle: 'Buy fresh fruit at the stall',
    kind: DistrictKind.market,
    scenes: [
      Scene(id: 'market_fruit', title: 'At the fruit stall', steps: [
        SceneStep(
          speaker: 'Vendor',
          line: 'Fresh apples today!',
          choices: ['How much are they?', 'I am a tree.'],
          bestIndex: 0,
          reply: 'One dollar each.',
        ),
        SceneStep(
          speaker: 'Vendor',
          line: 'How many would you like?',
          choices: ['Three, please.', 'The sky is blue.'],
          bestIndex: 0,
          reply: 'Here you are. Thank you!',
        ),
      ]),
    ],
  ),
];

Scene? findScene(String sceneId) {
  for (final a in adventuresCatalog) {
    for (final s in a.scenes) {
      if (s.id == sceneId) return s;
    }
  }
  return null;
}

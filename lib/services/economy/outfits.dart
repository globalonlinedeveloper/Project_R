import 'package:flutter/foundation.dart';

/// A cosmetic badger outfit (E1 · R-I4 spend side). [cost] 0 ⇒ owned from the
/// start. [emoji] is the avatar shown on the Profile when the outfit is equipped.
@immutable
class BadgerOutfit {
  const BadgerOutfit({
    required this.id,
    required this.emoji,
    required this.name,
    required this.cost,
  });

  final String id;
  final String emoji;
  final String name;
  final int cost;
}

/// The fixed badger-outfit catalogue. The Classic badger is free + owned by
/// default; the rest are real 💎 spends.
class OutfitCatalogue {
  const OutfitCatalogue._();

  static const BadgerOutfit classic =
      BadgerOutfit(id: 'classic', emoji: '🦡', name: 'Classic', cost: 0);

  static const List<BadgerOutfit> all = <BadgerOutfit>[
    classic,
    BadgerOutfit(id: 'scholar', emoji: '🎓', name: 'Scholar', cost: 25),
    BadgerOutfit(id: 'explorer', emoji: '🧭', name: 'Explorer', cost: 25),
    BadgerOutfit(id: 'astronaut', emoji: '🚀', name: 'Astronaut', cost: 40),
    BadgerOutfit(id: 'wizard', emoji: '🧙', name: 'Wizard', cost: 50),
  ];

  /// The outfit for [id], or [classic] when unknown.
  static BadgerOutfit byId(String id) => all.firstWhere(
        (BadgerOutfit o) => o.id == id,
        orElse: () => classic,
      );
}

/// Immutable owned-set + equipped selection (device-local cosmetic state).
/// 'classic' is always owned and is the safe fallback selection.
@immutable
class OutfitState {
  OutfitState({Set<String>? owned, this.selected = 'classic'})
      : owned = <String>{'classic', ...?owned};

  final Set<String> owned;
  final String selected;

  bool isOwned(String id) => owned.contains(id);

  OutfitState copyWith({Set<String>? owned, String? selected}) => OutfitState(
        owned: owned ?? this.owned,
        selected: selected ?? this.selected,
      );

  @override
  bool operator ==(Object other) =>
      other is OutfitState &&
      setEquals(other.owned, owned) &&
      other.selected == selected;

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(owned), selected);
}

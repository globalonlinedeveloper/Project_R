/// Economy engines — the earned soft-currency wallet arithmetic (diamonds.dart)
/// plus the first real SPEND sink, the streak-freeze purchase
/// (streak_freeze.dart). Pure + clockless: the controller owns the balances and
/// persistence; these models compute reward/spend amounts and the purchase
/// transition. A real-money IAP 💎 top-up and other Shop consumables stay
/// design-spec §6 owner decisions (R-I4), not faked.
library;

export 'diamonds.dart';
export 'energy.dart';
export 'streak_freeze.dart';

/// Economy engines — the earned soft-currency wallet arithmetic (diamonds.dart).
/// Pure + clockless: the controller owns the balance and persistence; these
/// models only compute reward amounts. Spend sinks (streak-freeze / Shop) and a
/// real-money IAP top-up stay design-spec §6 owner decisions (R-I4), not faked.
library;

export 'diamonds.dart';

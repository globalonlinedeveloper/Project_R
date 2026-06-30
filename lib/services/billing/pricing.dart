// R-J2 · Pro price points + billing (PPP-banded, annual-led, 7-day trial) — LOCKED.
// R-J7 · permanent reverse-DNS SKU catalogue.
//
// Pure Dart, ZERO network, NOTHING charges money. This is the DISPLAY catalogue the
// paywall (R-J6) renders: the real price a user pays + the Pro entitlement are set by
// the store / web-checkout at go-live (R-J7 / R-J7a), never asserted here. The numbers
// are the spec's locked starting values (A/B-tuned at launch).

/// The single Pro tier's billing period (R-J2). Annual is the led plan and the only
/// one carrying the 7-day free trial.
enum ProPlan { monthly, annual }

/// PPP price band (R-J2). The real band is resolved by the store / region at go-live;
/// [ProBand.tier1] is the display default the paywall shows until then.
enum ProBand { tier1, mid, lowPpp }

/// Days of free trial on the annual plan (R-J2 / R-J6). Monthly has no trial.
const int kProTrialDays = 7;

/// Permanent, reverse-DNS, never-reused store product IDs (R-J2 / R-J7). Named ONCE,
/// before any product is created (IDs are non-reusable on both Apple + Google even after
/// deletion). The Pro+/Max + credit-pack IDs are reserved but NOT built in v1.
abstract final class ProSku {
  static const String monthly = "com.learnwithratel.ratel.pro.monthly";
  static const String annual = "com.learnwithratel.ratel.pro.annual";

  /// The subscription SKU for [plan] (group "Ratel Pro").
  static String forPlan(ProPlan plan) =>
      plan == ProPlan.annual ? annual : monthly;
}

/// One PPP band's display prices. Amounts are in whole display-currency units; the store
/// shows the per-market PPP point at purchase. Pure value type — no money moves here.
class ProBandPricing {
  const ProBandPricing({
    required this.band,
    required this.regions,
    required this.monthly,
    required this.annual,
    this.symbol = r"$",
  });

  /// Which band this is.
  final ProBand band;

  /// Human label for the markets in this band (paywall fine print).
  final String regions;

  /// Monthly price in display units, e.g. 6.99.
  final double monthly;

  /// Annual price in display units, e.g. 44.99.
  final double annual;

  /// Currency symbol for the display figure.
  final String symbol;

  /// The annual price expressed per month (annual / 12).
  double get annualPerMonth => annual / 12;

  /// Whole-percent saving of the annual plan vs paying [monthly] twelve times.
  int get annualSavingPercent =>
      (100 * (1 - (annual / (monthly * 12)))).round();

  String _fmt(double v) => "$symbol${v.toStringAsFixed(2)}";

  /// e.g. "$6.99".
  String get monthlyDisplay => _fmt(monthly);

  /// e.g. "$44.99".
  String get annualDisplay => _fmt(annual);

  /// e.g. "$3.75".
  String get annualPerMonthDisplay => _fmt(annualPerMonth);

  /// The display price for [plan].
  String displayFor(ProPlan plan) =>
      plan == ProPlan.annual ? annualDisplay : monthlyDisplay;
}

/// The locked R-J2 price catalogue — three PPP bands, one thin Pro tier each.
abstract final class ProCatalog {
  /// US / EU / JP / AU.
  static const ProBandPricing tier1 = ProBandPricing(
    band: ProBand.tier1,
    regions: "US, EU, Japan, Australia",
    monthly: 6.99,
    annual: 44.99,
  );

  /// LatAm / SE Asia / Eastern Europe.
  static const ProBandPricing mid = ProBandPricing(
    band: ProBand.mid,
    regions: "Latin America, SE Asia, E. Europe",
    monthly: 2.99,
    annual: 17.99,
  );

  /// India / Pakistan / Nigeria / Bangladesh.
  static const ProBandPricing lowPpp = ProBandPricing(
    band: ProBand.lowPpp,
    regions: "India, Pakistan, Nigeria, Bangladesh",
    monthly: 1.49,
    annual: 8.99,
  );

  /// All bands, tier-1 first.
  static const List<ProBandPricing> bands = <ProBandPricing>[tier1, mid, lowPpp];

  /// The band the paywall shows until the store / region resolves the real one at
  /// go-live (R-J7a).
  static const ProBandPricing displayDefault = tier1;

  /// Look up a band's prices.
  static ProBandPricing of(ProBand band) =>
      bands.firstWhere((ProBandPricing p) => p.band == band);
}

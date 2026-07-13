import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/analytics/analytics.dart';
import 'package:ratel/services/billing/billing.dart';

/// RATEL PRO paywall — design spec §4.10 (the amber "RATEL PRO" upsell) and
/// requirements R-J6 (store-clean single-CTA paywall), R-J2 (PPP prices, 7-day
/// trial) and R-J1 (free-vs-Pro split).
///
/// HONESTY (charter §6 "don't fake depth"): the prices are the REAL locked
/// catalogue ([ProCatalog], R-J2) and the free/Pro split is the REAL one (R-J1),
/// but a purchase CANNOT complete in this build — the [proCheckoutProvider] seam's
/// default refuses honestly (no store / web checkout wired; the entitlement stays
/// free). Tapping the CTA states plainly that checkout opens at launch; it NEVER
/// fakes a Pro unlock. No countdowns, no toggle (Apple 3.1.2), no pre-ticked upsell.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.source = 'direct'});

  /// Where the paywall was opened from — the only allow-listed `paywall_viewed`
  /// analytics prop (R-M1 taxonomy).
  final String source;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  // Annual-led (R-J2). Selectable plan CARDS, not a toggle (R-J6 / Apple 3.1.2).
  ProPlan _plan = ProPlan.annual;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).logEvent('paywall_viewed',
        props: <String, Object?>{'source': widget.source});
  }

  @override
  Widget build(BuildContext context) {
    final bool isPro = ref.watch(isProProvider);
    final ProBandPricing price = ProCatalog.displayDefault;

    return Scaffold(
      backgroundColor: context.palette.cream,
      appBar: AppBar(
        backgroundColor: context.palette.cream,
        surfaceTintColor: context.palette.cream,
        elevation: 0,
        leading: IconButton(
          icon: Icon(RatelIcons.arrowBack, color: context.palette.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(context.l10n.paywallTitle,
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const ValueKey<String>('screen-paywall'),
          padding: const EdgeInsets.fromLTRB(
              RatelSpace.screen, RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
          children: <Widget>[
            _hero(context),
            const SizedBox(height: RatelSpace.lg),
            if (isPro)
              _alreadyProCard(context)
            else ...<Widget>[
              _planCard(context, ProPlan.annual, price),
              const SizedBox(height: RatelSpace.cardGap),
              _planCard(context, ProPlan.monthly, price),
              const SizedBox(height: RatelSpace.lg),
              if (_plan == ProPlan.annual) ...<Widget>[
                _trialTimeline(context, price),
                const SizedBox(height: RatelSpace.lg),
              ],
              _included(context),
              const SizedBox(height: RatelSpace.lg),
              RatelButton(
                key: const ValueKey<String>('paywall-cta'),
                label: _plan == ProPlan.annual
                    ? context.l10n.paywallStartTrial
                    : context.l10n.paywallGoPro(price.monthlyDisplay),
                onPressed: () => _startCheckout(context, price),
              ),
              const SizedBox(height: RatelSpace.sm),
              RatelButton(
                label: context.l10n.paywallRestore,
                variant: RatelButtonVariant.secondary,
                onPressed: () => _restore(context),
              ),
              const SizedBox(height: RatelSpace.md),
              _finePrint(context, price),
            ],
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) => RatelCard(
        gradient: const LinearGradient(
            colors: <Color>[RatelColors.gold, RatelColors.amber],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        child: Row(
          children: <Widget>[
            const Text('🦡', style: TextStyle(fontSize: 34)),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(context.l10n.paywallTitle,
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.cardTitle,
                          color: RatelColors.onColor)),
                  const SizedBox(height: 2),
                  Text(context.l10n.paywallHero,
                      style: TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: RatelColors.onColor.withValues(alpha: 0.95))),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _planCard(
      BuildContext context, ProPlan plan, ProBandPricing price) {
    final bool selected = _plan == plan;
    final bool annual = plan == ProPlan.annual;
    return RatelCard(
      key: ValueKey<String>('paywall-plan-${plan.name}'),
      onTap: () => setState(() => _plan = plan),
      child: Row(
        children: <Widget>[
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? RatelColors.teal : Colors.transparent,
              border: Border.all(
                  color: selected ? RatelColors.teal : context.palette.muted,
                  width: 2),
            ),
          ),
          const SizedBox(width: RatelSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(annual ? context.l10n.paywallAnnual : context.l10n.paywallMonthly,
                    style: TextStyle(
                        fontFamily: RatelFont.display,
                        fontWeight: RatelType.extraBold,
                        fontSize: RatelType.cardTitle,
                        color: context.palette.ink)),
                const SizedBox(height: 2),
                Text(
                    annual
                        ? context.l10n.paywallAnnualLine(
                            price.annualDisplay, price.annualPerMonthDisplay)
                        : context.l10n.paywallMonthlyLine(price.monthlyDisplay),
                    style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.small,
                        color: context.palette.muted)),
              ],
            ),
          ),
          if (annual) ...<Widget>[
            const SizedBox(width: RatelSpace.sm),
            RatelChip(
                label: context.l10n.paywallSavePercent(price.annualSavingPercent),
                tone: RatelChipTone.green,
                filled: true),
          ],
        ],
      ),
    );
  }

  Widget _trialTimeline(BuildContext context, ProBandPricing price) => RatelCard(
        color: context.palette.cream2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(context.l10n.paywallTrialHow,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.body,
                    color: context.palette.ink)),
            const SizedBox(height: RatelSpace.sm),
            _timelineRow(context, context.l10n.paywallTrialToday,
                context.l10n.paywallTrialTodayDesc),
            _timelineRow(context, context.l10n.paywallTrialDay5,
                context.l10n.paywallTrialDay5Desc),
            _timelineRow(context, context.l10n.paywallTrialDay7,
                context.l10n.paywallTrialDay7Desc(price.annualDisplay)),
          ],
        ),
      );

  Widget _timelineRow(BuildContext context, String when, String what) => Padding(
        padding: const EdgeInsets.only(bottom: RatelSpace.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 52,
              child: Text(when,
                  style: TextStyle(
                      fontFamily: RatelFont.display,
                      fontWeight: RatelType.extraBold,
                      fontSize: RatelType.small,
                      color: RatelColors.teal)),
            ),
            const SizedBox(width: RatelSpace.sm),
            Expanded(
              child: Text(what,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.muted)),
            ),
          ],
        ),
      );

  Widget _included(BuildContext context) => RatelCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(context.l10n.paywallIncluded,
                style: TextStyle(
                    fontFamily: RatelFont.display,
                    fontWeight: RatelType.extraBold,
                    fontSize: RatelType.body,
                    color: context.palette.ink)),
            const SizedBox(height: RatelSpace.sm),
            _featureRow(context, '🎙️', context.l10n.paywallFeatureLiveAi),
            _featureRow(context, '🚫', context.l10n.paywallFeatureNoAds),
            _featureRow(context, '📥', context.l10n.paywallFeatureOffline),
            _featureRow(context, '🗣️', context.l10n.paywallFeaturePronunciation),
            const SizedBox(height: RatelSpace.sm),
            Text(
                context.l10n.paywallEverythingFree,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted,
                    height: 1.4)),
          ],
        ),
      );

  Widget _featureRow(BuildContext context, String emoji, String label) =>
      Padding(
        padding: const EdgeInsets.only(bottom: RatelSpace.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: RatelSpace.sm),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      color: context.palette.ink)),
            ),
          ],
        ),
      );

  Widget _alreadyProCard(BuildContext context) => RatelCard(
        color: context.palette.cream2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                RatelChip.pro(),
                const SizedBox(width: RatelSpace.sm),
                Expanded(
                  child: Text(context.l10n.paywallYouArePro,
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.body,
                          color: context.palette.ink)),
                ),
              ],
            ),
            const SizedBox(height: RatelSpace.sm),
            Text(
                context.l10n.paywallThanks,
                style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted,
                    height: 1.4)),
            const SizedBox(height: RatelSpace.md),
            GestureDetector(
              onTap: () async {
                final ManageResult r =
                    await ref.read(manageSubscriptionProvider).open();
                if (!context.mounted) return;
                _snack(context, r.message);
              },
              child: Text(context.l10n.paywallManage,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.body,
                      fontWeight: RatelType.semiBold,
                      color: RatelColors.teal)),
            ),
          ],
        ),
      );

  Widget _finePrint(BuildContext context, ProBandPricing price) => Column(
        children: <Widget>[
          Text(
            context.l10n.paywallFinePrint(price.regions),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.caption,
                color: context.palette.muted,
                height: 1.4),
          ),
          const SizedBox(height: RatelSpace.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _legalLink(context, context.l10n.paywallTerms, 'learnwithratel.com/terms'),
              Text('  ·  ',
                  style: TextStyle(
                      fontSize: RatelType.caption, color: context.palette.muted)),
              _legalLink(context, context.l10n.paywallPrivacy, 'learnwithratel.com/privacy'),
            ],
          ),
        ],
      );

  Widget _legalLink(BuildContext context, String label, String url) =>
      GestureDetector(
        onTap: () => _snack(context, url),
        child: Text(label,
            style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.caption,
                fontWeight: RatelType.semiBold,
                color: RatelColors.teal)),
      );

  Future<void> _startCheckout(
      BuildContext context, ProBandPricing price) async {
    final CheckoutResult result = await ref
        .read(proCheckoutProvider)
        .start(plan: _plan, band: price.band);
    if (!context.mounted) return;
    _snack(context, result.message);
  }

  void _restore(BuildContext context) => _snack(
      context, context.l10n.paywallNothingToRestore);

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}

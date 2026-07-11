import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/notifications/notifications_controller.dart';
import 'package:ratel/services/notifications/notifications.dart';

/// Notifications inbox (🔔) — R-L11 (design spec §4.5 / §6). A REAL in-app feed:
/// every item is PROJECTED from the learner's genuine milestones (lessons, XP,
/// streak, CEFR level), so a fresh account shows an honest empty state and an
/// item appears only when truly earned — never a fabricated alert. Tapping a
/// card (or "Mark all read") persists the read-state device-locally with the
/// other preferences, so the unread badge survives a relaunch.
///
/// Each row's trailing relative-time label (design §4.14 `2h/5h/1d`) comes
/// from a REAL device-local earn stamp recorded the moment the milestone was
/// crossed (D-13); a milestone with no recorded stamp (earned before stamps
/// shipped, or on another device) honestly shows no label.
///
/// HONESTY (charter "don't fake depth"): PUSH delivery, opt-in categories and
/// per-platform delivery profiles (a separate owner/$$-gated item) have NO
/// engine — shown here as an
/// honest note, never a fake toggle.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<AppNotification> items = ref.watch(notificationsProvider);
    final int unread = ref.watch(unreadNotificationsCountProvider);
    final Set<String> earned = ref.watch(earnedNotificationIdsProvider);
    // One clock read per build (injected — tests pin it); each row renders its
    // relative age against the same now, like the quests reset label.
    final DateTime now = ref.read(clockProvider)();

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
        title: Text(
          context.l10n.profileNotifications,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
        actions: <Widget>[
          if (unread > 0)
            TextButton(
              onPressed: () => ref
                  .read(appSettingsControllerProvider.notifier)
                  .addReadNotifications(earned),
              child: Text(
                context.l10n.notifMarkAllRead,
                style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  fontWeight: RatelType.semiBold,
                  color: RatelColors.blue,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: items.isEmpty
            ? _empty(context)
            : ListView(
                padding: const EdgeInsets.fromLTRB(RatelSpace.screen,
                    RatelSpace.lg, RatelSpace.screen, RatelSpace.xl),
                children: <Widget>[
                  for (final AppNotification n in items) ...<Widget>[
                    _tile(context, ref, n, now),
                    const SizedBox(height: RatelSpace.sm),
                  ],
                  const SizedBox(height: RatelSpace.sm),
                  _pushNote(context),
                ],
              ),
      ),
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, AppNotification n,
          DateTime now) =>
      RatelCard(
        key: ValueKey<String>('notification-${n.id}'),
        color: n.read ? context.palette.cream2 : context.palette.white,
        onTap: n.read
            ? null
            : () => ref
                .read(appSettingsControllerProvider.notifier)
                .addReadNotifications(<String>{n.id}),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Opacity(
              opacity: n.read ? 0.5 : 1,
              child: Text(n.emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: RatelSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(ratelNotificationTitle(context, n.id, n.title),
                      style: TextStyle(
                          fontFamily: RatelFont.display,
                          fontWeight: RatelType.extraBold,
                          fontSize: RatelType.body,
                          color: context.palette.ink)),
                  const SizedBox(height: 2),
                  Text(ratelNotificationBody(context, n.id, n.body),
                      style: TextStyle(
                          fontFamily: RatelFont.body,
                          fontSize: RatelType.small,
                          color: context.palette.muted,
                          height: 1.3)),
                ],
              ),
            ),
            if (n.earnedAt != null || !n.read) ...<Widget>[
              const SizedBox(width: RatelSpace.sm),
              // Trailing cluster per the design row: relative-time label above
              // the unread dot, right-aligned (§4.14 — 11px muted 700 / 5 gap).
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (n.earnedAt != null)
                    Text(
                      relativeEarnedLabel(n.earnedAt!, now),
                      style: TextStyle(
                        fontFamily: RatelFont.body,
                        fontSize: RatelType.caption,
                        fontWeight: RatelType.semiBold,
                        color: context.palette.muted,
                      ),
                    ),
                  if (n.earnedAt != null && !n.read)
                    const SizedBox(height: 5),
                  if (!n.read)
                    Container(
                      width: 10,
                      height: 10,
                      margin: n.earnedAt == null
                          ? const EdgeInsets.only(top: 4)
                          : EdgeInsets.zero,
                      decoration: const BoxDecoration(
                          color: RatelColors.coral, shape: BoxShape.circle),
                    ),
                ],
              ),
            ],
          ],
        ),
      );

  Widget _empty(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🔔', style: TextStyle(fontSize: 56)),
              const SizedBox(height: RatelSpace.md),
              Text(context.l10n.notifEmptyTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: RatelFont.display,
                      fontWeight: RatelType.extraBold,
                      fontSize: RatelType.cardTitle,
                      color: context.palette.ink)),
              const SizedBox(height: RatelSpace.xs),
              Text(
                  context.l10n.notifEmptyBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: RatelFont.body,
                      fontSize: RatelType.small,
                      color: context.palette.muted,
                      height: 1.4)),
            ],
          ),
        ),
      );

  Widget _pushNote(BuildContext context) => Text(
        context.l10n.notifPushNote,
        style: TextStyle(
            fontFamily: RatelFont.body,
            fontSize: RatelType.caption,
            color: context.palette.muted,
            height: 1.4),
      );
}

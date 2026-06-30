import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/services/social/friends_service.dart';

/// Edit profile (§4.9 · APPEARANCE & ACCOUNT). The learner sets a display name
/// (persisted through the `preferences` engine, device-local; it surfaces on the
/// Profile header) and claims a public **@handle** that other learners use to
/// add them as a friend (R-I9/R-L8). The handle is written to the server profile
/// via [FriendsService.setHandle]; when there is no session the seam returns an
/// honest "sign in" note — nothing is fabricated.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _handle;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
        text: ref.read(appSettingsControllerProvider).displayName);
    _handle = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(appSettingsControllerProvider.notifier)
        .setDisplayName(_name.text);

    final String handle = _handle.text.trim();
    FriendDeliveryResult? handleResult;
    if (handle.isNotEmpty) {
      handleResult = await ref.read(friendsServiceProvider).setHandle(handle);
    }
    if (!mounted) return;

    final String message;
    bool stay = false;
    if (handleResult == null) {
      message = 'Profile saved';
    } else if (handleResult.outcome == FriendDeliveryOutcome.delivered) {
      message = 'Saved — your @handle is set.';
    } else if (handleResult.outcome == FriendDeliveryOutcome.unavailable) {
      message = 'Name saved. Sign in to claim your @handle.';
    } else {
      message = handleResult.message ?? 'That @handle could not be set.';
      stay = true; // keep the screen open so they can fix the handle
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
    // Router-agnostic pop (works for the go_router-pushed route in app; a
    // no-op when there's nothing below, e.g. in widget tests).
    if (!stay) await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Edit profile',
            style: TextStyle(
                fontFamily: RatelFont.display,
                fontWeight: RatelType.extraBold,
                color: context.palette.ink,
                fontSize: RatelType.cardTitle)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(RatelSpace.screen, RatelSpace.md,
            RatelSpace.screen, RatelSpace.xl),
        children: <Widget>[
          const RatelSectionHeader(label: 'Display name'),
          const SizedBox(height: RatelSpace.sm),
          RatelCard(
            child: TextField(
              key: const ValueKey<String>('edit-display-name'),
              controller: _name,
              maxLength: 40,
              textInputAction: TextInputAction.next,
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.body,
                  color: context.palette.ink),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: 'How should we greet you?',
                hintStyle: TextStyle(color: context.palette.muted),
              ),
            ),
          ),
          const SizedBox(height: RatelSpace.sm),
          Text(
              'Shown on your profile. Saved on this device — it syncs to your '
              'account when you sign in.',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted)),
          const SizedBox(height: RatelSpace.lg),
          const RatelSectionHeader(label: 'Your @handle'),
          const SizedBox(height: RatelSpace.sm),
          RatelCard(
            child: TextField(
              key: const ValueKey<String>('edit-handle'),
              controller: _handle,
              maxLength: 20,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.body,
                  color: context.palette.ink),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                prefixText: '@',
                hintText: 'yourname',
                hintStyle: TextStyle(color: context.palette.muted),
              ),
            ),
          ),
          const SizedBox(height: RatelSpace.sm),
          Text(
              'Other learners add you by your @handle (2–20 letters, numbers '
              'or _). Claiming it needs you to be signed in.',
              style: TextStyle(
                  fontFamily: RatelFont.body,
                  fontSize: RatelType.small,
                  color: context.palette.muted)),
          const SizedBox(height: RatelSpace.lg),
          RatelButton(label: 'Save', onPressed: _save),
        ],
      ),
    );
  }
}

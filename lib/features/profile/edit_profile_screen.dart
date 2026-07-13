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
      text: ref.read(appSettingsControllerProvider).displayName,
    );
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
      message = context.l10n.editProfileSaved;
    } else if (handleResult.outcome == FriendDeliveryOutcome.delivered) {
      message = context.l10n.editProfileHandleSet;
    } else if (handleResult.outcome == FriendDeliveryOutcome.unavailable) {
      message = context.l10n.editProfileSignInForHandle;
    } else {
      message = handleResult.code != null
          ? ratelFriendMessage(context, handleResult.code!)
          : (handleResult.message ?? context.l10n.editProfileHandleFailed);
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
        title: Text(
          context.l10n.settingsEditProfile,
          style: TextStyle(
            fontFamily: RatelFont.display,
            fontWeight: RatelType.extraBold,
            color: context.palette.ink,
            fontSize: RatelType.cardTitle,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          RatelSpace.screen,
          RatelSpace.md,
          RatelSpace.screen,
          RatelSpace.xl,
        ),
        children: <Widget>[
          RatelSectionHeader(label: context.l10n.editProfileDisplayName),
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
                color: context.palette.ink,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: context.l10n.editProfileNameHint,
                hintStyle: TextStyle(color: context.palette.muted),
              ),
            ),
          ),
          const SizedBox(height: RatelSpace.sm),
          Text(
            context.l10n.editProfileNameNote,
            style: TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.small,
              color: context.palette.muted,
            ),
          ),
          const SizedBox(height: RatelSpace.lg),
          RatelSectionHeader(label: context.l10n.editProfileHandle),
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
                color: context.palette.ink,
              ),
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
            context.l10n.editProfileHandleNote,
            style: TextStyle(
              fontFamily: RatelFont.body,
              fontSize: RatelType.small,
              color: context.palette.muted,
            ),
          ),
          const SizedBox(height: RatelSpace.lg),
          RatelButton(label: context.l10n.commonSave, onPressed: _save),
        ],
      ),
    );
  }
}

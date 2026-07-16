import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';
import 'package:ratel/features/shop/outfits_controller.dart';
import 'package:ratel/services/preferences/app_settings.dart';
import 'package:ratel/services/social/friends_service.dart';

/// Edit profile (§4.9 · APPEARANCE & ACCOUNT). The learner sets a display name,
/// an **emoji avatar** and a short **bio** — all persisted through the
/// `preferences` engine (device-local; they surface on the Profile header) — and
/// claims a public **@handle** that other learners use to add them as a friend
/// (R-I9/R-L8).
///
/// HONESTY: RATEL is mascot/emoji-based and there is NO photo/upload backend and
/// NO `bio` column on the server `profiles` table (design #60/#61). So the avatar
/// is an **emoji picker** and the bio is a **device-local note** — both stored in
/// [AppSettings] exactly like the display name. Nothing is faked as server-synced.
/// The handle alone is written to the server profile via [FriendsService.setHandle];
/// with no session the seam returns an honest "sign in" note.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _handle;
  late final TextEditingController _bio;

  /// The emoji avatar currently selected in the editor. Empty ⇒ "not
  /// customised": Save then leaves [AppSettings.avatarEmoji] empty so the Profile
  /// header keeps falling back to the equipped outfit emoji.
  String _avatar = '';

  /// The curated emoji-avatar set (mascot/emoji-based app). The free Classic
  /// badger 🦡 leads so it doubles as the honest default.
  static const List<String> _avatarChoices = <String>[
    '🦡', '🦊', '🐨', '🐼', '🦁', '🐯',
    '🐸', '🐵', '🐰', '🐶', '🐱', '🐻',
  ];

  @override
  void initState() {
    super.initState();
    final AppSettings settings = ref.read(appSettingsControllerProvider);
    _name = TextEditingController(text: settings.displayName);
    _handle = TextEditingController();
    _bio = TextEditingController(text: settings.bio);
    _avatar = settings.avatarEmoji;
  }

  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    _bio.dispose();
    super.dispose();
  }

  /// The emoji actually rendered in the avatar circle: the picked one, or (when
  /// the learner hasn't customised) the equipped outfit emoji (Classic 🦡).
  String get _effectiveAvatar =>
      _avatar.isNotEmpty ? _avatar : ref.read(equippedOutfitProvider).emoji;

  Future<void> _pickAvatar() async {
    final String current = _effectiveAvatar;
    final String? picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.palette.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(RatelRadius.featureLg),
        ),
      ),
      builder: (BuildContext sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RatelSpace.lg),
          child: Column(
            key: const ValueKey<String>('edit-avatar-picker'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: RatelSpace.sm,
                  bottom: RatelSpace.xs,
                ),
                child: RatelSectionHeader(
                  label: context.l10n.editProfileAvatarTitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: RatelSpace.sm,
                  bottom: RatelSpace.md,
                ),
                child: Text(
                  context.l10n.editProfileAvatarNote,
                  style: TextStyle(
                    fontFamily: RatelFont.body,
                    fontSize: RatelType.small,
                    color: context.palette.muted,
                  ),
                ),
              ),
              Wrap(
                spacing: RatelSpace.md,
                runSpacing: RatelSpace.md,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  for (final String emoji in _avatarChoices)
                    _AvatarOption(
                      key: ValueKey<String>('edit-avatar-$emoji'),
                      emoji: emoji,
                      selected: emoji == current,
                      onTap: () => Navigator.of(sheetContext).pop(emoji),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _avatar = picked);
    }
  }

  Future<void> _save() async {
    final AppSettingsController settings =
        ref.read(appSettingsControllerProvider.notifier);
    await settings.setDisplayName(_name.text);
    await settings.setAvatarEmoji(_avatar);
    await settings.setBio(_bio.text);

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
          RatelSectionHeader(label: context.l10n.editProfileAvatar),
          const SizedBox(height: RatelSpace.sm),
          RatelCard(
            child: Row(
              children: <Widget>[
                Container(
                  key: const ValueKey<String>('edit-avatar-display'),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.palette.cream3,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(_effectiveAvatar,
                      style: const TextStyle(fontSize: 34)),
                ),
                const SizedBox(width: RatelSpace.lg),
                Expanded(
                  child: RatelButton(
                    key: const ValueKey<String>('edit-change-avatar'),
                    label: context.l10n.editProfileChangeAvatar,
                    variant: RatelButtonVariant.secondary,
                    onPressed: _pickAvatar,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RatelSpace.lg),
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
              textInputAction: TextInputAction.next,
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
          RatelSectionHeader(label: context.l10n.editProfileBio),
          const SizedBox(height: RatelSpace.sm),
          RatelCard(
            child: TextField(
              key: const ValueKey<String>('edit-bio'),
              controller: _bio,
              maxLength: 160,
              maxLines: 3,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontFamily: RatelFont.body,
                fontSize: RatelType.body,
                color: context.palette.ink,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: context.l10n.editProfileBioHint,
                hintStyle: TextStyle(color: context.palette.muted),
              ),
            ),
          ),
          const SizedBox(height: RatelSpace.sm),
          Text(
            context.l10n.editProfileBioNote,
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

/// A single tappable emoji avatar in the picker sheet: the emoji in a cream
/// circle, ringed when it is the current selection.
class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    super.key,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: context.palette.cream3,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? context.palette.ink : context.palette.border,
              width: selected ? 3 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}

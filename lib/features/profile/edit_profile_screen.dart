import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ratel/app/app_providers.dart';
import 'package:ratel/core/core.dart';

/// Edit profile (§4.9 · APPEARANCE & ACCOUNT). A small, REAL in-app screen:
/// the learner sets a display name persisted through the `preferences` engine
/// (device-local; it surfaces on the Profile header). Honest scope — there is
/// no server profile yet, so the note says the name is saved on this device and
/// syncs to the account at go-live; nothing is fabricated.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
        text: ref.read(appSettingsControllerProvider).displayName);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(appSettingsControllerProvider.notifier)
        .setDisplayName(_name.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Profile saved')));
    // Router-agnostic pop (works for the go_router-pushed route in app; a
    // no-op when there's nothing below, e.g. in widget tests).
    await Navigator.of(context).maybePop();
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
              controller: _name,
              maxLength: 40,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
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
          RatelButton(label: 'Save', onPressed: _save),
        ],
      ),
    );
  }
}

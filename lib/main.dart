import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/ratel_app.dart';

/// RATEL entrypoint — Riverpod scope + the design-system app shell.
void main() => runApp(const ProviderScope(child: RatelApp()));

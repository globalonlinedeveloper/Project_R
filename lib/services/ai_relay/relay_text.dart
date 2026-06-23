import 'dart:convert' show htmlEscape;

import 'package:flutter/foundation.dart' show immutable;

/// TS-13 (Stage-4 threat model): every value returned by the AI relay (R-H7) is
/// **untrusted**. A model can be prompt-injected into emitting HTML, `<script>`,
/// or markdown control characters, so relay output must never reach an HTML or
/// markdown sink unescaped. `RelayText` is the box every relay response is
/// wrapped in: it deliberately does NOT expose the raw text through `toString()`
/// or any implicitly-rendered path, forcing callers to pick an explicit,
/// context-correct accessor (`plain` / `toHtml` / `toMarkdown`) before sinking it.
///
/// Contract:
///  - the only Dart sink safe for [plain] is one that renders text verbatim
///    (e.g. a Flutter `Text` widget) — never an HTML/markdown context;
///  - any HTML sink MUST use [toHtml]; any markdown sink MUST use [toMarkdown];
///  - `'$relayText'` interpolation is injection-safe by construction (see [toString]).
@immutable
class RelayText {
  const RelayText(this._raw);

  final String _raw;

  /// Raw text, safe ONLY for verbatim sinks (a Flutter `Text` widget renders
  /// text literally and interprets no markup). NEVER pass to an HTML/markdown
  /// context — use [toHtml] / [toMarkdown] there.
  String get plain => _raw;

  bool get isEmpty => _raw.isEmpty;
  bool get isNotEmpty => _raw.isNotEmpty;
  int get length => _raw.length;

  /// HTML-escaped form, safe to interpolate into an HTML sink (WebView /
  /// `dart:html`). Uses the SDK [htmlEscape] (escapes `& < > " ' /`).
  String toHtml() => htmlEscape.convert(_raw);

  /// Markdown-escaped form: backslash-escapes the CommonMark control characters
  /// so any injected markup renders as literal text in a markdown sink.
  String toMarkdown() {
    final out = StringBuffer();
    for (final unit in _raw.runes) {
      final ch = String.fromCharCode(unit);
      if (_markdownSpecials.contains(ch)) out.write(r'\');
      out.write(ch);
    }
    return out.toString();
  }

  static const String _markdownSpecials = r'\`*_{}[]()#+-.!>|~';

  /// Intentionally does NOT leak the raw text — a stray `'$relayText'`
  /// interpolation into an HTML/markdown sink would otherwise be an invisible
  /// injection vector. Use [plain] / [toHtml] / [toMarkdown] explicitly.
  @override
  String toString() => 'RelayText(${_raw.length} chars, untrusted)';

  @override
  bool operator ==(Object other) => other is RelayText && other._raw == _raw;

  @override
  int get hashCode => _raw.hashCode;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/services/services.dart';

void main() {
  group('RelayText (TS-13 — AI/relay output is untrusted)', () {
    test('toHtml escapes every HTML-significant character', () {
      const payload = '<script>alert("xss")</script> & end';
      final html = const RelayText(payload).toHtml();
      // No raw angle brackets / ampersand survive into the HTML sink.
      expect(html.contains('<'), isFalse);
      expect(html.contains('>'), isFalse);
      expect(html.contains('&lt;'), isTrue);
      expect(html.contains('&gt;'), isTrue);
      expect(html.contains('&amp;'), isTrue);
      // The literal injected tag must not appear.
      expect(html.contains('<script>'), isFalse);
    });

    test('toMarkdown backslash-escapes CommonMark control characters', () {
      const payload = '[link](http://evil) **bold** `code` _i_';
      final md = const RelayText(payload).toMarkdown();
      expect(md.contains(r'\['), isTrue);
      expect(md.contains(r'\]'), isTrue);
      expect(md.contains(r'\('), isTrue);
      expect(md.contains(r'\)'), isTrue);
      expect(md.contains(r'\*'), isTrue);
      expect(md.contains(r'\`'), isTrue);
      expect(md.contains(r'\_'), isTrue);
      // An active link must not survive verbatim.
      expect(md.contains('[link]('), isFalse);
    });

    test('toString does NOT leak the raw text (interpolation is injection-safe)',
        () {
      const secret = '<img src=x onerror=alert(1)>';
      final s = const RelayText(secret).toString();
      expect(s.contains(secret), isFalse);
      expect(s.contains('onerror'), isFalse);
      expect(s, contains('untrusted'));
    });

    test('plain exposes raw text only for verbatim (non-markup) sinks', () {
      const t = 'hello <b>';
      expect(const RelayText(t).plain, t);
    });

    test('value equality + length/empty helpers', () {
      expect(const RelayText('a') == const RelayText('a'), isTrue);
      expect(const RelayText('a') == const RelayText('b'), isFalse);
      expect(const RelayText('a').hashCode, const RelayText('a').hashCode);
      expect(const RelayText('').isEmpty, isTrue);
      expect(const RelayText('ab').isNotEmpty, isTrue);
      expect(const RelayText('ab').length, 2);
    });

    test('empty relay text escapes to empty (no spurious markup)', () {
      expect(const RelayText('').toHtml(), '');
      expect(const RelayText('').toMarkdown(), '');
    });
  });

  test('AiRelay.complete returns the untrusted RelayText box; unconfigured fails closed',
      () {
    const relay = UnconfiguredAiRelay();
    expect(relay.isAvailable, isFalse);
    expect(() => relay.complete('hi'), throwsStateError);
  });
}

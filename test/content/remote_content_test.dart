import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/app/content_wiring.dart';
import 'package:ratel/content/repository/remote_content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseManifest (pure, tolerant)', () {
    test('parses good entries, skips garbage, never throws', () {
      final m = RemoteContentRepository.parseManifest(
          '{"courses":[{"code":"en","batch_id":"13503-en","path":"en/course.13503.json"},'
          '{"code":"","path":"x"},{"nope":true},"junk",'
          '{"code":"es","path":"es/course.7.json"}]}');
      expect(m.keys.toList()..sort(), <String>['en', 'es']);
      expect(m['en']!.path, 'en/course.13503.json');
      expect(m['en']!.batchId, '13503-en');
    });

    test('unusable manifests yield empty (fallback ladder takes over)', () {
      expect(RemoteContentRepository.parseManifest('not json'), isEmpty);
      expect(RemoteContentRepository.parseManifest('[]'), isEmpty);
      expect(RemoteContentRepository.parseManifest('{"courses":42}'), isEmpty);
    });
  });

  test('joinUrl never doubles slashes', () {
    expect(RemoteContentRepository.joinUrl('https://x/content/', '/en/c.json'),
        Uri.parse('https://x/content/en/c.json'));
    expect(RemoteContentRepository.joinUrl('https://x/content', 'en/c.json'),
        Uri.parse('https://x/content/en/c.json'));
  });

  group('RemoteContentRepository.loadBatch (fail-closed)', () {
    test('valid remote batch passes the SAME loader as bundled', () async {
      final repo = RemoteContentRepository(
        baseUrl: 'https://cdn/content',
        fetch: (Uri u) async => '{"batch_id":"b","locale":"en","tables":{}}',
      );
      expect((await repo.loadBatch('en/c.json')).rowCount, 0);
    });

    test('unreachable remote throws (caller ladders to bundled)', () {
      final repo = RemoteContentRepository(
          baseUrl: 'https://cdn/content', fetch: (Uri u) async => null);
      expect(repo.loadBatch('en/c.json'), throwsA(isA<StateError>()));
    });

    test('invalid remote JSON throws via the fail-closed loader', () {
      final repo = RemoteContentRepository(
          baseUrl: 'https://cdn/content', fetch: (Uri u) async => '{"oops":1}');
      expect(repo.loadBatch('en/c.json'), throwsA(anything));
    });
  });

  group('initContentOverrides remote ladder', () {
    test('remote-off stays byte-identical: injected fetch is never called',
        () async {
      int calls = 0;
      final List<Override> o = await initContentOverrides(
        course: 'en',
        remoteEnabled: false,
        remoteBase: 'https://cdn/content',
        remoteFetch: (Uri u) async {
          calls++;
          return null;
        },
      );
      expect(calls, 0);
      expect(o, isNotEmpty); // bundled EN default loaded as always
    });

    test('remote failure falls back to the bundled course (never a broken boot)',
        () async {
      final List<Override> o = await initContentOverrides(
        course: 'en',
        remoteEnabled: true,
        remoteBase: 'https://cdn/content',
        remoteFetch: (Uri u) async => null, // offline / CDN down
      );
      expect(o, isNotEmpty); // bundled EN still boots the path
    });

    test('remote success serves the catalog course + publishes remote codes',
        () async {
      // Serve the REAL bundled EN batch as if it were the published file —
      // proves the remote path end-to-end over real content.
      final String realEn =
          await rootBundle.loadString('assets/content/en/course.batch.json');
      final List<Uri> seen = <Uri>[];
      final List<Override> o = await initContentOverrides(
        course: 'en',
        remoteEnabled: true,
        remoteBase: 'https://cdn/content',
        remoteFetch: (Uri u) async {
          seen.add(u);
          if (u.path.endsWith('manifest.json')) {
            return '{"courses":[{"code":"en","batch_id":"en-7","path":"en/course.en-7.json"},'
                '{"code":"tt","batch_id":"t","path":"tt/course.t.json"}]}';
          }
          if (u.path.endsWith('en/course.en-7.json')) return realEn;
          return null;
        },
      );
      expect(o, isNotEmpty);
      expect(seen.first.toString(), 'https://cdn/content/manifest.json');
      expect(seen.any((Uri u) => u.path.endsWith('en/course.en-7.json')), isTrue);
      expect(remoteCourseCodes, containsAll(<String>['en', 'tt']));
      expect(await availableCourseCodes(), contains('tt')); // picker grows remotely
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ratel/content/loader/content_loader.dart';
import 'package:ratel/content/repository/content_providers.dart';
import 'package:ratel/content/repository/content_repository.dart';

/// A Stage-3-style fake that returns content WITHOUT touching the asset bundle —
/// proving features (which read `seedBatchProvider`) depend only on the
/// [ContentRepository] interface, so Supabase can plug in behind it (P1-5).
class _FakeRepository implements ContentRepository {
  const _FakeRepository(this.batch);
  final ContentBatch batch;
  @override
  Future<ContentBatch> loadBatch(String ref) async => batch;
}

void main() {
  test('BundledContentRepository is the bundled impl of the interface', () {
    const repo = BundledContentRepository();
    expect(repo, isA<ContentRepository>());
  });

  test('a swapped-in repository feeds seedBatchProvider (seam is real)', () async {
    const fakeBatch = ContentBatch(batchId: 'fake-stage3', locale: 'en');
    final container = ProviderContainer(overrides: [
      contentRepositoryProvider.overrideWithValue(const _FakeRepository(fakeBatch)),
    ]);
    addTearDown(container.dispose);

    final batch = await container.read(seedBatchProvider.future);
    expect(batch.batchId, 'fake-stage3',
        reason: 'seedBatchProvider must resolve through the injected interface, '
            'not the hard-coded bundled asset');
  });
}

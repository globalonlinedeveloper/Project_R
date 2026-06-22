import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../loader/content_loader.dart';
import 'content_repository.dart';

/// Asset path for the beachhead seed batch (EN). Other locales add rows only.
const String kSeedEnAsset = 'assets/content/en/seed.batch.json';

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => const ContentRepository(ContentLoader()),
);

/// The loaded EN seed batch. Tests override this with an in-memory [ContentBatch]
/// so they never touch the asset bundle.
final seedBatchProvider = FutureProvider<ContentBatch>((ref) async {
  final repo = ref.read(contentRepositoryProvider);
  return repo.loadAsset(kSeedEnAsset);
});

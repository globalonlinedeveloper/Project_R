import 'dart:convert';

import '../models/models.dart';

/// Thrown when a batch is malformed or any row fails validation.
/// The loader is FAIL-CLOSED: it throws before returning, so a batch never
/// loads partially (T1.2 / R-C14 spirit on the client).
class BatchLoadException implements Exception {
  BatchLoadException(this.message);
  final String message;
  @override
  String toString() => 'BatchLoadException: $message';
}

/// A parsed, typed content batch. Local-only, NO DB (Stage 1).
class ContentBatch {
  const ContentBatch({
    required this.batchId,
    this.locale,
    this.sentences = const [],
    this.vocab = const [],
    this.senses = const [],
    this.grammar = const [],
    this.phonemes = const [],
    this.items = const [],
    this.locales = const [],
    this.media = const [],
    this.glosses = const [],
  });

  final String batchId;
  final String? locale;
  final List<Sentence> sentences;
  final List<VocabEntry> vocab;
  final List<Sense> senses;
  final List<GrammarPoint> grammar;
  final List<Phoneme> phonemes;
  final List<Item> items;
  final List<Locale> locales;
  final List<MediaAsset> media;
  final List<Gloss> glosses;

  int get rowCount =>
      sentences.length +
      vocab.length +
      senses.length +
      grammar.length +
      phonemes.length +
      items.length +
      locales.length +
      media.length +
      glosses.length;
}

typedef _FromJson = Object Function(Map<String, dynamic>);

/// Parses + validates versioned batch JSON into typed models. Web-safe (no
/// dart:io): callers supply the JSON string from a file/asset/bundle.
class ContentLoader {
  const ContentLoader();

  static final Map<String, _FromJson> _parsers = {
    'sentence': Sentence.fromJson,
    'vocab_entry': VocabEntry.fromJson,
    'sense': Sense.fromJson,
    'grammar_point': GrammarPoint.fromJson,
    'phoneme': Phoneme.fromJson,
    'item': Item.fromJson,
    'locale': Locale.fromJson,
    'media_asset': MediaAsset.fromJson,
    'gloss': Gloss.fromJson,
  };

  ContentBatch loadString(String source) {
    final decoded = _decode(source);
    if (decoded is! Map<String, dynamic>) {
      throw BatchLoadException('batch root must be a JSON object');
    }
    return loadMap(decoded);
  }

  ContentBatch loadMap(Map<String, dynamic> env) {
    final batchId = env['batch_id'];
    if (batchId is! String || batchId.isEmpty) {
      throw BatchLoadException('batch missing required string "batch_id"');
    }
    final tables = env['tables'];
    if (tables is! Map) {
      throw BatchLoadException('batch missing required object "tables"');
    }
    for (final key in tables.keys) {
      if (!_parsers.containsKey(key)) {
        throw BatchLoadException('unknown table "$key" (rows-only: not in the schema)');
      }
    }
    List<T> rows<T>(String table) => _parse<T>(table, tables[table], _parsers[table]!);
    return ContentBatch(
      batchId: batchId,
      locale: env['locale'] as String?,
      sentences: rows<Sentence>('sentence'),
      vocab: rows<VocabEntry>('vocab_entry'),
      senses: rows<Sense>('sense'),
      grammar: rows<GrammarPoint>('grammar_point'),
      phonemes: rows<Phoneme>('phoneme'),
      items: rows<Item>('item'),
      locales: rows<Locale>('locale'),
      media: rows<MediaAsset>('media_asset'),
      glosses: rows<Gloss>('gloss'),
    );
  }

  Object? _decode(String source) {
    try {
      return jsonDecode(source);
    } catch (e) {
      throw BatchLoadException('invalid JSON: $e');
    }
  }

  List<T> _parse<T>(String table, Object? raw, _FromJson fromJson) {
    if (raw == null) return const [];
    if (raw is! List) throw BatchLoadException('table "$table" must be a JSON array');
    final out = <T>[];
    for (var i = 0; i < raw.length; i++) {
      final r = raw[i];
      if (r is! Map) throw BatchLoadException('table "$table" row $i is not an object');
      try {
        out.add(fromJson(Map<String, dynamic>.from(r)) as T);
      } catch (e) {
        throw BatchLoadException('table "$table" row $i failed validation: $e');
      }
    }
    return out;
  }
}

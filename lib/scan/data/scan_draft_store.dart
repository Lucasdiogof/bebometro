import 'dart:convert';

import '../../core/data/local_store.dart';
import '../../outing_drinks/domain/outing_drink.dart';

/// A reading in progress, tied to the outing it started in. It survives
/// closing the app and is never moved to another outing.
class ScanDraft {
  const ScanDraft({
    required this.outingId,
    required this.kind,
    this.photoIds = const [],
    this.text = '',
    this.payload = const {},
  });

  final String outingId;
  final OutingPhotoKind kind;

  /// Files already saved in the app's own storage.
  final List<String> photoIds;

  /// Text extracted or typed so far.
  final String text;

  /// Screen-specific edits (label fields, menu items).
  final Map<String, dynamic> payload;

  bool get isEmpty => photoIds.isEmpty && text.trim().isEmpty && payload.isEmpty;

  ScanDraft copyWith({
    List<String>? photoIds,
    String? text,
    Map<String, dynamic>? payload,
  }) =>
      ScanDraft(
        outingId: outingId,
        kind: kind,
        photoIds: photoIds ?? this.photoIds,
        text: text ?? this.text,
        payload: payload ?? this.payload,
      );

  Map<String, dynamic> toJson() => {
        'outing_id': outingId,
        'kind': kind.code,
        'photo_ids': photoIds,
        'text': text,
        'payload': payload,
      };

  factory ScanDraft.fromJson(Map<String, dynamic> j) => ScanDraft(
        outingId: j['outing_id'] as String,
        kind: OutingPhotoKind.fromCode(j['kind'] as String?),
        photoIds: (j['photo_ids'] as List?)?.cast<String>() ?? const [],
        text: j['text'] as String? ?? '',
        payload: Map<String, dynamic>.from(j['payload'] as Map? ?? const {}),
      );
}

/// Durable drafts on the device (not synced). One per outing and kind.
class ScanDraftStore {
  ScanDraftStore(this._store);

  final LocalStore _store;

  static const _indexKey = 'scan.drafts';

  String _key(String outingId, OutingPhotoKind kind) =>
      'scan.draft.$outingId.${kind.code}';

  ScanDraft? load(String outingId, OutingPhotoKind kind) {
    final raw = _store.getString(_key(outingId, kind));
    if (raw == null || raw.isEmpty) return null;
    try {
      return ScanDraft.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  /// Drafts still open for an outing, so the outing can offer to resume.
  List<ScanDraft> openFor(String outingId) => [
        for (final kind in OutingPhotoKind.values)
          if (load(outingId, kind) case final d? when !d.isEmpty) d,
      ];

  Future<void> save(ScanDraft draft) async {
    if (draft.isEmpty) return clear(draft.outingId, draft.kind);
    await _store.setString(
        _key(draft.outingId, draft.kind), jsonEncode(draft.toJson()));
    final index = _store.getStringSet(_indexKey)
      ..add(_key(draft.outingId, draft.kind));
    await _store.setStringSet(_indexKey, index);
  }

  Future<void> clear(String outingId, OutingPhotoKind kind) async {
    final key = _key(outingId, kind);
    await _store.setString(key, '');
    final index = _store.getStringSet(_indexKey)..remove(key);
    await _store.setStringSet(_indexKey, index);
  }
}

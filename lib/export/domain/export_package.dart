import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

/// A photo that belongs to an exported record.
class ExportPhotoRef {
  const ExportPhotoRef({
    required this.id,
    required this.outingId,
    this.storagePath,
  });

  final String id;
  final String outingId;

  /// Object path in the private bucket, when the photo was uploaded.
  final String? storagePath;

  /// Always plain ASCII, no separators and no dots at the start: ids come from
  /// synced rows, and an extracted ZIP must never write outside its folder
  /// (no `..`, no `/`, no drive letters) on Windows, macOS or Android.
  String get zipPath =>
      'photos/${ExportPhotoRef.safeSegment(outingId)}/${ExportPhotoRef.safeSegment(id)}.jpg';

  static String safeSegment(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return cleaned.isEmpty ? '_' : cleaned;
  }
}

/// A photo that is not in the package. The reason code also goes into
/// manifest.json.
class OmittedFile {
  const OmittedFile(this.path, this.reason);

  final String path;
  final String reason;

  Map<String, dynamic> toJson() => {'path': path, 'reason': reason};
}

class ExportPackage {
  const ExportPackage({
    required this.zip,
    required this.manifest,
    required this.omitted,
    required this.photosIncluded,
    required this.verified,
    required this.mismatches,
  });

  final Uint8List zip;
  final Map<String, dynamic> manifest;
  final List<OmittedFile> omitted;
  final int photosIncluded;

  /// Every file was read back from the finished ZIP and its SHA-256 matched
  /// the manifest.
  final bool verified;
  final List<String> mismatches;
}

class ExportCancelled implements Exception {
  const ExportCancelled();
}

/// Builds the optional full export: the same JSON/CSV files as the plain
/// export plus the photo files, and a manifest.json with a SHA-256 per file,
/// totals and everything that was left out (never silently). Pure Dart: the
/// caller supplies how photos are read, so the logic is testable off a device.
class ExportPackageBuilder {
  const ExportPackageBuilder._();

  static const omittedMissing = 'file_missing';
  static const omittedUnreadable = 'unreadable';
  static const omittedDownloadFailed = 'download_failed';
  static const omittedSizeLimit = 'size_limit';

  /// 150 MB of photos: the ZIP is built in memory.
  static const defaultMaxPhotoBytes = 150 * 1024 * 1024;

  static String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

  static Future<ExportPackage> build({
    required DateTime exportedAt,
    required Map<String, String> textFiles,
    required List<ExportPhotoRef> photos,
    required Future<Uint8List?> Function(ExportPhotoRef photo) readLocal,
    Future<Uint8List?> Function(ExportPhotoRef photo)? download,
    bool Function()? isCancelled,
    void Function(int done, int total)? onProgress,
    int maxPhotoBytes = defaultMaxPhotoBytes,
    String? note,
  }) async {
    final files = <String, Uint8List>{};
    for (final e in textFiles.entries) {
      files[e.key] = Uint8List.fromList(utf8.encode(e.value));
    }
    final omitted = <OmittedFile>[];
    var photoBytes = 0;
    final taken = <String>{};
    for (var i = 0; i < photos.length; i++) {
      if (isCancelled?.call() ?? false) throw const ExportCancelled();
      onProgress?.call(i, photos.length);
      final p = photos[i];
      var path = p.zipPath;
      // Two photos can end up with the same name (ids that differ only in
      // characters that were replaced): never overwrite one with the other.
      for (var n = 2; files.containsKey(path) || taken.contains(path); n++) {
        path = p.zipPath.replaceFirst(RegExp(r'\.jpg$'), '-$n.jpg');
      }
      taken.add(path);
      var failure = omittedMissing;
      Uint8List? bytes;
      try {
        bytes = await readLocal(p);
      } catch (_) {
        failure = omittedUnreadable;
      }
      if (bytes == null && download != null && p.storagePath != null) {
        try {
          bytes = await download(p);
        } catch (_) {
          bytes = null;
        }
        if (bytes == null) failure = omittedDownloadFailed;
      }
      if (bytes == null || bytes.isEmpty) {
        omitted.add(OmittedFile(path, failure));
        continue;
      }
      if (photoBytes + bytes.length > maxPhotoBytes) {
        omitted.add(OmittedFile(path, omittedSizeLimit));
        continue;
      }
      photoBytes += bytes.length;
      files[path] = bytes;
    }
    if (isCancelled?.call() ?? false) throw const ExportCancelled();
    onProgress?.call(photos.length, photos.length);

    final entries = [
      for (final e in files.entries)
        {'path': e.key, 'bytes': e.value.length, 'sha256': sha256Hex(e.value)},
    ];
    final photosIncluded = files.keys
        .where((k) => k.startsWith('photos/'))
        .length;
    final manifest = <String, dynamic>{
      'app': 'Bebômetro',
      'manifest_version': 1,
      'exported_at': exportedAt.toUtc().toIso8601String(),
      'hash': 'sha256',
      'files': entries,
      'totals': {
        'files': entries.length,
        'bytes': files.values.fold<int>(0, (a, b) => a + b.length),
        'photos_included': photosIncluded,
        'photos_requested': photos.length,
        'photos_omitted': omitted.length,
      },
      'omitted': [for (final o in omitted) o.toJson()],
      'note': ?note,
    };
    final manifestBytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(manifest)),
    );

    final archive = Archive();
    for (final e in files.entries) {
      archive.addFile(ArchiveFile.bytes(e.key, e.value));
    }
    archive.addFile(ArchiveFile.bytes('manifest.json', manifestBytes));
    final zip = Uint8List.fromList(ZipEncoder().encode(archive));

    // Read the finished ZIP back and recompute every hash.
    final mismatches = <String>[];
    try {
      final back = ZipDecoder().decodeBytes(zip);
      final byName = {for (final f in back) f.name: f};
      for (final e in entries) {
        final f = byName[e['path']];
        final content = f?.readBytes();
        if (content == null ||
            content.length != e['bytes'] ||
            sha256Hex(content) != e['sha256']) {
          mismatches.add(e['path'] as String);
        }
      }
      if (!byName.containsKey('manifest.json')) mismatches.add('manifest.json');
    } catch (_) {
      mismatches.add('zip');
    }
    return ExportPackage(
      zip: zip,
      manifest: manifest,
      omitted: omitted,
      photosIncluded: photosIncluded,
      verified: mismatches.isEmpty,
      mismatches: mismatches,
    );
  }
}

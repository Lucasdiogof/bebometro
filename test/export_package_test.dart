import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bebometro/export/domain/export_package.dart';

Uint8List _b(String s) => Uint8List.fromList(utf8.encode(s));

void main() {
  final when = DateTime.utc(2026, 10, 20);
  const a = ExportPhotoRef(id: 'a', outingId: 'o1', storagePath: 'u/o1/a.jpg');
  const b = ExportPhotoRef(id: 'b', outingId: 'o1');
  const c = ExportPhotoRef(id: 'c', outingId: 'o2', storagePath: 'u/o2/c.jpg');

  Future<ExportPackage> run({
    required Map<String, Uint8List> local,
    Map<String, Uint8List?>? remote,
    bool Function()? cancelled,
    int max = 1000,
  }) => ExportPackageBuilder.build(
    exportedAt: when,
    textFiles: {'data/bebometro-dados.json': '{"x":1}'},
    photos: const [a, b, c],
    readLocal: (p) async => local[p.id],
    download: remote == null ? null : (p) async => remote[p.id],
    isCancelled: cancelled,
    maxPhotoBytes: max,
  );

  test('writes files, manifest hashes and verifies the finished zip', () async {
    final r = await run(local: {'a': _b('AAA'), 'b': _b('BBBB'), 'c': _b('C')});
    expect(r.verified, isTrue);
    expect(r.photosIncluded, 3);
    expect(r.omitted, isEmpty);
    final zip = ZipDecoder().decodeBytes(r.zip);
    final manifest = jsonDecode(
      utf8.decode(
        zip.firstWhere((f) => f.name == 'manifest.json').readBytes()!,
      ),
    );
    final files = manifest['files'] as List;
    expect(files.length, 4);
    expect(
      files.firstWhere((f) => f['path'] == 'photos/o1/a.jpg')['sha256'],
      ExportPackageBuilder.sha256Hex(_b('AAA')),
    );
    expect(manifest['totals']['photos_omitted'], 0);
  });

  test('a missing photo is reported, never silent', () async {
    final r = await run(local: {'a': _b('AAA')});
    expect(r.photosIncluded, 1);
    expect(r.omitted.map((o) => '${o.path}:${o.reason}').toList(), [
      'photos/o1/b.jpg:file_missing',
      'photos/o2/c.jpg:file_missing',
    ]);
    expect(r.manifest['totals']['photos_omitted'], 2);
    expect((r.manifest['omitted'] as List).length, 2);
    expect(r.verified, isTrue);
  });

  test(
    'a cloud-only photo is downloaded; a failed download is reported',
    () async {
      final r = await run(local: {}, remote: {'a': _b('REMOTE'), 'c': null});
      expect(r.photosIncluded, 1);
      final reasons = {for (final o in r.omitted) o.path: o.reason};
      expect(reasons['photos/o2/c.jpg'], 'download_failed');
      // b was never uploaded: nothing to download.
      expect(reasons['photos/o1/b.jpg'], 'file_missing');
    },
  );

  test('throwing sources are reported with their reason', () async {
    final r = await ExportPackageBuilder.build(
      exportedAt: when,
      textFiles: const {},
      photos: const [a, c],
      readLocal: (p) async => throw StateError('io'),
      download: (p) async => throw StateError('net'),
    );
    expect(r.photosIncluded, 0);
    expect(r.omitted.map((o) => o.reason).toSet(), {'download_failed'});
    final r2 = await ExportPackageBuilder.build(
      exportedAt: when,
      textFiles: const {},
      photos: const [b],
      readLocal: (p) async => throw StateError('io'),
    );
    expect(r2.omitted.single.reason, 'unreadable');
  });

  test('size limit leaves the rest out and says so', () async {
    final r = await run(
      local: {'a': _b('AAAA'), 'b': _b('BBBB'), 'c': _b('CC')},
      max: 6,
    );
    expect(r.photosIncluded, 2); // a (4) + c (2); b would exceed 6
    expect(r.omitted.single.path, 'photos/o1/b.jpg');
    expect(r.omitted.single.reason, 'size_limit');
    expect(r.manifest['totals']['photos_included'], 2);
  });

  test('cancelling stops the export', () async {
    var n = 0;
    await expectLater(
      run(local: {'a': _b('A')}, cancelled: () => ++n > 1),
      throwsA(isA<ExportCancelled>()),
    );
  });

  test('the hash changes when a byte changes', () {
    expect(
      ExportPackageBuilder.sha256Hex(_b('x')),
      isNot(ExportPackageBuilder.sha256Hex(_b('y'))),
    );
  });
}

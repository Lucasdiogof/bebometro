import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as c;
import 'package:flutter_test/flutter_test.dart';
import 'package:bebometro/export/domain/export_package.dart';

/// Minimal ZIP reader written here on purpose: it does not share any code with
/// the builder or with package:archive, so a mistake in either is caught.
/// Handles the "stored" and "deflate" methods through dart:io's zlib.
Map<String, Uint8List> _readZip(Uint8List z) {
  final d = ByteData.sublistView(z);
  var eocd = z.length - 22;
  while (eocd >= 0 && d.getUint32(eocd, Endian.little) != 0x06054b50) {
    eocd--;
  }
  expect(eocd, greaterThanOrEqualTo(0), reason: 'no end of central directory');
  final count = d.getUint16(eocd + 10, Endian.little);
  var p = d.getUint32(eocd + 16, Endian.little);
  final out = <String, Uint8List>{};
  for (var i = 0; i < count; i++) {
    expect(d.getUint32(p, Endian.little), 0x02014b50);
    final method = d.getUint16(p + 10, Endian.little);
    final crc = d.getUint32(p + 16, Endian.little);
    final csize = d.getUint32(p + 20, Endian.little);
    final usize = d.getUint32(p + 24, Endian.little);
    final nlen = d.getUint16(p + 28, Endian.little);
    final xlen = d.getUint16(p + 30, Endian.little);
    final clen = d.getUint16(p + 32, Endian.little);
    final local = d.getUint32(p + 42, Endian.little);
    final name = utf8.decode(z.sublist(p + 46, p + 46 + nlen));
    final lnlen = d.getUint16(local + 26, Endian.little);
    final lxlen = d.getUint16(local + 28, Endian.little);
    final start = local + 30 + lnlen + lxlen;
    final raw = z.sublist(start, start + csize);
    final data = method == 0
        ? Uint8List.fromList(raw)
        : Uint8List.fromList(ZLibDecoder(raw: true).convert(raw));
    expect(data.length, usize, reason: name);
    expect(_crc32(data), crc, reason: 'crc of $name');
    out[name] = data;
    p += 46 + nlen + xlen + clen;
  }
  return out;
}

int _crc32(List<int> bytes) {
  var crc = 0xFFFFFFFF;
  for (final b in bytes) {
    crc ^= b;
    for (var k = 0; k < 8; k++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
    }
  }
  return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}

String _hex(List<int> b) => c.sha256.convert(b).toString();

void main() {
  final when = DateTime.utc(2026, 10, 20);
  final rnd = Random(7);
  Uint8List bytes(int n) =>
      Uint8List.fromList(List.generate(n, (_) => rnd.nextInt(256)));

  void checkAgainstOriginals(
    ExportPackage pkg,
    Map<String, Uint8List> originalsByPath,
  ) {
    final files = _readZip(pkg.zip);
    final manifest = jsonDecode(utf8.decode(files['manifest.json']!));
    final listed = {for (final f in manifest['files'] as List) f['path']: f};
    expect(files.keys.toSet(), {...listed.keys, 'manifest.json'});
    for (final e in listed.entries) {
      final data = files[e.key]!;
      expect(_hex(data), e.value['sha256'], reason: e.key);
      expect(data.length, e.value['bytes'], reason: e.key);
    }
    originalsByPath.forEach((path, original) {
      expect(files[path], original, reason: 'bytes of $path');
    });
    for (final name in files.keys) {
      expect(name.startsWith('/') || name.contains('..'), isFalse);
      expect(name.contains(r'\'), isFalse);
      expect(name.contains(':'), isFalse);
    }
  }

  test(
    'round trip with a large photo, read by an independent reader',
    () async {
      final big = bytes(6 * 1024 * 1024);
      final small = bytes(1500);
      const a = ExportPhotoRef(id: 'big', outingId: 'o1');
      const b = ExportPhotoRef(id: 'small', outingId: 'o1');
      final pkg = await ExportPackageBuilder.build(
        exportedAt: when,
        textFiles: {'data/bebometro-dados.json': '{"nome":"Cervejão"}'},
        photos: const [a, b],
        readLocal: (p) async => p.id == 'big' ? big : small,
      );
      expect(pkg.verified, isTrue);
      checkAgainstOriginals(pkg, {
        'photos/o1/big.jpg': big,
        'photos/o1/small.jpg': small,
        'data/bebometro-dados.json': Uint8List.fromList(
          utf8.encode('{"nome":"Cervejão"}'),
        ),
      });
    },
  );

  test('hostile and duplicate names become safe, distinct entries', () async {
    const refs = [
      ExportPhotoRef(id: '../../etc/passwd', outingId: '..'),
      ExportPhotoRef(id: r'C:\Windows\x', outingId: 'o/1'),
      ExportPhotoRef(id: 'a b', outingId: 'o1'),
      ExportPhotoRef(id: 'a_b', outingId: 'o1'), // same name after cleaning
      ExportPhotoRef(id: 'a_b', outingId: 'o1'), // exact duplicate
      ExportPhotoRef(id: 'ração ñ 🍺', outingId: 'o1'),
      ExportPhotoRef(id: '', outingId: ''),
    ];
    final originals = <String, Uint8List>{};
    final pkg = await ExportPackageBuilder.build(
      exportedAt: when,
      textFiles: const {},
      photos: refs,
      readLocal: (p) async {
        final b = Uint8List.fromList(utf8.encode('x${p.id}|${p.outingId}'));
        return b;
      },
    );
    expect(pkg.photosIncluded, refs.length);
    expect(pkg.verified, isTrue);
    final files = _readZip(pkg.zip);
    final names = files.keys.where((n) => n.startsWith('photos/')).toList();
    expect(names.toSet().length, refs.length, reason: 'no overwritten entry');
    for (final n in names) {
      expect(
        RegExp(r'^photos/[A-Za-z0-9_-]+/[A-Za-z0-9_-]+\.jpg$').hasMatch(n),
        isTrue,
        reason: n,
      );
    }
    // Every original byte string is present exactly once.
    for (final r in refs) {
      originals[r.id] = Uint8List.fromList(
        utf8.encode('x${r.id}|${r.outingId}'),
      );
    }
    final present =
        files.entries
            .where((e) => e.key.startsWith('photos/'))
            .map((e) => utf8.decode(e.value))
            .toList()
          ..sort();
    final expected = refs.map((r) => 'x${r.id}|${r.outingId}').toList()..sort();
    expect(present, expected);
  });

  test(
    'partial download failure keeps the good photos and reports the rest',
    () async {
      const a = ExportPhotoRef(
        id: 'a',
        outingId: 'o',
        storagePath: 'u/o/a.jpg',
      );
      const b = ExportPhotoRef(
        id: 'b',
        outingId: 'o',
        storagePath: 'u/o/b.jpg',
      );
      const d = ExportPhotoRef(
        id: 'd',
        outingId: 'o',
        storagePath: 'u/o/d.jpg',
      );
      final goodA = bytes(2000);
      final goodD = bytes(3000);
      final pkg = await ExportPackageBuilder.build(
        exportedAt: when,
        textFiles: const {},
        photos: const [a, b, d],
        readLocal: (p) async => null,
        download: (p) async {
          if (p.id == 'b') throw const SocketException('reset');
          return p.id == 'a' ? goodA : goodD;
        },
      );
      expect(pkg.verified, isTrue);
      expect(pkg.photosIncluded, 2);
      expect(pkg.omitted.single.path, 'photos/o/b.jpg');
      expect(pkg.omitted.single.reason, 'download_failed');
      checkAgainstOriginals(pkg, {
        'photos/o/a.jpg': goodA,
        'photos/o/d.jpg': goodD,
      });
      final manifest = jsonDecode(
        utf8.decode(_readZip(pkg.zip)['manifest.json']!),
      );
      expect(manifest['totals']['photos_omitted'], 1);
    },
  );

  test('cancelling during the downloads stops and builds nothing', () async {
    const refs = [
      ExportPhotoRef(id: 'a', outingId: 'o', storagePath: 'p/a'),
      ExportPhotoRef(id: 'b', outingId: 'o', storagePath: 'p/b'),
      ExportPhotoRef(id: 'c', outingId: 'o', storagePath: 'p/c'),
    ];
    var cancelled = false;
    var downloads = 0;
    await expectLater(
      ExportPackageBuilder.build(
        exportedAt: when,
        textFiles: const {},
        photos: refs,
        readLocal: (p) async => null,
        download: (p) async {
          downloads++;
          if (downloads == 2) cancelled = true;
          return bytes(10);
        },
        isCancelled: () => cancelled,
      ),
      throwsA(isA<ExportCancelled>()),
    );
    expect(downloads, 2);
  });

  test('writes a sample ZIP for the external verifier', () async {
    final photoA = bytes(4096);
    final photoB = bytes(70000);
    final pkg = await ExportPackageBuilder.build(
      exportedAt: when,
      textFiles: {
        'data/bebometro-dados.json': '{"ok":true}',
        'data/bebometro-roles.csv': '"id";"nome"\n"1";"Bar do Zé"\n',
      },
      photos: const [
        ExportPhotoRef(id: 'p1', outingId: 'o1'),
        ExportPhotoRef(id: 'p2', outingId: 'o1'),
        ExportPhotoRef(id: 'gone', outingId: 'o2'),
      ],
      readLocal: (p) async => p.id == 'p1'
          ? photoA
          : p.id == 'p2'
          ? photoB
          : null,
    );
    expect(pkg.omitted.single.reason, 'file_missing');
    final out = Platform.environment['EXPORT_SAMPLE_OUT'];
    if (out != null) await File(out).writeAsBytes(pkg.zip);
  });
}

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/geo_point.dart';
import '../../l10n/l10n.dart';

/// Opens the place in a maps app, only after a tap. Coordinates when known,
/// otherwise a text search for the ADDRESS (a nickname is never sent as a
/// geographic query). Never starts navigation nor shares the location.
/// Returns false when nothing could be opened.
Future<bool> openInMaps({
  GeoPoint? point,
  String? address,
  String? city,
  String? state,
  String? label,
}) async {
  final query = [address, city, state]
      .where((v) => v != null && v.trim().isNotEmpty)
      .map((v) => v!.trim())
      .join(', ');
  if (point == null && address?.trim().isNotEmpty != true) return false;

  final lat = point?.lat.toStringAsFixed(6);
  final lng = point?.lng.toStringAsFixed(6);
  final name = label?.trim().isNotEmpty == true ? label!.trim() : null;

  // Universal fallback: opens any installed maps app that handles it, or the
  // browser.
  final web = point != null
      ? Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': '$lat,$lng'})
      : Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query});

  final candidates = <Uri>[];
  if (kIsWeb) {
    candidates.add(point != null
        ? Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=18/$lat/$lng')
        : Uri.https('www.openstreetmap.org', '/search', {'query': query}));
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    candidates.add(point != null
        ? Uri.https('maps.apple.com', '/', {'ll': '$lat,$lng', 'q': name ?? tr.placeFallbackName})
        : Uri.https('maps.apple.com', '/', {'q': query}));
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    // geo: lets the person pick any installed maps app.
    candidates.add(point != null
        ? Uri.parse('geo:$lat,$lng?q=$lat,$lng${name != null ? '(${Uri.encodeComponent(name)})' : ''}')
        : Uri.parse('geo:0,0?q=${Uri.encodeComponent(query)}'));
  }
  candidates.add(web);

  for (final uri in candidates) {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (opened) return true;
    } catch (_) {
      // No app for this scheme: try the next one.
    }
  }
  return false;
}

/// Opens an attribution link (provider/OSM) in the browser.
Future<void> openLink(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
}

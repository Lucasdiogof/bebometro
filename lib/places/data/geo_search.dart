import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/env.dart';
import '../domain/geo_point.dart';
import '../../l10n/l10n.dart';

/// Why a search gave no answer.
enum GeoSearchError {
  /// No key in this build: search and map are off.
  notConfigured,

  /// No connection or the request timed out.
  offline,

  /// The provider refused (bad key, daily quota, server error).
  unavailable,
}

class GeoSearchException implements Exception {
  const GeoSearchException(this.error);

  final GeoSearchError error;

  @override
  String toString() => 'GeoSearchException($error)';
}

/// One result from the provider: a place with a name (bar, restaurant) or a
/// plain address. Nothing here is invented: missing parts stay null.
class GeoResult {
  const GeoResult({
    required this.point,
    this.name,
    this.line1,
    this.line2,
    this.address,
    this.city,
    this.state,
    this.placeId,
    this.distanceMeters,
  });

  final GeoPoint point;

  /// Name of the establishment, when the result is one.
  final String? name;

  /// First display line (name or street) and second line (the rest).
  final String? line1;
  final String? line2;

  /// Full address without the country, for storing and showing in details.
  final String? address;
  final String? city;

  /// Two-letter state code, only when the provider gave a valid one.
  final String? state;

  /// Provider id, used only to recognise a place already saved.
  final String? placeId;
  final int? distanceMeters;

  String get title => name ?? line1 ?? address ?? tr.placePointOnMap;

  /// Second line that tells homonyms apart (street, district, city).
  String? get subtitle => name != null ? (address ?? line2) : line2;

  static GeoResult? fromJson(Map<String, dynamic> j) {
    final point = GeoPoint.tryCreate(j['lat'], j['lon']);
    if (point == null) return null;
    String? s(Object? v) {
      if (v is! String) return null;
      final t = v.trim();
      return t.isEmpty ? null : t;
    }

    String? stripCountry(String? v) {
      if (v == null) return null;
      final t = v.replaceAll(RegExp(r',\s*(Brasil|Brazil)\s*$'), '').trim();
      return t.isEmpty ? null : t;
    }

    final name = s(j['name']);
    final formatted = stripCountry(s(j['formatted']));
    final line1 = s(j['address_line1']);
    final line2 = stripCountry(s(j['address_line2']));
    // For an establishment, line2 is its address; for an address result,
    // the whole formatted text is.
    final address = name != null ? (line2 ?? formatted) : formatted;
    final uf = s(j['state_code'])?.toUpperCase();
    final dist = j['distance'];
    return GeoResult(
      point: point,
      name: name,
      line1: line1,
      line2: line2,
      address: address == name ? null : address,
      city: s(j['city']),
      state: uf != null && RegExp(r'^[A-Z]{2}$').hasMatch(uf) ? uf : null,
      placeId: s(j['place_id']),
      distanceMeters: dist is num ? dist.round() : null,
    );
  }
}

/// Place and address search on Geoapify (OpenStreetMap data).
///
/// Chosen because one client key covers autocomplete of establishments AND
/// addresses, nearby places and the map tiles; the free plan needs no credit
/// card; and its terms allow keeping the results (OSM attribution required).
/// Calls are made only on demand: debounced typing with a minimum length,
/// repeated queries answered from a small in-memory cache.
class GeoSearch {
  GeoSearch({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _key = apiKey ?? Env.geoapifyKey;

  final http.Client _client;
  final String _key;
  final _cache = <String, List<GeoResult>>{};

  static const provider = 'geoapify';
  static const minChars = 3;
  static const _timeout = Duration(seconds: 8);

  bool get configured => _key.isNotEmpty;

  /// Raster tiles of the dark style; `{r}` becomes "@2x" on dense screens.
  String? get tileUrlTemplate => configured
      ? 'https://maps.geoapify.com/v1/tile/dark-matter-yellow-roads/{z}/{x}/{y}{r}.png?apiKey=$_key'
      : null;

  /// Establishments and addresses that match [text], in Brazil, closer to
  /// [near] when known.
  Future<List<GeoResult>> autocomplete(String text, {GeoPoint? near}) {
    final q = text.trim();
    if (q.length < minChars) return Future.value(const []);
    return _get(
      'https://api.geoapify.com/v1/geocode/autocomplete',
      {
        'text': q,
        'lang': 'pt',
        'limit': '8',
        'filter': 'countrycode:br',
        'format': 'json',
        if (near != null) 'bias': 'proximity:${near.lng},${near.lat}',
      },
      (body) => body['results'],
    );
  }

  /// Bars, pubs, restaurants and clubs within [radiusMeters] of [p], closest
  /// first. Being near one does not mean being in it: the person chooses.
  Future<List<GeoResult>> nearby(GeoPoint p, {int radiusMeters = 300}) => _get(
        'https://api.geoapify.com/v2/places',
        {
          'categories':
              'catering.bar,catering.pub,catering.biergarten,catering.restaurant,adult.nightclub',
          'filter': 'circle:${p.lng},${p.lat},$radiusMeters',
          'bias': 'proximity:${p.lng},${p.lat}',
          'lang': 'pt',
          'limit': '20',
        },
        (body) => [
          for (final f in (body['features'] as List? ?? const []))
            if (f is Map && f['properties'] is Map) f['properties'],
        ],
      );

  /// The address at [p], asked only when the person taps for it.
  Future<GeoResult?> reverse(GeoPoint p) async {
    final list = await _get(
      'https://api.geoapify.com/v1/geocode/reverse',
      {
        'lat': '${p.lat}',
        'lon': '${p.lng}',
        'lang': 'pt',
        'format': 'json',
      },
      (body) => body['results'],
    );
    return list.isEmpty ? null : list.first;
  }

  Future<List<GeoResult>> _get(
    String base,
    Map<String, String> params,
    Object? Function(Map<String, dynamic>) pick,
  ) async {
    if (!configured) throw const GeoSearchException(GeoSearchError.notConfigured);
    final uri = Uri.parse(base).replace(queryParameters: {...params, 'apiKey': _key});
    final cacheKey = Uri.parse(base).replace(queryParameters: params).toString();
    final hit = _cache.remove(cacheKey);
    if (hit != null) return _cache[cacheKey] = hit; // most recent last

    http.Response res;
    try {
      res = await _client.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw const GeoSearchException(GeoSearchError.offline);
    } on http.ClientException {
      throw const GeoSearchException(GeoSearchError.offline);
    } catch (_) {
      // SocketException on mobile, XHR errors on the web.
      throw const GeoSearchException(GeoSearchError.offline);
    }
    if (res.statusCode != 200) {
      throw const GeoSearchException(GeoSearchError.unavailable);
    }
    final List<GeoResult> results;
    try {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final raw = body is Map<String, dynamic> ? pick(body) : null;
      results = [
        for (final r in (raw is List ? raw : const []))
          if (r is Map) ?GeoResult.fromJson(Map<String, dynamic>.from(r)),
      ];
    } catch (_) {
      throw const GeoSearchException(GeoSearchError.unavailable);
    }
    _cache[cacheKey] = results;
    if (_cache.length > 40) _cache.remove(_cache.keys.first);
    return results;
  }
}

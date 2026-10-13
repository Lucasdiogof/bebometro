import 'dart:math' as math;

/// A validated latitude/longitude pair. "No coordinates" is always null,
/// never (0, 0).
class GeoPoint {
  const GeoPoint._(this.lat, this.lng);

  final double lat;
  final double lng;

  /// Null unless both values are finite and inside the valid ranges.
  static GeoPoint? tryCreate(Object? lat, Object? lng) {
    final la = _num(lat);
    final lo = _num(lng);
    if (la == null || lo == null) return null;
    if (!la.isFinite || !lo.isFinite) return null;
    if (la < -90 || la > 90 || lo < -180 || lo > 180) return null;
    return GeoPoint._(la, lo);
  }

  static double? _num(Object? v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// Rough distance in metres (equirectangular; enough to tell whether two
  /// points are the same spot within a few hundred metres).
  double metersTo(GeoPoint o) {
    const r = 6371000.0;
    const rad = math.pi / 180;
    final x = (o.lng - lng) * rad * math.cos((lat + o.lat) / 2 * rad);
    final y = (o.lat - lat) * rad;
    return r * math.sqrt(x * x + y * y);
  }

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);
}

/// Where the coordinates/address of a place came from.
enum LocationSource {
  /// Chosen from a search result (name/address given by the provider).
  search('search'),

  /// A point taken from the device location and confirmed on the map.
  currentLocation('current_location'),

  /// A point the person moved by hand on the map.
  adjusted('adjusted');

  const LocationSource(this.code);
  final String code;

  static LocationSource? fromCode(String? code) {
    for (final s in values) {
      if (s.code == code) return s;
    }
    return null;
  }
}

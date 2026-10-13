import 'geo_point.dart';
import 'place.dart';

/// What the place picker hands back: a saved place as it is, or new place
/// data the person confirmed (from a search result, the device location or
/// typed by hand), plus whether to keep it in the saved places.
class PlaceDraft {
  const PlaceDraft({
    this.saved,
    this.nickname,
    this.providerName,
    this.address,
    this.city,
    this.state,
    this.point,
    this.source,
    this.provider,
    this.providerPlaceId,
    this.save = false,
  });

  /// A saved place chosen as it is.
  factory PlaceDraft.saved(Place place) => PlaceDraft(saved: place);

  /// The saved place this draft updates or reuses, if any. When set together
  /// with location fields, the person confirmed new location data for it.
  final Place? saved;

  final String? nickname;
  final String? providerName;
  final String? address;
  final String? city;

  /// Two-letter state, only when it came from the provider or was typed.
  final String? state;
  final GeoPoint? point;
  final LocationSource? source;
  final String? provider;
  final String? providerPlaceId;

  /// Keep it in the saved places (ignored for a saved place chosen as is).
  final bool save;

  /// Chosen from the saved list without new data.
  bool get isSavedAsIs =>
      saved != null &&
      point == null &&
      providerName == null &&
      address == null &&
      nickname == null;

  String get title => isSavedAsIs
      ? saved!.displayName
      : placeTitle(
          nickname: nickname ?? saved?.nickname,
          providerName: providerName,
          address: address,
          point: point,
          fallback: 'Local');

  /// Something to show and store: a name, an address or a point.
  bool get isEmpty =>
      !isSavedAsIs &&
      _blank(nickname) &&
      _blank(providerName) &&
      _blank(address) &&
      point == null;

  static bool _blank(String? v) => v == null || v.trim().isEmpty;
}

/// The copy of the place an outing keeps. Editing a saved place later never
/// rewrites it.
class PlaceSnapshot {
  const PlaceSnapshot({
    this.placeId,
    this.nickname,
    this.placeName,
    this.address,
    this.city,
    this.state,
    this.point,
  });

  factory PlaceSnapshot.ofPlace(Place p) => PlaceSnapshot(
        placeId: p.id,
        nickname: p.nickname,
        placeName: p.providerName,
        address: p.address,
        city: p.city,
        state: p.state,
        point: p.point,
      );

  factory PlaceSnapshot.ofDraft(PlaceDraft d) => PlaceSnapshot(
        nickname: d.nickname,
        placeName: d.providerName,
        address: d.address,
        city: d.city,
        state: d.state,
        point: d.point,
      );

  final String? placeId;
  final String? nickname;
  final String? placeName;
  final String? address;
  final String? city;
  final String? state;
  final GeoPoint? point;
}

import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../domain/geo_point.dart';

enum LocationProblem {
  /// Location services (GPS) are off.
  serviceOff,

  /// The person said no this time.
  denied,

  /// Said no for good: only the system settings can change it.
  deniedForever,

  /// No fix in time.
  timeout,

  /// Not available here (browser without support, insecure page, error).
  unavailable,
}

class LocationResult {
  const LocationResult.ok(this.point, {this.approximate = false})
      : problem = null;
  const LocationResult.failed(this.problem)
      : point = null,
        approximate = false;

  final GeoPoint? point;

  /// The person granted only an approximate location.
  final bool approximate;
  final LocationProblem? problem;
}

/// One reading of the device location, asked only after the person taps
/// "Usar minha localização". Foreground only, no tracking, no background.
class DeviceLocation {
  Future<LocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.failed(LocationProblem.serviceOff);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failed(LocationProblem.deniedForever);
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return const LocationResult.failed(LocationProblem.denied);
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final point = GeoPoint.tryCreate(pos.latitude, pos.longitude);
      if (point == null) {
        return const LocationResult.failed(LocationProblem.unavailable);
      }
      var approximate = false;
      try {
        approximate = await Geolocator.getLocationAccuracy() ==
            LocationAccuracyStatus.reduced;
      } catch (_) {
        // Not reported on every platform (web).
      }
      // Without "reduced" support, a very loose fix also counts as approximate.
      if (pos.accuracy > 500) approximate = true;
      return LocationResult.ok(point, approximate: approximate);
    } on TimeoutException {
      return const LocationResult.failed(LocationProblem.timeout);
    } on LocationServiceDisabledException {
      return const LocationResult.failed(LocationProblem.serviceOff);
    } on PermissionDeniedException {
      return const LocationResult.failed(LocationProblem.denied);
    } catch (_) {
      return const LocationResult.failed(LocationProblem.unavailable);
    }
  }

  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {}
  }

  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (_) {}
  }
}

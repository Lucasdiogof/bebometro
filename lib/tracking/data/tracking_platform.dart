import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// What the device can do for the lock-screen tracking.
class TrackingCapabilities {
  const TrackingCapabilities({
    required this.supported,
    this.systemEnabled = true,
    this.permission = 'unknown',
    this.detail,
  });

  static const unsupported = TrackingCapabilities(supported: false);

  /// The OS version/platform has the feature (iOS 16.2+ Live Activities,
  /// Android notifications). Never true on the web.
  final bool supported;

  /// The user did not switch it off in the system (Live Activities in iOS
  /// Settings, notifications in Android Settings).
  final bool systemEnabled;

  /// `granted`, `denied`, `notRequired` (no runtime permission on this OS
  /// version) or `unknown`.
  final String permission;
  final String? detail;
}

enum TrackingOutcome {
  started,
  updated,

  /// The user removed it from the lock screen / notification shade.
  dismissed,
  permissionDenied,
  systemOff,
  unavailable,
  error,
}

class NativeTrackingStatus {
  const NativeTrackingStatus({
    this.shownOutingIds = const [],
    this.dismissed = const [],
  });

  /// Outings that have a live activity / notification right now.
  final List<String> shownOutingIds;

  /// Outings whose surface the user removed by hand.
  final List<String> dismissed;
}

/// A tap on the live activity / notification, waiting to be handled.
class TrackingLink {
  const TrackingLink(this.outingId, this.action);

  final String outingId;

  /// `open`, `another` or `water`.
  final String action;
}

/// Bridge to the native surfaces (ActivityKit on iOS, a notification on
/// Android). Everything here is best effort: a missing plugin (web, desktop,
/// tests) means "not supported", never an exception into the app. The native
/// side never reads or writes the app's records.
class TrackingPlatform {
  TrackingPlatform();

  static const _channel = MethodChannel('bebometro/tracking');

  /// Called when the native side received a tap while the app was running.
  VoidCallback? onLink;

  bool get isNativePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  bool get isIos => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  void attach() {
    if (!isNativePlatform) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'linkReceived') onLink?.call();
      return null;
    });
  }

  Future<T?> _call<T>(String method, [Object? args]) async {
    if (!isNativePlatform) return null;
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('[tracking] $method failed: ${e.message}');
      return null;
    }
  }

  Future<TrackingCapabilities> capabilities() async {
    final m = await _call<Map<Object?, Object?>>('capabilities');
    if (m == null) return TrackingCapabilities.unsupported;
    return TrackingCapabilities(
      supported: m['supported'] == true,
      systemEnabled: m['systemEnabled'] != false,
      permission: (m['permission'] as String?) ?? 'unknown',
      detail: m['detail'] as String?,
    );
  }

  /// Asks the OS for the notification permission (Android 13+). Only called
  /// in response to the user switching the feature on.
  Future<String> requestPermission() async =>
      (await _call<String>('requestPermission')) ?? 'unknown';

  Future<TrackingOutcome> sync(Map<String, Object?> snapshot) async {
    final r = await _call<String>('sync', snapshot);
    return switch (r) {
      'started' => TrackingOutcome.started,
      'updated' => TrackingOutcome.updated,
      'dismissed' => TrackingOutcome.dismissed,
      'permissionDenied' => TrackingOutcome.permissionDenied,
      'systemOff' => TrackingOutcome.systemOff,
      'unavailable' => TrackingOutcome.unavailable,
      _ => TrackingOutcome.error,
    };
  }

  /// Ends the surface of [outingId], or every one when null.
  Future<void> end({String? outingId}) =>
      _call<void>('end', {'outingId': outingId});

  Future<NativeTrackingStatus> status() async {
    final m = await _call<Map<Object?, Object?>>('status');
    if (m == null) return const NativeTrackingStatus();
    List<String> ids(Object? v) =>
        (v as List?)?.map((e) => '$e').toList() ?? const [];
    return NativeTrackingStatus(
      shownOutingIds: ids(m['shown']),
      dismissed: ids(m['dismissed']),
    );
  }

  /// Lets the native side forget a manual removal, so it can show again.
  Future<void> clearDismissed(String outingId) =>
      _call<void>('clearDismissed', {'outingId': outingId});

  /// The tap that opened or woke the app, once.
  Future<TrackingLink?> consumeLink() async {
    final m = await _call<Map<Object?, Object?>>('consumeLink');
    final id = m?['outingId'] as String?;
    if (id == null || id.isEmpty) return null;
    return TrackingLink(id, (m?['action'] as String?) ?? 'open');
  }
}

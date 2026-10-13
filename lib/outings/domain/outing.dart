import 'package:flutter/material.dart';

import '../../places/domain/geo_point.dart';
import '../../places/domain/place.dart' show placeTitle;

enum OutingType {
  bar('bar', 'Bar', Icons.sports_bar_rounded),
  club('club', 'Balada', Icons.nightlife_rounded),
  barbecue('barbecue', 'Churrasco', Icons.outdoor_grill_rounded),
  home('home', 'Casa', Icons.home_rounded),
  restaurant('restaurant', 'Restaurante', Icons.restaurant_rounded),
  beach('beach', 'Praia', Icons.beach_access_rounded),
  other('other', 'Outro', Icons.celebration_rounded);

  const OutingType(this.code, this.label, this.icon);

  final String code;
  final String label;
  final IconData icon;

  static OutingType fromCode(String code) => OutingType.values
      .firstWhere((t) => t.code == code, orElse: () => OutingType.other);
}

enum FeedbackMood {
  smooth('smooth', 'Suave', Icons.sentiment_satisfied_rounded),
  cheerful('cheerful', 'Alegre', Icons.sentiment_very_satisfied_rounded),
  drunk('drunk', 'Bêbado', Icons.sentiment_neutral_rounded),
  wasted('wasted', 'Bebaço', Icons.sentiment_very_dissatisfied_rounded);

  const FeedbackMood(this.code, this.label, this.icon);

  final String code;
  final String label;
  final IconData icon;

  static FeedbackMood? fromCode(String? code) {
    for (final m in FeedbackMood.values) {
      if (m.code == code) return m;
    }
    return null;
  }
}

enum FeedbackStatus {
  pending('pending'),
  answered('answered'),
  snoozed('snoozed'),
  dismissed('dismissed');

  const FeedbackStatus(this.code);

  final String code;

  static FeedbackStatus fromCode(String? code) => FeedbackStatus.values
      .firstWhere((s) => s.code == code, orElse: () => FeedbackStatus.pending);
}

/// How the person woke up the day after. A personal account, not a measure.
enum WakeFeeling {
  great('great', 'Bem'),
  ok('ok', 'Normal'),
  tired('tired', 'Cansado'),
  bad('bad', 'Mal');

  const WakeFeeling(this.code, this.label);

  final String code;
  final String label;

  static WakeFeeling? fromCode(String? code) {
    for (final w in WakeFeeling.values) {
      if (w.code == code) return w;
    }
    return null;
  }
}

enum Hangover {
  none('none', 'Nenhuma'),
  mild('mild', 'Leve'),
  moderate('moderate', 'Moderada'),
  strong('strong', 'Forte');

  const Hangover(this.code, this.label);

  final String code;
  final String label;

  static Hangover? fromCode(String? code) {
    for (final h in Hangover.values) {
      if (h.code == code) return h;
    }
    return null;
  }
}

class Outing {
  const Outing({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.createdAt,
    required this.updatedAt,
    this.nickname,
    this.address,
    this.endedAt,
    this.feedbackMood,
    this.feedbackStatus = FeedbackStatus.pending,
    this.feedbackSnoozedUntil,
    this.placeId,
    this.city,
    this.state,
    this.budgetCents,
    this.wakeFeeling,
    this.hangover,
    this.feedbackNote,
    this.placeName,
    this.point,
  });

  final String id;
  final OutingType type;

  /// Friendly name such as "Casa da Samara". Shown as the place name when set.
  final String? nickname;
  final String? address;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// Personal account of how the night went; not a measurement.
  final FeedbackMood? feedbackMood;
  final FeedbackStatus feedbackStatus;
  final DateTime? feedbackSnoozedUntil;

  /// Optional details of the personal account, filled in later if the person
  /// wants. Never required.
  final WakeFeeling? wakeFeeling;
  final Hangover? hangover;
  final String? feedbackNote;

  /// The saved place this outing was linked to (null for a one-off place).
  /// [nickname], [address], [city] and [state] are this outing's own snapshot
  /// and are never rewritten when the saved place is edited.
  final String? placeId;
  final String? city;
  final String? state;

  /// This outing's copy of the name given by the map data ("Bar MELT").
  final String? placeName;

  /// This outing's copy of the confirmed coordinates; null when unknown.
  final GeoPoint? point;

  /// Optional drinks budget in cents. Null = none set.
  final int? budgetCents;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => endedAt == null;

  String get displayName => placeTitle(
      nickname: nickname, providerName: placeName, address: address,
      point: point, fallback: 'Rolê');

  /// The address is only a subtitle when a name already titles the place.
  String? get subtitleAddress =>
      ((nickname?.trim().isNotEmpty ?? false) ||
              (placeName?.trim().isNotEmpty ?? false))
          ? address
          : null;

  /// Replaces only this outing's own copy of the place (explicit correction).
  /// Drinks, photos, tab and everything else stay on the same outing id.
  Outing withPlace({
    required String? placeId,
    required String? nickname,
    required String? placeName,
    required String? address,
    required String? city,
    required String? state,
    required GeoPoint? point,
    required DateTime updatedAt,
  }) =>
      Outing(
        id: id,
        type: type,
        nickname: nickname,
        address: address,
        placeId: placeId,
        city: city,
        state: state,
        placeName: placeName,
        point: point,
        startedAt: startedAt,
        endedAt: endedAt,
        feedbackMood: feedbackMood,
        feedbackStatus: feedbackStatus,
        feedbackSnoozedUntil: feedbackSnoozedUntil,
        budgetCents: budgetCents,
        wakeFeeling: wakeFeeling,
        hangover: hangover,
        feedbackNote: feedbackNote,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Duration durationAt(DateTime now) => (endedAt ?? now).difference(startedAt);

  bool isFeedbackEligible(DateTime now) {
    if (isActive) return false;
    switch (feedbackStatus) {
      case FeedbackStatus.pending:
        return true;
      case FeedbackStatus.snoozed:
        final until = feedbackSnoozedUntil;
        return until == null || !until.isAfter(now);
      case FeedbackStatus.answered:
      case FeedbackStatus.dismissed:
        return false;
    }
  }

  Outing copyWith({
    DateTime? endedAt,
    FeedbackMood? feedbackMood,
    FeedbackStatus? feedbackStatus,
    DateTime? feedbackSnoozedUntil,
    bool clearSnooze = false,
    int? Function()? budgetCents,
    WakeFeeling? Function()? wakeFeeling,
    Hangover? Function()? hangover,
    String? Function()? feedbackNote,
    required DateTime updatedAt,
  }) =>
      Outing(
        id: id,
        type: type,
        nickname: nickname,
        address: address,
        placeId: placeId,
        city: city,
        state: state,
        placeName: placeName,
        point: point,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        feedbackMood: feedbackMood ?? this.feedbackMood,
        feedbackStatus: feedbackStatus ?? this.feedbackStatus,
        feedbackSnoozedUntil: clearSnooze
            ? null
            : (feedbackSnoozedUntil ?? this.feedbackSnoozedUntil),
        budgetCents: budgetCents != null ? budgetCents() : this.budgetCents,
        wakeFeeling: wakeFeeling != null ? wakeFeeling() : this.wakeFeeling,
        hangover: hangover != null ? hangover() : this.hangover,
        feedbackNote:
            feedbackNote != null ? feedbackNote() : this.feedbackNote,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.code,
        'nickname': nickname,
        'address': address,
        'started_at': startedAt.toUtc().toIso8601String(),
        'ended_at': endedAt?.toUtc().toIso8601String(),
        'status': isActive ? 'active' : 'ended',
        'feedback_mood': feedbackMood?.code,
        'feedback_status': feedbackStatus.code,
        'feedback_snoozed_until':
            feedbackSnoozedUntil?.toUtc().toIso8601String(),
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        // Newer fields are only sent when set, so outings keep syncing to a
        // database that does not have those columns yet.
        if (placeId != null) 'place_id': placeId,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (budgetCents != null) 'budget_cents': budgetCents,
        if (wakeFeeling != null) 'feedback_wake': wakeFeeling!.code,
        if (hangover != null) 'feedback_hangover': hangover!.code,
        if (feedbackNote != null) 'feedback_note': feedbackNote,
        if (placeName != null) 'place_name': placeName,
        if (point != null) 'latitude': point!.lat,
        if (point != null) 'longitude': point!.lng,
      };

  factory Outing.fromJson(Map<String, dynamic> json) => Outing(
        id: json['id'] as String,
        type: OutingType.fromCode(json['type'] as String),
        nickname: json['nickname'] as String?,
        address: json['address'] as String?,
        startedAt: DateTime.parse(json['started_at'] as String).toLocal(),
        endedAt: json['ended_at'] == null
            ? null
            : DateTime.parse(json['ended_at'] as String).toLocal(),
        feedbackMood: FeedbackMood.fromCode(json['feedback_mood'] as String?),
        feedbackStatus:
            FeedbackStatus.fromCode(json['feedback_status'] as String?),
        feedbackSnoozedUntil: json['feedback_snoozed_until'] == null
            ? null
            : DateTime.parse(json['feedback_snoozed_until'] as String)
                .toLocal(),
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
        placeId: json['place_id'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        budgetCents: (json['budget_cents'] as num?)?.toInt(),
        wakeFeeling: WakeFeeling.fromCode(json['feedback_wake'] as String?),
        hangover: Hangover.fromCode(json['feedback_hangover'] as String?),
        feedbackNote: json['feedback_note'] as String?,
        placeName: json['place_name'] as String?,
        point: GeoPoint.tryCreate(json['latitude'], json['longitude']),
      );
}

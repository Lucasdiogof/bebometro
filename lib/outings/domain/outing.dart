import 'package:flutter/material.dart';

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

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isActive => endedAt == null;

  String get displayName => (nickname != null && nickname!.isNotEmpty)
      ? nickname!
      : (address ?? 'Rolê');

  /// The address is only a subtitle when a nickname already names the place.
  String? get subtitleAddress =>
      (nickname != null && nickname!.isNotEmpty) ? address : null;

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
    required DateTime updatedAt,
  }) =>
      Outing(
        id: id,
        type: type,
        nickname: nickname,
        address: address,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        feedbackMood: feedbackMood ?? this.feedbackMood,
        feedbackStatus: feedbackStatus ?? this.feedbackStatus,
        feedbackSnoozedUntil: clearSnooze
            ? null
            : (feedbackSnoozedUntil ?? this.feedbackSnoozedUntil),
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
      );
}

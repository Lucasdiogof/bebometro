import '../../outings/domain/outing.dart';

/// A personal, reusable place. Private to the user. Rolês keep their own
/// copy of the name/address, so editing a place never rewrites old outings.
class Place {
  const Place({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.nickname,
    this.address,
    this.city,
    this.state,
    this.favorite = false,
    this.archivedAt,
  });

  final String id;
  final OutingType type;

  /// "Casa da Samara". Shown as the title when set.
  final String? nickname;
  final String? address;
  final String? city;

  /// Two-letter state (UF), upper case.
  final String? state;
  final bool favorite;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isArchived => archivedAt != null;

  String get displayName => (nickname != null && nickname!.isNotEmpty)
      ? nickname!
      : (address ?? 'Local');

  /// The address is a subtitle only when a nickname already names the place.
  String? get subtitleAddress =>
      (nickname != null && nickname!.isNotEmpty) ? address : null;

  /// "São Paulo, SP", "SP", "São Paulo" or null.
  String? get cityState {
    final parts = [
      if (city != null && city!.isNotEmpty) city!,
      if (state != null && state!.isNotEmpty) state!,
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }

  Place copyWith({
    OutingType? type,
    String? Function()? nickname,
    String? Function()? address,
    String? Function()? city,
    String? Function()? state,
    bool? favorite,
    DateTime? Function()? archivedAt,
    required DateTime updatedAt,
  }) =>
      Place(
        id: id,
        type: type ?? this.type,
        nickname: nickname != null ? nickname() : this.nickname,
        address: address != null ? address() : this.address,
        city: city != null ? city() : this.city,
        state: state != null ? state() : this.state,
        favorite: favorite ?? this.favorite,
        archivedAt: archivedAt != null ? archivedAt() : this.archivedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.code,
        'nickname': nickname,
        'address': address,
        'city': city,
        'state': state,
        'favorite': favorite,
        'archived_at': archivedAt?.toUtc().toIso8601String(),
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  factory Place.fromJson(Map<String, dynamic> j) => Place(
        id: j['id'] as String,
        type: OutingType.fromCode(j['type'] as String? ?? 'other'),
        nickname: j['nickname'] as String?,
        address: j['address'] as String?,
        city: j['city'] as String?,
        state: j['state'] as String?,
        favorite: j['favorite'] as bool? ?? false,
        archivedAt: j['archived_at'] == null
            ? null
            : DateTime.parse(j['archived_at'] as String).toLocal(),
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
        updatedAt: DateTime.parse(j['updated_at'] as String).toLocal(),
      );
}

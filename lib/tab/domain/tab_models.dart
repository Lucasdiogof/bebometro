import 'package:flutter/material.dart';

import '../../drinks/domain/drink_entry.dart';
import '../../l10n/l10n.dart';

/// What an extra line of the tab is. Extras belong to one outing only: they
/// never enter the drink catalog or any price history.
enum ExtraCategory {
  food('food', Icons.restaurant_rounded, true),
  soft('soft', Icons.water_drop_outlined, true),
  cover('cover', Icons.music_note_rounded, true),
  starter('starter', Icons.confirmation_number_outlined, false),
  transport('transport', Icons.directions_car_outlined, false),
  other('other', Icons.receipt_long_outlined, true),
  drink('drink', Icons.local_bar_outlined, true);

  const ExtraCategory(this.code, this.icon, this.defaultService);

  /// Stored value; never translated.
  final String code;
  final IconData icon;

  String get label => switch (this) {
    ExtraCategory.food => tr.tabCatFood,
    ExtraCategory.soft => tr.tabCatSoft,
    ExtraCategory.cover => tr.tabCatCover,
    ExtraCategory.starter => tr.tabCatStarter,
    ExtraCategory.transport => tr.tabCatTransport,
    ExtraCategory.other => tr.tabCatOther,
    ExtraCategory.drink => tr.tabCatDrink,
  };

  /// Entry and transport start without the service charge.
  final bool defaultService;

  static ExtraCategory fromCode(String? code) => ExtraCategory.values
      .firstWhere((c) => c.code == code, orElse: () => ExtraCategory.other);
}

/// Whether the typed amount is per unit or for the whole line.
enum PriceBasis {
  unit('unit'),
  total('total');

  const PriceBasis(this.code);

  final String code;

  static PriceBasis fromCode(String? code) => PriceBasis.values.firstWhere(
    (b) => b.code == code,
    orElse: () => PriceBasis.total,
  );
}

enum SplitMode {
  equal('equal'),
  item('item'),
  custom('custom');

  const SplitMode(this.code);

  /// Stored value; never translated.
  final String code;

  String get label => switch (this) {
    SplitMode.equal => tr.tabSplitEqual,
    SplitMode.item => tr.tabSplitItem,
    SplitMode.custom => tr.tabSplitCustom,
  };

  static SplitMode fromCode(String? code) => SplitMode.values.firstWhere(
    (m) => m.code == code,
    orElse: () => SplitMode.equal,
  );
}

enum DiscountKind {
  none('none'),
  amount('amount'),
  percent('percent');

  const DiscountKind(this.code);

  final String code;

  static DiscountKind fromCode(String? code) => DiscountKind.values.firstWhere(
    (k) => k.code == code,
    orElse: () => DiscountKind.none,
  );
}

/// A person of the table, known only by a nickname inside this tab. The id is
/// the identity; the name can change freely.
class Participant {
  const Participant({
    required this.id,
    required this.name,
    this.isMe = false,
    this.left = false,
  });

  final String id;
  final String name;
  final bool isMe;

  /// The person left the outing. They stay on every order they were part of,
  /// but are not selected by default for new items ("everybody present").
  final bool left;

  /// The name to show. The automatic "me" person keeps showing in the
  /// language on screen until the user renames it.
  String get displayName =>
      isMe && const {'Você', 'You', 'Tú'}.contains(name) ? tr.tabMe : name;

  /// First letter, to tell people apart next to the name (names can repeat).
  String get initial {
    final t = displayName.trim();
    return t.isEmpty ? '?' : String.fromCharCode(t.runes.first).toUpperCase();
  }

  Participant copyWith({String? name, bool? left}) => Participant(
    id: id,
    name: name ?? this.name,
    isMe: isMe,
    left: left ?? this.left,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'me': isMe,
    if (left) 'left': true,
  };

  factory Participant.fromJson(Map<String, dynamic> j) => Participant(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    isMe: j['me'] as bool? ?? false,
    left: j['left'] as bool? ?? false,
  );
}

Map<String, int>? _weightsFromJson(Object? raw) {
  if (raw is! Map) return null;
  final out = <String, int>{};
  raw.forEach((k, v) {
    final w = (v as num?)?.toInt() ?? 0;
    if (w > 0) out[k as String] = w;
  });
  return out;
}

/// An extra line typed on the tab (snack, cover, transport, a drink that is
/// only on the tab...). Creating one never creates a drink record.
class TabExtra {
  const TabExtra({
    required this.id,
    required this.description,
    required this.category,
    required this.createdAt,
    this.quantity = 1,
    this.priceKind = PriceKind.unknown,
    this.basis = PriceBasis.total,
    this.cents,
    this.service = true,
    this.assign,
  });

  final String id;
  final String description;
  final ExtraCategory category;
  final DateTime createdAt;
  final int quantity;
  final PriceKind priceKind;
  final PriceBasis basis;

  /// The typed amount, in cents: per unit or for the line (see [basis]).
  final int? cents;

  /// Whether the service charge applies to this line.
  final bool service;

  /// Who takes part, with weights; null = everybody.
  final Map<String, int>? assign;

  /// Cost of the whole line; null when the price is unknown.
  int? get totalCents {
    switch (priceKind) {
      case PriceKind.complimentary:
        return 0;
      case PriceKind.unknown:
        return null;
      case PriceKind.informed:
        final c = cents;
        if (c == null) return null;
        return basis == PriceBasis.unit ? c * quantity : c;
    }
  }

  TabExtra copyWith({
    String? description,
    ExtraCategory? category,
    int? quantity,
    PriceKind? priceKind,
    PriceBasis? basis,
    int? Function()? cents,
    bool? service,
    Map<String, int>? Function()? assign,
  }) => TabExtra(
    id: id,
    description: description ?? this.description,
    category: category ?? this.category,
    createdAt: createdAt,
    quantity: quantity ?? this.quantity,
    priceKind: priceKind ?? this.priceKind,
    basis: basis ?? this.basis,
    cents: cents != null ? cents() : this.cents,
    service: service ?? this.service,
    assign: assign != null ? assign() : this.assign,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'category': category.code,
    'quantity': quantity,
    'price_kind': priceKind.code,
    'basis': basis.code,
    'cents': cents,
    'service': service,
    'assign': assign,
    'created_at': createdAt.toUtc().toIso8601String(),
  };

  factory TabExtra.fromJson(Map<String, dynamic> j) => TabExtra(
    id: j['id'] as String,
    description: j['description'] as String? ?? '',
    category: ExtraCategory.fromCode(j['category'] as String?),
    quantity: ((j['quantity'] as num?)?.toInt() ?? 1).clamp(1, 9999).toInt(),
    priceKind: PriceKind.fromCode(j['price_kind'] as String? ?? 'unknown'),
    basis: PriceBasis.fromCode(j['basis'] as String?),
    cents: (j['cents'] as num?)?.toInt(),
    service: j['service'] as bool? ?? true,
    assign: _weightsFromJson(j['assign']),
    createdAt:
        DateTime.tryParse(j['created_at'] as String? ?? '')?.toLocal() ??
        DateTime.now(),
  );
}

/// An explicit link to a drink record. Only the id (and how the line is
/// shared) is stored: price and name are always read from the record, so a
/// correction there is a correction here, and nothing can diverge.
class TabLink {
  const TabLink({
    required this.entryId,
    this.service = true,
    this.assign,
    this.mergedIds = const [],
  });

  final String entryId;
  final bool service;
  final Map<String, int>? assign;

  /// Other records the user confirmed to be the same shared bottle/jug as
  /// this one. They are not charged again.
  final List<String> mergedIds;

  TabLink copyWith({
    bool? service,
    Map<String, int>? Function()? assign,
    List<String>? mergedIds,
  }) => TabLink(
    entryId: entryId,
    service: service ?? this.service,
    assign: assign != null ? assign() : this.assign,
    mergedIds: mergedIds ?? this.mergedIds,
  );

  Map<String, dynamic> toJson() => {
    'entry_id': entryId,
    'service': service,
    'assign': assign,
    'merged_ids': mergedIds,
  };

  factory TabLink.fromJson(Map<String, dynamic> j) => TabLink(
    entryId: j['entry_id'] as String,
    service: j['service'] as bool? ?? true,
    assign: _weightsFromJson(j['assign']),
    mergedIds: (j['merged_ids'] as List?)?.cast<String>() ?? const [],
  );
}

/// What a person says to have paid the establishment. It never changes the
/// total, the consumption or the budget: only the balance.
class TabPayment {
  const TabPayment({
    required this.id,
    required this.participantId,
    required this.cents,
    required this.at,
    this.note,
  });

  final String id;
  final String participantId;
  final int cents;
  final DateTime at;
  final String? note;

  TabPayment copyWith({String? participantId, int? cents, String? note}) =>
      TabPayment(
        id: id,
        participantId: participantId ?? this.participantId,
        cents: cents ?? this.cents,
        at: at,
        note: note ?? this.note,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'participant_id': participantId,
    'cents': cents,
    'at': at.toUtc().toIso8601String(),
    'note': note,
  };

  factory TabPayment.fromJson(Map<String, dynamic> j) => TabPayment(
    id: j['id'] as String,
    participantId: j['participant_id'] as String,
    cents: (j['cents'] as num?)?.toInt() ?? 0,
    at:
        DateTime.tryParse(j['at'] as String? ?? '')?.toLocal() ??
        DateTime.now(),
    note: j['note'] as String?,
  );
}

/// The whole tab of one outing, saved as a single document so participants,
/// shares, settings and payments can never be half-saved.
class TabDoc {
  const TabDoc({
    required this.outingId,
    this.participants = const [],
    this.extras = const [],
    this.links = const [],
    this.serviceOn = false,
    this.serviceBp = 1000,
    this.discountKind = DiscountKind.none,
    this.discountValue = 0,
    this.mode = SplitMode.equal,
    this.equalIds = const [],
    this.custom = const {},
    this.payments = const [],
    this.autoLink = false,
  });

  factory TabDoc.empty(String outingId) => TabDoc(outingId: outingId);

  /// An outing started with people: every live drink record of the outing is on
  /// the tab by itself (no second write), shared by what each person ordered.
  factory TabDoc.forTable(String outingId, Participant me) => TabDoc(
    outingId: outingId,
    participants: [me],
    equalIds: [me.id],
    mode: SplitMode.item,
    autoLink: true,
  );

  /// Every record of the outing counts on the tab (see [TabDoc.forTable]).
  /// False for tabs made before people existed: those keep their explicit links.
  final bool autoLink;

  final String outingId;
  final List<Participant> participants;
  final List<TabExtra> extras;
  final List<TabLink> links;

  /// Service charge, off at first. [serviceBp] is in basis points (1000 = 10%).
  final bool serviceOn;
  final int serviceBp;

  /// Discount: cents for [DiscountKind.amount], basis points for percent.
  final DiscountKind discountKind;
  final int discountValue;

  final SplitMode mode;

  /// Participants taking part in the equal split.
  final List<String> equalIds;

  /// Typed shares (cents) per participant for the custom split.
  final Map<String, int> custom;
  final List<TabPayment> payments;

  bool get isEmpty =>
      participants.isEmpty &&
      extras.isEmpty &&
      links.isEmpty &&
      payments.isEmpty;

  /// People still at the table (not marked as left), in order.
  List<Participant> get present => [
    for (final p in participants)
      if (!p.left) p,
  ];

  Participant? get me {
    for (final p in participants) {
      if (p.isMe) return p;
    }
    return null;
  }

  Participant? participant(String id) {
    for (final p in participants) {
      if (p.id == id) return p;
    }
    return null;
  }

  TabLink? linkFor(String entryId) {
    for (final l in links) {
      if (l.entryId == entryId) return l;
    }
    return null;
  }

  /// Records already charged on the tab (linked or merged into a link).
  Set<String> get coveredEntryIds => {
    for (final l in links) ...[l.entryId, ...l.mergedIds],
  };

  TabDoc copyWith({
    List<Participant>? participants,
    List<TabExtra>? extras,
    List<TabLink>? links,
    bool? serviceOn,
    int? serviceBp,
    DiscountKind? discountKind,
    int? discountValue,
    SplitMode? mode,
    List<String>? equalIds,
    Map<String, int>? custom,
    List<TabPayment>? payments,
    bool? autoLink,
  }) => TabDoc(
    outingId: outingId,
    participants: participants ?? this.participants,
    extras: extras ?? this.extras,
    links: links ?? this.links,
    serviceOn: serviceOn ?? this.serviceOn,
    serviceBp: serviceBp ?? this.serviceBp,
    discountKind: discountKind ?? this.discountKind,
    discountValue: discountValue ?? this.discountValue,
    mode: mode ?? this.mode,
    equalIds: equalIds ?? this.equalIds,
    custom: custom ?? this.custom,
    payments: payments ?? this.payments,
    autoLink: autoLink ?? this.autoLink,
  );

  Map<String, dynamic> toJson() => {
    'participants': [for (final p in participants) p.toJson()],
    'extras': [for (final e in extras) e.toJson()],
    'links': [for (final l in links) l.toJson()],
    'service_on': serviceOn,
    'service_bp': serviceBp,
    'discount_kind': discountKind.code,
    'discount_value': discountValue,
    'mode': mode.code,
    'equal_ids': equalIds,
    'custom': custom,
    'payments': [for (final p in payments) p.toJson()],
    if (autoLink) 'auto_link': true,
  };

  factory TabDoc.fromJson(String outingId, Map<String, dynamic> j) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) => [
      for (final raw in (j[key] as List? ?? const []))
        f(Map<String, dynamic>.from(raw as Map)),
    ];
    final custom = <String, int>{};
    (j['custom'] as Map?)?.forEach((k, v) {
      custom[k as String] = (v as num?)?.toInt() ?? 0;
    });
    return TabDoc(
      outingId: outingId,
      participants: list('participants', Participant.fromJson),
      extras: list('extras', TabExtra.fromJson),
      links: list('links', TabLink.fromJson),
      serviceOn: j['service_on'] as bool? ?? false,
      serviceBp: (j['service_bp'] as num?)?.toInt() ?? 1000,
      discountKind: DiscountKind.fromCode(j['discount_kind'] as String?),
      discountValue: (j['discount_value'] as num?)?.toInt() ?? 0,
      mode: SplitMode.fromCode(j['mode'] as String?),
      equalIds: (j['equal_ids'] as List?)?.cast<String>() ?? const [],
      custom: custom,
      payments: list('payments', TabPayment.fromJson),
      autoLink: j['auto_link'] as bool? ?? false,
    );
  }
}

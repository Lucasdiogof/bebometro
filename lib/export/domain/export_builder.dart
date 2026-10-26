import 'dart:convert';

import '../../drinks/domain/drink_entry.dart';
import '../../outings/domain/outing.dart';
import '../../outings/domain/outing_summary.dart';
import '../../l10n/l10n.dart';

/// Builds the user's own exports. Nothing here reads credentials, tokens or
/// session identifiers: only the records the person created.
class ExportBuilder {
  const ExportBuilder._();

  /// UTF-8 byte order mark, so spreadsheet apps read the accents correctly.
  static const bom = '﻿';

  /// Everything, with details and compositions preserved.
  static String json({
    required DateTime exportedAt,
    required List<Map<String, dynamic>> places,
    required List<Map<String, dynamic>> outings,
    required List<Map<String, dynamic>> drinkEntries,
    required List<Map<String, dynamic>> customDrinks,
    List<Map<String, dynamic>> outingDrinks = const [],
    List<Map<String, dynamic>> outingPhotos = const [],
    List<Map<String, dynamic>> outingTabs = const [],
  }) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'app': 'Bebômetro',
      'format_version': 1,
      'exported_at': exportedAt.toUtc().toIso8601String(),
      // Keys and codes never depend on the language; only this note and
      // "language" follow the app language at the moment of the export.
      'language': trLanguage,
      'note': tr.exportJsonNote,
      'places': places,
      'outings': outings,
      'drink_entries': drinkEntries,
      'custom_drinks': customDrinks,
      // Drinks and photos that belong to one outing each (outing_id). Photo
      // files are not included, only their metadata.
      'outing_drinks': outingDrinks,
      'outing_photos': outingPhotos,
      // The tab (comanda) of each outing: participants are nicknames only.
      'outing_tabs': outingTabs,
    });
  }

  /// One row per outing. Separator ";" (the default of pt-BR spreadsheets),
  /// every text quoted, empty cell = unknown. Columns and values are
  /// machine codes ("tipo" is an outing type code, "relato" a mood code...):
  /// they do not change with the app language, so a file exported in one
  /// language reads exactly like one exported in another.
  static String outingsCsv(
    List<Outing> outings,
    List<DrinkEntry> Function(String outingId) entriesOf,
  ) {
    final rows = <List<Object?>>[
      [
        'id',
        'inicio_utc',
        'fim_utc',
        'duracao_min',
        'tipo',
        'local',
        'endereco',
        'cidade',
        'uf',
        'orcamento_centavos',
        'bebidas',
        'gasto_informado_centavos',
        'bebidas_sem_preco',
        'relato',
        'acordou',
        'ressaca',
        'nota',
      ],
      for (final o in outings)
        () {
          final s = OutingSummary.of(entriesOf(o.id));
          return <Object?>[
            o.id,
            o.startedAt.toUtc().toIso8601String(),
            o.endedAt?.toUtc().toIso8601String(),
            o.endedAt == null ? null : o.durationAt(o.endedAt!).inMinutes,
            o.type.code,
            o.nickname,
            o.address,
            o.city,
            o.state,
            o.budgetCents,
            s.entryCount,
            s.informedCents,
            s.unpricedCount,
            o.feedbackMood?.code,
            o.wakeFeeling?.code,
            o.hangover?.code,
            o.feedbackNote,
          ];
        }(),
    ];
    return _csv(rows);
  }

  /// One row per drink record. No alcohol is computed any more; the raw ABV and
  /// volume columns only carry what older records stored.
  static String drinksCsv(List<DrinkEntry> entries) {
    final rows = <List<Object?>>[
      [
        'id',
        'rolê_id',
        'horario_utc',
        'bebida',
        'categoria',
        'marca',
        'estilo',
        'apresentacao',
        'teor_percentual',
        'volume_embalagem_ml',
        'volume_pessoal_ml',
        'compartilhada',
        'pessoas',
        'preco_tipo',
        'pago_centavos',
        'total_conta_centavos',
        'composicao_json',
        // Added at the end so older readers keep their column positions:
        // "voce" = the account owner, otherwise the participant id.
        'consumidor',
        'porcoes_json',
        // Who bears the cost, apart from who consumed (weights by person; empty
        // on records that never named payers).
        'pagantes_json',
      ],
      for (final e in entries)
        () {
          return <Object?>[
            e.id,
            e.outingId,
            e.consumedAt.toUtc().toIso8601String(),
            e.name,
            e.category.code,
            e.brand,
            e.style,
            e.presentation,
            e.abvPercent,
            e.containerMl,
            e.personalMl,
            e.isShared,
            e.peopleCount,
            switch (e.priceKind) {
              PriceKind.informed => 'informado',
              PriceKind.complimentary => 'cortesia',
              PriceKind.unknown => 'nao_informado',
            },
            e.paidCents,
            e.billTotalCents,
            e.composition == null ? null : jsonEncode(e.composition!.toJson()),
            e.portions != null ? null : (e.consumerId ?? 'voce'),
            e.portions == null ? null : jsonEncode(e.portions),
            e.payers == null ? null : jsonEncode(e.payers),
          ];
        }(),
    ];
    return _csv(rows);
  }

  static String _csv(List<List<Object?>> rows) {
    final out = StringBuffer(bom);
    for (final row in rows) {
      out.writeln(row.map(_cell).join(';'));
    }
    return out.toString();
  }

  /// Text is quoted ("" escapes a quote), numbers use a decimal comma, null is
  /// an empty cell, booleans are "sim"/"nao".
  static String _cell(Object? v) {
    if (v == null) return '';
    if (v is bool) return v ? 'sim' : 'nao';
    if (v is int) return '$v';
    if (v is double) return v.toString().replaceAll('.', ',');
    final s = v.toString().replaceAll('"', '""');
    return '"$s"';
  }
}

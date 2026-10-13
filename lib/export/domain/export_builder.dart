import 'dart:convert';

import '../../drinks/domain/drink_entry.dart';
import '../../outings/domain/outing.dart';
import '../../outings/domain/outing_summary.dart';

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
      'note': 'Dados pessoais exportados pela própria pessoa. Valores em '
          'centavos, volumes em ml, horários em UTC. Campos nulos são '
          'desconhecidos, não zero.',
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
  /// every text quoted, empty cell = unknown.
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
            o.type.label,
            o.nickname,
            o.address,
            o.city,
            o.state,
            o.budgetCents,
            s.entryCount,
            s.informedCents,
            s.unpricedCount,
            o.feedbackMood?.label,
            o.wakeFeeling?.label,
            o.hangover?.label,
            o.feedbackNote,
          ];
        }(),
    ];
    return _csv(rows);
  }

  /// One row per drink record. Pure alcohol is only filled when it could be
  /// computed; "alcool_completo" says whether anything was missing.
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
        'alcool_puro_ml_conhecido',
        'alcool_completo',
        'composicao_json',
      ],
      for (final e in entries)
        () {
          final alcohol = e.alcohol;
          return <Object?>[
            e.id,
            e.outingId,
            e.consumedAt.toUtc().toIso8601String(),
            e.name,
            e.category.label,
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
            alcohol?.pureMl,
            alcohol?.isComplete,
            e.composition == null ? null : jsonEncode(e.composition!.toJson()),
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

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/device_store.dart';
import '../../outings/domain/outing.dart';
import '../domain/table_scenario.dart';

enum TableView { table, list }

class TablePrefs {
  const TablePrefs({
    this.view = TableView.table,
    this.animations = true,
    this.scenarios = const {},
  });

  /// The view used on the outing screen (also the "table as default" setting).
  final TableView view;

  /// Whether the table's decorative animations are on.
  final bool animations;

  /// Scenario chosen per outing id (device-local, decorative only).
  final Map<String, String> scenarios;

  TablePrefs copyWith({
    TableView? view,
    bool? animations,
    Map<String, String>? scenarios,
  }) => TablePrefs(
    view: view ?? this.view,
    animations: animations ?? this.animations,
    scenarios: scenarios ?? this.scenarios,
  );

  TableScenario scenarioFor(String outingId, OutingType type) =>
      TableScenario.fromCode(scenarios[outingId]) ??
      TableScenario.suggestedFor(type);
}

/// Purely visual preferences, kept on the device. They never touch the
/// outing's data or the drink records.
class TablePrefsCubit extends Cubit<TablePrefs> {
  TablePrefsCubit(this._store) : super(const TablePrefs()) {
    emit(_read());
  }

  final DeviceStore _store;

  static const _viewKey = 'table.view';
  static const _animKey = 'table.animations';
  static const _scenKey = 'table.scenarios';

  TablePrefs _read() {
    var scenarios = <String, String>{};
    try {
      final raw = _store.getString(_scenKey);
      if (raw != null) {
        scenarios = Map<String, String>.from(jsonDecode(raw) as Map);
      }
    } catch (_) {
      // A damaged value just falls back to the suggested scenario.
    }
    return TablePrefs(
      view: _store.getString(_viewKey) == 'list'
          ? TableView.list
          : TableView.table,
      animations: _store.getString(_animKey) != '0',
      scenarios: scenarios,
    );
  }

  Future<void> setView(TableView v) async {
    emit(state.copyWith(view: v));
    await _store.setString(_viewKey, v == TableView.list ? 'list' : 'table');
  }

  Future<void> setAnimations(bool on) async {
    emit(state.copyWith(animations: on));
    await _store.setString(_animKey, on ? '1' : '0');
  }

  Future<void> setScenario(String outingId, TableScenario s) async {
    final next = {...state.scenarios, outingId: s.code};
    emit(state.copyWith(scenarios: next));
    await _store.setString(_scenKey, jsonEncode(next));
  }
}

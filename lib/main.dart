import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Date/number symbols of the three languages of the app.
  await initializeDateFormatting('pt_BR');
  await initializeDateFormatting('en');
  await initializeDateFormatting('es');
  await configureDependencies();
  runApp(const BebometroApp());
}

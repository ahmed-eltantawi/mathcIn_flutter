import 'package:flutter/material.dart';

import 'package:MatchIn/app.dart';
import 'package:MatchIn/core/services/app_initializer.dart';
import 'package:MatchIn/core/services/services_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core dependencies
  await setupServiceLocator();

  // Run the full startup sequence (Firebase, base URL, ads, push)
  await getIt<AppInitializer>().init();

  // Run the app
  runApp(const MatchIn());
}

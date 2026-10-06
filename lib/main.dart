import 'dart:async';
import 'dart:developer';

import 'package:MatchIn/app.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core dependencies
  await setupServiceLocator();

  // Initialize Mobile Ads asynchronously in background without blocking startup
  unawaited(
    MobileAds.instance.initialize().catchError((e) {
      log('MobileAds init error: $e');
      return InitializationStatus({});
    }),
  );

  // Run the app
  runApp(const MatchIn());
}

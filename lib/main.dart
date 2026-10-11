import 'dart:developer';

import 'package:MatchIn/app.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core dependencies
  await setupServiceLocator();

  // Initialize Mobile Ads before runApp so RewardedAd.load() in the
  // roadmap feature never races an uninitialized SDK (which caused
  // "Watch Ad" taps to silently do nothing / show "Ad Not Available").
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    log('MobileAds init error: $e');
  }

  // Run the app
  runApp(const MatchIn());
}

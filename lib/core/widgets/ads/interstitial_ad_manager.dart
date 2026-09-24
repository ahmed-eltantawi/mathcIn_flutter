import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages the lifecycle of a single interstitial ad.
///
/// Flow: [loadAd] preloads in the background, [showAd] shows the ad only
/// when it is ready and notifies the caller via [onAdClosed] once the ad
/// is dismissed or fails to show, so navigation never gets stuck.
class InterstitialAdManager {
  InterstitialAdManager();

  // --- Ad Unit IDs ---
  // TODO: replace with your production interstitial ad unit IDs from AdMob.
  // Ad Unit IDs must use the '/' format (ca-app-pub-XXXX/YYYY).
  // Never use the App ID ('~' format) here. The App ID stays only in
  // AndroidManifest.xml / Info.plist.
  static const String _androidAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosAdUnitId = 'ca-app-pub-3940256099942544/4411468910';

  String get adUnitId =>
      Platform.isAndroid ? _androidAdUnitId : _iosAdUnitId;

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  bool _isDisposed = false;

  /// Whether an ad is ready to be shown.
  bool get isAdReady => _interstitialAd != null && _isAdLoaded;

  //! ===== Load =====
  void loadAd() {
    if (_isDisposed) {
      return;
    }
    if (_isLoading || isAdReady) {
      return;
    }
    _isLoading = true;
    developer.log('Interstitial ad loading started.');

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_isDisposed) {
            ad.dispose();
            return;
          }
          _isLoading = false;
          _isAdLoaded = true;
          _interstitialAd = ad;
          developer.log('Interstitial ad loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _isAdLoaded = false;
          _interstitialAd = null;
          developer.log('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  //! ===== Show =====
  Future<void> showAd({required VoidCallback onAdClosed}) async {
    final ad = _interstitialAd;
    if (!_isDisposed && ad != null && _isAdLoaded) {
      developer.log('Interstitial ad is being shown.');
      bool isCallbackInvoked = false;
      void notifyClosedOnce() {
        if (!isCallbackInvoked) {
          isCallbackInvoked = true;
          onAdClosed();
        }
      }

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (shownAd) {
          developer.log('Interstitial ad showed full screen content.');
        },
        onAdDismissedFullScreenContent: (dismissedAd) {
          developer.log('Interstitial ad dismissed.');
          dismissedAd.dispose();
          _clearAdReference();
          notifyClosedOnce();
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (failedAd, error) {
          developer.log('Interstitial ad failed to show: $error');
          failedAd.dispose();
          _clearAdReference();
          notifyClosedOnce();
          loadAd();
        },
      );
      _interstitialAd = null;
      _isAdLoaded = false;
      ad.show();
    } else {
      developer.log('Interstitial ad was not ready, skipping show.');
      loadAd();
      onAdClosed();
    }
  }

  // --- Clear the old ad reference ---
  void _clearAdReference() {
    _interstitialAd = null;
    _isAdLoaded = false;
    _isLoading = false;
  }

  void dispose() {
    _isDisposed = true;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _isLoading = false;
  }
}

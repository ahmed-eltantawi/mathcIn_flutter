import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages the lifecycle of a single rewarded ad.
///
/// Flow: [loadAd] preloads in the background, [showAd] shows the ad only
/// when it is ready. [onUserEarnedReward] is triggered ONLY when AdMob
/// confirms that the user completed watching the ad.
class RewardedAdManager {
  RewardedAdManager();

  // --- Ad Unit IDs ---
  // Production Android Rewarded Ad Unit ID: ca-app-pub-890932530990984/9210302806
  // Test iOS Rewarded Ad Unit ID: ca-app-pub-3940256099942544/5224354917
  static const String _androidAdUnitId =
      'ca-app-pub-890932530990984/9210302806';
  static const String _iosAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  String get adUnitId =>
      Platform.isAndroid ? _androidAdUnitId : _iosAdUnitId;

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  bool _isDisposed = false;

  /// Whether a rewarded ad is loaded and ready to be shown.
  bool get isAdReady => _rewardedAd != null && _isAdLoaded;

  /// Whether an ad is currently in the process of loading.
  bool get isLoading => _isLoading;

  //! ===== Load =====
  void loadAd() {
    if (_isDisposed) {
      return;
    }
    if (_isLoading || isAdReady) {
      return;
    }
    _isLoading = true;
    developer.log('Rewarded ad loading started.');

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (_isDisposed) {
            ad.dispose();
            return;
          }
          _isLoading = false;
          _isAdLoaded = true;
          _rewardedAd = ad;
          developer.log('Rewarded ad loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _isAdLoaded = false;
          _rewardedAd = null;
          developer.log('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  //! ===== Show =====
  Future<void> showAd({
    required Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdClosed,
    Function(AdError error)? onAdFailedToShow,
  }) async {
    final ad = _rewardedAd;
    if (!_isDisposed && ad != null && _isAdLoaded) {
      developer.log('Rewarded ad is being shown.');

      bool hasEarnedReward = false;
      bool isCallbackInvoked = false;

      void notifyClosedOnce() {
        if (!isCallbackInvoked) {
          isCallbackInvoked = true;
          onAdClosed?.call();
        }
      }

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (shownAd) {
          developer.log('Rewarded ad showed full screen content.');
        },
        onAdDismissedFullScreenContent: (dismissedAd) {
          developer.log('Rewarded ad dismissed.');
          dismissedAd.dispose();
          _clearAdReference();
          notifyClosedOnce();
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (failedAd, error) {
          developer.log('Rewarded ad failed to show: $error');
          failedAd.dispose();
          _clearAdReference();
          onAdFailedToShow?.call(error);
          notifyClosedOnce();
          loadAd();
        },
      );

      _rewardedAd = null;
      _isAdLoaded = false;

      ad.show(
        onUserEarnedReward: (adWithoutView, reward) {
          if (!hasEarnedReward) {
            hasEarnedReward = true;
            developer.log(
              'User earned reward: ${reward.amount} ${reward.type}',
            );
            onUserEarnedReward(reward);
          }
        },
      );
    } else {
      developer.log('Rewarded ad was not ready, skipping show.');
      loadAd();
      onAdClosed?.call();
    }
  }

  // --- Clear the old ad reference ---
  void _clearAdReference() {
    _rewardedAd = null;
    _isAdLoaded = false;
    _isLoading = false;
  }

  void dispose() {
    _isDisposed = true;
    _rewardedAd?.dispose();
    _clearAdReference();
  }
}

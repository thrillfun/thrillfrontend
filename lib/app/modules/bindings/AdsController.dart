import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

class AdsController extends GetxController {
  final String _nativeAdUnitId = 'ca-app-pub-3566466065033894/6507076010';
  NativeAd? nativeAd;
  var nativeAdIsLoaded = false.obs;
  final String _adUnitId = 'ca-app-pub-3566466065033894/4388337265';
  InterstitialAd? interstitialAd;
  var isInterstitialAdShowing = false.obs;
  @override
  void onInit() {
    loadNativeAd();
    loadIntersitialAd();
    super.onInit();
  }

  @override
  void dispose() {
    interstitialAd!.dispose();
    nativeAd!.dispose();
    super.dispose();
  }

  Future<void> loadIntersitialAd() async {
    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              isInterstitialAdShowing.value = false;
              interstitialAd!.dispose();
              ad.dispose();
            }, onAdShowedFullScreenContent: (ad) {
              isInterstitialAdShowing.value = true;
            }, onAdFailedToShowFullScreenContent: (ad, _) {
              isInterstitialAdShowing.value = false;
              interstitialAd!.dispose();
              ad.dispose();
            }, onAdWillDismissFullScreenContent: (ad) {
              isInterstitialAdShowing.value = false;
              interstitialAd!.dispose();
              ad.dispose();
            });
            // Keep a reference to the ad so you can show it later.
            interstitialAd = ad;
          },

          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            Logger().e('InterstitialAd failed to load: $error');
            isInterstitialAdShowing.value = false;
          },
        ));
  }

  loadNativeAd() async {
    nativeAd = NativeAd(
        adUnitId: _nativeAdUnitId,
        factoryId: 'adFactory',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            print('$NativeAd loaded.');
            nativeAdIsLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) async {
            // Dispose the ad here to free resources.
            Logger().wtf('$NativeAd failedToLoad: $error');
            loadNativeAd1();
            ad.dispose();
          },
        ),
        request: const AdRequest(),
        nativeAdOptions: NativeAdOptions(mediaAspectRatio: MediaAspectRatio.any)

        // Optional: Pass custom options to your native ad factory implementation.
        )
      ..load();
  }

  /// Loads a native ad.
  loadNativeAd1() async {
    nativeAd = NativeAd(
        adUnitId: 'ca-app-pub-3566466065033894/8741716488',
        factoryId: 'adFactory',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            print('$NativeAd loaded.');
            nativeAdIsLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) async {
            // Dispose the ad here to free resources.
            Logger().wtf('$NativeAd failedToLoad: $error');
            loadNativeAd2();

            ad.dispose();
          },
        ),
        request: const AdRequest(),
        nativeAdOptions: NativeAdOptions(mediaAspectRatio: MediaAspectRatio.any)

        // Optional: Pass custom options to your native ad factory implementation.
        )
      ..load();
  }

  loadNativeAd2() async {
    nativeAd = NativeAd(
        adUnitId: 'ca-app-pub-3566466065033894/9908416355',
        factoryId: 'adFactory',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            print('$NativeAd loaded.');
            nativeAdIsLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) async {
            // Dispose the ad here to free resources.
            Logger().wtf('$NativeAd failedToLoad: $error');
            loadNativeAd3();

            ad.dispose();
          },
        ),
        request: const AdRequest(),
        nativeAdOptions: NativeAdOptions(mediaAspectRatio: MediaAspectRatio.any)

        // Optional: Pass custom options to your native ad factory implementation.
        )
      ..load();
  }

  loadNativeAd3() async {
    nativeAd = NativeAd(
        adUnitId: 'ca-app-pub-3566466065033894/4492561853',
        factoryId: 'adFactory',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            print('$NativeAd loaded.');
            nativeAdIsLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) async {
            // Dispose the ad here to free resources.
            Logger().wtf('$NativeAd failedToLoad: $error');
            ad.dispose();
          },
        ),
        request: const AdRequest(),
        nativeAdOptions: NativeAdOptions(mediaAspectRatio: MediaAspectRatio.any)

        // Optional: Pass custom options to your native ad factory implementation.
        )
      ..load();
  }
}

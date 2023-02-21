import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_notifier.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mac_address/mac_address.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/rest/rest_url.dart';

InterstitialAd? interstitialAd;

class HomeController extends FullLifeCycleController with StateMixin<dynamic> {
  RxString? token = "".obs;
  RxInt? userId;
  final info = NetworkInfo();
  var dio  = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  @override
  void onDetached() {
    print('HomeController - onDetached called');
  }

  @override
  void onInit() {
    super.onInit();
    pushUserLoginCount(getIpAddress().toString(), getMacAddress().toString());
  }
  // Mandatory
  @override
  void onInactive() {
    print('HomeController - onInative called');
  }

  // Mandatory
  @override
  void onPaused() {
    print('HomeController - onPaused called');
  }

  // Mandatory
  @override
  void onResumed() {
    print('HomeController - onResumed called');
  }



  getMacAddress()async=>await GetMac.macAddress;
  getIpAddress() async => await info.getWifiIP();
  HomeController() {
    getAuthData();
  }
    
  pushUserLoginCount(String ip,String mac) async{
    dio.options.headers={"Authorization":"Bearer ${await GetStorage().read("token")}"};
    
    dio.post("/user_login_history",queryParameters: {
      "ip": ip,
      "mac": mac,
    } ).then((value) {}).onError((error, stackTrace) {});
  }
  getAuthData() async {}

  loadInterstitialAd() async {
    InterstitialAd.load(
      adUnitId: homeInterstitialAdUnit,
      request: const AdRequest(),
      adLoadCallback:
          InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
        interstitialAd = ad;
      }, onAdFailedToLoad: (LoadAdError error) {
        interstitialAd = null;
      }),
    );
  }

  Future<void> refreshAllData() async {}

  showAd() async {
    if (interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        interstitialAd = null;
        loadInterstitialAd();
      }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        interstitialAd = null;
        loadInterstitialAd();
      });
      interstitialAd!.show();
    }
  }
}

import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:logger/logger.dart';
import 'package:mac_address/mac_address.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:thrill/app/modules/discover/views/discover_view.dart';
import 'package:thrill/app/modules/home/home_videos_player/views/home_videos_player_view.dart';
import 'package:thrill/app/modules/settings/views/settings_view.dart';
import 'package:thrill/app/modules/wallet/views/wallet_view.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../rest/models/site_settings_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../utils/utils.dart';

class HomeController extends GetxController {
  var storage = GetStorage();
  var bottomNavIndex = 0.obs;
  var pageController = PageController();
  List<Widget> homeScreens = [];
  final info = NetworkInfo();
  BetterPlayerEventType? eventType;
  final count = 0.obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var playerController = BetterPlayerListVideoPlayerController();
  RxList<SiteSettings> siteSettingsList = RxList();
  var connectionType = 1.obs;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription _streamSubscription;
  NativeAd? nativeAd;
  var nativeAdIsLoaded = false.obs;
  InterstitialAd? _interstitialAd;

  var isDialogVisible = false.obs;

  // TODO: replace this test ad unit with your own ad unit.
  final String _adUnitId = 'ca-app-pub-3566466065033894/6507076010';

  @override
  void onInit() {
    super.onInit();
    loadAd();
    // siteSettingsList.listen((p0) {
    //   if (p0.isNotEmpty && isDialogVisible.isFalse) {
    //     showCustomAd();
    //     isDialogVisible = true.obs;
    //   }
    // });
    // ever(nativeAdIsLoaded, (callback) {
    //   if (nativeAdIsLoaded.isTrue && nativeAd != null) {
    //     Get.defaultDialog(content: Container(height: Get.height/2,width: Get.width,child: AdWidget(ad: nativeAd!),));
    //   }
    // });

    try {
      InAppUpdate.checkForUpdate().then((updateInfo) {
        if (updateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              //App Update successful
              InAppUpdate.completeFlexibleUpdate();
            }
          });
        }
      });
    } catch (e) {
      Logger().wtf(e);
    }
    homeScreens = [
      const HomeVideosPlayerView(),
      const DiscoverView(),
      const WalletView(),
      const SettingsView()
    ];
    getConnectivityType();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen(_updateState);
    pushUserLoginCount(getIpAddress().toString(), getMacAddress().toString());
  }

  getMacAddress() async => await GetMac.macAddress;

  getIpAddress() async => await info.getWifiIP();

  void loadAd() {
    try {
      nativeAd = NativeAd(
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.medium),
        adUnitId: _adUnitId,
        // Factory ID registered by your native ad factory implementation.
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            print('$NativeAd loaded.');
            nativeAdIsLoaded.value = true;
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            Logger().wtf('$NativeAd failedToLoad: $error');
            ad.dispose();
          },
        ),
        request: const AdRequest(),
        // Optional: Pass custom options to your native ad factory implementation.
      );
      nativeAd!.load();
    } on Exception catch (e) {
      nativeAd!.dispose();
      nativeAd = null;
    }
  }

  showAd() async {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
        loadAd();
      }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
        loadAd();
      });
    }
  }

  @override
  void onReady() {
    getSiteSettings();
    super.onReady();
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
  }

  Future<void> getConnectivityType() async {
    late ConnectivityResult connectivityResult;
    try {
      connectivityResult = await (_connectivity.checkConnectivity());
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return _updateState(connectivityResult);
  }

  _updateState(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        connectionType.value = 1;
        break;
      case ConnectivityResult.mobile:
        connectionType.value = 2;
        break;

      case ConnectivityResult.none:
        connectionType.value = 0;
        break;
      case ConnectivityResult.other:
        connectionType.value = 1;
        break;
      default:
        break;
    }
  }

  pushUserLoginCount(String ip, String mac) async {
    if (GetStorage().read("token") != null) {
      dio.options.headers = {
        "Authorization": "Bearer ${await GetStorage().read("token")}"
      };
      dio.post("/user_login_history", queryParameters: {
        "ip": ip,
        "mac": mac,
      }).then((value) {
        print(value.data);
      }).onError((error, stackTrace) {
        print(error.toString());
      });
    }
  }

  Future<void> getSiteSettings() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    await dio.post("SiteSettings").then((value) {
      siteSettingsList.value = SiteSettingsModel.fromJson(value.data).data!;
    }).onError((error, stackTrace) {});
  }

  showCustomAd() {
    siteSettingsList.forEach((element) {
      if (element.name == "advertisement_image") {
        // showGeneralDialog(
        //   context: Get.context!,
        //   barrierColor: Colors.black12.withOpacity(0.6),
        //   // Background color
        //   barrierDismissible: false,
        //   barrierLabel: 'Dialog',
        //   transitionDuration: Duration(milliseconds: 400),
        //   pageBuilder: (_, __, ___) {
        //     return Scaffold(
        //       backgroundColor: Colors.transparent.withOpacity(0.0),
        //       body: Container(
        //         alignment: Alignment.center,
        //         child: SizedBox(
        //           height: Get.height / 1.2,
        //           width: Get.width / 1.2,
        //           child: InkWell(
        //             onTap: () {
        //               Get.back();
        //               Get.toNamed(Routes.SPIN_WHEEL);
        //             },
        //             child: Stack(
        //               children: [
        //                 CachedNetworkImage(
        //                     fit: BoxFit.fill,
        //                     height: Get.height,
        //                     width: Get.width,
        //                     imageUrl: RestUrl.profileUrl + element.value),
        //                 Align(
        //                   alignment: Alignment.topRight,
        //                   child: IconButton(
        //                       onPressed: () => Get.back(),
        //                       icon: Icon(Icons.close)),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        // );
        Get.defaultDialog(
            title: "",
            middleText: "",
            backgroundColor: Colors.transparent.withOpacity(0.0),
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            content: InkWell(
              onTap: () => Get.toNamed(Routes.SPIN_WHEEL),
              child: Stack(
                children: [
                  CachedNetworkImage(
                      fit: BoxFit.fill,
                      height: Get.height / 1.5,
                      width: Get.width,
                      imageUrl: RestUrl.profileUrl + element.value),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () => Get.back(closeOverlays: true),
                        icon: Icon(Icons.close)),
                  )
                ],
              ),
            ));
      }
    });
  }
}

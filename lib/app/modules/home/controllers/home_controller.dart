import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/app/modules/discover/views/discover_view.dart';
import 'package:thrill/app/modules/home/home_videos_player/views/home_videos_player_view.dart';
import 'package:thrill/app/modules/login/views/login_view.dart';
import 'package:thrill/app/modules/profile/views/profile_view.dart';
import 'package:thrill/app/modules/related_videos/controllers/related_videos_controller.dart';
import 'package:thrill/app/modules/settings/views/settings_view.dart';
import 'package:thrill/app/modules/wallet/views/wallet_view.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:mac_address/mac_address.dart';

import '../../../rest/models/site_settings_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../utils/utils.dart';
import '../../camera/views/camera_view.dart';
import '../../related_videos/views/related_videos_view.dart';

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

  @override
  void onInit() {
    super.onInit();
    InAppUpdate.checkForUpdate().then((updateInfo) {

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Perform immediate update
          InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              //App Update successful
            }
          });
        } else if (updateInfo.flexibleUpdateAllowed) {
          //Perform flexible update
          InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
            if (appUpdateResult == AppUpdateResult.success) {
              //App Update successful
              InAppUpdate.completeFlexibleUpdate();
            }
          });
        }
      }
    });
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

  @override
  void onReady() {
    // getSiteSettings();
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
      showCustomAd();
    }).onError((error, stackTrace) {});
  }

  showCustomAd() {
    siteSettingsList.forEach((element) {
      if (element.name == "advertisement_image") {
        Get.defaultDialog(
            title: "",
            middleText: "",
            content: CachedNetworkImage(
                imageUrl: RestUrl.profileUrl + element.value));
      }
    });
  }
}

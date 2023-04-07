import 'package:better_player/better_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

import '../../../rest/rest_urls.dart';
import '../../../utils/utils.dart';
import '../../camera/views/camera_view.dart';
import '../../related_videos/views/related_videos_view.dart';

class HomeController extends GetxController {
  var storage = GetStorage();
  var bottomNavIndex = 0.obs;
  var pageController = PageController();
  var homeScreens = [];
  final info = NetworkInfo();
  BetterPlayerEventType? eventType;
  final count = 0.obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var playerController = BetterPlayerListVideoPlayerController();

  @override
  void onInit() {
    super.onInit();
    pushUserLoginCount(getIpAddress().toString(), getMacAddress().toString());

    homeScreens = [
      GetX<RelatedVideosController>(
          builder: (controller) => controller.isLoading.isTrue
              ? loader()
              :  HomeVideosPlayerView()),
      const DiscoverView(),
      const WalletView(),
      const SettingsView()
    ];
  }

  getMacAddress() async => await GetMac.macAddress;

  getIpAddress() async => await info.getWifiIP();

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
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
}

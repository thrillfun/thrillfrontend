import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/modules/discover/views/discover_view.dart';
import 'package:thrill/app/modules/login/views/login_view.dart';
import 'package:thrill/app/modules/profile/views/profile_view.dart';
import 'package:thrill/app/modules/related_videos/controllers/related_videos_controller.dart';
import 'package:thrill/app/modules/wallet/views/wallet_view.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../utils/utils.dart';
import '../../related_videos/views/related_videos_view.dart';

class HomeController extends GetxController {
  var storage = GetStorage();
  var bottomNavIndex = 0.obs;
  var pageController = PageController();
  var homeScreens = [];

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();

    homeScreens = [
      GetX<RelatedVideosController>(
          builder: (controller) =>controller.isLoading.isTrue?loader(): PageView.builder(
              itemCount: controller.relatedVideosList.length,
              scrollDirection: Axis.vertical,
              controller: pageController,
              itemBuilder: (context, index) =>

                  RelatedVideosView(
                    videoUrl:
                        controller.relatedVideosList[index].video.toString(),
                    pageController: pageController!,
                    nextPage: index + 1,
                    videoId: controller.relatedVideosList[index].id!,
                  ))),
      const DiscoverView(),
      const WalletView(),
      const ProfileView()
    ];
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

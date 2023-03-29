import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/app/modules/discover/views/discover_view.dart';
import 'package:thrill/app/modules/login/views/login_view.dart';
import 'package:thrill/app/modules/profile/views/profile_view.dart';
import 'package:thrill/app/modules/related_videos/controllers/related_videos_controller.dart';
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

  final count = 0.obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  @override
  void onInit() {
    super.onInit();
    pushUserLoginCount(getIpAddress().toString(), getMacAddress().toString());

    homeScreens = [
      GetX<RelatedVideosController>(
          builder: (controller) => controller.isLoading.isTrue
              ? loader()
              : Stack(
                  children: [
                    PageView.builder(
                        itemCount: controller.relatedVideosList.length,
                        scrollDirection: Axis.vertical,
                        controller: pageController,
                        itemBuilder: (context, index) => RelatedVideosView(
                              videoUrl: controller
                                  .relatedVideosList[index].video
                                  .toString(),
                              pageController: pageController!,
                              nextPage: index + 1,
                              videoId: controller.relatedVideosList[index].id!,
                              gifImage:
                                  controller.relatedVideosList[index].gifImage,
                              publicUser:
                                  controller.relatedVideosList[index].user,
                              soundName:
                                  controller.relatedVideosList[index].soundName,
                              UserId:
                                  controller.relatedVideosList[index].user!.id,
                              userName: controller
                                  .relatedVideosList[index].user!.username!.obs,
                              description: controller
                                  .relatedVideosList[index].description!.obs,
                              hashtagsList:
                                  controller.relatedVideosList[index].hashtags??[],
                              soundOwner: controller
                                  .relatedVideosList[index].soundOwner,
                              sound: controller.relatedVideosList[index].sound,
                              videoLikeStatus: controller
                                  .relatedVideosList[index].videoLikeStatus
                                  .toString(),
                              isCommentAllowed: controller
                                          .relatedVideosList[index]
                                          .isCommentable ==
                                      "Yes"
                                  ? true.obs
                                  : false.obs,
                              like: controller
                                  .relatedVideosList[index].likes!.obs,
                              isfollow: controller
                                  .relatedVideosList[index].user!.isfollow!,
                              commentsCount: controller
                                  .relatedVideosList[index].comments!.obs,
                              soundId:
                                  controller.relatedVideosList[index].soundId,
                          avatar: controller
                              .relatedVideosList[index].user!.avatar,
                          currentPageIndex: index.obs,
                            )),
                    Align(
                      child: IconButton(
                          onPressed: () async {
                            if (await Permission.camera.isGranted &&
                                await Permission.storage.isGranted &&
                                await Permission.microphone.isGranted) {
                              Get.toNamed(Routes.CAMERA, arguments: {
                                "selected_sound": "",
                                "sound_path": ""
                              });
                            } else {
                              await Permission.camera.request().then(
                                  (value) async => await Permission.storage
                                          .request()
                                          .then((value) async {
                                        await Permission.microphone
                                            .request()
                                            .then((value) {
                                          Get.toNamed(Routes.CAMERA,
                                              arguments: {
                                                "selected_sound": "",
                                                "sound_path": ""
                                              });
                                        });
                                      }));
                            }
                          },
                          icon: Icon(Icons.camera)),
                      alignment: Alignment.topRight,
                    ),
                  ],
                )),
      const DiscoverView(),
      const WalletView(),
      const ProfileView()
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

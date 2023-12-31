import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_data/sim_data.dart';
import 'package:thrill/app/modules/following_videos/controllers/following_videos_controller.dart';
import 'package:thrill/app/modules/related_videos/controllers/related_videos_controller.dart';
import 'package:thrill/app/modules/trending_videos/controllers/trending_videos_controller.dart';
import 'package:thrill/app/utils/color_manager.dart';
import 'package:thrill/app/utils/utils.dart';

import '../../../../routes/app_pages.dart';
import '../../../login/views/login_view.dart';
import '../controllers/home_videos_player_controller.dart';

class HomeVideosPlayerView extends StatefulWidget {
  const HomeVideosPlayerView({Key? key}) : super(key: key);

  @override
  State<HomeVideosPlayerView> createState() => _HomeVideosPlayerViewState();
}

class _HomeVideosPlayerViewState extends State<HomeVideosPlayerView>
    with AutomaticKeepAliveClientMixin<HomeVideosPlayerView> {
  var relatedVideosController = Get.find<RelatedVideosController>();
  var followingVideosController = Get.find<FollowingVideosController>();
  var trendingVideosController = Get.find<TrendingVideosController>();
  var controller = Get.find<HomeVideosPlayerController>();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Obx(() => controller.videoScreens[controller.selectedIndex.value]),
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 50.0,
                spreadRadius: 50, //
              )
            ]),
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        controller.listOfScreens.length,
                        (index) => Obx(() => InkWell(
                            onTap: () {
                              if (index == 0) {
                                relatedVideosController.refereshVideos();
                                controller.selectedIndex.value = index;
                              }
                              if (index == 1) {
                                checkForLogin(() {
                                  followingVideosController.refereshVideos();
                                  controller.selectedIndex.value = index;
                                });
                              }
                              if (index == 2) {
                                trendingVideosController.refereshVideos();
                                controller.selectedIndex.value = index;
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  controller.listOfScreens[index],
                                  style: TextStyle(
                                      color: index ==
                                              controller.selectedIndex.value
                                          ? Colors.white
                                          : ColorManager.colorAccent,
                                      fontSize: index ==
                                              controller.selectedIndex.value
                                          ? 16
                                          : 16,
                                      fontWeight: index ==
                                              controller.selectedIndex.value
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Visibility(
                                    visible:
                                        index == controller.selectedIndex.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: ColorManager.colorAccent),
                                      height: 2,
                                      width: 50,
                                    ))
                              ],
                            ))),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: InkWell(
                    onTap: () async {
                      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                      AndroidDeviceInfo androidInfo =
                          await deviceInfo.androidInfo;
                      checkForLogin(() async {
                        try {
                          if (androidInfo.version.sdkInt > 31) {
                            if (await Permission.audio.isGranted) {
                              Get.toNamed(Routes.CAMERA, arguments: {
                                "sound_url": "".obs,
                                "sound_owner": GetStorage()
                                        .read("name")
                                        .toString()
                                        .isEmpty
                                    ? GetStorage()
                                        .read("username")
                                        .toString()
                                        .obs
                                    : GetStorage().read("name").toString().obs
                              });
                              // refreshAlreadyCapturedImages();
                            } else if (await Permission.audio.isDenied ||
                                await Permission.audio.isPermanentlyDenied ||
                                await Permission.audio.isLimited) {
                              await Permission.audio
                                  .request()
                                  .then((value) async => value.isGranted
                                      ? Get.toNamed(Routes.CAMERA, arguments: {
                                          "sound_url": "".obs,
                                          "sound_owner": GetStorage()
                                                  .read("name")
                                                  .toString()
                                                  .isEmpty
                                              ? GetStorage()
                                                  .read("username")
                                                  .toString()
                                                  .obs
                                              : GetStorage()
                                                  .read("name")
                                                  .toString()
                                                  .obs
                                        })
                                      : await openAppSettings().then((value) {
                                          if (value) {
                                            Get.toNamed(Routes.CAMERA,
                                                arguments: {
                                                  "sound_url": "".obs,
                                                  "sound_owner": GetStorage()
                                                          .read("name")
                                                          .toString()
                                                          .isEmpty
                                                      ? GetStorage()
                                                          .read("username")
                                                          .toString()
                                                          .obs
                                                      : GetStorage()
                                                          .read("name")
                                                          .toString()
                                                          .obs
                                                });
                                          } else {
                                            errorToast(
                                                'Audio Permission not granted!');
                                          }
                                        }));
                            }
                          } else {
                            if (await Permission.storage.isGranted) {
                              Get.toNamed(Routes.CAMERA, arguments: {
                                "sound_url": "".obs,
                                "sound_owner": GetStorage()
                                        .read("name")
                                        .toString()
                                        .isEmpty
                                    ? GetStorage()
                                        .read("username")
                                        .toString()
                                        .obs
                                    : GetStorage().read("name").toString().obs
                              });
                              // refreshAlreadyCapturedImages();
                            } else if (await Permission.storage.isDenied ||
                                await Permission.storage.isPermanentlyDenied ||
                                await Permission.storage.isLimited) {
                              await Permission.storage
                                  .request()
                                  .then((value) async => value.isGranted
                                      ? Get.toNamed(Routes.CAMERA, arguments: {
                                          "sound_url": "".obs,
                                          "sound_owner": GetStorage()
                                                  .read("name")
                                                  .toString()
                                                  .isEmpty
                                              ? GetStorage()
                                                  .read("username")
                                                  .toString()
                                                  .obs
                                              : GetStorage()
                                                  .read("name")
                                                  .toString()
                                                  .obs
                                        })
                                      : await openAppSettings().then((value) {
                                          if (value) {
                                            Get.toNamed(Routes.CAMERA,
                                                arguments: {
                                                  "sound_url": "".obs,
                                                  "sound_owner": GetStorage()
                                                          .read("name")
                                                          .toString()
                                                          .isEmpty
                                                      ? GetStorage()
                                                          .read("username")
                                                          .toString()
                                                          .obs
                                                      : GetStorage()
                                                          .read("name")
                                                          .toString()
                                                          .obs
                                                });
                                          } else {
                                            errorToast(
                                                'Audio Permission not granted!');
                                          }
                                        }));
                            }
                          }
                        } catch (e) {
                          Logger().e(e);
                        }
                      });
                    },
                    child: Icon(
                      IconlyBroken.camera,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

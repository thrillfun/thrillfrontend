import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/videos/Following_videos_controller.dart';
import 'package:thrill/controller/videos/related_videos_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/screens/video/camera_screen.dart';
import 'package:thrill/utils/util.dart';

import '../../controller/home/home_controller.dart';

User user = GetStorage().read("user");

class HomeGetx extends GetView<HomeController> {
  HomeGetx({Key? key}) : super(key: key);

  var videosController = Get.find<VideosController>();
  @override
  Widget build(BuildContext context) {
    controller.loadInterstitialAd();
    TabController? tabController =
        TabController(length: 2, vsync: Scaffold.of(context), initialIndex: 0);
    return Scaffold(
        backgroundColor: ColorManager.dayNight,
        body: Stack(
          fit: StackFit.expand,
          children: [
            TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                  const RelatedVideos(),
                  GetStorage().read("token") == null
                      ? const Center(
                          child: Text(
                            "Login to access followers",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : const FollowingVideos(),
                ]),
            Container(
                alignment: Alignment.topCenter,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Center(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: SegmentedTabControl(
                                    height: 35,
                                    splashColor: ColorManager.colorAccent,
                                    splashHighlightColor:
                                        ColorManager.colorPrimaryLight,
                                    radius: const Radius.circular(10),
                                    backgroundColor: const Color(0xff1F2128),
                                    indicatorColor: ColorManager.colorAccent,
                                    tabTextColor: Colors.white,
                                    selectedTabTextColor: Colors.white,
                                    controller: tabController,
                                    tabs: const [
                                      SegmentTab(label: 'Related'),
                                      SegmentTab(label: 'Following'),
                                    ]),
                              ),
                            )),
                        Expanded(
                            flex: 0,
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                  onTap: () {
                                    // ImagePicker()
                                    //     .pickVideo(source: ImageSource.gallery)
                                    //     .then((value) {
                                    //   if (value != null) {
                                    //     int currentUnix = DateTime.now()
                                    //         .millisecondsSinceEpoch;

                                    //     // videosController
                                    //     //     .awsUploadVideo(
                                    //     //         File(value.path), currentUnix)
                                    //     //     .then((_) =>
                                    //     //         videosController.postVideo(
                                    //     //             userDetailsController
                                    //     //                 .storage
                                    //     //                 .read("userId"),
                                    //     //             basename(value.path),
                                    //     //             "",
                                    //     //             "original",
                                    //     //             "",
                                    //     //             "testing",
                                    //     //             'yes',
                                    //     //             1,
                                    //     //             "testing",
                                    //     //             "",
                                    //     //             "english",
                                    //     //             "",
                                    //     //             "1",
                                    //     //             true,
                                    //     //             true,
                                    //     //             "",
                                    //     //             true,
                                    //     //             userDetailsController
                                    //     //                 .storage
                                    //     //                 .read("userId")));
                                    //     videosController.openEditor(
                                    //         true,
                                    //         value.path,
                                    //         "",
                                    //         userDetailsController.storage
                                    //             .read("userId"),
                                    //         "");
                                    //   }
                                    // });
                                    Get.to(CameraScreen(
                                      selectedSound: "",
                                      owner: userDetailsController
                                              .userProfile.value.name ??
                                          "",
                                      id: userDetailsController.storage
                                          .read("userId"),
                                    ));
                                  },
                                  child: const Icon(
                                    IconlyLight.camera,
                                    color: Colors.white,
                                  )),
                            ))
                      ],
                    ),
                  ],
                ))
          ],
        ));
  }

  relatedLayout() => const RelatedVideos();

  followingVideosLayout() => const FollowingVideos();
}

class RelatedVideos extends GetView<RelatedVideosController> {
  const RelatedVideos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<RelatedVideosController>(
        builder: (controller) => controller.isLoading.isTrue
            ? loader()
            : videoItemLayout(controller.publicVideosList));
  }
}

class FollowingVideos extends GetView<RelatedVideosController> {
  const FollowingVideos({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetX<RelatedVideosController>(
        builder: (controller) => controller.isLoading.isTrue
            ? loader()
            : videoItemLayout(controller.followingVideosList));
  }
}

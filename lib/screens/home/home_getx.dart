import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconly/iconly.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/comments_controller.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos/Following_videos_controller.dart';
import 'package:thrill/controller/videos/related_videos_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/screens/video/camera_screen.dart';
import 'package:thrill/utils/util.dart';

User user = GetStorage().read("user");

class HomeGetx extends GetView<VideosController> {
  HomeGetx({Key? key}) : super(key: key);

  InterstitialAd? interstitialAd;

  @override
  Widget build(BuildContext context) {
    loadInterstitialAd();
    TabController? tabController =
        TabController(length: 2, vsync: Scaffold.of(context), initialIndex: 0);
    return Scaffold(
        backgroundColor: ColorManager.dayNight,
        body: Stack(
          fit: StackFit.expand,
          children: [
            TabBarView(
                physics: NeverScrollableScrollPhysics(),
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
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: SegmentedTabControl(
                                    height: 35,
                                    splashColor: ColorManager.colorAccent,
                                    splashHighlightColor:
                                        ColorManager.colorPrimaryLight,
                                    radius: Radius.circular(10),
                                    backgroundColor: Color(0xff1F2128),
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
                                    Get.to(CameraScreen(
                                      selectedSound: "",
                                      id: usersController.storage
                                          .read("userId"),
                                      owner: "",
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

class RelatedVideos extends GetView<RelatedVideosController> {
  const RelatedVideos({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return controller.obx((relatedVideos) => controller.obx(
        (state) => videoItemLayout(relatedVideos!),
        onLoading: loader(),
        onEmpty: emptyListWidget()));
  }
}

class FollowingVideos extends GetView<FollowingVideosController> {
  const FollowingVideos({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return controller.obx(
        (followingVideos) => videoItemLayout(followingVideos!),
        onLoading: loader(),
        onEmpty: emptyListWidget());
  }
}

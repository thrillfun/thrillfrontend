import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconly/iconly.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/comments_controller.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/screens/video/camera_screen.dart';
import 'package:thrill/utils/util.dart';

class HomeGetx extends StatefulWidget {
  const HomeGetx({Key? key}) : super(key: key);

  @override
  State<HomeGetx> createState() => _HomeGetxState();
}

class _HomeGetxState extends State<HomeGetx>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeGetx> {
  InterstitialAd? interstitialAd;

  var commentsController = Get.find<CommentsController>();
  var videosController = Get.find<VideosController>();
  var usersController = Get.find<UserController>();

  var current = 0.obs;
  var related = 0.obs;
  var popular = 0.obs;
  var isOnPageTurning = false.obs;
  var isRelatedTurning = false.obs;
  var isPopularTurning = false.obs;

  PreloadPageController? preloadPageController;
  PreloadPageController? preloadPageController1;
  PreloadPageController? preloadPageController2;

  TabController? tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInterstitialAd();

    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    preloadPageController = PreloadPageController();
    preloadPageController!.addListener(scrollListener);

    preloadPageController1 = PreloadPageController();
    preloadPageController1!.addListener(scrollListener1);

    preloadPageController2 = PreloadPageController();
    preloadPageController2!.addListener(scrollListener2);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: ColorManager.dayNight,
        body: Stack(
          fit: StackFit.expand,
          children: [
            TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                  RefreshIndicator(
                      child: relatedLayout(),
                      onRefresh: () async =>
                          await videosController.getAllVideos()),
                  GetStorage().read("token") == null
                      ? const Center(
                          child: Text(
                            "Login to access followers",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : RefreshIndicator(
                          child: followingVideosLayout(),
                          onRefresh: () =>
                              videosController.getFollowingVideos()),
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
                                      owner:"",
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

  relatedLayout() {
    return GetX<VideosController>(
        builder: (videosController) => videosController.publicVideosList.isEmpty
            ? Container(
                height: Get.height,
                child: Center(
                  child: Text(
                    "No Videos!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ),
              )
            : videosController.videosLoading.value
                ? Container(
                    color: ColorManager.dayNight,
                    child: Center(
                      child: loader(),
                    ),
                    height: Get.height,
                  )
                : videoItemLayout(videosController.publicVideosList));

    // videosController.obx(
    //   (state) =>,
    //   onLoading: Container(
    //     child: loader(),
    //     height: Get.height,
    //     width: Get.width,
    //   ),
    //   onEmpty: Container(
    //     child: Center(
    //       child: Text(
    //         "No Videos Found",
    //         style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
    //       ),
    //     ),
    //   ));
  }

  followingVideosLayout() {
    return Obx(() => videosController.isFollowingLoading.isTrue
        ? Container(
            height: Get.height,
            child: Center(
              child: loader(),
            ),
          )
        : videosController.followingVideosList.isNotEmpty
            ? videoItemLayout(videosController.followingVideosList)
            : Container(
                height: Get.height,
                child: Center(
                  child: Text(
                    "No Videos!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ),
              ));
  }

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

  Future<bool> isLogined() async {
    var instance = await SharedPreferences.getInstance();
    var loginData = instance.getString('currentUser');
    if (loginData != null) {
      return true;
    } else {
      return false;
    }
  }

  void scrollListener() {
    if (isOnPageTurning.value &&
        preloadPageController!.page ==
            preloadPageController!.page!.roundToDouble()) {
      setState(() {
        current.value = preloadPageController!.page!.toInt();
        isOnPageTurning.value = false;
      });
    } else if (!isOnPageTurning.value &&
        current.toDouble() != preloadPageController!.page) {
      if ((current.toDouble() - preloadPageController!.page!.toDouble()).abs() >
          0.1) {
        setState(() {
          isOnPageTurning.value = true;
        });
      }
    }
  }

  void scrollListener1() {
    if (isRelatedTurning.value &&
        preloadPageController1!.page ==
            preloadPageController1!.page!.roundToDouble()) {
      setState(() {
        related.value = preloadPageController1!.page!.toInt();
        isRelatedTurning.value = false;
      });
    } else if (!isRelatedTurning.value &&
        related.toDouble() != preloadPageController1!.page) {
      if ((related.toDouble() - preloadPageController1!.page!.toDouble())
              .abs() >
          0.1) {
        setState(() {
          isRelatedTurning.value = true;
        });
      }
    }
  }

  void scrollListener2() {
    if (isPopularTurning.value &&
        preloadPageController2!.page ==
            preloadPageController2!.page!.roundToDouble()) {
      setState(() {
        popular.value = preloadPageController2!.page!.toInt();
        isPopularTurning.value = false;
      });
    } else if (!isPopularTurning.value &&
        popular.toDouble() != preloadPageController2!.page) {
      if ((popular.toDouble() - preloadPageController2!.page!.toDouble())
              .abs() >
          0.1) {
        setState(() {
          isPopularTurning.value = true;
        });
      }
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

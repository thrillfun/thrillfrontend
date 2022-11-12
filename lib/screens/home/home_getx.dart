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
import 'package:thrill/widgets/better_video_player.dart';

class HomeGetx extends StatefulWidget {
  const HomeGetx({Key? key}) : super(key: key);

  @override
  State<HomeGetx> createState() => _HomeGetxState();
}

class _HomeGetxState extends State<HomeGetx> with TickerProviderStateMixin {
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
    return GetX<VideosController>(
        builder: (videosController) => Scaffold(
                body: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  "assets/background_profile.png",
                  fit: BoxFit.fill,
                ),
                TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: tabController,
                    children: [
                      videosController.isLoading.value
                          ?  Center(
                              child: loader(),
                            )
                          : videosController.publicVideosList.isEmpty
                              ? RefreshIndicator(
                                  child: const Center(
                                    child: Text(
                                      "no videos found",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  onRefresh: () =>
                                      videosController.getAllVideos())
                              : RefreshIndicator(
                                  child: relatedLayout(),
                                  onRefresh: () async =>
                                      await videosController.getAllVideos()),
                      GetStorage().read("token").toString().isEmpty ||
                              GetStorage().read("token") == null
                          ? const Center(
                              child: Text(
                                "Login to access followers",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            )
                          : videosController.followingVideosList.isEmpty
                              ? RefreshIndicator(
                                  child: const Center(
                                    child: Text(
                                      "You dont have any followings yet",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  onRefresh: () =>
                                      videosController.getFollowingVideos())
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
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: SegmentedTabControl(
                                        height: 35,
                                        splashColor: ColorManager.colorAccent,
                                        splashHighlightColor: Colors.red,
                                        radius: Radius.circular(10),
                                        backgroundColor: Color(0xff1F2128),
                                        indicatorColor:
                                            ColorManager.colorAccent,
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
                                          id: User.fromJson(GetStorage().read("user")).id,
                                          owner: User.fromJson(GetStorage().read("user")).username,
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
            )));
  }

  relatedLayout() {
    return PreloadPageView.builder(
        controller: preloadPageController1,
        onPageChanged: (int index) {
          if (videosController.adIndexes.contains(index)) {
            showAd();
          }
        },
        scrollDirection: Axis.vertical,
        preloadPagesCount: 6,
        itemCount: videosController.publicVideosList.length,
        //Notice this
        itemBuilder: (context, index) => BetterReelsPlayer(
                videosController.publicVideosList[index].gifImage!,
                videosController.publicVideosList[index].video!,
                index,
                related.value,
                isRelatedTurning.value, () {
              videosController.publicVideosList[index].videoLikeStatus == 0
                  ? videosController.likeVideo(
                      1, videosController.publicVideosList[index].id!)
                  : videosController.likeVideo(
                      0, videosController.publicVideosList[index].id!);
            },
                videosController.publicVideosList[index].user,
                videosController.publicVideosList[index].id!,
                videosController.publicVideosList[index].soundName.toString(),
                videosController.publicVideosList[index].isDuetable == "yes"
                    ? true
                    : false,
                videosController.publicVideosList[index],
                videosController.publicVideosList[index].user!.id!,
                videosController.publicVideosList[index].user!.name.toString(),
                videosController.publicVideosList[index].description.toString(),
                true,
                videosController.publicVideosList[index].hashtags!,
                videosController.publicVideosList[index].sound.toString(),
                videosController.publicVideosList[index].soundOwner.toString(),
                videosController.publicVideosList[index].videoLikeStatus,
                videosController.publicVideosList[index].isCommentable
                            .toString()
                            .toLowerCase() ==
                        "yes"
                    ? true
                    : false));
  }

  followingVideosLayout() {
    return PreloadPageView.builder(
        preloadPagesCount: 6,
        physics: AlwaysScrollableScrollPhysics(),
        controller: preloadPageController,
        onPageChanged: (int index) {
          if (videosController.adIndexes.contains(index)) {
            showAd();
          }
        },
        scrollDirection: Axis.vertical,
        itemCount: videosController.followingVideosList.length,
        itemBuilder: (context, index) => BetterReelsPlayer(
            videosController.followingVideosList[index].gifImage!,
            videosController.followingVideosList[index].video!,
            index,
            current.value,
            isOnPageTurning.value,
            () {},
            videosController.followingVideosList[index].user,
            videosController.followingVideosList[index].id!,
            videosController.followingVideosList[index].soundName.toString(),
            videosController.followingVideosList[index].isDuetable == "yes"
                ? true
                : false,
            videosController.followingVideosList[index],
            videosController.followingVideosList[index].user!.id!,
            videosController.followingVideosList[index].user!.name.toString(),
            videosController.followingVideosList[index].description.toString(),
            true,
            videosController.followingVideosList[index].hashtags!,
            videosController.followingVideosList[index].sound.toString(),
            videosController.followingVideosList[index].soundOwner.toString(),
            videosController.followingVideosList[index].videoLikeStatus,
            videosController.followingVideosList[index].isCommentable
                        .toString()
                        .toLowerCase() ==
                    "yes"
                ? true
                : false,like:videosController.publicVideosList[index].likes));
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
}

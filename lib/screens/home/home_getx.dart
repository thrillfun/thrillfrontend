import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:iconly/iconly.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/blocs/login/login_bloc.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/comments_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/video/record.dart';
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

  int current = 0;
  int related = 0;
  int popular = 0;
  bool isOnPageTurning = false;
  bool isRelatedTurning = false;
  bool isPopularTurning = false;

  PreloadPageController? preloadPageController;
  PreloadPageController? preloadPageController1;
  PreloadPageController? preloadPageController2;

  TabController? tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadInterstitialAd();
    tabController = TabController(length: 3, vsync: this);
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
    return Obx(() => Scaffold(
            body: Stack(
          children: [
            TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                  PreloadPageView.builder(
                      preloadPagesCount: 6,
                      controller: preloadPageController,
                      onPageChanged: (int index) {
                        if (videosController.adIndexes.contains(index)) {
                          showAd();
                        }
                      },
                      scrollDirection: Axis.vertical,
                      itemCount: videosController.followingVideosList.length,
                      itemBuilder: (context, index) => GetX<VideosController>(
                          builder: (vidoesController) => BetterReelsPlayer(
                              videosController
                                  .followingVideosList[index].gifImage!,
                              videosController
                                  .followingVideosList[index].video!,
                              index,
                              current,
                              isOnPageTurning,
                              () {},
                              videosController.followingVideosList[index].user,
                              videosController.followingVideosList[index].id!,
                              videosController
                                  .followingVideosList[index].soundName
                                  .toString(),
                              videosController.followingVideosList[index]
                                          .isDuetable ==
                                      "yes"
                                  ? true
                                  : false,
                              vidoesController.followingVideosList[index],
                              videosController
                                  .followingVideosList[index].user!.id!,
                              videosController
                                  .followingVideosList[index].user!.name
                                  .toString(),
                              videosController
                                  .followingVideosList[index].description
                                  .toString(),
                              true,
                              videosController
                                  .publicVideosList[index].hashtags!))),
                  PreloadPageView.builder(
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
                      itemBuilder: (context, index) => GetX<VideosController>(
                          builder: (vidoesController) => BetterReelsPlayer(
                              videosController
                                  .publicVideosList[index].gifImage!,
                              videosController.publicVideosList[index].video!,
                              index,
                              related,
                              isRelatedTurning,
                              () {},
                              videosController.publicVideosList[index].user,
                              videosController.publicVideosList[index].id!,
                              videosController.publicVideosList[index].soundName
                                  .toString(),
                              videosController
                                          .publicVideosList[index].isDuetable ==
                                      "yes"
                                  ? true
                                  : false,
                              videosController.publicVideosList[index],
                              videosController
                                  .publicVideosList[index].user!.id!,
                              videosController
                                  .publicVideosList[index].user!.name
                                  .toString(),
                              videosController
                                  .publicVideosList[index].description
                                  .toString(),
                              true,
                              videosController
                                  .publicVideosList[index].hashtags!))),
                  PreloadPageView.builder(
                      controller: preloadPageController2,
                      onPageChanged: (int index) {
                        if (videosController.adIndexes.contains(index)) {
                          showAd();
                        }
                      },
                      scrollDirection: Axis.vertical,
                      preloadPagesCount: 6,
                      itemCount: videosController.publicVideosList.length,
                      //Notice this
                      itemBuilder: (context, index) => GetX<VideosController>(
                          builder: (vidoesController) => BetterReelsPlayer(
                              videosController
                                  .publicVideosList[index].gifImage!,
                              videosController.publicVideosList[index].video!,
                              index,
                              popular,
                              isPopularTurning,
                              () {},
                              videosController.publicVideosList[index].user,
                              videosController.publicVideosList[index].id!,
                              videosController.publicVideosList[index].soundName
                                  .toString(),
                              videosController
                                          .publicVideosList[index].isDuetable ==
                                      "Yes"
                                  ? true
                                  : false,
                              vidoesController.publicVideosList[index],
                              videosController
                                  .publicVideosList[index].user!.id!,
                              videosController
                                  .publicVideosList[index].user!.name
                                  .toString(),
                              videosController
                                  .publicVideosList[index].description
                                  .toString(),
                              true,
                              videosController
                                  .publicVideosList[index].hashtags!)))
                ]),
            Container(
                alignment: Alignment.topCenter,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TabBar(
                            physics: const NeverScrollableScrollPhysics(),
                            indicatorColor: Colors.transparent,
                            controller: tabController,
                            isScrollable: true,
                            tabs: const [
                              Tab(child: Text('Following')),
                              Tab(child: Text('Related')),
                              Tab(child: Text('Popular')),
                            ]),
                        InkWell(
                            onTap: () {
                              Get.to(const Record(soundMap: {
                                "soundName": "",
                                "soundPath": "",
                              }));
                            },
                            child: const Icon(
                              IconlyLight.camera,
                              color: Colors.white,
                            ))
                      ],
                    ),
                  ],
                ))
          ],
        )));
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
    if (isOnPageTurning &&
        preloadPageController!.page ==
            preloadPageController!.page!.roundToDouble()) {
      setState(() {
        current = preloadPageController!.page!.toInt();
        isOnPageTurning = false;
      });
    } else if (!isOnPageTurning &&
        current.toDouble() != preloadPageController!.page) {
      if ((current.toDouble() - preloadPageController!.page!.toDouble()).abs() >
          0.1) {
        setState(() {
          isOnPageTurning = true;
        });
      }
    }
  }

  void scrollListener1() {
    if (isRelatedTurning &&
        preloadPageController1!.page ==
            preloadPageController1!.page!.roundToDouble()) {
      setState(() {
        related = preloadPageController1!.page!.toInt();
        isRelatedTurning = false;
      });
    } else if (!isRelatedTurning &&
        related.toDouble() != preloadPageController1!.page) {
      if ((related.toDouble() - preloadPageController1!.page!.toDouble())
              .abs() >
          0.1) {
        setState(() {
          isRelatedTurning = true;
        });
      }
    }
  }

  void scrollListener2() {
    if (isPopularTurning &&
        preloadPageController2!.page ==
            preloadPageController2!.page!.roundToDouble()) {
      setState(() {
        popular = preloadPageController2!.page!.toInt();
        isPopularTurning = false;
      });
    } else if (!isPopularTurning &&
        popular.toDouble() != preloadPageController2!.page) {
      if ((popular.toDouble() - preloadPageController2!.page!.toDouble())
              .abs() >
          0.1) {
        setState(() {
          isPopularTurning = true;
        });
      }
    }
  }
}

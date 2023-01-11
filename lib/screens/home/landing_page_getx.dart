import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/comments_controller.dart';
import 'package:thrill/controller/hashtags/top_hashtags_controller.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos/UserVideosController.dart';
import 'package:thrill/controller/videos/like_videos_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/controller/wallet/wallet_balance_controller.dart';
import 'package:thrill/controller/wallet/wallet_currencies_controller.dart';
import 'package:thrill/controller/wallet_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/screens/home/discover_getx.dart';
import 'package:thrill/screens/home/home_getx.dart';
import 'package:thrill/screens/profile/profile.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/setting/wallet_getx.dart';
import 'package:thrill/screens/spin/spin_the_wheel_getx.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/fab_items.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/videos/PrivateVideosController.dart';
import '../../widgets/better_video_player.dart';

var usersController = Get.find<UserController>();
var videosController = Get.find<VideosController>();
var commentsController = Get.find<CommentsController>();

var likedVideosController = Get.find<LikedVideosController>();
var userVideosController = Get.find<UserVideosController>();
var userDetailsController = Get.find<UserDetailsController>();
var walletController = Get.find<WalletController>();
var walletBalanceController = Get.find<WalletBalanceController>();
var walletCurrencyController = Get.find<WalletCurrenciesController>();
var privateVideosController = Get.find<PrivateVideosController>();

var tophashtagsController = Get.find<TopHashtagsController>();

class LandingPageGetx extends StatelessWidget {
  LandingPageGetx({this.initialLink});
  PendingDynamicLinkData? initialLink;
  var selectedIndex = 0.obs;
  @override
  Widget build(BuildContext context) {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      // launchUrl(Uri.parse(RestUrl.videoUrl + dynamicLinkData.link.path));

      if (dynamicLinkData.link.queryParameters["type"] == "profile") {
        otherUsersController
            .getOtherUserProfile(dynamicLinkData.link.queryParameters["id"])
            .then((value) {
              likedVideosController.getOthersLikedVideos(int.parse(dynamicLinkData.link.queryParameters["id"].toString())).then((value) {
                 userVideosController
                    .getOtherUserVideos(int.parse(dynamicLinkData.link.queryParameters["id"].toString())).then((value) {
                   Get.to(ViewProfile(
                       dynamicLinkData.link.queryParameters["id"],
                       0.obs,
                       dynamicLinkData.link.queryParameters["name"],
                       dynamicLinkData.link.queryParameters["something"]));
                 });

              });

        });
      } else if (dynamicLinkData.link.queryParameters["type"] == "video") {
        successToast(dynamicLinkData.link.queryParameters["id"].toString());
      }
      else if(dynamicLinkData.link.queryParameters["type"]=="referal"){
        otherUsersController
            .getOtherUserProfile(dynamicLinkData.link.queryParameters["id"])
            .then((value) {
          likedVideosController.getOthersLikedVideos(int.parse(dynamicLinkData.link.queryParameters["id"].toString())).then((value) {
            userVideosController
                .getOtherUserVideos(int.parse(dynamicLinkData.link.queryParameters["id"].toString())).then((value) {
              Get.to(ViewProfile(
                  dynamicLinkData.link.queryParameters["id"],
                  0.obs,
                  dynamicLinkData.link.queryParameters["name"],
                  dynamicLinkData.link.queryParameters["something"]));
            });

          });

        });
      }
    }).onError((error) {
      errorToast(error.toString());
    });
    GlobalKey key = GlobalKey();

    // WidgetsBinding.instance.addPostFrameCallback(
    //     (timeStamp) => ShowCaseWidget.of(context).startShowCase([key]));

    RxList<Widget> screens = [
      HomeGetx(),
      const DiscoverGetx(),
      const WalletGetx(),
      Profile(),
    ].obs;
    return WillPopScope(
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.transparent,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(80)),
              // boxShadow: [
              //   BoxShadow(
              //     color: Color(0xff00CCC9).withOpacity(0.7),
              //     blurRadius: 8,
              //     spreadRadius: 8,
              //   )
              // ]
            ),
            child: Container(
                child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Lottie.asset("assets/loader_fab.json",
                    height: 100, width: 100, fit: BoxFit.fill),
                FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.transparent.withOpacity(0.0),
                  child: SvgPicture.network(
                    RestUrl.assetsUrl + 'spin_wheel.svg',
                    //scale: 1.4,
                    height: 50,
                    width: 50,
                    fit: BoxFit.fill,
                  ),
                  onPressed: () {
                    if (userDetailsController.storage.read("token") != null) {
                      Get.to(() => SpinTheWheelGetx());
                    } else {
                      Get.to(LoginGetxScreen());
                    }
                  },
                )
              ],
            )
                // Showcase(
                //     showcaseBackgroundColor:
                //         Color.fromARGB(255, 1, 180, 177),
                //     shapeBorder: const CircleBorder(),
                //     radius: const BorderRadius.all(Radius.circular(40)),
                //     tipBorderRadius:
                //         const BorderRadius.all(Radius.circular(8)),
                //     overlayPadding: const EdgeInsets.all(5),
                //     key: key!,
                //     child: ,
                //     textColor: Colors.white,
                //     descTextStyle: const TextStyle(
                //         fontWeight: FontWeight.bold, color: Colors.white),
                //     description:
                //         "check out the spin wheel to earn rewards!!"),
                ),
          ),
          extendBody: true,
          body: Obx(() => IndexedStack(
                index: selectedIndex.value,
                children: screens,
              )),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            elevation: 10,
            color: ColorManager.dayNight, //Color.fromRGBO(24, 26, 32, 0.85)
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 22,
                        icon: Icon(IconlyLight.home,
                            color: selectedIndex.value == 0
                                ? ColorManager.colorPrimaryLight
                                : ColorManager.dayNightText),
                        onPressed: () {
                          selectedIndex.value = 0;
                        },
                      ),
                      Text(
                        "home",
                        style: TextStyle(
                            fontSize: 12,
                            color: selectedIndex.value == 0
                                ? ColorManager.colorPrimaryLight
                                : ColorManager.dayNightText),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 25,
                        icon: Icon(IconlyLight.discovery,
                            color: selectedIndex.value == 1
                                ? ColorManager.colorPrimaryLight
                                : ColorManager.dayNightText),
                        onPressed: () {
                          tophashtagsController.getTopHashTags();
                          selectedIndex.value = 1;
                        },
                      ),
                      Text(
                        "Discover",
                        style: TextStyle(
                            fontSize: 12,
                            color: selectedIndex.value == 1
                                ? ColorManager.colorPrimaryLight
                                : ColorManager.dayNightText),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "",
                        style: TextStyle(
                            fontSize: 12,
                            color: selectedIndex.value == 1
                                ? ColorManager.colorPrimaryLight
                                : ColorManager.dayNightText),
                      )
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 25,
                        icon: Icon(
                          IconlyLight.wallet,
                          color: selectedIndex.value == 2
                              ? ColorManager.colorAccent
                              : ColorManager.dayNightText,
                        ),
                        onPressed: () {
                          GetStorage().read("token") != null
                              ? walletBalanceController
                                  .getBalance()
                                  .then((value) => selectedIndex.value = 2)
                              : Get.to(LoginGetxScreen());
                        },
                      ),
                      Text(
                        "Wallet",
                        style: TextStyle(
                            fontSize: 12,
                            color: selectedIndex.value == 2
                                ? ColorManager.colorPrimaryLight
                                : ColorManager.dayNightText),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        iconSize: 25,
                        icon: Icon(IconlyLight.profile,
                            color: selectedIndex.value == 3
                                ? ColorManager.colorPrimaryLight
                                : ColorManager.dayNightText),
                        onPressed: () {
                          if (userDetailsController.storage.read("token") !=
                              null) {
                            userVideosController.getOtherUserVideos(
                                userDetailsController.storage.read("userId"));

                            userDetailsController
                                .getUserProfile()
                                .then((value) => selectedIndex.value = 3);
                            likedVideosController.getUserLikedVideos(
                                );
                            privateVideosController.getUserPrivateVideos();
                          } else {
                            Get.to(LoginGetxScreen());
                          }
                        },
                      ),
                      Text(
                        "Profile",
                        style: TextStyle(
                            fontSize: 12,
                            color: selectedIndex.value == 3
                                ? ColorManager.colorPrimaryLight
                                : ColorManager.dayNightText),
                      ),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                ],
              ),
            ),
          )

          //  myDrawer2()

          // GlassmorphicContainer(
          //     width: Get.width,
          //     height: 80,
          //     borderRadius: 20,
          //     blur: 20,
          //     alignment: Alignment.bottomCenter,
          //     border: 0.5,
          //     linearGradient: LinearGradient(
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //         colors: [
          //           Colors.black.withOpacity(0.2),
          //           Colors.black.withOpacity(0.4),
          //         ],
          //         stops: [
          //           0.1,
          //           1,
          //         ]),
          //     borderGradient: LinearGradient(
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //       colors: [
          //         const Color(0xFFffffff).withOpacity(0.5),
          //         const Color((0xFFFFFFFF)).withOpacity(0.5),
          //       ],
          //     ),
          //     child:
          //     )
          ,
        ),
        onWillPop: () async {
          if (selectedIndex.value != 0) {
            _selectedTab(0);
            selectedIndex.value = 0;
            return false;
          } else {
            SystemNavigator.pop(animated: true);
            return true;
          }
        });
  }

  myDrawer2() {
    return Container(
      color: Colors.transparent.withOpacity(0.0),
      child: FABBottomAppBar(
        backgroundColor: Colors.green,
        color: const Color(0xffB2E3E3),
        selectedColor: ColorManager.colorAccent,
        iconSize: 35,
        notchedShape: const CircularNotchedRectangle(),
        onTabSelected: _selectedTab,
        items: [
          FABBottomAppBarItem(iconData: IconlyLight.home, text: ''),
          FABBottomAppBarItem(iconData: IconlyLight.discovery, text: ''),
          FABBottomAppBarItem(iconData: IconlyLight.wallet, text: ''),
          FABBottomAppBarItem(iconData: IconlyLight.profile, text: ''),
        ],
      ),
    );
  }

  void _selectedTab(index) async {
    if (index == 1) {
      // discoverController.getHashTagsList();
      // discoverController.getBanners();
      tophashtagsController.getTopHashTags();
      selectedIndex.value = 2;
    }
    if (index == 2) {
      if (await GetStorage().read("token") != null) {
        selectedIndex.value = 2;
        walletBalanceController.getBalance();
        walletCurrencyController.getCurrencies();
        //walletBalanceController.getCurrencies();
      } else {
        Get.to(LoginGetxScreen());
      }
    }
    if (index == 3) {
      if (await GetStorage().read("token") != null) {
        await userVideosController
            .getOtherUserVideos(userDetailsController.storage.read("userId"));
        await likedVideosController
            .getOthersLikedVideos(userDetailsController.storage.read("userId"));

        await privateVideosController.getUserPrivateVideos();
        await userDetailsController
            .getUserProfile();
        selectedIndex.value = 3;
      } else {
        Get.to(LoginGetxScreen());
      }
    } else {
      selectedIndex.value = index;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/screens/home/discover_getx.dart';
import 'package:thrill/screens/home/home_getx.dart';
import 'package:thrill/screens/profile/profile.dart';
import 'package:thrill/screens/setting/wallet_getx.dart';
import 'package:thrill/screens/spin/spin_the_wheel_getx.dart';

var usersController = Get.find<UserController>();
var videosController = Get.find<VideosController>();

class LandingPageGetx extends StatelessWidget {
  const LandingPageGetx({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey key = GlobalKey();

    WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => ShowCaseWidget.of(context).startShowCase([key]));

    RxList<Widget> screens = [
      const HomeGetx(),
      const DiscoverGetx(),
      const WalletGetx(),
       Profile(),
    ].obs;
    return WillPopScope(
        child: Scaffold(
          extendBody: true,
            body: Obx(() =>
                IndexedStack(index: usersController.selectedIndex.value,children: screens,)),
            bottomNavigationBar: GlassContainer(
              blur: 20,
              //--code to remove border
              border: Border.all(color: Colors.white),
              shape: BoxShape.circle,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              child: BottomAppBar(
                elevation: 0,
                color: Colors.black.withOpacity(0.3),
                //Color.fromRGBO(24, 26, 32, 0.85)
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 22,
                            icon: Icon(IconlyLight.home,
                                color: usersController.selectedIndex.value == 0
                                    ? ColorManager.colorPrimaryLight
                                    : Colors.white),
                            onPressed: () {
                              videosController.getAllVideos();
                              usersController.selectedIndex.value = 0;
                            },
                          ),
                          Text(
                            "home",
                            style: TextStyle(
                                fontSize: 12,
                                color: usersController.selectedIndex.value == 0
                                    ? ColorManager.colorPrimaryLight
                                    : Colors.white),
                          )
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 25,
                            icon: Icon(IconlyLight.discovery,
                                color: usersController.selectedIndex.value == 1
                                    ? ColorManager.colorPrimaryLight
                                    : Colors.white),
                            onPressed: () {
                              discoverController.getTopHashTags();
                              discoverController.getBanners();
                              discoverController.getHashTagsList();
                              discoverController.searchHashtags("");
                              usersController.selectedIndex.value = 1;
                            },
                          ),
                          Text(
                            "Discover",
                            style: TextStyle(
                                fontSize: 12,
                                color: usersController.selectedIndex.value == 1
                                    ? ColorManager.colorPrimaryLight
                                    : Colors.white),
                          )
                        ],
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.transparent.withOpacity(0),
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(80)),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Color(0xff00CCC9).withOpacity(0.7),
                          //     blurRadius: 8,
                          //     spreadRadius: 8,
                          //   )
                          // ]
                        ),
                        child: Container(
                            width: 100,
                            color: Colors.transparent.withOpacity(0.0),
                            child: Stack(
                              fit: StackFit.expand,
                              alignment: Alignment.center,
                              children: [
                                Lottie.asset("assets/loader_fab.json",
                                    height: 100, width: 100),
                                FloatingActionButton(
                                  elevation: 0,
                                  backgroundColor:
                                      Colors.transparent.withOpacity(0.0),
                                  child: SvgPicture.network(
                                    RestUrl.assetsUrl + 'spin_wheel.svg',
                                    //scale: 1.4,
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.fill,
                                  ),
                                  onPressed: () =>
                                      Get.to(() => SpinTheWheelGetx()),
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 25,
                            icon: Icon(
                              IconlyLight.wallet,
                              color: usersController.selectedIndex.value == 2
                                  ? ColorManager.colorPrimaryLight
                                  : Colors.white,
                            ),
                            onPressed: () {
                              GetStorage().read("token") != null
                                  ? usersController.selectedIndex.value = 2
                                  : Get.to(LoginGetxScreen());
                            },
                          ),
                          Text(
                            "Wallet",
                            style: TextStyle(
                                fontSize: 12,
                                color: usersController.selectedIndex.value == 2
                                    ? ColorManager.colorPrimaryLight
                                    : Colors.white),
                          )
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 25,
                            icon: Icon(IconlyLight.profile,
                                color: usersController.selectedIndex.value == 3
                                    ? ColorManager.colorPrimaryLight
                                    : Colors.white),
                            onPressed: () {
                              if (usersController.storage.read("token") !=
                                  null) {
                                usersController
                                    .getUserProfile(
                                        usersController.storage.read("userId"));
                                usersController
                                    .selectedIndex.value = 3;
                              } else {
                                Get.to(LoginGetxScreen());
                              }
                            },
                          ),
                          Text(
                            "Profile",
                            style: TextStyle(
                                fontSize: 12,
                                color: usersController.selectedIndex.value == 3
                                    ? ColorManager.colorPrimaryLight
                                    : Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )

            // GlassmorphicContainer(
            //   width: Get.width,
            //   height: 80,
            //   borderRadius: 20,
            //   blur: 20,
            //   alignment: Alignment.bottomCenter,
            //   border: 0.5,
            //   linearGradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [
            //         Colors.black.withOpacity(0.2),
            //         Colors.black.withOpacity(0.4),
            //       ],
            //       stops: [
            //         0.1,
            //         1,
            //       ]),
            //   borderGradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: [
            //       const Color(0xFFffffff).withOpacity(0.5),
            //       const Color((0xFFFFFFFF)).withOpacity(0.5),
            //     ],
            //   ),
            //   child:BottomAppBar(
            //     elevation: 0,
            //     color: Colors.transparent.withOpacity(0.0), //Color.fromRGBO(24, 26, 32, 0.85)
            //     child:Obx(() => Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: [
            //         Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             IconButton(
            //               iconSize: 22,
            //               icon: Icon(IconlyLight.home,
            //                   color: usersController.selectedIndex.value == 0
            //                       ? ColorManager.colorPrimaryLight
            //                       : Colors.white),
            //               onPressed: () {
            //                 usersController.selectedIndex.value = 0;
            //               },
            //             )
            //             ,Text("home",style: TextStyle(fontSize: 12,color: usersController.selectedIndex.value == 0
            //                 ? ColorManager.colorPrimaryLight
            //                 : Colors.white),)],)
            //         ,
            //         Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             IconButton(
            //               iconSize: 25,
            //               icon: Icon(IconlyLight.discovery,
            //                   color: usersController.selectedIndex.value == 1
            //                       ? ColorManager.colorPrimaryLight
            //                       : Colors.white),
            //               onPressed: () {
            //                 usersController.selectedIndex.value = 1;
            //               },
            //             ),
            //             Text("Discover",style: TextStyle(fontSize: 12,color: usersController.selectedIndex.value == 1
            //                 ? ColorManager.colorPrimaryLight
            //                 : Colors.white),)],),
            //
            //         Container(
            //           height: 80,
            //           width: 80,
            //           decoration: BoxDecoration(
            //             border: Border.all(
            //               color: Colors.transparent,
            //             ),
            //             borderRadius: const BorderRadius.all(Radius.circular(80)),
            //             // boxShadow: [
            //             //   BoxShadow(
            //             //     color: Color(0xff00CCC9).withOpacity(0.7),
            //             //     blurRadius: 8,
            //             //     spreadRadius: 8,
            //             //   )
            //             // ]
            //           ),
            //           child: Container(
            //               width: 100,
            //               child: Stack(
            //                 fit: StackFit.expand,
            //                 alignment: Alignment.center,
            //                 children: [
            //                   Lottie.asset("assets/loader_fab.json",
            //                       height: 100, width: 100),
            //                   FloatingActionButton(
            //                     elevation: 0,
            //                     backgroundColor:
            //                     Colors.transparent.withOpacity(0.0),
            //                     child: SvgPicture.network(
            //                       RestUrl.assetsUrl + 'spin_wheel.svg',
            //                       //scale: 1.4,
            //                       height: 40,
            //                       width: 40,
            //                       fit: BoxFit.fill,
            //                     ),
            //                     onPressed: () => Get.to(() => SpinTheWheelGetx()),
            //                   )
            //                 ],
            //               )
            //             // Showcase(
            //             //     showcaseBackgroundColor:
            //             //         Color.fromARGB(255, 1, 180, 177),
            //             //     shapeBorder: const CircleBorder(),
            //             //     radius: const BorderRadius.all(Radius.circular(40)),
            //             //     tipBorderRadius:
            //             //         const BorderRadius.all(Radius.circular(8)),
            //             //     overlayPadding: const EdgeInsets.all(5),
            //             //     key: key!,
            //             //     child: ,
            //             //     textColor: Colors.white,
            //             //     descTextStyle: const TextStyle(
            //             //         fontWeight: FontWeight.bold, color: Colors.white),
            //             //     description:
            //             //         "check out the spin wheel to earn rewards!!"),
            //           ),
            //         ),
            //
            //         Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             IconButton(
            //               iconSize: 25,
            //               icon: Icon(
            //                 IconlyLight.wallet,
            //                 color: usersController.selectedIndex.value == 2
            //                     ? ColorManager.colorPrimaryLight
            //                     : Colors.white,
            //               ),
            //               onPressed: () {
            //
            //                 GetStorage().read("token") != null
            //                     ? usersController.selectedIndex.value = 2
            //                     : Get.to(LoginGetxScreen());
            //               },
            //             ),
            //             Text("Wallet",style: TextStyle(fontSize: 12,color: usersController.selectedIndex.value == 2
            //                 ? ColorManager.colorPrimaryLight
            //                 : Colors.white),)],),
            //
            //         Column(
            //           mainAxisSize: MainAxisSize.min,
            //           children: [
            //             IconButton(
            //               iconSize: 25,
            //               icon: Icon(IconlyLight.profile,
            //                   color: usersController.selectedIndex.value == 3
            //                       ? ColorManager.colorPrimaryLight
            //                       : Colors.white),
            //               onPressed: () {
            //
            //                 if (usersController.storage.read("token") != null) {
            //                   usersController
            //                       .getUserProfile(
            //                       usersController.storage.read("userId"))
            //                       .then((value) => usersController.selectedIndex.value = 3);
            //                 } else {
            //                   Get.to(LoginGetxScreen());
            //                 }
            //               },
            //             ),
            //             Text("Profile",style: TextStyle(fontSize: 12,color: usersController.selectedIndex.value == 3
            //                 ? ColorManager.colorPrimaryLight
            //                 : Colors.white),)],),
            //
            //       ],
            //     ),
            //   ) ,)
            //
            //
            //
            //
            //
            //
            // )
            ),
        onWillPop: () async {
          if (usersController.selectedIndex.value != 0) {
            usersController.selectedIndex.value = 0;
            return false;
          } else {
            SystemNavigator.pop(animated: true);
            return true;
          }
        });
  }
}

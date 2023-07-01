import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_data/sim_data.dart';
import 'package:sim_data/sim_model.dart';
import 'package:thrill/app/modules/login/controllers/login_controller.dart';
import 'package:thrill/app/modules/login/views/login_view.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/utils/color_manager.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:thrill/app/widgets/no_internet_connection.dart';
import 'package:thrill/app/widgets/no_liked_videos.dart';

import '../controllers/ConnectionManagerController.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var pageController = PageController();
  var controller = Get.find<HomeController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.connectionType == 0
        ? Scaffold(
            body: NoInternetConnection(),
          )
        : Scaffold(
            backgroundColor: Colors.black,
            extendBodyBehindAppBar: true,
            extendBody: true,
            floatingActionButton: Stack(
              alignment: Alignment.center,
              children: [
                Lottie.asset("assets/loader_fab.json",
                    height: 50, width: 50, fit: BoxFit.fill),
                Transform.rotate(
                  angle: 120,
                  child: FloatingActionButton(
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://ahaslides.com/wp-content/uploads/2021/06/Spin-the-wheel-783x630.png",
                      fit: BoxFit.cover,
                    ),
                    onPressed: () async {
                      checkForLogin(() {
                        Get.toNamed(Routes.SPIN_WHEEL);
                      });
                    },
                    //params
                  ),
                )
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: Obx(() => AnimatedBottomNavigationBar(
                  blurEffect: true,
                  icons: [
                    Icons.home,
                    Icons.discord,
                    Icons.wallet,
                    Icons.person
                  ],
                  activeIndex: controller.bottomNavIndex.value,
                  gapLocation: GapLocation.center,
                  height: 50,
                  activeColor: ColorManager.cyan,
                  inactiveColor: ColorManager.colorAccent,
                  notchSmoothness: NotchSmoothness.defaultEdge,
                  leftCornerRadius: 32,
                  rightCornerRadius: 32,
                  borderColor: ColorManager.colorAccent,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  onTap: (index) async {
                    if (index != 0) {
                      checkForLogin(() {
                        pageController.animateToPage(index,
                            duration: Duration(microseconds: 300),
                            curve: Curves.bounceIn);
                        controller.bottomNavIndex.value = index;
                      });
                    } else {
                      pageController.animateToPage(index,
                          duration: Duration(microseconds: 300),
                          curve: Curves.bounceIn);
                      controller.bottomNavIndex.value = index;
                    }
                    setState(() {});
                  },
                  //other params
                )),
            body: Obx(() => DoubleBack(
                condition: controller.bottomNavIndex.value == 0,
                // only show message when tabIndex=0
                onConditionFail: () {
                  controller.bottomNavIndex.value = 0;
                  pageController.animateToPage(controller.bottomNavIndex.value,
                      duration: Duration(microseconds: 300),
                      curve: Curves.bounceIn);
                  setState(() {});
                },
                message: "Press back again to close",
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: controller.homeScreens,
                ))),
          ));
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    super.dispose();
  }
}

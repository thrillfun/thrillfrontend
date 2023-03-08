import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:thrill/app/modules/login/controllers/login_controller.dart';
import 'package:thrill/app/modules/login/views/login_view.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/utils/color_manager.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [ Lottie.asset("assets/loader_fab.json",
          height: 100, width: 100, fit: BoxFit.fill),FloatingActionButton(
        child: CachedNetworkImage(imageUrl: "https://ahaslides.com/wp-content/uploads/2021/06/Spin-the-wheel-783x630.png",fit: BoxFit.cover,),
        onPressed: ()async {
          if(await GetStorage().read("token")==null){
          Get.bottomSheet(LoginView());
          }
          else{
            Get.toNamed(Routes.SPIN_WHEEL);
          }

        },
        //params
      )],),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(()=>AnimatedBottomNavigationBar(
        blurEffect: true,
        icons: [Icons.home,Icons.discord,Icons.wallet,Icons.person],
        activeIndex: controller.bottomNavIndex.value,
        gapLocation: GapLocation.center,
        height: 80,
        activeColor: ColorManager.colorAccent,
        inactiveColor: ColorManager.colorAccentTransparent,
        notchSmoothness: NotchSmoothness.defaultEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index)async  {

          if(index == 2  && await GetStorage().read("token")==null){
            Get.bottomSheet(LoginView());
          }
          if( index == 3 && await GetStorage().read("token")==null){
            Get.bottomSheet(LoginView());
          }
          else{
            controller.bottomNavIndex.value = index;
          }

        } ,
        //other params
      )),
      body:Obx(()=>controller.homeScreens[controller.bottomNavIndex.value]) ,
    );
  }
}

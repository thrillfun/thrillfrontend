import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:thrill/app/utils/color_manager.dart';
import 'package:video_player/video_player.dart';

import '../../../routes/app_pages.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body:
        LottieBuilder.asset(
          "assets/splash_1.json",
          frameRate: FrameRate(60),
          alignment: Alignment.center,
          width: Get.width,
          height: Get.height,
          fit: BoxFit.fill,
        ));
  }
}

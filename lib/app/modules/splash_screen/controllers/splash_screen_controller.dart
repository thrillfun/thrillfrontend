import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../routes/app_pages.dart';

class SplashScreenController extends GetxController {
  //TODO: Implement SplashScreenController

  @override
  void onInit() {
    Future.delayed(Duration(seconds: 5)).then((value) => Get.offAllNamed(Routes.HOME));

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}

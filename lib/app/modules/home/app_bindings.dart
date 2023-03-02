import 'package:get/get.dart';
import 'package:thrill/app/modules/home/controllers/home_controller.dart';
import 'package:thrill/app/modules/login/otpverify/controllers/otpverify_controller.dart';
import 'package:thrill/app/modules/related_videos/controllers/related_videos_controller.dart';

import '../login/controllers/login_controller.dart';

class AppBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(),fenix: true);
    Get.lazyPut(() => HomeController(),fenix: true);
    Get.lazyPut(() => OtpverifyController(),fenix: true);
    Get.lazyPut(() => RelatedVideosController(),fenix: true);
  }

}
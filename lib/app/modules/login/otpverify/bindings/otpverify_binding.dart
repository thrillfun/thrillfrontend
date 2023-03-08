import 'package:get/get.dart';

import '../controllers/otpverify_controller.dart';

class OtpverifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpverifyController>(
      () => OtpverifyController(),
    );
  }
}

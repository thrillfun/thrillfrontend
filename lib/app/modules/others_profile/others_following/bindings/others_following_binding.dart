import 'package:get/get.dart';

import '../controllers/others_following_controller.dart';

class OthersFollowingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtherssFollowingController>(
      () => OtherssFollowingController(),
    );
  }
}

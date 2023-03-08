import 'package:get/get.dart';

import '../controllers/others_following_controller.dart';

class FollowingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OthersFollowingController>(
      () => OthersFollowingController(),
    );
  }
}

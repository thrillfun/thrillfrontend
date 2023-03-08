import 'package:get/get.dart';

import '../controllers/followings_controller.dart';

class FollowingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FollowingsController>(
      () => FollowingsController(),
    );
  }
}

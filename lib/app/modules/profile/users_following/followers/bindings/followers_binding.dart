import 'package:get/get.dart';

import '../controllers/followers_controller.dart';

class FollowersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FollowersController>(
      () => FollowersController(),
    );
  }
}

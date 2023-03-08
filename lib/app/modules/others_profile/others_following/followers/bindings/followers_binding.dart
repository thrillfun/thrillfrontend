import 'package:get/get.dart';

import '../controllers/others_followers_controller.dart';

class FollowersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtherFollowersController>(
      () => OtherFollowersController(),
    );
  }
}

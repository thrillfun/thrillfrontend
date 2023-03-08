import 'package:get/get.dart';

import '../controllers/users_following_controller.dart';

class UsersFollowingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsersFollowingController>(
      () => UsersFollowingController(),
    );
  }
}

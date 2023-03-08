import 'package:get/get.dart';

import '../controllers/user_levels_controller.dart';

class UserLevelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserLevelsController>(
      () => UserLevelsController(),
    );
  }
}

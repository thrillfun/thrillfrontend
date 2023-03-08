import 'package:get/get.dart';

import '../controllers/user_private_videos_controller.dart';

class UserPrivateVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserPrivateVideosController>(
      () => UserPrivateVideosController(),
    );
  }
}

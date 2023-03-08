import 'package:get/get.dart';

import '../controllers/user_videos_controller.dart';

class UserVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserVideosController>(
      () => UserVideosController(),
    );
  }
}

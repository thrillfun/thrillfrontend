import 'package:get/get.dart';

import '../controllers/user_liked_videos_controller.dart';

class UserLikedVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserLikedVideosController>(
      () => UserLikedVideosController(),
    );
  }
}

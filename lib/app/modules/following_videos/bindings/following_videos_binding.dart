import 'package:get/get.dart';

import '../controllers/following_videos_controller.dart';

class FollowingVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FollowingVideosController>(
      () => FollowingVideosController(),
    );
  }
}

import 'package:get/get.dart';

import '../controllers/liked_video_player_controller.dart';

class LikedVideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LikedVideoPlayerController>(
      () => LikedVideoPlayerController(),
    );
  }
}

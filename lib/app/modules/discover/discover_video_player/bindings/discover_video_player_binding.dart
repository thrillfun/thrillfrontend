import 'package:get/get.dart';

import '../controllers/discover_video_player_controller.dart';

class DiscoverVideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiscoverVideoPlayerController>(
      () => DiscoverVideoPlayerController(),
    );
  }
}

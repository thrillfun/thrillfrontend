import 'package:get/get.dart';

import '../controllers/private_videos_player_controller.dart';

class PrivateVideosPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivateVideosPlayerController>(
      () => PrivateVideosPlayerController(),
    );
  }
}

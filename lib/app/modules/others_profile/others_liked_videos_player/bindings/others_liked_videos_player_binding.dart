import 'package:get/get.dart';

import '../controllers/others_liked_videos_player_controller.dart';

class OthersLikedVideosPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OthersLikedVideosPlayerController>(
      () => OthersLikedVideosPlayerController(),
    );
  }
}

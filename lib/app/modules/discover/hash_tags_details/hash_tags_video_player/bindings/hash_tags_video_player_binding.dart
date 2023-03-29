import 'package:get/get.dart';

import '../controllers/hash_tags_video_player_controller.dart';

class HashTagsVideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HashTagsVideoPlayerController>(
      () => HashTagsVideoPlayerController(),
    );
  }
}

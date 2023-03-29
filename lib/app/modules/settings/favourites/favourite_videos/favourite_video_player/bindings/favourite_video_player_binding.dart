import 'package:get/get.dart';

import '../controllers/favourite_video_player_controller.dart';

class FavouriteVideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavouriteVideoPlayerController>(
      () => FavouriteVideoPlayerController(),
    );
  }
}

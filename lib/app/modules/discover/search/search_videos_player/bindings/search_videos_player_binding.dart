import 'package:get/get.dart';

import '../controllers/search_videos_player_controller.dart';

class SearchVideosPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchVideosPlayerController>(
      () => SearchVideosPlayerController(),
    );
  }
}

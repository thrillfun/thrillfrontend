import 'package:get/get.dart';

import '../controllers/home_videos_player_controller.dart';

class HomeVideosPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeVideosPlayerController>(
      () => HomeVideosPlayerController(),
    );
  }
}

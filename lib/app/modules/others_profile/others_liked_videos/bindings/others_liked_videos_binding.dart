import 'package:get/get.dart';

import '../controllers/others_liked_videos_controller.dart';

class OthersLikedVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OthersLikedVideosController>(
      () => OthersLikedVideosController(),
    );
  }
}

import 'package:get/get.dart';

import '../controllers/other_user_videos_controller.dart';

class OtherUserVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtherUserVideosController>(
      () => OtherUserVideosController(),
    );
  }
}

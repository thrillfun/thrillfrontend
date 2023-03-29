import 'package:get/get.dart';

import '../controllers/profile_videos_controller.dart';

class ProfileVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileVideosController>(
      () => ProfileVideosController(),
    );
  }
}

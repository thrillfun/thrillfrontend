import 'package:get/get.dart';

import '../controllers/others_profile_videos_controller.dart';

class OthersProfileVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OthersProfileVideosController>(
      () => OthersProfileVideosController(),
    );
  }
}

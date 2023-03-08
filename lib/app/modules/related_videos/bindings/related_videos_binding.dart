import 'package:get/get.dart';

import '../controllers/related_videos_controller.dart';

class RelatedVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RelatedVideosController>(
      () => RelatedVideosController(),
    );
  }
}

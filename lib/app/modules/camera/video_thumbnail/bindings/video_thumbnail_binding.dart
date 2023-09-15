import 'package:get/get.dart';

import '../controllers/video_thumbnail_controller.dart';

class VideoThumbnailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoThumbnailController>(
      () => VideoThumbnailController(),
    );
  }
}

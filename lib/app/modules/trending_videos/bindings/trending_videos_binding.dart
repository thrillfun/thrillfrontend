import 'package:get/get.dart';

import '../controllers/trending_videos_controller.dart';

class TrendingVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrendingVideosController>(
      () => TrendingVideosController(),
    );
  }
}

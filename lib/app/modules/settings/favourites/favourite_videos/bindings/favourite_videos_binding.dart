import 'package:get/get.dart';

import '../controllers/favourite_videos_controller.dart';

class FavouriteVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavouriteVideosController>(
      () => FavouriteVideosController(),
    );
  }
}

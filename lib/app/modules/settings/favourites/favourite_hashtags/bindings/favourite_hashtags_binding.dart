import 'package:get/get.dart';

import '../controllers/favourite_hashtags_controller.dart';

class FavouriteHashtagsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavouriteHashtagsController>(
      () => FavouriteHashtagsController(),
    );
  }
}

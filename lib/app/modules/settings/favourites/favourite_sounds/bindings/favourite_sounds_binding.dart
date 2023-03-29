import 'package:get/get.dart';

import '../controllers/favourite_sounds_controller.dart';

class FavouriteSoundsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavouriteSoundsController>(
      () => FavouriteSoundsController(),
    );
  }
}

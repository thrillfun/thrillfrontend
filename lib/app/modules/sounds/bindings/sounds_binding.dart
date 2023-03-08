import 'package:get/get.dart';

import '../controllers/sounds_controller.dart';

class SoundsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SoundsController>(
      () => SoundsController(),
    );
  }
}

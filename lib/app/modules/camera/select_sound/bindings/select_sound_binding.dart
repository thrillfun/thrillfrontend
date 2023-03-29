import 'package:get/get.dart';

import '../controllers/select_sound_controller.dart';

class SelectSoundBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectSoundController>(
      () => SelectSoundController(),
    );
  }
}

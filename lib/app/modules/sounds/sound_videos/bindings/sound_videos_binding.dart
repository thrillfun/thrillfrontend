import 'package:get/get.dart';

import '../controllers/sound_videos_controller.dart';

class SoundVideosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SoundVideosController>(
      () => SoundVideosController(),
    );
  }
}

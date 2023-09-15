import 'package:get/get.dart';

import '../controllers/privacy_settings_controller.dart';

class PrivacySettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivacySettingsController>(
      () => PrivacySettingsController(),
    );
  }
}

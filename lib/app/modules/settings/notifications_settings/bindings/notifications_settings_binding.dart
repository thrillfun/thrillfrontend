import 'package:get/get.dart';

import '../controllers/notifications_settings_controller.dart';

class NotificationsSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsSettingsController>(
      () => NotificationsSettingsController(),
    );
  }
}

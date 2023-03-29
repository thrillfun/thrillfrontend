import 'package:get/get.dart';

import '../controllers/referal_controller.dart';

class ReferalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReferalController>(
      () => ReferalController(),
    );
  }
}

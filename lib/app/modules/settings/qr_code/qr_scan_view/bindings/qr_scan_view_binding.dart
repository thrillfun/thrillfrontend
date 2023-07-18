import 'package:get/get.dart';

import '../controllers/qr_scan_view_controller.dart';

class QrScanViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrScanViewController>(
      () => QrScanViewController(),
    );
  }
}

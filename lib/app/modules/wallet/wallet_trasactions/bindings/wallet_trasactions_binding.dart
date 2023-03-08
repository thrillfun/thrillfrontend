import 'package:get/get.dart';

import '../controllers/wallet_trasactions_controller.dart';

class WalletTrasactionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletTrasactionsController>(
      () => WalletTrasactionsController(),
    );
  }
}

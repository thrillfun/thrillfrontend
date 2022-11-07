import 'package:get/get.dart';
import 'package:thrill/controller/comments_controller.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/sounds_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/controller/wallet_controller.dart';
import 'package:thrill/controller/wheel_controller.dart';

import 'data_controller.dart';

class DataBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(UserController());
    Get.put(CommentsController());
    Get.put(VideosController());
    Get.put(DiscoverController());
    Get.put(WheelController());
    Get.put(WalletController());
    Get.put(SoundsController());
  }
}

import 'package:get/get.dart';
import 'package:thrill/controller/InboxController.dart';
import 'package:thrill/controller/auth_controller.dart';
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
    Get.lazyPut(()=>VideosController(),fenix: true);
    Get.lazyPut(()=>AuthController(),fenix: true);
    Get.lazyPut(()=>SoundsController(),fenix: true);
    Get.lazyPut(()=>UserController(),fenix: true);
    Get.lazyPut(()=>CommentsController(),fenix: true);
    Get.lazyPut(()=>DiscoverController(),fenix: true);
    Get.lazyPut(()=>WheelController(),fenix: true);
    Get.lazyPut(()=>WalletController(),fenix: true);
    Get.lazyPut(()=>InboxController(),fenix: true);
  }
}

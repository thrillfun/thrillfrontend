import 'package:better_player/better_player.dart';
import 'package:get/get.dart';

class FavouriteVideoPlayerController extends GetxController {
  BetterPlayerEventType? eventType;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}

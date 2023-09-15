import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PrivacySettingsController extends GetxController {
  var isVideoDownloadble = true.obs;
  var isPostPublic = true.obs;
  @override
  void onInit() {
    super.onInit();
    getVideoDownloadbleValue();
    getisPostPublic();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getVideoDownloadbleValue() {
    isVideoDownloadble.value = GetStorage().read('isVideoDownloadble') ?? true;
  }

  updateVideoDownloads(bool value) async {
    isVideoDownloadble.value = value;
    await GetStorage().write('isVideoDownloadble', isVideoDownloadble.value);
  }

  getisPostPublic() async {
    isPostPublic.value = GetStorage().read('isPostPublic') ?? true;
  }

  updateIsPostPublic(bool value) async {
    isPostPublic.value = value;
    await GetStorage().write('isPostPublic', value);
  }
}

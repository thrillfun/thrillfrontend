import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../rest/models/notifications_settings_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../utils/utils.dart';

class NotificationsSettingsController extends GetxController {
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  RxBool likesSwitch = true.obs;

  RxBool commentsSwitch = true.obs;
  RxBool newFollowerSwitch = true.obs;
  RxBool mentionSwitch = true.obs;
  RxBool followerVideoSwitch = true.obs;
  RxBool directMessageSwitch = true.obs;
  RxBool isLoading = true.obs;
  var isVideoDownloadble = true.obs;
  var isPostPublic = true.obs;
  @override
  void onInit() {
    super.onInit();
    getNotificationsSettings();
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

  Future<void> changeNotificationSettings(String type, int action) async {
    dio.post("/user/push-notification-settings",
        queryParameters: {"type": type, "action": action}).then((value) {
      if (value.data["status"] == true) {
        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });
  }

  Future<void> getNotificationsSettings() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    isLoading.value = true;
    dio.get("/user/push-notification-settings").then((value) {
      if (NotificationsSettingsModel.fromJson(value.data).status == true) {
        likesSwitch.value = int.parse(
                    NotificationsSettingsModel.fromJson(value.data)
                        .data!
                        .likes
                        .toString()) ==
                1
            ? true
            : false;
        commentsSwitch.value = int.parse(
                    NotificationsSettingsModel.fromJson(value.data)
                        .data!
                        .comments
                        .toString()) ==
                1
            ? true
            : false;
        newFollowerSwitch.value = int.parse(
                    NotificationsSettingsModel.fromJson(value.data)
                        .data!
                        .newFollowers
                        .toString()) ==
                1
            ? true
            : false;
        mentionSwitch.value = int.parse(
                    NotificationsSettingsModel.fromJson(value.data)
                        .data!
                        .mentions
                        .toString()) ==
                1
            ? true
            : false;
        followerVideoSwitch.value = int.parse(
                    NotificationsSettingsModel.fromJson(value.data)
                        .data!
                        .videoFromAccountsYouFollow
                        .toString()) ==
                1
            ? true
            : false;
        directMessageSwitch.value = int.parse(
                    NotificationsSettingsModel.fromJson(value.data)
                        .data!
                        .directMessages
                        .toString()) ==
                1
            ? true
            : false;
      } else {
        errorToast(
            NotificationsSettingsModel.fromJson(value.data).message.toString());
      }
      isLoading.value = false;
    }).onError((error, stackTrace) {
      errorToast(error.toString());
      isLoading.value = false;
    });
    isLoading.value = false;
  }
}

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/modules/profile/user_videos/controllers/user_videos_controller.dart';

import '../../../../rest/models/user_private_video_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../utils/utils.dart';

class UserPrivateVideosController extends GetxController
    with StateMixin<RxList<PrivateVideos>> {
  RxList<PrivateVideos> privateVideosList = RxList();
  var storage = GetStorage();
  var userProfile = User().obs;
  var nextPageUrl = "https://thrill.fun/api/video/private?page=1".obs;
  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  @override
  void onInit() {
    getUserPrivateVideos();
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

  getUserPrivateVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(privateVideosList, status: RxStatus.loading());
    dio.get('/video/private').then((value) {
      privateVideosList.value =
          UserPrivateVideosModel.fromJson(value.data).data!.obs;
      nextPageUrl.value =
          UserPrivateVideosModel.fromJson(value.data).pagination!.nextPageUrl ??
              "";
      change(privateVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(privateVideosList, status: RxStatus.error(error.toString()));
    });
  }

  Future<void> getPaginationAllVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    if (privateVideosList.isEmpty) {
      change(privateVideosList, status: RxStatus.loading());
    }
    dio.post(nextPageUrl.value, queryParameters: {
      "user_id": "${Get.arguments["profileId"]}"
    }).then((value) {
      nextPageUrl.value =
          UserPrivateVideosModel.fromJson(value.data).pagination!.nextPageUrl ??
              "";
      if (nextPageUrl.isNotEmpty) {
        UserPrivateVideosModel.fromJson(value.data).data!.forEach((element) {
          privateVideosList.add(element);
        });
        privateVideosList.refresh();
      }
      change(privateVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {});
  }

  Future<void> deleteUserVideo(int videoId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("video/delete", queryParameters: {"video_id": videoId}).then(
        (value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
        getUserPrivateVideos();
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  Future<void> makeVideoPrivateOrPublic(int videoId, String visibility) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("video/change-visibility", queryParameters: {
      "video_id": videoId,
      "visibility": visibility
    }).then((value) {
      if (value.data["status"]) {
        Get.find<UserVideosController>().getUserVideos();
        getUserPrivateVideos();
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}

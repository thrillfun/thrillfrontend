import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/rest/models/user_videos_model.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:thrill/app/utils/utils.dart';

import '../../user_private_videos/controllers/user_private_videos_controller.dart';

class UserVideosController extends GetxController
    with StateMixin<RxList<Videos>> {
  //TODO: Implement UserVideosController

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var userVideos = RxList<Videos>();

  var isInitialised = false.obs;

  @override
  void onInit() {
    getUserVideos();

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

  Future<void> getUserVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userVideos, status: RxStatus.loading());

 await   dio
        .post('/video/user-videos', queryParameters: {
          "user_id": "${await GetStorage().read("userId")}"
        })
        .then((response) {
          userVideos = UserVideosModel.fromJson(response.data).data!.obs;
          change(userVideos, status: RxStatus.success());
        })
        .onError((error, stackTrace) {
          change(userVideos, status: RxStatus.error());
        });
  }

  Future<void> deleteUserVideo(int videoId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("video/delete", queryParameters: {"video_id": videoId}).then(
        (value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
        getUserVideos();
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
        Get.find<UserPrivateVideosController>().getUserPrivateVideos();
        getUserVideos();
        // successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}

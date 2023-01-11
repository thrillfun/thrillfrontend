import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';
import 'package:video_player/video_player.dart';

import '../model/own_videos_model.dart';

class UserVideosController extends GetxController with StateMixin<RxList<Videos>> {
  var otherUserVideos = RxList<Videos>();
  var userVideos = RxList<Videos>();


  var storage = GetStorage();
  var userProfile = User().obs;

  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));


  @override
  void onInit() {
  }

  Future<void> getUserVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userVideos, status: RxStatus.loading());
    dio
        .post('/video/user-videos', queryParameters: {"user_id": "${await GetStorage().read("userId")}"})
        .timeout(const Duration(seconds: 10))
        .then((response) {
      userVideos.clear();
      userVideos = OwnVideosModel.fromJson(response.data).data!.obs;
      change(userVideos, status: RxStatus.success());
    })
        .onError((error, stackTrace) {
      change(userVideos, status: RxStatus.error());
    });
  }

  Future<void> getOtherUserVideos(int userId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(otherUserVideos, status: RxStatus.loading());
    dio
        .post('/video/user-videos', queryParameters: {"user_id": "$userId"})
        .timeout(const Duration(seconds: 10))
        .then((response) {
          otherUserVideos.clear();
          otherUserVideos = OwnVideosModel.fromJson(response.data).data!.obs;
          change(otherUserVideos, status: RxStatus.success());
        })
        .onError((error, stackTrace) {
          change(otherUserVideos, status: RxStatus.error());
        });
  }

  deleteVideo(int videoId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("/video/delete",
        queryParameters: {'video_id': videoId.toString()}).then((value) async {
      successToast(value.data["message"]);
      int id = await GetStorage().read("userId");
      getOtherUserVideos(id);
    }).onError((error, stackTrace) {
      change(otherUserVideos, status: RxStatus.error());
    });
  }
}

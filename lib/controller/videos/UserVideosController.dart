import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/rest/rest_url.dart';

import '../model/own_videos_model.dart';

class UserVideosController extends GetxController
    with StateMixin<RxList<Videos>> {
  var otherUserVideos = RxList<Videos>();

  var storage = GetStorage();
  var userProfile = User().obs;

  var dio = Dio(BaseOptions(
      baseUrl: RestUrl.baseUrl,
      ));

  Future<void> getOtherUserVideos(int userId) async {
        dio.options.headers = {"Authorization": "Bearer ${await GetStorage().read("token")}"};
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

    if (otherUserVideos.isEmpty) {
      change(otherUserVideos, status: RxStatus.empty());
    }
  }
}

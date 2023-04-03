import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../rest/models/user_videos_model.dart';
import '../../../../rest/rest_urls.dart';

class OtherUserVideosController extends GetxController with StateMixin<RxList<Videos>>  {
  //TODO: Implement OtherUserVideosController

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var userVideos = RxList<Videos>();
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
    dio
        .post('/video/user-videos', queryParameters: {"user_id": "${Get.arguments["profileId"]}"})
        .timeout(const Duration(seconds: 10))
        .then((response) {
      userVideos.clear();
      userVideos = UserVideosModel.fromJson(response.data).data!.obs;
      change(userVideos, status: RxStatus.success());
    })
        .onError((error, stackTrace) {
      change(userVideos, status: RxStatus.error());
    });
  }
}

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../rest/models/user_private_video_model.dart';
import '../../../../rest/rest_urls.dart';

class UserPrivateVideosController extends GetxController with StateMixin<RxList<PrivateVideos>> {
  RxList<PrivateVideos> privateVideosList = RxList();
  var storage = GetStorage();
  var userProfile = User().obs;

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
      change(privateVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(privateVideosList, status: RxStatus.error(error.toString()));
    });
  }
}

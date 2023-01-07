import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/private_videos_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/auth/login_getx.dart';

class PrivateVideosController extends GetxController
    with StateMixin<RxList<PrivateVideos>> {
  RxList<PrivateVideos> privateVideosList = RxList();
  var storage = GetStorage();
  var userProfile = User().obs;

  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  getUserPrivateVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(privateVideosList, status: RxStatus.loading());
    dio.get('/video/private').then((value) {
      privateVideosList.value =
          PrivateVideosModel.fromJson(value.data).data!.obs;
      change(privateVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(privateVideosList, status: RxStatus.error(error.toString()));
    });
  }
}

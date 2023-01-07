import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/liked_videos_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';

class LikedVideosController extends GetxController
    with StateMixin<RxList<LikedVideos>> {
  var storage = GetStorage();
  RxList<LikedVideos> othersLikedVideos = RxList<LikedVideos>();

  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  Future<void> getOthersLikedVideos(int userId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(othersLikedVideos, status: RxStatus.loading());
    dio.post('/user/user-liked-videos',
        queryParameters: {"user_id": "$userId"}).then((result) {
      othersLikedVideos.value = LikedVideosModel.fromJson(result.data).data!;
      change(othersLikedVideos, status: RxStatus.success());
    }).onError((error, stackTrace) {
      print(error);
      change(othersLikedVideos, status: RxStatus.error());
    });
  }
}

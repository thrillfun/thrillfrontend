import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/controller/model/liked_videos_model.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';

class LikedVideosController extends GetxController
    with StateMixin<Rx<LikedVideosModel>> {
  var storage = GetStorage();

  var likedVideosModel = LikedVideosModel().obs;
  RxList<LikedVideos> likedVideos = RxList<LikedVideos>();
  RxList<LikedVideos> othersLikedVideos = RxList<LikedVideos>();

  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  Future<void> getOthersLikedVideos(int userId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(likedVideosModel, status: RxStatus.loading());
    dio.post('/user/user-liked-videos',
        queryParameters: {"user_id": "$userId"}).then((result) {
      likedVideosModel = LikedVideosModel.fromJson(result.data).obs;
      othersLikedVideos.value = likedVideosModel.value.data!;
      change(likedVideosModel, status: RxStatus.success());
    }).onError((error, stackTrace) {
      print(error);
      change(likedVideosModel, status: RxStatus.error());
    });
  }

  Future<void> getUserLikedVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(likedVideosModel, status: RxStatus.loading());
    dio.post('/user/user-liked-videos',
        queryParameters: {"user_id": "${await GetStorage().read("userId")}"}).then((result) {
      likedVideosModel = LikedVideosModel.fromJson(result.data).obs;
      likedVideos.value = likedVideosModel.value.data!;
      change(likedVideosModel, status: RxStatus.success());
    }).onError((error, stackTrace) {
      print(error);
      change(likedVideosModel, status: RxStatus.error());
    });
  }
}

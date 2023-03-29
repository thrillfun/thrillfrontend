import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../rest/models/user_liked_videos_model.dart';
import '../../../../rest/rest_urls.dart';

class UserLikedVideosController extends GetxController with StateMixin<RxList<LikedVideos>> {
  RxList<LikedVideos> likedVideos = RxList<LikedVideos>();

  var dio = Dio(BaseOptions(
    baseUrl: RestUrl.baseUrl,
  ));

  @override
  void onInit() {
    getUserLikedVideos();
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

  Future<void> getUserLikedVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(likedVideos, status: RxStatus.loading());
    dio.post('/user/user-liked-videos',
        queryParameters: {"user_id": "${await GetStorage().read("userId")}"}).then((result) {
      likedVideos = UserLikedVideosModel.fromJson(result.data).data!.obs;
      change(likedVideos, status: RxStatus.success());
    }).onError((error, stackTrace) {
      print(error);
      change(likedVideos, status: RxStatus.error(error.toString()));
    });
  }}

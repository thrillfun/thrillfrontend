import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../rest/models/user_liked_videos_model.dart';
import '../../../../rest/rest_urls.dart';

class UserLikedVideosController extends GetxController
    with StateMixin<RxList<LikedVideos>> {
  RxList<LikedVideos> likedVideos = RxList<LikedVideos>();

  var nextPageUrl = "https://thrill.fun/api/user/user-liked-videos?page=1".obs;
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
    dio.post('/user/user-liked-videos', queryParameters: {
      "user_id": "${await GetStorage().read("userId")}"
    }).then((result) {
      likedVideos = UserLikedVideosModel.fromJson(result.data).data!.obs;
      change(likedVideos, status: RxStatus.success());
      nextPageUrl.value =
          UserLikedVideosModel.fromJson(result.data).pagination!.nextPageUrl ??
              "";
    }).onError((error, stackTrace) {
      print(error);
      change(likedVideos, status: RxStatus.error(error.toString()));
    });
  }

  Future<void> refereshVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(likedVideos, status: RxStatus.loading());
    dio.post('/user/user-liked-videos', queryParameters: {
      "user_id": "${await GetStorage().read("userId")}"
    }).then((result) {
      likedVideos = UserLikedVideosModel.fromJson(result.data).data!.obs;

      change(likedVideos, status: RxStatus.success());

      nextPageUrl.value =
          UserLikedVideosModel.fromJson(result.data).pagination!.nextPageUrl ??
              "";
    }).onError((error, stackTrace) {
      print(error);
      change(likedVideos, status: RxStatus.error(error.toString()));
    });
  }

  Future<void> getPaginationAllVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    if (likedVideos.isEmpty) {
      change(likedVideos, status: RxStatus.loading());
    }
    dio.post(nextPageUrl.value, queryParameters: {
      "user_id": "${await GetStorage().read("userId")}"
    }).then((value) {
      if (nextPageUrl.isNotEmpty) {
        UserLikedVideosModel.fromJson(value.data).data!.forEach((element) {
          likedVideos.add(element);
        });
        likedVideos.refresh();
      }
      nextPageUrl.value =
          UserLikedVideosModel.fromJson(value.data).pagination!.nextPageUrl ??
              "";
      change(likedVideos, status: RxStatus.success());
    }).onError((error, stackTrace) {});
  }
}

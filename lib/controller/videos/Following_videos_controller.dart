import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/rest/rest_url.dart';

import '../model/following_video_model.dart';

class FollowingVideosController extends GetxController
    with StateMixin<RxList<FollowingVideos>> {
  RxList<FollowingVideos> followingVideosList = RxList();

  var dio = Dio(BaseOptions(
      baseUrl: RestUrl.baseUrl,
      responseType: ResponseType.json));

  FollowingVideosController() {
    getFollowingVideos();
  }

getFollowingVideos() async {
      dio.options.headers = {"Authorization": "Bearer ${await GetStorage().read("token")}"};
    change(followingVideosList, status: RxStatus.loading());
    dio.get("/video/following").then((response) {
      followingVideosList =
          FollowingVideoModel.fromJson(response.data).data!.obs;
      change(followingVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(followingVideosList, status: RxStatus.error(error.toString()));
      change(followingVideosList, status: RxStatus.empty());
    });
    if (followingVideosList.isEmpty) {change(followingVideosList, status: RxStatus.empty());}
  }
}

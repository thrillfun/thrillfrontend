import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

import '../model/following_video_model.dart';
import '../model/public_videosModel.dart';

class FollowingVideosController extends GetxController
    with StateMixin<RxList<PublicVideos>> {

  var dio = Dio(
      BaseOptions(baseUrl: RestUrl.baseUrl, responseType: ResponseType.json));
  var isLoading = false.obs;
  RxList<PublicVideos> followingVideosList = RxList();

  FollowingVideosController() {
    getFollowingVideos();
  }

  getFollowingVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.get("/video/following").then((response) {
      followingVideosList.value =
            PublicVideosModel.fromJson(response.data).data!.obs;
    }).onError((error, stackTrace) {
      print(error.toString());
      isLoading.value = false;
    });
    isLoading.value = false;
  }
  
}

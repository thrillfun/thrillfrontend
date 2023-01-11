import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/videos/Following_videos_controller.dart';
import 'package:thrill/rest/rest_url.dart';

import 'Following_videos_controller.dart';

class RelatedVideosController extends GetxController
    with StateMixin<RxList<PublicVideos>> {
  RxList<PublicVideos> publicVideosList = RxList();
    RxList<PublicVideos> followingVideosList = RxList();
  var isLoading = false.obs;
  var isRelatedLoading = false.obs;

  var dio = Dio(
      BaseOptions(baseUrl: RestUrl.baseUrl, responseType: ResponseType.json));
  var followingVideosController = Get.find<FollowingVideosController>();
  var userDetailsController = Get.find<UserDetailsController>();

  RelatedVideosController() {
    getAllVideos();
  }
  Future<void> getAllVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    //change(publicVideosList, status: RxStatus.loading());

    dio.get("/video/list").then((value) {
      if (publicVideosList.isEmpty) {
        isLoading.value = true;
        publicVideosList = PublicVideosModel.fromJson(value.data).data!.obs;
      } else {
        publicVideosList.value =
            PublicVideosModel.fromJson(value.data).data!.obs;
      }
      getFollowingVideos();

      //  change(publicVideosList, status: RxStatus.success());
      isLoading.value = false;
    }).onError((error, stackTrace) {
      isLoading.value = false;
      //   change(publicVideosList, status: RxStatus.error());
    });
    isLoading.value = false;
  }

  getFollowingVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.get("/video/following").then((response) {
      if (followingVideosList.isEmpty) {
        isRelatedLoading.value = true;
        followingVideosList =
            PublicVideosModel.fromJson(response.data).data!.obs;
      } else {
        followingVideosList.value =
            PublicVideosModel.fromJson(response.data).data!.obs;
      }
    }).onError((error, stackTrace) {
      isRelatedLoading.value = false;
    });
    isRelatedLoading.value = false;
  }

  Future<bool> likeVideo(int isLike, int videoId) async {
    var isLiked = false;
    dio.options.headers = {
      "Authorization":
          "Bearer ${await userDetailsController.storage.read("token")}"
    };
    dio.post('${RestUrl.baseUrl}/video/like', queryParameters: {
      "video_id": "$videoId",
      "is_like": "$isLike"
    }).then((value) async {
      await getAllVideos();
      getFollowingVideos();
    }).onError((error, stackTrace) {});

    if (isLike == 0) {
      isLiked = false;
    } else {
      isLiked = true;
    }

    return isLiked;
  }
}

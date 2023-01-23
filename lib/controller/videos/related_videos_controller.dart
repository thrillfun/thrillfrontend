import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:file_support/file_support.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/videos/Following_videos_controller.dart';
import 'package:thrill/rest/rest_url.dart';

import '../../utils/util.dart';

class RelatedVideosController extends GetxController
    with StateMixin<RxList<PublicVideos>> {
  RxList<PublicVideos> publicVideosList = RxList();
  RxList<PublicVideos> followingVideosList = RxList();
  var isLoading = false.obs;
  var isRelatedLoading = false.obs;
  var fileSupport = FileSupport();
  var downloadFilePath = "".obs;

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

  downloadAndProcessVideo(String videoUrl, String videoName) async {
    Get.defaultDialog(title: "Loading", content: loader());
    var path = await getTemporaryDirectory();
    await fileSupport
        .downloadCustomLocation(
      url: "https://thrillvideonew.s3.ap-south-1.amazonaws.com/test/$videoUrl",
      path: path.path,
      filename:"/$videoName",
      extension: ".mp4",
      progress: (progress) async {
      Logger().i(progress);
      },
    ).then((video) async {
      await fileSupport
          .downloadCustomLocation(
              url:
              "https://thrillvideonew.s3.ap-south-1.amazonaws.com/assets/logo.png",
              filename: '/logo',
              extension: ".png",
              progress: (progress)=>Logger().w(progress),
              path: path.path)
          .then((logo) async {
            Logger().wtf(logo!.path);
        FFmpegKit.execute(
            "-y -i ${video!.path}.mp4 -i ${logo!.path}.png -filter_complex overlay=10:10 -codec:a copy ${path.path}/output/video.mp4")
            .then((session) async {
          var logs = await session.getReturnCode();
          if (logs!.isValueSuccess()) {
            successToast("Video Downloaded successfully!");
          } else if (logs.isValueError()) {
            Logger().wtf(logs.getValue());
          }
        }).onError((error, stackTrace) => errorToast(error.toString()));
      });
    }).onError((error, stackTrace) {
      errorToast(error.toString());
      Get.back();

    });
    Get.back();
  }
}

import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/notifications/notifications_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

import '../model/following_video_model.dart';
import '../model/public_videosModel.dart';
import '../users/user_details_controller.dart';
import 'package:file_support/file_support.dart';

class FollowingVideosController extends GetxController
    with StateMixin<RxList<PublicVideos>> {
  var betterPlayercontroller = BetterPlayerListVideoPlayerController();
  var pageViewController = PageController(keepPage: false);
  var dio = Dio(
      BaseOptions(baseUrl: RestUrl.baseUrl, responseType: ResponseType.json));
  var isLoading = false.obs;
  RxList<PublicVideos> followingVideosList = RxList();
  BetterPlayerEvent? eventType;
  var userDetailsController = Get.find<UserDetailsController>();
  var notificationsController = Get.find<NotificationsController>();
  var fileSupport = FileSupport();

  FollowingVideosController() {
    getFollowingVideos();
  }

  getFollowingVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    dio.get("/video/following").then((response) {
      if(followingVideosList.isEmpty){
        change(followingVideosList,status: RxStatus.loading());

        followingVideosList =
            PublicVideosModel.fromJson(response.data).data!.obs;
      }
      else{
        followingVideosList.value =
            PublicVideosModel.fromJson(response.data).data!.obs;
      }
      change(followingVideosList,status: RxStatus.success());

    }).onError((error, stackTrace) {
      print(error.toString());
      isLoading.value = false;
      change(followingVideosList,status: RxStatus.error(error.toString()));

    });
    isLoading.value = false;
  }

  Future<bool> likeVideo(int isLike, int videoId,
      {int userId = 0, String? token}) async {
    var isLiked = false;
    dio.options.headers = {
      "Authorization":
      "Bearer ${await userDetailsController.storage.read("token")}"
    };
    dio.post('${RestUrl.baseUrl}/video/like', queryParameters: {
      "video_id": "$videoId",
      "is_like": "$isLike"
    }).then((value) async {
      await getFollowingVideos();
      getFollowingVideos();
      if (isLike == 1) {
        await notificationsController.sendFcmNotification(token.toString(),
            title:
            "${await GetStorage().read("user")["username"]} liked you video",
            body: "Enjoy",
            image: RestUrl.profileUrl +
                await GetStorage().read("user")["avatar"].toString());
        // await notificationsController.sendChatNotifcations(userId,
        //     "${await GetStorage().read("user")["username"]} liked your video!");
      }
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
    final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES);
    if (await Directory('$directory/thrill/downloads').exists() == true) {
      print('Yes this directory Exists');
    } else {
      print('creating new Directory');
      await Directory('$directory/thrill/downloads').create();
    }
    var path = await Directory('$directory/thrill/downloads');
    var dir = await getApplicationSupportDirectory();

    await fileSupport
        .downloadCustomLocation(
      url: "https://thrillvideonew.s3.ap-south-1.amazonaws.com/test/$videoUrl",
      path: dir.path,
      filename: "/$videoName",
      extension: ".mp4",
      progress: (progress) async {
        Logger().i(progress);
      },
    )
        .then((video) async {
      await fileSupport
          .downloadCustomLocation(
          url:
          "https://thrillvideonew.s3.ap-south-1.amazonaws.com/assets/logo.png",
          filename: '/logo',
          extension: ".png",
          progress: (progress) => Logger().w(progress),
          path: path.path)
          .then((logo) async {
        await FFmpegKit.execute(
            "-y -i ${video!.path} -i ${logo!.path} -filter_complex overlay=10:10 -codec:a copy ${path.path}/$videoName.mp4")
            .then((session) async {
          var logs = await session.getReturnCode();
          Logger().wtf(dir.path);
          if (logs!.isValueSuccess()) {
            Get.back();
            successToast("Video Downloaded successfully!");
          } else if (logs.isValueError()) {
            Logger().wtf(logs.getValue());
            Get.back();
          }
        }).onError((error, stackTrace) => errorToast(error.toString()));
      });
    }).onError((error, stackTrace) {
      errorToast(error.toString());
      Get.back();
    });
  }

  Future<void> reportVideo(int VideoId, int reportedId, String reason) async {
    dio.options.headers = {
      "Authorization":
      "Bearer ${await userDetailsController.storage.read("token")}"
    };

    dio.post("/video/report", queryParameters: {
      "video_id": "$videoId",
      "reported_by": "$reportedId",
      "reason": reason
    }).then((value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }
}

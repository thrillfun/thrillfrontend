import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:file_support/file_support.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:thrill/app/rest/models/related_videos_model.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:thrill/app/utils/strings.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../rest/models/following_videos_model.dart';
import '../../../rest/models/site_settings_model.dart';
class TrendingVideosController extends GetxController {

  late VideoPlayerController videoPlayerController;

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  RxList<FollowingVideos> followingVideosList = RxList();
  RxList<SiteSettings> siteSettingsList = RxList();

  var isUserBlocked = false.obs;
  var isLoading = false.obs;
  var isVideoReported = false.obs;

  var isInitialised = false.obs;
  var fileSupport = FileSupport();
  @override
  void onInit() {
    getAllVideos();

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
  Future<void> getAllVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    //change(publicVideosList, status: RxStatus.loading());

    dio.get("video/top").then((value) {
      if (followingVideosList.isEmpty) {
        // change(relatedVideosList, status: RxStatus.loading());

        isLoading.value = true;
        followingVideosList = FollowingVideosModel.fromJson(value.data).data!.obs;

        // change(relatedVideosList, status: RxStatus.success());
      } else {
        followingVideosList.value =
            FollowingVideosModel.fromJson(value.data).data!.obs;

        // change(publicVideosList, status: RxStatus.success());
      }

      //  change(publicVideosList, status: RxStatus.success());
      isLoading.value = false;
    }).onError((error, stackTrace) {
      isLoading.value = false;
      //   change(publicVideosList, status: RxStatus.error());
    });
    isLoading.value = false;
  }

  Future<void> postVideoView(int videoId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("video/view", queryParameters: {"video_id": videoId}).then(
            (value) {
          if (value.data["status"]) {
            Logger().wtf("View posted successfully");
          }
        }).onError((error, stackTrace) {});
  }

  Future<bool> likeVideo(int isLike, int videoId,
      {int userId = 0, String? token}) async {
    var isLiked = false;
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post('video/like', queryParameters: {
      "video_id": "$videoId",
      "is_like": "$isLike"
    }).then((value) async {
      getAllVideos();
      if (isLike == 1) {
        sendNotification(token.toString(), title: "Someone liked your video!");
      }
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });

    if (isLike == 0) {
      isLiked = false;
    } else {
      isLiked = true;
    }

    return isLiked;
  }

  Future<void> followUnfollowUser(int userId, String action,
      {String? searchQuery}) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-unfollow-user", queryParameters: {
      "publisher_user_id": userId,
      "action": "$action"
    }).then((value) {
      if (value.data["status"]) {
        getAllVideos();
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }

  checkUserBlocked(int userId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    await dio.post("user/is-user-blocked",
        queryParameters: {"blocked_user": userId}).then((value) {
      isUserBlocked.value = value.data["status"];
      getAllVideos();
    }).onError((error, stackTrace) => errorToast(error.toString()));
    return isUserBlocked.value;
  }

  blockUnblockUser(int userId, bool isBlocked) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    await dio.post("user/block-unblock-user", queryParameters: {
      "blocked_user": userId,
      "action": isBlocked ? "Unblock" : "Block"
    }).then((value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });
  }

  Future<void> deleteUserVideo(int videoId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("video/delete", queryParameters: {"video_id": videoId}).then(
            (value) {
          if (value.data["status"]) {
            successToast(value.data["message"]);
            getAllVideos();
          } else {
            errorToast(value.data["message"]);
          }
        }).onError((error, stackTrace) {
      errorToast(error.toString());
    });
  }

  downloadAndProcessVideo(String videoUrl, String videoName) async {
    Get.defaultDialog(title: "Loading", content: loader());
    final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES);
    if (await Directory('$directory/thrill/').exists() == false) {
      await Directory('$directory/thrill/').create();
    }

    var path = Directory('$directory/thrill/');
    var dir = await getApplicationSupportDirectory();

    await fileSupport
        .downloadCustomLocation(
      url: RestUrl.videoDownloadUrl + videoUrl,
      path: path.path,
      filename: videoName,
      extension: ".mp4",
      progress: (progress) async {
        Logger().i(progress);
      },
    )
        .then((video) async {
      successToast("video downloaded successfully");
      Get.back();

      // await FFmpegKit.execute(
      //     "-y -i ${video!.path} -i ${logo!.path} -filter_complex overlay=10:10 -codec:a copy ${path.path}$videoName.mp4")
      //     .then((session) async {
      //   var logs = await session.getReturnCode();
      //   Logger().wtf(path.path);
      //   if (logs!.isValueSuccess()) {
      //     Get.back();
      //   } else if (logs.isValueError()) {
      //     Logger().wtf(logs.getValue());
      //     Get.back();
      //   }
      // }).onError((error, stackTrace) => errorToast(error.toString()));
    }).onError((error, stackTrace) {
      errorToast(error.toString());
      Get.back();
    });
  }

  Future<void> reportVideo(int videoId, int reportedId, String reason) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
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

  Future<void> getSiteSettings() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    await dio.post("SiteSettings").then((value) {
      siteSettingsList.value = SiteSettingsModel.fromJson(value.data).data!;
    }).onError((error, stackTrace) => errorToast(error.toString()));
  }

  Future<bool> checkIfVideoReported(int videoId, int userId) async {
    dio.post("video/is-video-report", queryParameters: {
      "video_id": videoId,
      "reported_by": userId,
      "reason": "nothing"
    }).then((value) {
      isVideoReported.value = value.data["status"];
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });

    return isVideoReported.value;
  }

  Future<void> favUnfavVideo(int videoId, String action) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("video/do-fav-unfav", queryParameters: {
      "video_id": "$videoId",
      "action": action
    }).then((value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }

  Future<String> createDynamicLink(
      String id, String? type, String? name, String? avatar,
      {String? referal}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.page.link/',
      link: Uri.parse(
          "https://thrill.fun?type=$type&id=$id&name=$name&something=$avatar&referal=$referal"),
      androidParameters: const AndroidParameters(
        packageName: 'com.thrill.media',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',x
      //   appStoreId: 'your_app_store_id',
      // ),
    );
    final dynamicLink =
    await FirebaseDynamicLinks.instance.buildLink(parameters);

    return dynamicLink.toString();
  }

  Future<void> sendNotification(String fcmToken,
      {String? body = "", String? title = "", String? image = ""}) async {
    var dio = Dio(BaseOptions(baseUrl: "https://fcm.googleapis.com/fcm"));
    dio.options.headers = {
      "Authorization":
      "key= AAAAzWymZ2o:APA91bGABMolgt7oiBiFeTU7aCEj_hL-HSLlwiCxNGaxkRl385anrsMMNLjuuqmYnV7atq8vZ5LCNBPt3lPNA1-0ZDKuCJHezvoRBpL9VGvixJ-HHqPScZlwhjeQJPhbsiLDSTtZK-MN"
    };
    final data = {
      "to": fcmToken,
      "notification": {"body": body, "title": title, "image": image},
      "priority": "high",
      "image": image,
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "image":
        "https://scontent.fbom19-2.fna.fbcdn.net/v/t39.30808-6/271720827_4979339162088555_3028905257532289818_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=HMgk-tDtBcQAX9uJheY&_nc_ht=scontent.fbom19-2.fna&oh=00_AfCVE7nSsxVGPTfTa8FCyff4jOzTKWi_JvTXpDWm7WrVjg&oe=63E84FB2"
      }
    };
    dio.post("/send", data: jsonEncode(data)).then((value) {
      Logger().wtf(value);
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}

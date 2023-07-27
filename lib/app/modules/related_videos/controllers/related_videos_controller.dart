import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:file_support/file_support.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thrill/app/rest/models/related_videos_model.dart';
import 'package:thrill/app/rest/rest_urls.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:video_player/video_player.dart';

import '../../../rest/models/site_settings_model.dart';

class RelatedVideosController extends GetxController
    with StateMixin<RxList<RelatedVideos>> {
  late VideoPlayerController videoPlayerController;

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  RxList<RelatedVideos> relatedVideosList = RxList();
  RxList<SiteSettings> siteSettingsList = RxList();

  var isUserBlocked = false.obs;
  var isLoading = false.obs;
  var isVideoReported = false.obs;

  var isInitialised = false.obs;
  var fileSupport = FileSupport();

  var currentPage = 10.obs;
  var nextPage = 2.obs;
  var nextPageUrl = "https://thrill.fun/api/video/list?page=2".obs;
  var isLikeEnable = true.obs;
  var isLiked = false.obs;
  var totalLikes =0.obs;
  @override
  void onInit() {
    super.onInit();
    getAllVideos(true);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> notInterested(int videoId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("video/change_interest", queryParameters: {
      "content_id": videoId,
      "filter_by": "tag"
    }).then((value) {
      value.data["status"]
          ? successToast(value.data["message"])
          : errorToast(value.data["message"]);
      refereshVideos();
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  Future<void> getAllVideos(bool isRefresh) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    if (relatedVideosList.isEmpty) {
      change(relatedVideosList, status: RxStatus.loading());
    }
    dio.get("video/list").then((value) {
      relatedVideosList.value =
          RelatedVideosModel.fromJson(value.data).data!.obs;

      change(relatedVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(relatedVideosList, status: RxStatus.error(error.toString()));
    });
  }

  Future<void> getPaginationAllVideos(int page) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    dio.get(nextPageUrl.value).then((value) {
      if (nextPageUrl.isNotEmpty) {
        relatedVideosList.addAll(RelatedVideosModel.fromJson(value.data).data!);
      }
      relatedVideosList.refresh();
      nextPageUrl.value =
          RelatedVideosModel.fromJson(value.data).pagination!.nextPageUrl ?? "";
      change(relatedVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  Future<void> refereshVideos() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(relatedVideosList, status: RxStatus.loading());

    await dio.get("video/list").then((value) {
      relatedVideosList.value =
          RelatedVideosModel.fromJson(value.data).data!.obs;

      change(relatedVideosList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(relatedVideosList, status: RxStatus.error());
    });
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
      {int userId = 0, String? token, String userName = ""}) async {
    isLikeEnable.value = false;

    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post('video/like', queryParameters: {
      "video_id": "$videoId",
      "is_like": "$isLike"
    }).then((value) async {
      // getAllVideos(false);
      totalLikes.value = value.data["data"]["likes"]??0;

      if ((value.data["data"]["is_like"]??0) == "0") {
        isLiked.value = false;
      } else {
        isLiked.value = true;
      }

      if (isLike == 1) {
        sendNotification(token.toString(),
            title: "New Likes!",
            body: "${GetStorage().read("userName")} liked your video");
      }
    }).onError((error, stackTrace) {});
    isLikeEnable.value = true;

    return isLiked.value;
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
        getAllVideos(false);
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
      // getAllVideos(false);
    }).onError((error, stackTrace) {});
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
    }).onError((error, stackTrace) {});
  }

  Future<void> deleteUserVideo(int videoId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("video/delete", queryParameters: {"video_id": videoId}).then(
        (value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
        getAllVideos(true);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }

  downloadAndProcessVideo(String videoUrl, String videoName) async {
    var videoProgress = "0".obs;
    Get.defaultDialog(
        title: "Download video....",
        content: Container(
          child: Obx(() => Text(videoProgress.value)),
        ));
    final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_MOVIES);
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
        videoProgress.value = progress;
      },
    )
        .then((video) async {
      if (Get.isDialogOpen!) {
        Get.back();
      }
      successToast("video downloaded successfully");

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
    }).onError((error, stackTrace) {});
  }

  Future<bool> checkIfVideoReported(int videoId, int userId) async {
    dio.post("video/is-video-report", queryParameters: {
      "video_id": videoId,
      "reported_by": userId,
      "reason": "nothing"
    }).then((value) {
      isVideoReported.value = value.data["status"];
    }).onError((error, stackTrace) {});

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
        "url": image,
        "body": body,
        "title": title,
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "image": image
      }
    };
    dio.post("/send", data: jsonEncode(data)).then((value) {
      Logger().wtf(value);
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}

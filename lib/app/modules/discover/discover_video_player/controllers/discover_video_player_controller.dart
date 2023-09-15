import 'dart:convert';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:file_support/file_support.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thrill/app/modules/bindings/AdsController.dart';

import '../../../../rest/models/hash_tag_details_model.dart';
import '../../../../rest/models/site_settings_model.dart';
import '../../../../rest/rest_urls.dart';
import '../../../../utils/utils.dart';
import '../../../comments/controllers/comments_controller.dart';

class DiscoverVideoPlayerController extends GetxController
    with StateMixin<RxList<HashtagRelatedVideos>> {
  BetterPlayerEventType? eventType;
  var isUserBlocked = false.obs;
  var isLoading = false.obs;
  var isVideoReported = false.obs;
  RxList<HashtagRelatedVideos> hashTagsDetailsList = RxList();
  var isVideoFavourite = false.obs;

  var isFavouriteHastag = false.obs;
  var isInitialised = false.obs;
  var fileSupport = FileSupport();
  RxList<SiteSettings> siteSettingsList = RxList();
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var nextPageUrl =
      "https://thrill.fun/api/hashtag/get-videos-by-hashtag?page=2".obs;
  final String _nativeAdUnitId = 'ca-app-pub-3566466065033894/6507076010';
  NativeAd? nativeAd;
  var nativeAdIsLoaded = false.obs;
  var isLikeEnable = true.obs;
  var isLiked = false.obs;
  var totalLikes = 0.obs;

  var isUserFollowed = false.obs;
  var commentsController = Get.find<CommentsController>();
  var currentDuration = Duration().obs;
  var adsController = Get.find<AdsController>();
  @override
  void onInit() {
    refereshVideos();
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

  Future<void> getVideoFavStatus(int videoId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    await dio.post("video/fav_status_by_Videoid",
        queryParameters: {"video_id": videoId}).then((value) {
      isVideoFavourite.value = value.data["data"]["is_fav"] == 0 ? false : true;
    }).onError((error, stackTrace) {
      Logger().e(error);
    });
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
      getVideoFavStatus(videoId);
    }).onError((error, stackTrace) {});
  }

  /// Loads a native ad.
  Future<void> getVideosByHashTags() async {
    change(hashTagsDetailsList, status: RxStatus.loading());

    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";

    dio.post("hashtag/get-videos-by-hashtag", queryParameters: {
      "hashtag_id": "${Get.arguments["hashtagId"]}"
    }).then((value) {
      hashTagsDetailsList = HashtagDetailsModel.fromJson(value.data).data!.obs;
      isFavouriteHastag.value =
          hashTagsDetailsList[0].is_favorite_hasttag == 0 ? false : true;

      if (adsController.adFailedToLoad.isTrue) {
        hashTagsDetailsList.removeWhere((element) => element.id == null);
        hashTagsDetailsList.refresh();
      }
      commentsController.getComments(hashTagsDetailsList[0].id ?? 0);
      videoLikeStatus(hashTagsDetailsList[0].id ?? 0);
      followUnfollowStatus(hashTagsDetailsList[0].user!.id!);
      change(hashTagsDetailsList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(hashTagsDetailsList, status: RxStatus.error());
    });
  }

  Future<void> getPaginationVideosByHashTags() async {
    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";

    isLoading.value = true;
    dio.post(nextPageUrl.value, queryParameters: {
      "hashtag_id": "${Get.arguments["hashtagId"]}"
    }).then((value) {
      nextPageUrl.value =
          HashtagDetailsModel.fromJson(value.data).pagination!.nextPageUrl ??
              "";

      hashTagsDetailsList
          .addAll(HashtagDetailsModel.fromJson(value.data).data!);
      isLoading.value = false;

      if (adsController.adFailedToLoad.isTrue) {
        hashTagsDetailsList.removeWhere((element) => element.id == null);
        hashTagsDetailsList.refresh();
      }

      commentsController.getComments(hashTagsDetailsList[0].id ?? 0);
      videoLikeStatus(hashTagsDetailsList[0].id ?? 0);
      followUnfollowStatus(hashTagsDetailsList[0].user!.id!);
      isFavouriteHastag.value =
          hashTagsDetailsList[0].is_favorite_hasttag == 0 ? false : true;
      change(hashTagsDetailsList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      isLoading.value = false;
    });
  }

  Future<void> refereshVideos() async {
    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";
    change(hashTagsDetailsList, status: RxStatus.loading());

    dio.post("hashtag/get-videos-by-hashtag", queryParameters: {
      "hashtag_id": "${Get.arguments["hashtagId"]}"
    }).then((value) {
      hashTagsDetailsList = HashtagDetailsModel.fromJson(value.data).data!.obs;
      isFavouriteHastag.value =
          hashTagsDetailsList[0].is_favorite_hasttag == 0 ? false : true;
      commentsController.getComments(hashTagsDetailsList[0].id ?? 0);
      videoLikeStatus(hashTagsDetailsList[0].id ?? 0);
      followUnfollowStatus(hashTagsDetailsList[0].user!.id!);
      change(hashTagsDetailsList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(hashTagsDetailsList, status: RxStatus.error());
    });
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

  Future<void> likeVideo(int isLike, int videoId,
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
      videoLikeStatus(videoId);
      if (isLike == 1) {
        showLikeDialog();

        sendNotification(token.toString(),
            title: "New Likes!",
            body: "${GetStorage().read("username")} liked your video");
      }
    }).onError((error, stackTrace) {});
  }

  Future<void> videoLikeStatus(
    int videoId,
  ) async {
    isLikeEnable.value = false;

    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post('video/like-by-id', queryParameters: {
      "video_id": "$videoId",
    }).then((value) async {
      if ((value.data["data"]["is_like"] ?? 0) == 0) {
        isLiked.value = false;
      } else {
        isLiked.value = true;
      }
      // getAllVideos(false);
      totalLikes.value = value.data["data"]["likes"] ?? 0;
    }).onError((error, stackTrace) {
      Logger().e(error);
    });
  }

  Future<void> followUnfollowStatus(int userId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("user/follow-by-userid",
        queryParameters: {"user_id": userId}).then((value) {
      if (value.data["data"]["is_follow"] == 0) {
        isUserFollowed.value = false;
      } else {
        isUserFollowed.value = true;
      }
    }).onError((error, stackTrace) {
      Logger().e(error);
    });
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
      followUnfollowStatus(userId);
    }).onError((error, stackTrace) {});
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
        // getAllVideos();
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

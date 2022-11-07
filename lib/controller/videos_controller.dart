import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:simple_s3/simple_s3.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/model/delete_video_response.dart';
import 'package:thrill/controller/model/liked_videos_model.dart';
import 'package:thrill/controller/model/own_videos_model.dart';
import 'package:thrill/controller/model/private_videos_model.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/model/user_details_model.dart' as user;
import 'package:thrill/controller/model/video_fields_model.dart' as videoFields;
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/models/videos_post_response.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/utils/util.dart';
import 'package:velocity_x/velocity_x.dart';

class VideosController extends GetxController {
  RxBool on = false.obs; // our observable
  var token = GetStorage().read('token');
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var simpleS3 = SimpleS3();
  GetSnackBar? snackBar;

  // swap true/false & save it to observable

  var usersController = Get.find<UserController>();

  var isLoading = false.obs;
  var isLikedVideosLoading = true.obs;
  var isUserVideosLoading = false.obs;
  var videosLoading = false.obs;
  var isFollowingLoading = false.obs;
  var isError = false.obs;

  RxList<Videos> userVideosList = RxList();
  RxList<PrivateVideos> privateVideosList = RxList();
  RxList<PublicVideos> publicVideosList = RxList();
  RxList<PublicVideos> followingVideosList = RxList();
  var languageList = RxList<videoFields.Languages>();
  var categoriesList = RxList<videoFields.Categories>();
  var hashTagList = RxList<videoFields.Hashtags>();

  var otherUserVideos = RxList<Videos>();
  var likedVideos = RxList<LikedVideos>();
  var othersLikedVideos = RxList<LikedVideos>();

  VideosController() {
    try {
      getAllVideos();
    } catch (e) {
      print(e);
    }
    snackBar = GetSnackBar(
      duration: null,
      barBlur: 10,
      borderColor: ColorManager.colorPrimaryLight,
      borderWidth: 1.5,
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      borderRadius: 10,
      backgroundColor: Colors.green.shade50,
      messageText: StreamBuilder<dynamic>(
          stream: simpleS3.getUploadPercentage,
          builder: (context, snapshot) {
            return snapshot.data != null
                ? Text(snapshot.data)
                : const LinearProgressIndicator(
                    value: 0,
                  );
          }),
      isDismissible: false,
      mainButton: IconButton(
        onPressed: () {
          Get.back();
        },
        icon: const Icon(Icons.close),
      ),
      icon: const Icon(
        Icons.error,
        color: Colors.green,
      ),
    );

  }

  void toggle() => on.value = on.value ? false : true;

  RxList<int> adIndexes = [
    10,
    20,
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100,
    110,
    120,
    130,
    140,
    150,
    160,
    170,
    180,
    190,
    200,
    210,
    220,
    230,
    240,
    250,
    260,
    270,
    280,
    290,
    300
  ].obs;

  Future<void> getAllVideos() async {
    isLoading.value = true;
    dio.options.headers['Authorization'] = token;
    var response =
        await dio.get("/video/list").timeout(const Duration(seconds: 60));

    print(response.data);
    try {
      publicVideosList = PublicVideosModel.fromJson(response.data).data!.obs;
    } catch (e) {
      errorToast(PublicVideosModel.fromJson(json.decode(response.data))
          .message
          .toString());
    }
    publicVideosList.refresh();
    isLoading.value = false;
    update();
  }

  getFollowingVideos() async {
    isFollowingLoading.value = true;

    if (token.isEmpty) {
      errorToast("Please Login to get your followings");
    } else {
      var response = await http.get(
        Uri.parse('${RestUrl.baseUrl}/video/following'),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 60));

      try {
        followingVideosList =
            PublicVideosModel.fromJson(json.decode(response.body)).data!.obs;
      } on HttpException catch (e) {
        errorToast(PublicVideosModel.fromJson(json.decode(response.body))
            .message
            .toString());
      } on Exception catch (e) {
        print(e);
      }
    }

    isFollowingLoading.value = false;
    followingVideosList.refresh();
    update();
  }

  getUserVideos() async {
    isUserVideosLoading.value = true;
    if (token == null) {
    } else {
      var id = user.User.fromJson(GetStorage().read("user")).id;
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/video/user-videos'),
          headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
          body: {"user_id": "$id"}).timeout(const Duration(seconds: 60));

      try {
        userVideosList =
            OwnVideosModel.fromJson(json.decode(response.body)).data!.obs;
      } catch (e) {
        errorToast(OwnVideosModel.fromJson(json.decode(response.body))
            .message
            .toString());
      }
    }

    isUserVideosLoading.value = false;
    update();
  }

  getUserPrivateVideos() async {
    isUserVideosLoading.value = true;
    var id = user.User.fromJson(GetStorage().read("user")).id;

    var response = await http.get(
      Uri.parse('${RestUrl.baseUrl}/video/private'),
      headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
    ).timeout(const Duration(seconds: 60));

    try {
      privateVideosList =
          PrivateVideosModel.fromJson(json.decode(response.body)).data!.obs;
    } catch (e) {
      errorToast(PrivateVideosModel.fromJson(json.decode(response.body))
          .message
          .toString());
    }

    isUserVideosLoading.value = false;
    update();
  }

  getOtherUserVideos(int userId) async {
    videosLoading.value = true;
    otherUserVideos.clear();
    if (token != null) {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/video/user-videos'),
          headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
          body: {"user_id": "$userId"}).timeout(const Duration(seconds: 60));
      try {
        otherUserVideos =
            OwnVideosModel.fromJson(json.decode(response.body)).data!.obs;
      } on Exception catch (e) {
        errorToast(OwnVideosModel.fromJson(json.decode(response.body))
            .message
            .toString());
      }
    }
    videosLoading.value = false;
    update();
  }

  getUserLikedVideos() async {
    isLikedVideosLoading.value = true;
    var id = user.User.fromJson(GetStorage().read("user")).id;
    if (token != null) {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/user/user-liked-videos'),
          headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
          body: {"user_id": "$id"}).timeout(const Duration(seconds: 60));

      try {
        likedVideos =
            LikedVideosModel.fromJson(json.decode(response.body)).data!.obs;
      } catch (e) {
        errorToast(LikedVideosModel.fromJson(json.decode(response.body))
            .message
            .toString());
      }
    }
    isLikedVideosLoading.value = false;
    update();
  }

  getOthersLikedVideos(int userId) async {
    othersLikedVideos.clear();
    isLikedVideosLoading.value = true;

    if (token != null) {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/user/user-liked-videos'),
          headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
          body: {"user_id": "$userId"}).timeout(const Duration(seconds: 60));

      try {
        othersLikedVideos =
            LikedVideosModel.fromJson(json.decode(response.body)).data!.obs;
      } catch (e) {
        errorToast(LikedVideosModel.fromJson(json.decode(response.body))
            .message
            .toString());
      }
    }
    isLikedVideosLoading.value = false;
    update();
  }

  likeVideo(int isLike, int videoId) async {
    isLikedVideosLoading.value = true;
    if (token != null) {
      var response = await http.post(Uri.parse('${RestUrl.baseUrl}/video/like'),
          headers: {
            "Authorization": "Bearer $token"
          },
          body: {
            "video_id": "$videoId",
            "is_like": "$isLike"
          }).timeout(const Duration(seconds: 60));
      likedVideos.clear();
      try {
        likedVideos =
            LikedVideosModel.fromJson(json.decode(response.body)).data!.obs;
        successToast(LikedVideosModel.fromJson(json.decode(response.body))
            .message
            .toString());
      } catch (e) {
        errorToast(LikedVideosModel.fromJson(json.decode(response.body))
            .message
            .toString());
      }
    }
    publicVideosList.refresh();
    isLikedVideosLoading.value = false;
    update();
  }

  postVideo(
      String userId,
      String videoUrl,
      String sound,
      String soundName,
      String category,
      String hashtags,
      String visibility,
      int isCommentAllowed,
      String description,
      String filterImg,
      String language,
      String gifName,
      String speed,
      bool isDuetable,
      bool isCommentable,
      String? duetFrom,
      bool isDuet,
      int soundOwnerId) async {
    isLoading.value = true;

    if (token != null) {
      var response = await http.post(
        Uri.parse('${RestUrl.baseUrl}/video/post'),
        headers: {"Authorization": "Bearer $token"},
        body: {
          'user_id': userId,
          'video': videoUrl,
          'sound': sound,
          'sound_name': soundName,
          'filter': filterImg,
          'language': language,
          'category': category,
          'hashtags': hashtags,
          'visibility': visibility,
          'is_comment_allowed': isCommentAllowed.toString(),
          'description': description,
          'gif_image': gifName,
          'speed': speed,
          'is_duetable': isDuetable ? "Yes" : "No",
          'is_commentable': isCommentable ? "Yes" : "No",
          'is_duet': isDuet ? "Yes" : "No",
          'duet_from': duetFrom ?? '',
          'sound_owner': soundOwnerId.toString()
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        try {
          // likedVideos =
          //     VideoPostResponse.fromJson(json.decode(response.body)).data!.obs;
          successToast(VideoPostResponse.fromJson(json.decode(response.body))
              .message
              .toString());

          final directory =
              await ExternalPath.getExternalStoragePublicDirectory(
                  ExternalPath.DIRECTORY_PICTURES);
          final dir = Directory("$directory/thrill");

          await dir.exists().then((value) => dir.delete(recursive: true));
          Get.offAll(BottomNavigation());
        } catch (e) {
          errorToast(VideoPostResponse.fromJson(json.decode(response.body))
              .message
              .toString());
        }
      }
    }
    snackBar!.hide();

    isLoading.value = false;
    update();
  }

  deleteVideo(int videoId) async {
    if (token.isEmpty) {
    } else {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/video/delete'),
          headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
          body: {"video_id": "$videoId"}).timeout(const Duration(seconds: 60));

      try {
        successToast(DeleteVideoResponse.fromJson(json.decode(response.body))
            .message
            .toString());

        getAllVideos();
        getUserVideos();
        getUserPrivateVideos();
      } catch (e) {
        errorToast(DeleteVideoResponse.fromJson(json.decode(response.body))
            .message
            .toString());
      }
    }
  }

  getVideoFields() async {
    isLoading.value = true;

    var response = await http.get(
      Uri.parse('${RestUrl.baseUrl}/video/field-data'),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(const Duration(seconds: 60));
    try {
      languageList =
          videoFields.VideoFieldsModel.fromJson(json.decode(response.body))
              .data!
              .languages!
              .obs;

      categoriesList =
          videoFields.VideoFieldsModel.fromJson(json.decode(response.body))
              .data!
              .categories!
              .obs;
      hashTagList =
          videoFields.VideoFieldsModel.fromJson(json.decode(response.body))
              .data!
              .hashtags!
              .obs;
    } catch (e) {
      errorToast(e.toString());
    }
    languageList.refresh();
    categoriesList.refresh();
    hashTagList.refresh();
    isLoading.value = false;
    update();
  }

  Future<void> awsUploadVideo(File file, int currentUnix) async {
    await simpleS3
        .uploadFile(
          file,
          "thrillvideo",
          "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
          AWSRegions.usEast1,
          debugLog: true,
          fileName: "Thrill-$currentUnix.mp4",
          s3FolderPath: "test",
          accessControl: S3AccessControl.publicRead,
        )
        .then((value) => {printInfo(info: value)});
  }

  Future<void> createGIF(int currentUnix, String filePath) async {
    uploadingToast(simpleS3);

    String outputPath = saveCacheDirectory + 'thumbnail.png';
    String path = filePath.substring(7, filePath.length);
    FFmpegKit.execute(
            "-y -i $path -r 3 -filter:v scale=${Get.width}:${Get.height} -t 5 $outputPath")
        .then((session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        Get.back();
        // print("============================> GIF Success!!!!");
      } else {
        snackBar!.hide();

        // print("============================> GIF Error!!!!");
      }
    });
  }

  Future<void> awsUploadThumbnail(int currentUnix) async {
    var file = File(saveCacheDirectory + 'thumbnail.png');
    await simpleS3
        .uploadFile(
      file,
      "thrillvideo",
      "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
      AWSRegions.usEast1,
      debugLog: true,
      s3FolderPath: "gif",
      fileName: 'Thrill-$currentUnix.png',
      accessControl: S3AccessControl.publicRead,
    )
        .then((value) async {
      print(value);
      Get.back();
    });
  }

  Future<void> awsUploadSound(File file, int currentUnix) async {
    await simpleS3
        .uploadFile(
      file,
      "thrillvideo",
      "us-east-1:f16a909a-8482-4c7b-b0c7-9506e053d1f0",
      AWSRegions.usEast1,
      debugLog: true,
      fileName: 'Thrill-$currentUnix.mp3',
      s3FolderPath: "sound",
      accessControl: S3AccessControl.publicRead,
    )
        .then((value) async {
      print(value);
    });
  }
}

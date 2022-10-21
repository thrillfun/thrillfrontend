import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:thrill/controller/model/delete_video_response.dart';
import 'package:thrill/controller/model/liked_videos_model.dart';
import 'package:thrill/controller/model/own_videos_model.dart';
import 'package:thrill/controller/model/private_videos_model.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/model/video_fields_model.dart' as videoFields;
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/models/videos_post_response.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/utils/util.dart';

import '../screens/profile/profile.dart';

class VideosController extends GetxController {
  RxBool on = false.obs; // our observable
  var token = GetStorage().read('token');

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

    var response = await http
        .get(
          Uri.parse('http://3.129.172.46/dev/api/video/list'),
          // headers: {"Authorization": "Bearer $token"},
        )
        .timeout(const Duration(seconds: 60));
    try {
      publicVideosList =
          PublicVideosModel.fromJson(json.decode(response.body)).data!.obs;
    } catch (e) {
      errorToast(PublicVideosModel.fromJson(json.decode(response.body))
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
    if (token.isEmpty) {
    } else {
      var response = await http
          .post(Uri.parse('${RestUrl.baseUrl}/video/user-videos'), headers: {
        "Authorization": "Bearer ${GetStorage().read("token")}"
      }, body: {
        "user_id": "${UserController().userModel.value.id}"
      }).timeout(const Duration(seconds: 60));

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

    if (GetStorage().read("token").toString().isEmpty) {
    } else {
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

    if (token != null) {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/user/user-liked-videos'),
          headers: {
            "Authorization": "Bearer ${GetStorage().read("token")}"
          },
          body: {
            "user_id": "${UserController().userModel.value.id}"
          }).timeout(const Duration(seconds: 60));

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
      var response = await http.post(Uri.parse('${RestUrl.baseUrl}/user/like'),
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
    isLikedVideosLoading.value = false;
    update();
  }

  postVideo(
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
          'user_id': UserController().userModel.value.id.toString(),
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

          videosController.getAllVideos();
          Get.offAll(BottomNavigation());
        } catch (e) {
          errorToast(VideoPostResponse.fromJson(json.decode(response.body))
              .message
              .toString());
        }
      } else {
        print(response.body);
        errorToast("${response.body}");
      }
    }
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
}

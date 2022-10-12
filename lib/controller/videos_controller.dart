import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/blocs/login/login_bloc.dart';
import 'package:thrill/controller/data_controller.dart';
import 'package:thrill/controller/model/liked_videos_model.dart';
import 'package:thrill/controller/model/own_videos_model.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/models/videos_post_response.dart';
import 'package:thrill/screens/home/home.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/controller/model/delete_video_response.dart';

class VideosController extends GetxController {
  RxBool on = false.obs; // our observable

  // swap true/false & save it to observable

  var usersController = Get.find<UserController>();
  var dataController = Get.find<DataController>();

  var isLoading = false.obs;
  var isLikedVideosLoading = false.obs;
  var isUserVideosLoading = false.obs;
  var videosLoading = false.obs;
  var isFollowingLoading = false.obs;
  var isError = false.obs;

  RxList<Videos> userVideosList = RxList();
  RxList<PublicVideos> publicVideosList = RxList();
  RxList<PublicVideos> followingVideosList = RxList();

  var otherUserVideos = RxList<Videos>();
  var likedVideos = RxList<LikedVideos>();
  var othersLikedVideos = RxList<LikedVideos>();

  VideosController() {
    getUserVideos();
    getAllVideos();
    getFollowingVideos();
    getUserLikedVideos();
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
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var currentUser = instance.getString('currentUser');

    if (token!.isEmpty && currentUser!.isEmpty) {
      errorToast("Please Login to get your followings");
    } else {
      var response = await http.get(
        Uri.parse('http://3.129.172.46/dev/api/video/following'),
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 60));

      try {
        followingVideosList =
            PublicVideosModel.fromJson(json.decode(response.body)).data!.obs;
      } catch (e) {
        errorToast(PublicVideosModel.fromJson(json.decode(response.body))
            .message
            .toString());
      }
    }

    isFollowingLoading.value = false;
    followingVideosList.refresh();
    update();
  }

  getUserVideos() async {
    isUserVideosLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var currentUser = instance.getString('currentUser');
    UserModel? current;
    if (currentUser != null) {
      current = UserModel.fromJson(jsonDecode(currentUser));
    }
    if (GetStorage().read("token").toString().isEmpty) {
    } else {
      var response = await http.post(
          Uri.parse('http://3.129.172.46/dev/api/video/user-videos'),
          headers: {
            "Authorization": "Bearer ${GetStorage().read("token")}"
          },
          body: {
            "user_id": "${current!.id}"
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

  getOtherUserVideos(int userId) async {
    videosLoading.value = true;
    otherUserVideos.clear();
    if (GetStorage().read("token").toString().isNotEmpty) {
      var response = await http.post(
          Uri.parse('http://3.129.172.46/dev/api/video/user-videos'),
          headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
          body: {"user_id": "$userId"}).timeout(const Duration(seconds: 60));
      try {
        otherUserVideos =
            OwnVideosModel.fromJson(json.decode(response.body)).data!.obs;
      } on Exception catch (e) {
        log(e.toString());
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
    var instance = await SharedPreferences.getInstance();
    var currentUser = instance.getString('currentUser');
    UserModel current = UserModel.fromJson(jsonDecode(currentUser!));

    if (GetStorage().read("token").toString().isNotEmpty) {
      var response = await http.post(
          Uri.parse('http://3.129.172.46/dev/api/user/user-liked-videos'),
          headers: {
            "Authorization": "Bearer ${GetStorage().read("token")}"
          },
          body: {
            "user_id": "${current.id}"
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
    var instance = await SharedPreferences.getInstance();

    if (GetStorage().read("token").toString().isNotEmpty) {
      var response = await http.post(
          Uri.parse('http://3.129.172.46/dev/api/user/user-liked-videos'),
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
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var currentUser = instance.getString('currentUser');
    UserModel current = UserModel.fromJson(jsonDecode(currentUser!));

    if (token!.isNotEmpty) {
      var response = await http
          .post(Uri.parse('http://3.129.172.46/dev/api/user/like'), headers: {
        "Authorization": "Bearer $token"
      }, body: {
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
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var currentUser = instance.getString('currentUser');
    UserModel current = UserModel.fromJson(jsonDecode(currentUser!));

    if (token!.isNotEmpty) {
      var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/video/post'),
        headers: {"Authorization": "Bearer $token"},
        body: {
          'user_id': current.id.toString(),
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
    var instance = await SharedPreferences.getInstance();
    var currentUser = instance.getString('currentUser');
    UserModel? current;
    if (currentUser != null) {
      current = UserModel.fromJson(jsonDecode(currentUser));
    }
    if (GetStorage().read("token").toString().isEmpty) {
    } else {
      var response = await http.post(
          Uri.parse('http://3.129.172.46/dev/api/video/delete'),
          headers: {"Authorization": "Bearer ${GetStorage().read("token")}"},
          body: {"video_id": "$videoId"}).timeout(const Duration(seconds: 60));

      try {
        successToast(DeleteVideoResponse.fromJson(json.decode(response.body))
            .message
            .toString());

        getAllVideos();
        getUserVideos();

      } catch (e) {
        errorToast(DeleteVideoResponse.fromJson(json.decode(response.body))
            .message
            .toString());
      }
    }
  }
}

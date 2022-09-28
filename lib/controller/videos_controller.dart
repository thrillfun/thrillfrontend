import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/data_controller.dart';
import 'package:thrill/controller/model/liked_videos_model.dart';
import 'package:thrill/controller/model/own_videos_model.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/models/videos_post_response.dart';
import 'package:thrill/screens/home/home.dart';
import 'package:thrill/utils/util.dart';

class VideosController extends GetxController {
  var usersController = Get.find<UserController>();
  var dataController = Get.find<DataController>();

  var isLoading = false.obs;
  var videosLoading = false.obs;
  var isFollowingLoading = false.obs;
  var isError = false.obs;

  RxList<Videos> videoModelsController = RxList();
  RxList<PublicVideos> publicVideosList = RxList();
  RxList<PublicVideos> followingVideosList = RxList();

  var otherUserVideos = RxList<Videos>();
  var likedVideos = RxList<LikedVideos>();

  VideosController() {
    getUserVideos();
    getAllVideos();
    getFollowingVideos();
  }

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

  getAllVideos() async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var currentUser = instance.getString('currentUser');
    UserModel? current;
    if (currentUser != null) {
      current = UserModel.fromJson(jsonDecode(currentUser));
    }
    var response = await http
        .get(
          Uri.parse('http://3.129.172.46/dev/api/video/list'),
          // headers: {"Authorization": "Bearer $token"},
        )
        .timeout(const Duration(seconds: 60));
    try {
      publicVideosList =
          PublicVideosModel.fromJson(json.decode(response.body)).data!.obs;

      isLoading.value = false;
      update();
    } catch (e) {
      errorToast(PublicVideosModel.fromJson(json.decode(response.body))
          .message
          .toString());
      isLoading.value = false;
      update();
    }
  }

  getFollowingVideos() async {
    isFollowingLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var currentUser = instance.getString('currentUser');

    var response = await http.get(
      Uri.parse('http://3.129.172.46/dev/api/video/following'),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(const Duration(seconds: 60));

    try {
      followingVideosList =
          PublicVideosModel.fromJson(json.decode(response.body)).data!.obs;

      isFollowingLoading.value = false;
      update();
    } catch (e) {
      errorToast(PublicVideosModel.fromJson(json.decode(response.body))
          .message
          .toString());
      isFollowingLoading.value = false;
      update();
    }
  }

  getUserVideos() async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var currentUser = instance.getString('currentUser');
    UserModel? current;
    if (currentUser != null) {
      current = UserModel.fromJson(jsonDecode(currentUser));
    }
    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/video/user-videos'),
        headers: {
          "Authorization": "Bearer $token"
        },
        body: {
          "user_id": "${current!.id}"
        }).timeout(const Duration(seconds: 60));

    try {
      videoModelsController =
          OwnVideosModel.fromJson(json.decode(response.body)).data!.obs;

      isLoading.value = false;
      update();
    } catch (e) {
      errorToast(OwnVideosModel.fromJson(json.decode(response.body))
          .message
          .toString());
      isLoading.value = false;
      update();
    }
  }

  getOtherUserVideos(int userId) async {
    videosLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/video/user-videos'),
        headers: {"Authorization": "Bearer $token"},
        body: {"user_id": "$userId"}).timeout(const Duration(seconds: 60));

    try {
      otherUserVideos =
          OwnVideosModel.fromJson(json.decode(response.body)).data!.obs;

      videosLoading.value = false;
    } on Exception catch (e) {
      log(e.toString());
      errorToast(OwnVideosModel.fromJson(json.decode(response.body))
          .message
          .toString());
      videosLoading.value = false;
    }
  }

  getUserLikedVideos(int userId) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var currentUser = instance.getString('currentUser');
    UserModel current = UserModel.fromJson(jsonDecode(currentUser!));

    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/user/user-liked-videos'),
        headers: {"Authorization": "Bearer $token"},
        body: {"user_id": "${userId}"}).timeout(const Duration(seconds: 60));

    try {
      likedVideos =
          LikedVideosModel.fromJson(json.decode(response.body)).data!.obs;

      isLoading.value = false;
    } catch (e) {
      errorToast(LikedVideosModel.fromJson(json.decode(response.body))
          .message
          .toString());
      isLoading.value = false;
    }
  }

  likeVideo(int isLike, int videoId) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');
    var currentUser = instance.getString('currentUser');
    UserModel current = UserModel.fromJson(jsonDecode(currentUser!));

    var response = await http
        .post(Uri.parse('http://3.129.172.46/dev/api/user/like'), headers: {
      "Authorization": "Bearer $token"
    }, body: {
      "video_id": "$videoId",
      "is_like": "$isLike"
    }).timeout(const Duration(seconds: 60));

    try {
      likedVideos =
          LikedVideosModel.fromJson(json.decode(response.body)).data!.obs;
      successToast(LikedVideosModel.fromJson(json.decode(response.body))
          .message
          .toString());
      isLoading.value = false;
      update();
    } catch (e) {
      errorToast(LikedVideosModel.fromJson(json.decode(response.body))
          .message
          .toString());
      isLoading.value = false;
      update();
    }
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
        isLoading.value = false;
        update();

        videosController.getAllVideos();
      } catch (e) {
        errorToast(VideoPostResponse.fromJson(json.decode(response.body))
            .message
            .toString());
        isLoading.value = false;
        update();
      }
    } else {
      print(response.body);
      errorToast("${response.body}");
    }
  }
}

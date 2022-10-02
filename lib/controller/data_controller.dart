import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/model/comments_model.dart';
import 'package:thrill/controller/model/comments_post_response.dart';
import 'package:thrill/controller/model/follow_unfollow_model.dart';
import 'package:thrill/controller/model/followers_model.dart';
import 'package:thrill/controller/model/login_model.dart';
import 'package:thrill/controller/model/popular_videos_model.dart';
import 'package:thrill/controller/model/profile_model_pojo.dart';
import 'package:thrill/controller/model/user_video_model.dart';
import 'package:thrill/models/level_model.dart';
import 'package:thrill/models/user.dart';

import '../models/video_model.dart';

class DataController extends GetxController with StateMixin<dynamic> {
  var isAdShown = false.obs;
  var commentsCounter = 0.obs;
  var isLoading = true.obs;
  var isPublicVideosLoading = true.obs;
  var isUserProfileLoading = true.obs;
  var LoginStatus = false.obs;

  var isMyProfile = true.obs;

  CommentsModel? commentsModel;
  late FollowersModel followersModel;
  late ProfileModelPojo profileModelPojo;
  LoginModel? loginModel;
  UserModel? model;
  UserVideosModel? userVideosModel;
  PopularVideosModel? popularVideosModel;
  late VideoModel videoModel;
  List<UserVideosModel> videoList = [];
  var selectedIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getPopularVideos();
  }

  loginUser(String phone, String password) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http
        .post(Uri.parse('http://3.129.172.46/dev/api/api/login'), body: {
      "phone": "$phone",
      "password": password,
      "login_type": "normal"
    }).timeout(const Duration(seconds: 60));
    try {
      isLoading.value = false;
      update();
      var result = jsonDecode(response.body);
      loginModel = LoginModel.fromJson(result);
      var pref = await SharedPreferences.getInstance();
      LevelModel levelModel = LevelModel(
          loginModel!.data!.user!.levels!.current!,
          loginModel!.data!.user!.levels!.next!,
          loginModel!.data!.user!.levels!.progress!,
          "0");

      UserModel user = UserModel(
          loginModel!.data!.user!.id!,
          loginModel!.data!.user!.name!,
          loginModel!.data!.user!.phone!,
          loginModel!.data!.user!.avatar!,
          loginModel!.data!.user!.dob!,
          loginModel!.data!.user!.socialLoginType!,
          loginModel!.data!.user!.socialLoginId!,
          loginModel!.data!.user!.email!,
          loginModel!.data!.user!.facebook!,
          loginModel!.data!.user!.firebaseToken!,
          loginModel!.data!.user!.youtube!,
          loginModel!.data!.user!.instagram!,
          loginModel!.data!.user!.bio!,
          loginModel!.data!.user!.twitter!,
          loginModel!.data!.user!.websiteUrl!,
          loginModel!.data!.user!.gender!,
          loginModel!.data!.user!.firstName!,
          loginModel!.data!.user!.lastName!,
          loginModel!.data!.user!.username!,
          loginModel!.data!.user!.referralCount!,
          loginModel!.data!.user!.following!,
          loginModel!.data!.user!.followers!,
          loginModel!.data!.user!.likes!,
          loginModel!.data!.user!.totalVideos!,
          loginModel!.data!.user!.boxTwo!,
          loginModel!.data!.user!.boxThree!,
          levelModel,
          loginModel!.data!.user!.isVerified!,
          loginModel!.data!.user!.referralCode!);
      ;
      await pref.setString(
        'currentUser',
        loginModel!.data!.user!.name!,
      );
      await pref.setString('currentToken', loginModel!.data!.token.toString());

      List<String> users = pref.getStringList('allUsers') ?? [];
      users.insert(0, pref.getString('currentUser')!);
      await pref.setStringList('allUsers', users);
      await pref.setString('${user.id}currentToken', result['data']['token']);
    } catch (e) {
      isLoading.value = false;
      update();
      GetSnackBar(
        message: "$e",
        title: "Error",
        duration: const Duration(seconds: 3),
        backgroundGradient: const LinearGradient(
            colors: [Color(0xFF2F8897), Color(0xff1F2A52), Color(0xff1F244E)]),
        isDismissible: true,
      ).show();
      var result = jsonDecode(response.body);
      loginModel = LoginModel.fromJson(result);
    }
  }

  Future<FollowUnfollowModel> followUnfollowUser(int userId) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/user/follow-unfollow-user'),
        headers: {
          "Authorization": "Bearer $token"
        },
        body: {
          "publisher_user_id": "$userId",
          "action": "unfollow"
        }).timeout(const Duration(seconds: 60));

    try {
      isLoading.value = false;
      update();
      return FollowUnfollowModel.fromJson(json.decode(response.body));
    } catch (e) {
      isLoading.value = false;
      update();
      GetSnackBar(
        message: "$e",
        title: "Error",
        duration: const Duration(seconds: 3),
        backgroundGradient: const LinearGradient(
            colors: [Color(0xFF2F8897), Color(0xff1F2A52), Color(0xff1F244E)]),
        isDismissible: true,
      ).show();
      return FollowUnfollowModel.fromJson(json.decode(response.body));
    }
  }

  Future<CommentsPostResponse> postComment(
      int videoId, String userId, String comment) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http
        .post(Uri.parse('http://3.129.172.46/dev/api/video/comment'), headers: {
      "Authorization": "Bearer $token"
    }, body: {
      "video_id": "$videoId",
      "comment_by": userId,
      "comment": comment
    }).timeout(const Duration(seconds: 60));

    try {
      isLoading.value = false;
      update();
      return CommentsPostResponse.fromJson(json.decode(response.body));
    } catch (e) {
      isLoading.value = false;
      update();
      GetSnackBar(
        message: "Something went wrong",
        title: "$e",
        duration: const Duration(seconds: 3),
        backgroundGradient: const LinearGradient(
            colors: [Color(0xFF2F8897), Color(0xff1F2A52), Color(0xff1F244E)]),
        isDismissible: true,
      ).show();
      return CommentsPostResponse.fromJson(json.decode(response.body));
    }
  }

  getPopularVideos() async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http.get(
      Uri.parse('http://3.129.172.46/dev/api/video/popular'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json;charset=utf-8",
        "Accept": "application/json"
      },
    ).timeout(const Duration(seconds: 60));
    try {
      var result = jsonDecode(response.body);
      popularVideosModel = PopularVideosModel.fromJson(result);

      isLoading.value = false;
      update();
    } catch (e) {
      isLoading.value = false;
      update();
    }
  }
}

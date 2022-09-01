import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/model/comments_model.dart';
import 'package:thrill/controller/model/comments_post_response.dart';
import 'package:thrill/controller/model/follow_unfollow_model.dart';
import 'package:thrill/controller/model/followers_model.dart';
import 'package:thrill/controller/model/profile_model_pojo.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/model/user_video_model.dart';
import 'package:thrill/controller/model/video_model_controller.dart';
import 'package:thrill/controller/model/profile_model_pojo.dart';
import 'package:thrill/models/level_model.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/screens/following_and_followers.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:video_player/video_player.dart';

import '../models/video_model.dart';

class DataController extends GetxController with StateMixin<dynamic> {
  var commentsCounter = 0.obs;
  var isLoading = true.obs;
  CommentsModel? commentsModel;
  late FollowersModel followersModel;
  late ProfileModelPojo profileModelPojo;
  late UserModel model;
  late UserVideosModel userVideosModel;
  late VideoModel videoModel;
  List<UserVideosModel>videoList = [];
  var selectedIndex = 0.obs;

  Future<VideoModelsController> getUserVideos(int userId) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http.get(
        Uri.parse('https://9starinfosolutions.com/thrill/api/video/list'),
        headers: {
          "Authorization": "Bearer$token"
        }).timeout(const Duration(seconds: 60));

    try {
      isLoading.value = false;
      update();
      return VideoModelsController.fromJson(json.decode(response.body));
    } catch (e) {
      isLoading.value = false;
      update();
      return VideoModelsController.fromJson(json.decode(response.body));
    }
  }

  getUserProfile(int userId) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/user/get-profile'),
        headers: {"Authorization": "Bearer $token"},
        body: {"id": "$userId"}).timeout(const Duration(seconds: 60));

    if(response.statusCode==200){
      try {
        var result = jsonDecode(response.body);
        profileModelPojo = ProfileModelPojo.fromJson(result);

        LevelModel levelModel = LevelModel(
            profileModelPojo.data!.user!.levels!.current!,
            profileModelPojo.data!.user!.levels!.next!,
            profileModelPojo.data!.user!.levels!.progress!,
            profileModelPojo.data!.user!.levels!.maxLevel!);

        model = UserModel(
            profileModelPojo.data!.user!.id!,
            profileModelPojo.data!.user!.name!,
            profileModelPojo.data!.user!.phone!,
            profileModelPojo.data!.user!.avatar!,
            profileModelPojo.data!.user!.dob!,
            profileModelPojo.data!.user!.socialLoginType!,
            profileModelPojo.data!.user!.socialLoginId!,
            profileModelPojo.data!.user!.email!,
            profileModelPojo.data!.user!.facebook!,
            profileModelPojo.data!.user!.firebaseToken!,
            profileModelPojo.data!.user!.youtube!,
            profileModelPojo.data!.user!.instagram!,
            profileModelPojo.data!.user!.bio!,
            profileModelPojo.data!.user!.twitter!,
            profileModelPojo.data!.user!.websiteUrl!,
            profileModelPojo.data!.user!.gender!,
            profileModelPojo.data!.user!.firstName!,
            profileModelPojo.data!.user!.lastName!,
            profileModelPojo.data!.user!.username!,
            profileModelPojo.data!.user!.referralCount!,
            profileModelPojo.data!.user!.following!,
            profileModelPojo.data!.user!.followers!,
            profileModelPojo.data!.user!.likes!,
            profileModelPojo.data!.user!.totalVideos!,
            profileModelPojo.data!.user!.boxTwo!,
            profileModelPojo.data!.user!.boxThree!,
            levelModel,
            profileModelPojo.data!.user!.isVerified!,
            profileModelPojo.data!.user!.referralCode!);

        Get.to(ViewProfile(
            mapData: {"userModel": model, "getProfile": false}));
        isLoading.value = false;
        update();

      } catch (e) {

        var result = jsonDecode(response.body);
        profileModelPojo = ProfileModelPojo.fromJson(result);

        isLoading.value = false;
        update();
        GetSnackBar(
          message: "$e",
          title: "Something went wrong",
          duration: const Duration(seconds: 3),
          backgroundGradient: const LinearGradient(
              colors: [Color(0xFF2F8897), Color(0xff1F2A52), Color(0xff1F244E)]),
          isDismissible: true,
        ).show();
      }
    }
    else{
      GetSnackBar(
        message: "${response.statusCode}",
        title: "Something went wrong",
        duration: const Duration(seconds: 3),
        backgroundGradient: const LinearGradient(
            colors: [Color(0xFF2F8897), Color(0xff1F2A52), Color(0xff1F244E)]),
        isDismissible: true,
      ).show();
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

  getComments(int videoId) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/video/comments'),
        headers: {"Authorization": "Bearer $token"},
        body: {"video_id": "$videoId"}).timeout(const Duration(seconds: 60));
    try {
      isLoading.value = false;
      update();
      var result = jsonDecode(response.body);
      commentsModel = CommentsModel.fromJson(result);
    } catch (e) {
      isLoading.value = false;
      update();
      GetSnackBar(
        message: "$e",
        title: "Error",
        duration: Duration(seconds: 3),
        backgroundGradient: LinearGradient(
            colors: [Color(0xFF2F8897), Color(0xff1F2A52), Color(0xff1F244E)]),
        isDismissible: true,
      ).show();
      var result = jsonDecode(response.body);

      commentsModel = CommentsModel.fromJson(result);
    }
  }

  Future<CommentsPostResponse> postComment(int videoId, String userId,
      String comment) async {
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

  getFollowers(int userId) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/user/get-followers'),
        headers: {"Authorization": "Bearer $token"},
        body: {"user_id": "$userId"}).timeout(const Duration(seconds: 60));
    try {
      isLoading.value = false;
      update();
      var result = jsonDecode(response.body);
      followersModel = FollowersModel.fromJson(result);
    } catch (e) {
      isLoading.value = false;
      update();
      GetSnackBar(
        message: "$e",
        title: "Error",
        duration: Duration(seconds: 3),
        backgroundGradient: LinearGradient(
            colors: [Color(0xFF2F8897), Color(0xff1F2A52), Color(0xff1F244E)]),
        isDismissible: true,
      ).show();

      var result = jsonDecode(response.body);
      followersModel = FollowersModel.fromJson(result);
    }
  }

  getUserPublicVideos(int userId) async {
    isLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken');

    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/video/user-videos'),
        headers: {"Authorization": "Bearer $token"},
        body: {"user_id": "$userId"}).timeout(const Duration(seconds: 60));
    try {
      var result = jsonDecode(response.body);
      userVideosModel = UserVideosModel.fromJson(result);
      userVideosModel.data!.forEach((element) {

        videoModel = VideoModel(
            element.id!,
            element.comments!,
            element.video!,
            element.description!,
            element.likes!,
            null,
            element.filter!,
            element.gifImage!,
            element. sound!,
            element. soundName!,
            element. soundCategoryName!,
            element. views!,
            element. speed!,
            element. hashtags!,
            element. isDuet!,
            element. duetFrom!,
            element. isDuetable!,
            element. isCommentable!,
            element. soundOwner!);
      });
      isLoading.value = false;
      update();
    } catch (e) {
      isLoading.value = false;
      update();

    }
  }

}

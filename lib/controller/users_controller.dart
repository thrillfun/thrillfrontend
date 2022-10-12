import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/model/block_status_response.dart';
import 'package:thrill/controller/model/followers_model.dart';
import 'package:thrill/controller/model/profile_model_pojo.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/utils/util.dart';

class UserController extends GetxController {
  var isProfileLoading = false.obs;
  var isFollowersLoading = false.obs;
  var isFollowingLoading = false.obs;

  var followersModel = RxList<Followers>();
  var followingModel = RxList<Followers>();

  var userFollowersModel = RxList<Followers>();
  var userFollowingModel = RxList<Followers>();

  var userBlocked = false.obs;
  var userId = 0.obs;
  var isMyProfile = false.obs;

  var userProfile = ProfileModelPojo().obs;

  UserController() {
    getFollowers();
    getFollowings();

  }

  getUserProfile(int userId) async {
    isProfileLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken') ?? "";
    var currentUser = instance.getString('currentUser') ?? "";

    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/user/get-profile'),
        headers: {"Authorization": "Bearer $token"},
        body: {"id": "$userId"}).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      try {
        userProfile = ProfileModelPojo.fromJson(result).obs;
      } catch (e) {
        errorToast(result['message']);
      }
    } else {
      errorToast(response.statusCode.toString());
    }
    isProfileLoading.value = false;
  }

  getFollowers() async {
    isFollowersLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken') ?? "";
    var currentUser = instance.getString('currentUser') ?? "";
    UserModel? current;
    current = UserModel.fromJson(jsonDecode(currentUser));
    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/user/get-followers'),
        headers: {
          "Authorization": "Bearer $token"
        },
        body: {
          "user_id": "${current!.id}"
        }).timeout(const Duration(seconds: 60));

    var result = jsonDecode(response.body);
    try {
      userFollowersModel = FollowersModel.fromJson(result).data!.obs;
    } catch (e) {
      errorToast(FollowersModel.fromJson(result).message.toString());
    }
    isFollowersLoading.value = false;
    update();
  }

  getFollowings() async {
    isFollowingLoading.value = true;
    var instance = await SharedPreferences.getInstance();

    var token = instance.getString('currentToken') ?? "";
    var currentUser = instance.getString('currentUser') ?? "";
    UserModel? current;
    current = UserModel.fromJson(jsonDecode(currentUser));

    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/user/get-followings'),
        headers: {
          "Authorization": "Bearer $token"
        },
        body: {
          "user_id": "${current?.id}"
        }).timeout(const Duration(seconds: 60));

    var result = jsonDecode(response.body);
    try {
      userFollowingModel = FollowersModel.fromJson(result).data!.obs;
    } catch (e) {
      errorToast(FollowersModel.fromJson(result).message.toString());
    }
    isFollowingLoading.value = false;
    update();
  }

  getUserFollowers(int userId) async {
    isFollowersLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken') ?? "";
    followersModel.clear();
    try {
      var response = await http.post(
          Uri.parse('http://3.129.172.46/dev/api/user/get-followers'),
          headers: {"Authorization": "Bearer $token"},
          body: {"user_id": "${userId}"}).timeout(const Duration(seconds: 60));

      var result = jsonDecode(response.body);
      followersModel = FollowersModel.fromJson(result).data!.obs;
    } catch (e) {
      GetSnackBar(
        message: "$e",
        title: "Error",
        duration: Duration(seconds: 3),
        backgroundGradient: LinearGradient(
            colors: [Color(0xFF2F8897), Color(0xff1F2A52), Color(0xff1F244E)]),
        isDismissible: true,
      ).show();
    }
    isFollowersLoading.value = false;
    update();
  }

  getUserFollowing(int userId) async {
    isFollowersLoading.value = true;
    followingModel.clear();
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken') ?? "";
    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/user/get-followings'),
        headers: {"Authorization": "Bearer $token"},
        body: {"user_id": "$userId"}).timeout(const Duration(seconds: 60));

    var result = jsonDecode(response.body);
    try {
      followingModel = FollowersModel.fromJson(result).data!.obs;
    } catch (e) {
      errorToast(FollowersModel.fromJson(result).message.toString());
    }
    isFollowersLoading.value = false;
    update();
  }

  isUserBlocked(int userId) async {
    isFollowersLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken') ?? "";
    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/user/is-user-blocked'),
        headers: {"Authorization": "Bearer $token"},
        body: {"blocked_user": "$userId"}).timeout(const Duration(seconds: 60));

    var result = jsonDecode(response.body);
    try {
      userBlocked = BlockStatusResponse.fromJson(result).status!.obs;
    } catch (e) {
      errorToast(BlockStatusResponse.fromJson(result).message.toString());
    }
    isFollowersLoading.value = false;
    update();
  }

  blockUnblockUser(int userId, String action) async {
    isFollowersLoading.value = true;
    var instance = await SharedPreferences.getInstance();
    var token = instance.getString('currentToken') ?? "";
    var response = await http.post(
        Uri.parse('http://3.129.172.46/dev/api/user/block-unblock-user'),
        headers: {
          "Authorization": "Bearer $token"
        },
        body: {
          "blocked_user": "$userId",
          "action": action
        }).timeout(const Duration(seconds: 60));

    var result = jsonDecode(response.body);
    try {
      userBlocked = BlockStatusResponse.fromJson(result).status!.obs;

      print(BlockStatusResponse.fromJson(result).message);
      successToast(BlockStatusResponse.fromJson(result).message.toString());
    } catch (e) {
      errorToast(BlockStatusResponse.fromJson(result).message.toString());
    }
    isFollowersLoading.value = false;
    update();
  }
}

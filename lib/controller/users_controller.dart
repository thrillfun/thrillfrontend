import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/discover_controller.dart';
import 'package:thrill/controller/model/block_status_response.dart';
import 'package:thrill/controller/model/followers_model.dart';
import 'package:thrill/controller/model/profile_model_pojo.dart';
import 'package:thrill/controller/model/user_details_model.dart' as authUser;
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/screens/home/home_getx.dart';
import 'package:thrill/utils/util.dart';

class UserController extends GetxController {
  var userModel = authUser.User().obs;

  var isProfileLoading = false.obs;
  var isFollowersLoading = false.obs;
  var isFollowingLoading = false.obs;
  var isLoggingIn = false.obs;

  var followersModel = RxList<Followers>();
  var followingModel = RxList<Followers>();

  var userFollowersModel = RxList<Followers>();
  var userFollowingModel = RxList<Followers>();

  var userBlocked = false.obs;
  var userId = 0.obs;
  var isMyProfile = false.obs;

  var userProfile = ProfileModelPojo().obs;
  String token = GetStorage().read("token");

  UserController() {
    if (GetStorage().read("user") != null) {
      userModel.value = authUser.User.fromJson(GetStorage().read("user"));
    }
  }

  getUserProfile(int userId) async {
    isProfileLoading.value = true;

    if (token.toString().isNotEmpty) {
      var response = await http
          .post(Uri.parse('${RestUrl.baseUrl}/user/get-profile'), headers: {
        "Authorization": "Bearer $token"
      }, body: {
        "id": "${userModel.value.id}"
      }).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        try {
          userProfile = ProfileModelPojo.fromJson(result).obs;
        } on HttpException catch (e) {
          errorToast(result['message']);
        } on Exception catch (e) {
          errorToast(e.toString());
        }
      } else {
        errorToast(response.statusCode.toString());
      }
    }
    isProfileLoading.value = false;
  }

  getFollowers() async {
    isFollowersLoading.value = true;

    if (token.toString().isNotEmpty) {
      var response = await http
          .post(Uri.parse('${RestUrl.baseUrl}/user/get-followers'), headers: {
        "Authorization": "Bearer $token"
      }, body: {
        "user_id": "${userModel.value.id}"
      }).timeout(const Duration(seconds: 60));

      var result = jsonDecode(response.body);
      try {
        userFollowersModel = FollowersModel.fromJson(result).data!.obs;
      } on HttpException catch (e) {
        errorToast(FollowersModel.fromJson(result).message.toString());
      } on Exception catch (e) {
        errorToast(e.toString());
      }
    }
    isFollowersLoading.value = false;
    update();
  }

  getFollowings() async {
    isFollowingLoading.value = true;

    if (token.toString().isNotEmpty) {
      var response = await http
          .post(Uri.parse('${RestUrl.baseUrl}/user/get-followings'), headers: {
        "Authorization": "Bearer $token"
      }, body: {
        "user_id": "${userModel.value.id}"
      }).timeout(const Duration(seconds: 60));

      var result = jsonDecode(response.body);
      try {
        userFollowingModel = FollowersModel.fromJson(result).data!.obs;
      } on HttpException catch (e) {
        errorToast(FollowersModel.fromJson(result).message.toString());
      } on Exception catch (e) {
        errorToast(e.toString());
      }
    }
    isFollowingLoading.value = false;
    update();
  }

  getUserFollowers(int userId) async {
    isFollowersLoading.value = true;

    followersModel.clear();
    if (token.isNotEmpty) {
      try {
        var response = await http
            .post(Uri.parse('${RestUrl.baseUrl}/user/get-followers'), headers: {
          "Authorization": "Bearer $token"
        }, body: {
          "user_id": "${userId}"
        }).timeout(const Duration(seconds: 60));

        var result = jsonDecode(response.body);
        followersModel = FollowersModel.fromJson(result).data!.obs;
      } on HttpException catch (e) {
        GetSnackBar(
          message: "$e",
          title: "Error",
          duration: Duration(seconds: 3),
          backgroundGradient: LinearGradient(colors: [
            Color(0xFF2F8897),
            Color(0xff1F2A52),
            Color(0xff1F244E)
          ]),
          isDismissible: true,
        ).show();
      }
    }
    isFollowersLoading.value = false;
    update();
  }

  getUserFollowing(int userId) async {
    isFollowersLoading.value = true;
    followingModel.clear();

    if (token.isNotEmpty) {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/user/get-followings'),
          headers: {"Authorization": "Bearer $token"},
          body: {"user_id": "$userId"}).timeout(const Duration(seconds: 60));

      var result = jsonDecode(response.body);
      try {
        followingModel = FollowersModel.fromJson(result).data!.obs;
      } catch (e) {
        errorToast(FollowersModel.fromJson(result).message.toString());
      }
    }
    isFollowersLoading.value = false;
    update();
  }

  isUserBlocked(int userId) async {
    isFollowersLoading.value = true;

    if (token.isNotEmpty) {
      var response = await http
          .post(Uri.parse('${RestUrl.baseUrl}/user/is-user-blocked'), headers: {
        "Authorization": "Bearer $token"
      }, body: {
        "blocked_user": "$userId"
      }).timeout(const Duration(seconds: 60));

      var result = jsonDecode(response.body);
      try {
        userBlocked = BlockStatusResponse.fromJson(result).status!.obs;
      } on HttpException catch (e) {
        errorToast(BlockStatusResponse.fromJson(result).message.toString());
      } on Exception catch (e) {
        errorToast(e.toString());
      }
    }
    isFollowersLoading.value = false;
    update();
  }

  blockUnblockUser(int userId, String action) async {
    isFollowersLoading.value = true;

    if (token.isNotEmpty) {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/user/block-unblock-user'),
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
      } on HttpException catch (e) {
        errorToast(BlockStatusResponse.fromJson(result).message.toString());
      } on Exception catch (e) {
        errorToast(e.toString());
      }
    }
    isFollowersLoading.value = false;
    update();
  }

  loginUser(var phone, var password) async {
    isLoggingIn.value = true;

    var response = await http.post(Uri.parse('${RestUrl.baseUrl}/login'),
        body: {
          "phone": phone,
          "password": password
        }).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      try {
        var userData = authUser.UserDetailsModel.fromJson(result).data;
        var user = userData!.user;
        var token = userData!.token;
        GetStorage().write('token', token).toString();
        GetStorage().write('user', user);

        Get.to(BottomNavigation());

        successToast(result['message']);
      } on HttpException catch (e) {
        errorToast(result['message']);
      } on Exception catch (e) {
        errorToast(e.toString());
      }
    } else {
      errorToast(response.statusCode.toString());
    }
    isLoggingIn.value = false;
  }

  socialLoginRegister(var social_login_id, social_login_type, email, phone,
      firebase_token, name) async {
    isLoggingIn.value = true;

    var response =
        await http.post(Uri.parse('${RestUrl.baseUrl}/SocialLogin'), body: {
      "social_login_id": social_login_id,
      "social_login_type": social_login_type,
      "email": email,
      "phone": phone,
      "firebase_token": firebase_token,
      "name": name,
    }).timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      try {
        var userData = authUser.UserDetailsModel.fromJson(result).data;
        var user = userData!.user;
        var token = userData!.token;
        GetStorage().write('token', token).toString();
        GetStorage().write('user', user);

        Get.to(BottomNavigation());

        successToast(result['message']);
      } on HttpException catch (e) {
        errorToast(result['message']);
      } on Exception catch (e) {
        errorToast(e.toString());
      }
    } else {
      errorToast(response.statusCode.toString());
    }
    isLoggingIn.value = false;
  }

  signInWithGoogle() async {
    GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();
    // fetch the auth details from the request made earlier
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // Create a new credential for signing in with google
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    GetStorage().write("token", googleAuth.accessToken);
    // Once signed in, return the UserCredential
    socialLoginRegister(googleUser.id, "google", googleUser.email ?? "", "",
        googleAuth.accessToken, googleUser.displayName ?? "");
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  signOut() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    final GoogleSignIn googleUser =
        await GoogleSignIn(scopes: <String>["email"]);

    await _firebaseAuth.signOut();

    googleUser.signOut();
  }
}

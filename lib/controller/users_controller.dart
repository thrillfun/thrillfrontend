import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:thrill/controller/model/block_status_response.dart';
import 'package:thrill/controller/model/followers_model.dart';
import 'package:thrill/controller/model/inbox_model.dart';
import 'package:thrill/controller/model/profile_model_pojo.dart';
import 'package:thrill/controller/model/user_details_model.dart' as authUser;
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
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

  var isInboxLoading = false.obs;
  var inboxList = RxList<Inbox>();

  var userBlocked = false.obs;
  var userId = 0.obs;
  var isMyProfile = false.obs;

  var userProfile = ProfileModelPojo().obs;
  String token = GetStorage().read("token");

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  Future<void> getUserProfile(int userId) async {
    isProfileLoading.value = true;
    Get.defaultDialog(content: loader(),title: "Loading");
    try {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/user/get-profile'),
          headers: {"Authorization": "Bearer $token"},
          body: {"id": "$userId"}).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        try {
          userProfile = ProfileModelPojo.fromJson(result).obs;

          videosController.getOtherUserVideos(int.parse(userId.toString()));
          videosController.getOthersLikedVideos(int.parse(userId.toString()));

        } on HttpException catch (e) {
          errorToast(result['message']);
        } on Exception catch (e) {
          errorToast(e.toString());
        }
      } else {
        isProfileLoading.value = false;
        errorToast(response.statusCode.toString());
      }
    } on Exception catch (e) {
      isProfileLoading.value = false;
      log(e.toString());
    }
    Get.back();
    isProfileLoading.value = false;
  }

  getFollowers() async {
    isFollowersLoading.value = true;

    try {
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
    } on Exception catch (e) {
      log(e.toString());
    }
    isFollowersLoading.value = false;
    update();
  }

  getFollowings() async {
    isFollowingLoading.value = true;

    try {
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
    } on Exception catch (e) {
      log(e.toString());
    }
    isFollowingLoading.value = false;
    update();
  }

  getUserFollowers(int userId) async {
    isFollowersLoading.value = true;

    followersModel.clear();
    try {
      var response = await http.post(
          Uri.parse('${RestUrl.baseUrl}/user/get-followers'),
          headers: {"Authorization": "Bearer $token"},
          body: {"user_id": "${userId}"}).timeout(const Duration(seconds: 60));

      var result = jsonDecode(response.body);
      followersModel = FollowersModel.fromJson(result).data!.obs;
    } on Exception catch (e) {
      log(e.toString());
    }
    isFollowersLoading.value = false;
    update();
  }

  getUserFollowing(int userId) async {
    isFollowersLoading.value = true;
    followingModel.clear();

    try {
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
    } on Exception catch (e) {
      log(e.toString());
    }
    isFollowersLoading.value = false;
    update();
  }

  isUserBlocked(int userId) async {
    isFollowersLoading.value = true;

    try {
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
    } on Exception catch (e) {
      log(e.toString());
    }
    isFollowersLoading.value = false;
    update();
  }

  blockUnblockUser(int userId, String action) async {
    isFollowersLoading.value = true;

    try {
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
    } on Exception catch (e) {
      log(e.toString());
    }
    isFollowersLoading.value = false;
    update();
  }

  loginUser(var phone, var password) async {
    isLoggingIn.value = true;

    try {
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

          Get.back(closeOverlays: true);
          update();
          // Get.to(BottomNavigation());

          successToast(result['message']);
        } on HttpException catch (e) {
          errorToast(result['message']);
        } on Exception catch (e) {
          errorToast(e.toString());
        }
      } else {
        errorToast(response.statusCode.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    isLoggingIn.value = false;
  }

  socialLoginRegister(var social_login_id, social_login_type, email, phone,
      firebase_token, name) async {
    isLoggingIn.value = true;

    try {
      createDynamicLink("123456").then((value) async {
        var response =
            await http.post(Uri.parse('${RestUrl.baseUrl}/SocialLogin'), body: {
          "social_login_id": social_login_id,
          "social_login_type": social_login_type,
          "email": email,
          "phone": phone,
          "firebase_token": firebase_token,
          "name": name,
          "referral_code": value.toString(),
        }).timeout(const Duration(seconds: 60));

        var result = jsonDecode(response.body);
        try {
          var userData = authUser.UserDetailsModel.fromJson(result).data;

          GetStorage().write('token', userData!.token!).toString();
          GetStorage().write('user', userData!.user).then((value) {
            Get.to(BottomNavigation());
            userModel.value = authUser.User.fromJson(GetStorage().read("user"));
            update();
          });

          successToast(result['message']);
        } on HttpException catch (e) {
          errorToast(result['message']);
        } on Exception catch (e) {
          errorToast(e.toString());
        }
      });
    } on Exception catch (e) {
      log(e.toString());
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

  getInbox() async {
    isInboxLoading.value = true;

    try {
      dio.options.headers['Authorization'] = "Bearer $token";
      var response = await dio.get("/user/chat-inbox");

      try {
        inboxList.clear();
        inboxList = InboxModel.fromJson(response.data).data!.obs;
      } catch (e) {
        errorToast(InboxModel.fromJson(response.data).message.toString());
      }
    } on Exception catch (e) {
      log(e.toString());
    }
    isInboxLoading.value = false;
    inboxList.refresh();
    update();
  }

  Future<Uri> createDynamicLink(String videoName) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.fun/',
      link: Uri.parse('https://thrillvideo.s3.amazonaws.com/test/$videoName'),
      androidParameters: AndroidParameters(
        packageName: 'com.thrill',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',x
      //   appStoreId: 'your_app_store_id',
      // ),
    );
    var dynamicUrl = await parameters.buildShortLink();
    final Uri shortUrl = dynamicUrl.shortUrl;
    return shortUrl;
  }
}

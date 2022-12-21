import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as client;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/user_details_model.dart' as authUser;
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/utils/util.dart';

import '../../screens/home/landing_page_getx.dart';

class UserDetailsController extends GetxController
    with StateMixin<Rx<authUser.User>> {
  var storage = GetStorage();
  var userProfile = authUser.User().obs;

  var dio = client.Dio(client.BaseOptions(baseUrl: RestUrl.baseUrl));

  getUserProfile(userId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userProfile, status: RxStatus.loading());
    if (storage.read("token") == null || storage.read("userId") == null) {
      Get.to(LoginGetxScreen());
    } else {
      dio.post('/user/get-profile', queryParameters: {"id": userId}).then(
          (result) {
        userProfile =
            authUser.UserDetailsModel.fromJson(result.data).data!.user!.obs;
        change(userProfile, status: RxStatus.success());
      }).onError((error, stackTrace) {
        change(userProfile, status: RxStatus.error(error.toString()));
      });
    }
  }

  Future<void> socialLoginRegister(var social_login_id, social_login_type,
      email, phone, firebase_token, name) async {
    createDynamicLink().then((value) =>
        dio.post("/SocialLogin", queryParameters: {
          "social_login_id": social_login_id,
          "social_login_type": social_login_type,
          "email": email,
          // "phone": phone,
          "firebase_token": firebase_token,
          "name": name,
          "referral_code": value.toString(),
        }).then((value) async {
          userProfile =
              authUser.UserDetailsModel.fromJson(value.data).data!.user!.obs;

          await storage.write("userId",
              authUser.UserDetailsModel.fromJson(value.data).data!.user!.id!);

          await storage.write(
              "token",
              authUser.UserDetailsModel.fromJson(value.data)
                  .data!
                  .token!
                  .toString());

          //var userDB =
          //     await openDatabase(join(await getDatabasesPath(), "users.db"),
          //         onCreate: (db, version) {
          //   return db.execute(
          //       "CREATE TABLE users(id PRIMARY KEY, name TEXT, username TEXT,email TEXTdob TEXT,phone TEXT,avatar TEXT,socialLoginId TEXT,socialLoginType TEXT,firstName TEXT,lastName TEXT,gender TEXT,websiteUrl TEXT,bio TEXT,youtube TEXT, firebaseToken TEXT,referralCount TEXT,following TEXT, followers TEXT, likes TEXT,isVerified TEXT,totalVideos TEXT,boxTwo TEXT, boxThree TEXT,referralCode TEXT)");
          // }, version: 1);

          // final authDB =
          //     await openDatabase(join(await getDatabasesPath(), "auth.db"),
          //         onCreate: (db, version) {
          //   return db.execute("CREATE TABLE auth(token PRIMARY KEY)");
          // }, version: 1);
          // await userDB.insert("users", userProfile.value.toJson(),
          //     conflictAlgorithm: ConflictAlgorithm.replace);

          // await authDB.insert(
          //     "auth",
          //     {
          //       "token":
          //           authUser.UserDetailsModel.fromJson(value.data).data!.token!
          //     },
          //     conflictAlgorithm: ConflictAlgorithm.replace);

          change(userProfile, status: RxStatus.success());

          await storage.write("user", userProfile).then((_) {
            Get.forceAppUpdate();
            Get.to(LandingPageGetx());
          });
        }).onError((error, stackTrace) {
          change(userProfile, status: RxStatus.error(error.toString()));
        }));
  }

  Future<void> signInWithGoogle() async {
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
    // Once signed in, return the UserCredential
    await socialLoginRegister(googleUser.id, "google", googleUser.email, "",
        googleAuth.accessToken, googleUser.displayName ?? "");
  }

  Future<void> updateuserProfile(
      {File? profileImage,
      String? fullName,
      String? lastName,
      String? userName,
      String? bio,
      String? gender,
      String? webSiteUrl}) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    showLoadingDialog();
    if (profileImage != null) {
      client.FormData formData = client.FormData.fromMap({
        "avatar": profileImage != null
            ? await client.MultipartFile.fromFile(profileImage.path,
                filename: basename(profileImage.path))
            : "",
        "username": userName,
        "first_name": fullName,
        "last_name": lastName,
        "gender": gender,
        "bio": bio,
        "website_url": webSiteUrl
      });
      await dio.post("/user/edit", data: formData).then((value) {
        successToast(value.data["message"]);
        Get.offAll(LandingPageGetx());
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
      getUserProfile(storage.read("userId"));
      Get.back();
    } else {
      client.FormData formData = client.FormData.fromMap({
        "username": userName,
        "first_name": fullName,
        "last_name": lastName,
        "gender": gender,
        "bio": bio,
        "website_url": webSiteUrl
      });
      dio.post("/user/edit", data: formData).then((value) {
        successToast(value.data["message"]);
        Get.offAll(LandingPageGetx());
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
    }
    getUserProfile(storage.read("userId"));

    Get.back();
  }

  signinTrueCaller(var social_login_id, social_login_type, phone,
      firebase_token, name) async {
  dio.post("/SocialLogin", queryParameters: {
          "social_login_id": social_login_id,
          "social_login_type": social_login_type,
          "phone": phone,
          "firebase_token": firebase_token,
          "name": name,
          "referral_code": value.toString(),
        }).then((value) async {
          userProfile =
              authUser.UserDetailsModel.fromJson(value.data).data!.user!.obs;

          await storage
              .write('token',
                  authUser.UserDetailsModel.fromJson(value.data).data!.token!)
              .toString();
        }).onError((error, stackTrace) {});
  }

  Future<Uri> createDynamicLink({String videoName = ""}) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
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
    var dynamicUrl = parameters.link;
    final Uri shortUrl = dynamicUrl;
    return shortUrl;
  }
}

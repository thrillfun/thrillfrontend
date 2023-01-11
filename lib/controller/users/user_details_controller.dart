import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as client;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/user_details_model.dart' as authUser;
import 'package:thrill/controller/videos_controller.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/screens/auth/otp_verification.dart';
import 'package:thrill/utils/util.dart';

import '../../screens/home/landing_page_getx.dart';

class UserDetailsController extends GetxController
    with StateMixin<Rx<authUser.User>> {
  var storage = GetStorage();
  var userProfile = authUser.User().obs;
  var otherUserProfile = authUser.User().obs;

  var dio = client.Dio(client.BaseOptions(baseUrl: RestUrl.baseUrl));
  var qrData = "".obs;

  var isOtpSent = false.obs;
  Future<void> getUserProfile() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userProfile, status: RxStatus.loading());
    if (await storage.read("token") == null ||
        await storage.read("userId") == null) {
      Get.to(LoginGetxScreen());
    } else {
      dio.post('/user/get-profile', queryParameters: {"id": "${GetStorage().read("userId")}"}).then(
          (result) {
        userProfile =
            authUser.UserDetailsModel.fromJson(result.data).data!.user!.obs;
        change(userProfile, status: RxStatus.success());
      }).onError((error, stackTrace) {
        change(userProfile, status: RxStatus.error(error.toString()));
      });
    }
  }

  Future<void> getOtherUserProfile(userId) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    change(userProfile, status: RxStatus.loading());
    dio.post('/user/get-profile', queryParameters: {"id": userId}).then(
            (result) {
          otherUserProfile =
              authUser.UserDetailsModel.fromJson(result.data).data!.user!.obs;
          change(userProfile, status: RxStatus.success());
        }).onError((error, stackTrace) {
      change(userProfile, status: RxStatus.error(error.toString()));
    });
  }

  followUnfollowUser(int userId, String action, {int? id}) async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    dio.post("/user/follow-unfollow-user", queryParameters: {
      "publisher_user_id": userId,
      "action": action
    }).then((value) {
      if (value.data["status"] == true) {
        relatedVideosController.getAllVideos();
        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }

  Future<void> socialLoginRegister(var social_login_id, social_login_type,
      email, phone, firebase_token, name) async {
    dio.post("/SocialLogin", queryParameters: {
      "social_login_id": social_login_id,
      "social_login_type": social_login_type,
      "email": email,
      // "phone": phone,
      "firebase_token": firebase_token,
      "name": name,
      "referral_code": await createDynamicLink(social_login_id,"referal",name,email),
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

      change(userProfile, status: RxStatus.success());

      await storage.write("user", userProfile).then((_) {
        Get.forceAppUpdate();
        Get.to(LandingPageGetx());
      });
    }).onError((error, stackTrace) {
      change(userProfile, status: RxStatus.error(error.toString()));
    });

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

  Future<void> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: [
        'public_profile',
        'email',
        'pages_show_list',
        'pages_messaging',
        'pages_manage_metadata'
      ],
    );
    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken accessToken = result.accessToken!;
      final userData = await FacebookAuth.i.getUserData(
        fields: "name,email,picture.width(200),id,birthday,friends,gender,link",
      );
      await socialLoginRegister(userData["id"], "facebook", userData["email"],
          "", accessToken, userData["name"] ?? "");
    } else {
      print(result.status);
      print(result.message);
    }
    // by default we request the email and the public profile

    // Once signed in, return the UserCredential
  }

  Future<void> signOutUser() async {
    await storage.erase();
    await signOutGoogle();
    await signOutFacebook();
  }

  Future<void> signOutGoogle() async {
    try{
      final GoogleSignIn googleUser = GoogleSignIn(scopes: <String>["email"]);

      await GoogleSignIn().disconnect().catchError((e, stack) {});
      await FirebaseAuth.instance.signOut();
      googleUser.signOut();
    }
    on Exception catch(e){
      errorToast(e.toString());
    }
  }

  Future<void> signOutFacebook() async {
    final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
// or FacebookAuth.i.accessToken
    if (accessToken != null) {
      // user is logged
      await FacebookAuth.instance.logOut();
    }
  }

  Future<void> updateuserProfile(
      {File? profileImage,
      String? fullName,
      String? lastName,
      String? userName,
      String? bio,
      String? gender,
      String? webSiteUrl,
      String? dob,
      String? location,
      String? phone,
      String? email}) async {
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
        "name": fullName,
        "gender": gender,
        "bio": bio,
        "website_url": webSiteUrl,
        "dob": dob,
        "location": location,
        "phone": phone,
        "email": email
      });
      await dio.post("/user/edit", data: formData).then((value) {
        if (value.data["status"] == true) {
          successToast(value.data["message"]);
          Get.offAll(LandingPageGetx());
        } else {
          errorToast(value.data["message"]);
        }
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
    } else {
      client.FormData formData = client.FormData.fromMap({
        "username": userName,
        "name": fullName,
        "gender": gender,
        "bio": bio,
        "website_url": webSiteUrl,
        "dob": dob,
        "location": location,
        "phone": phone,
        "email": email
      });
      dio.post("/user/edit", data: formData).then((value) {
        if (value.data["status"] == true) {
          successToast(value.data["message"]);
          Get.offAll(LandingPageGetx());
        } else {
          errorToast(value.data["message"]);
        }
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
    }
    getUserProfile();
  }

  Future<void> signinTrueCaller(String social_login_id, String phone,
      String firebase_token, String name) async {

    dio.post("/SocialLogin", queryParameters: {
      "social_login_id": social_login_id,
      "social_login_type": "truecaller",
      "phone": phone,
      "firebase_token": firebase_token,
      "name": name,
       "referral_code": await createDynamicLink(social_login_id, "referal", name, firebase_token),
    }).then((value) async {
      try {
        if (value.data["status"] == true) {
          successToast(value.data["message"].toString());
          authUser.UserDetailsModel.fromJson(value.data).data!.user!.obs;

          await storage.write("userId",
              authUser.UserDetailsModel.fromJson(value.data).data!.user!.id!);

          await storage.write(
              "token",
              authUser.UserDetailsModel.fromJson(value.data)
                  .data!
                  .token!
                  .toString());

          change(userProfile, status: RxStatus.success());

          await storage.write("user", userProfile).then((_) {
            Get.forceAppUpdate();
            Get.to(LandingPageGetx());
          });
        } else {
          errorToast(value.data["message"]);
        }
      } on Exception catch (e) {
        print(e.toString());
      }
    }).onError((error, stackTrace) {});

  }

  Future<void> verifyOtp(String mobileNumber, String otp) async {
    dio.post("/verify-otp", queryParameters: {
      "phone": mobileNumber,
      "otp": otp,
    }).then((value) async {
      if (value.data["status"] == true) {
        successToast(value.data["message"]);

        authUser.UserDetailsModel.fromJson(value.data).data!.user!.obs;

        await storage.write("userId",
            authUser.UserDetailsModel.fromJson(value.data).data!.user!.id!);

        await storage
            .write(
                "token",
                authUser.UserDetailsModel.fromJson(value.data)
                    .data!
                    .token!
                    .toString())
            .then((value) {
          Get.offAll(LandingPageGetx());
        });
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }

  Future<void> sendOtp(String mobileNumber) async {
    dio.post("/send-otp", queryParameters: {"phone": mobileNumber}).then(
        (value) {
      if (value.data["status"] == true) {
        successToast(value.data["message"]);
        isOtpSent.value = true;
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }

  Future<String> createDynamicLink(String id,
      String? type, String? name, String? something) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.page.link/',
      link: Uri.parse(
          "https://thrill.fun?type=$type&id=$id&name=$name&something=$something"),
      androidParameters: const AndroidParameters(
        packageName: 'com.thrill.media',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',x
      //   appStoreId: 'your_app_store_id',
      // ),
    );
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildLink(parameters);

    qrData.value = dynamicLink.toString();
    return qrData.value;
  }
}

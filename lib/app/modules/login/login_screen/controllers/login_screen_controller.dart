import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sim_data/sim_data.dart';
import 'package:sim_data/sim_model.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart' as user;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../../../../rest/models/user_details_model.dart';
import '../../../../rest/rest_urls.dart';

import '';
import '../../../../utils/utils.dart';

class LoginScreenController extends GetxController with StateMixin<dynamic> {
  //TODO: Implement LoginScreenController
  var storage = GetStorage();
  var userProfile = User();
  var otherUserProfile = User();
  var isSimCardAvailable = true.obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var qrData = "".obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> printSimCardsData() async {
    SimData simData = await SimDataPlugin.getSimData();
    if (simData.cards.isEmpty) {
      isSimCardAvailable.value = false;
    } else {
      isSimCardAvailable.value = true;
    }
    Get.forceAppUpdate();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> socialLoginRegister(
      var social_login_id, social_login_type, email, phone, name) async {
    var firebase_token = await FirebaseMessaging.instance.getToken();
    dio.post("/SocialLogin", queryParameters: {
      "social_login_id": social_login_id,
      "social_login_type": social_login_type,
      "email": email,
      // "phone": phone,
      "firebase_token": firebase_token,
      "name": name,
      "referral_code": GetStorage().read("referral_code") == null
          ? ""
          : GetStorage().read("referral_code").toString()
    }).then((value) async {
      if (Get.isBottomSheetOpen!) {
        Get.back();
        Get.defaultDialog(
            title: "Signing you in Please wait",
            content: loader(),
            middleText: "");
      }
      if (value.data["status"]) {
        userProfile = UserDetailsModel.fromJson(value.data).data!.user!;

        await storage.write(
            "userId", UserDetailsModel.fromJson(value.data).data!.user!.id!);
        await storage.write(
            "name", UserDetailsModel.fromJson(value.data).data!.user!.name!);
        await storage.write("avatar",
            UserDetailsModel.fromJson(value.data).data!.user!.avatar!);
        await storage.write("username",
            UserDetailsModel.fromJson(value.data).data!.user!.username!);
        await storage.write("token",
            UserDetailsModel.fromJson(value.data).data!.token!.toString());
        // await FirebaseChatCore.instance
        //     .createUserInFirestore(
        //   types.User(
        //     firstName: userProfile.firstName,
        //     id: userProfile.id.toString(),
        //     // UID from Firebase Authentication
        //     imageUrl: userProfile.avatar.toString(),
        //     lastName: userProfile.lastName,
        //   ),
        // )
        //     .then((value) => print("Firebase result => success"));

        change(userProfile, status: RxStatus.success());

        await storage.write("user", userProfile).then((_) async {
          await Get.forceAppUpdate();
          Get.back(closeOverlays: true);
        });
        pushUserLoginCount("ip", "mac");

        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }

  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? googleUser =
        await GoogleSignIn(scopes: <String>["email"]).signIn();
    // fetch the auth details from the request made earlier
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    // Create a new credential for signing in with google
    final credential = user.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await socialLoginRegister(googleUser.id, "google", googleUser.email, "",
        googleUser.displayName ?? "");
  }

  Future<void> signOutUser() async {
    await storage.erase();
    await signOutGoogle();
  }

  Future<void> signOutGoogle() async {
    try {
      final GoogleSignIn googleUser = GoogleSignIn(scopes: <String>["email"]);

      await GoogleSignIn().disconnect().catchError((e, stack) {});
      await user.FirebaseAuth.instance.signOut();
      googleUser.signOut();
    } on Exception catch (e) {
      errorToast(e.toString());
    }
  }

  Future<void> signinTrueCaller(
      String social_login_id, String phone, String name) async {
    var firebase_token = await FirebaseMessaging.instance.getToken();
    dio.post("/SocialLogin", queryParameters: {
      "social_login_id": firebase_token,
      "social_login_type": "truecaller",
      "phone": phone,
      "firebase_token": firebase_token,
      "name": name,
      "referral_code": GetStorage().read("referal") == null
          ? ""
          : GetStorage().read("referal").toString()
    }).then((value) async {
      try {
        if (value.data["status"] == true) {
          successToast(value.data["message"].toString());
          UserDetailsModel.fromJson(value.data).data!.user!.obs;

          await storage.write(
              "userId", UserDetailsModel.fromJson(value.data).data!.user!.id!);

          await storage.write("token",
              UserDetailsModel.fromJson(value.data).data!.token!.toString());

          change(userProfile, status: RxStatus.success());

          await storage.write("user", userProfile).then((_) {
            Get.forceAppUpdate();
            Get.toNamed(Routes.HOME);
          });
          pushUserLoginCount("ip", "mac");
        } else {
          errorToast(value.data["message"]);
        }
      } on Exception catch (e) {
        print(e.toString());
      }
    }).onError((error, stackTrace) {});
  }

  pushUserLoginCount(String ip, String mac) async {
    if (GetStorage().read("token") != null) {
      dio.options.headers = {
        "Authorization": "Bearer ${await GetStorage().read("token")}"
      };
      dio.post("/user_login_history", queryParameters: {
        "ip": ip,
        "mac": mac,
      }).then((value) {
        print(value.data);
      }).onError((error, stackTrace) {
        print(error.toString());
      });
    }
  }
}

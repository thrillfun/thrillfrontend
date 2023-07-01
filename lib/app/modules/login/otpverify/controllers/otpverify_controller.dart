import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/rest/models/user_details_model.dart';
import 'package:thrill/app/rest/rest_urls.dart';

import '../../../../routes/app_pages.dart';
import '../../../../utils/utils.dart';

class OtpverifyController extends GetxController with StateMixin<dynamic> {
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var isOtpSent = false.obs;
  var storage = GetStorage();
  FocusNode fieldNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> sendOtp(String mobileNumber) async {
    dio.post("send-otp", queryParameters: {"phone": mobileNumber}).then(
        (value) {
      if (value.data["status"] == true) {
        successToast(value.data["message"]);
        isOtpSent.value = true;
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {});
  }

  Future<void> verifyOtp(String mobileNumber, String otp) async {
    Get.defaultDialog(content: loader());
    dio.post("/verify-otp", queryParameters: {
      "phone": mobileNumber,
      "otp": otp,
      "firebase_token": await FirebaseMessaging.instance.getToken()
    }).then((value) async {
      if (value.data["error"] == false) {
        successToast(value.data["message"]);
        Navigator.pop(Get.context!);
        UserDetailsModel.fromJson(value.data).data!.user!.obs;

        await storage.write(
            "userId", UserDetailsModel.fromJson(value.data).data!.user!.id!);

        await storage
            .write("token",
                UserDetailsModel.fromJson(value.data).data!.token!.toString())
            .then((value) {
          pushUserLoginCount("ip", "mac");
          Get.toNamed(Routes.HOME);
        });
      } else {
        errorToast(value.data["message"]);
      }

      Get.back();
    }).onError((error, stackTrace) {
      Get.back();
    });
    Get.back();
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

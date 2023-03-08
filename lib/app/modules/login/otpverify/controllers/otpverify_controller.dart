import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    var firebase_token = await FirebaseMessaging.instance.getToken();
    Get.defaultDialog(
      content: loader()
    );
    dio.post("/verify-otp", queryParameters: {
      "phone": mobileNumber,
      "otp": otp,
      "firebase_token": firebase_token
    }).then((value) async {
      if (value.data["status"] == true) {
        successToast(value.data["message"]);

        UserDetailsModel.fromJson(value.data).data!.user!.obs;

        await storage.write("userId",
            UserDetailsModel.fromJson(value.data).data!.user!.id!);

        await storage
            .write(
            "token",
            UserDetailsModel.fromJson(value.data)
                .data!
                .token!
                .toString())
            .then((value) {
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
}

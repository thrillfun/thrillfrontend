import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/color_manager.dart';
import '../../../../utils/strings.dart';
import '../../otpverify/views/otpverify_view.dart';
import '../controllers/login_screen_controller.dart';

class LoginScreenView extends GetView<LoginScreenController> {
  LoginScreenView(this.isPhoneAvailable);
  var isPhoneAvailable = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          loginLayout(),
          Visibility(
            visible: isPhoneAvailable.value,
            child: InkWell(
                onTap: () {
                  TruecallerSdk.initializeSDK(
                      consentMode: TruecallerSdkScope.CONSENT_MODE_BOTTOMSHEET,
                      sdkOptions: TruecallerSdkScope.SDK_OPTION_WITH_OTP,
                      termsOfServiceUrl: "www.google.com",
                      privacyPolicyUrl: "www.google.com",
                      buttonColor: 0xff2DCBC8,
                      ctaTextPrefix: 0,
                      loginTextPrefix: 0,
                      consentTitleOptions: 1,
                      footerType: 256);
                  TruecallerSdk.isUsable.then((isUsable) {
                    if (isUsable) {
                      TruecallerSdk.getProfile;
                    } else {
                      const GetSnackBar(
                              title: "Truecaller not available",
                              message:
                                  "You cannot use trucaller on this device")
                          .show();
                    }
                  });
                },
                child: Container(
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 40, bottom: 20),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey)),
                    child: Row(
                      children: const [
                        Icon(
                          BoxIcons.bx_phone,
                        ),
                        Expanded(
                            child: Text(
                          "Truecaller",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ))
                      ],
                    ))),
          ),
          InkWell(
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) => Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: OtpverifyView()));
              },
              child: Container(
                  margin:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey)),
                  child: Row(
                    children: [
                      const Icon(
                        BoxIcons.bx_message,
                      ),
                      Expanded(
                          child: Container(
                        alignment: Alignment.center,
                        child: const Text(
                          "Login via OTP",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ))
                    ],
                  ))),
          InkWell(
            onTap: () async => await controller
                .signInWithGoogle()
                .then((value) => Navigator.pop(context)),
            child: Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, top: 0, bottom: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey)),
              child: Row(
                children: [
                  const Icon(
                    BoxIcons.bxl_google,
                  ),
                  Flexible(
                    child: Container(
                      width: Get.width,
                      alignment: Alignment.center,
                      child: const Text(
                        "Google",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SizedBox(
              child: Text.rich(TextSpan(children: [
                const TextSpan(
                  text: "By Login or Sign Up, you agree to our",
                ),
                TextSpan(
                    text: " Terms of Service ",
                    style:
                        const TextStyle(color: ColorManager.colorPrimaryLight),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async => {
                            launchUrl(Uri.parse(termsOfServiceUrl),
                                mode: LaunchMode.externalApplication)
                          }),
                const TextSpan(
                  text: "and ",
                ),
                TextSpan(
                    text: "Privacy Policy ",
                    style:
                        const TextStyle(color: ColorManager.colorPrimaryLight),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async => {
                            launchUrl(Uri.parse(privacyPolicyUrl),
                                mode: LaunchMode.externalApplication)
                          })
              ])),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  loginLayout() => Column(children: [
        Container(
          margin: const EdgeInsets.only(left: 10, top: 10),
          width: Get.width,
          child: const Text(
            'Hello there, welcome back.',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        loginTextLayout(),
      ]);

  loginTextLayout() => Container(
        margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
        width: Get.width,
        child: const Text(
          'You can Avail this invite by logging in or signing up.',
          style: TextStyle(fontSize: 20),
        ),
      );

  // trueCallerLayout()=> ;
  submitButtonLayout() => InkWell(
        child: const Text(
          "Phone Number",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        onTap: () {
          if (Get.isBottomSheetOpen!) {
            Get.back();
          }
          Get.bottomSheet(
              Container(
                margin: const EdgeInsets.all(10),
                child: OtpverifyView(),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)));
        },
      );

  StreamSubscription streamSubscription =
      TruecallerSdk.streamCallbackData.listen((truecallerSdkCallback) async {
    switch (truecallerSdkCallback.result) {
      case TruecallerSdkCallbackResult.success:
        String firstName = truecallerSdkCallback.profile!.firstName;
        String? lastName = truecallerSdkCallback.profile!.lastName;
        String phNo = truecallerSdkCallback.profile!.phoneNumber;

        var random = Random.secure();
        var values = List<int>.generate(10, (i) => random.nextInt(255));
        var token = base64UrlEncode(values);
        await LoginScreenController().signinTrueCaller(token,
            phNo.substring(3, 13), firstName + " " + lastName.toString());
        break;
      case TruecallerSdkCallbackResult.failure:
        int errorCode = truecallerSdkCallback.error!.code;
        break;
      case TruecallerSdkCallbackResult.verification:
        // Get.to(const NonTcVerification());
        break;
      default:
        print("Invalid result");
    }
  });
}

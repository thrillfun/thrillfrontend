import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/modules/login/otpverify/views/otpverify_view.dart';

import '../../../utils/color_manager.dart';
import '../../../utils/strings.dart';
import '../controllers/login_controller.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sim_data/sim_data.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginView extends GetView<LoginController> {
  LoginView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            ),
        height: Get.height,
        width: Get.width,
        child: Column(
          children: [
            loginLayout(),
            const SizedBox(
              height: 10,
            ),
            Visibility(
              visible: controller.isSimCardAvailable.isTrue,
              child: InkWell(
                  onTap: () {
                    TruecallerSdk.initializeSDK(
                        consentMode:
                        TruecallerSdkScope.CONSENT_MODE_BOTTOMSHEET,
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
                        children: [
                          Icon(
                            BoxIcons.bx_phone,
                          ),
                          Expanded(
                              child: Text(
                                "Login with phone",
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
                onTap: ()  {
                  if(Get.isBottomSheetOpen!){
                    Get.back();

                  }
                  Get.bottomSheet(
                      OtpverifyView(),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)));
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
                        Icon(
                          BoxIcons.bx_message,
                        ),
                        Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
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
              onTap: () async => await controller.signInWithGoogle(),
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
                    Icon(
                      BoxIcons.bxl_google,
                    ),
                    Flexible(
                      child: Container(
                        width: Get.width,
                        alignment: Alignment.center,
                        child: Text(
                          "Login with google",
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
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: SizedBox(
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                          text: "By Login or Sign Up, you agree to our",
                          ),
                      TextSpan(
                          text: " Terms of Service ",

                          recognizer: TapGestureRecognizer()
                            ..onTap = () async => {
                              launchUrl(Uri.parse(termsOfServiceUrl),
                                  mode: LaunchMode.externalApplication)
                            }),
                      TextSpan(
                          text: "and ",
                          ),
                      TextSpan(
                          text: "Privacy Policy ",
                          style: const TextStyle(
                              color: ColorManager.colorPrimaryLight),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async => {
                              launchUrl(Uri.parse(privacyPolicyUrl),
                                  mode: LaunchMode.externalApplication)
                            })
                    ])),
              ),
            ),
          ],
        ),
      ),
    );
  }
  loginLayout() => Column(
    children: [
      Container(
        margin: const EdgeInsets.only(left: 20, top: 10),
        width: Get.width,
        child: Text(
          'Login or Sign up ',
          textAlign: TextAlign.left,
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
             ),
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 20, top: 10, right: 10),
        width: Get.width,
        child: Text(
          'Make your own videos, Follow other accounts, Discover new trends and earn Free Bitcoin while doing so.',
          style: TextStyle(fontSize: 14),
        ),
      ),

      // Container(
      //   margin:
      //       const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      //   width: Get.width,
      //   decoration: BoxDecoration(
      //       color: const Color(0xff353841),
      //       border: Border.all(color: Colors.transparent),
      //       borderRadius: const BorderRadius.all(Radius.circular(10))),
      //   child: TextFormField(
      //     // onFieldSubmitted: (text)=> mobileNumber.value = text,
      //     onChanged: (text) => mobileNumber.value = text,
      //     style: const TextStyle(color: Colors.white),
      //     decoration: InputDecoration(
      //       hintText: "Mobile Number",
      //       hintStyle: const TextStyle(color: Colors.grey),
      //       isDense: true,
      //       counterText: '',
      //       border:
      //           OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      //       focusedBorder: OutlineInputBorder(
      //           borderSide:
      //               const BorderSide(color: ColorManager.colorPrimaryLight),
      //           borderRadius: BorderRadius.circular(10)),
      //     ),
      //   ),
      // ),
      // Container(
      //   margin:
      //       const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      //   width: Get.width,
      //   decoration: BoxDecoration(
      //       color: const Color(0xff353841),
      //       border: Border.all(color: Colors.transparent),
      //       borderRadius: const BorderRadius.all(Radius.circular(10))),
      //   child: TextFormField(
      //     onChanged: (text) {
      //       password.value = text;
      //     },
      //     obscureText: true,
      //     enableSuggestions: false,
      //     autocorrect: false,
      //     style: const TextStyle(color: Colors.white),
      //     decoration: InputDecoration(
      //       hintText: "Password",
      //       hintStyle: const TextStyle(color: Colors.grey),
      //       isDense: true,
      //       counterText: '',
      //       border:
      //           OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      //       focusedBorder: OutlineInputBorder(
      //           borderSide:
      //               const BorderSide(color: ColorManager.colorPrimaryLight),
      //           borderRadius: BorderRadius.circular(10)),
      //     ),
      //   ),
      // ),
    ],
  );

  // trueCallerLayout()=> ;
  submitButtonLayout() => InkWell(
    child: Text(
      "Login via OTP",
      style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          ),
    ),
    onTap: () {
      if(Get.isBottomSheetOpen!){
        Get.back();

      }
      Get.bottomSheet(
          Container(
            margin: const EdgeInsets.all(10),
            child: OtpverifyView(),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)));
    } ,
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
        await LoginController().signinTrueCaller(phNo, phNo.substring(3, 13),
            token, firstName + " " + lastName.toString());
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


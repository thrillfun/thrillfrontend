import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/screens/home/home.dart';
import 'package:thrill/screens/home/home_getx.dart';
import 'package:thrill/screens/truecaller/non_tc_verification.dart';
import 'package:thrill/screens/truecaller/truecaller.dart';
import 'package:thrill/utils/util.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

var isManualVerification = false.obs;
TruecallerSdkCallbackResult? tempResult;
late StreamSubscription? streamSubscription;
var usersController = Get.find<UserController>();

class LoginGetxScreen extends StatelessWidget {
  LoginGetxScreen({Key? key}) : super(key: key);
  var mobileNumber = "".obs;
  var password = ''.obs;
  final Stream<TruecallerSdkCallback> _stream =
      TruecallerSdk.streamCallbackData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: Get.width,
          height: Get.height,
          decoration: const BoxDecoration(gradient: gradient),
          child: SafeArea(
            child: Column(
              children: [
                Image.asset(
                  "assets/logo.png",
                  width: Get.width / 3,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 40,
                ),
                loginLayout(),
                submitButtonLayout(),
                const SizedBox(
                  child: Text(
                    'Or',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                trueCallerLoginLayout(),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: const [
                    Expanded(
                        child: Divider(
                      indent: 10,
                      endIndent: 10,
                      color: Colors.white,
                      thickness: 1,
                    )),
                    SizedBox(
                      child: Text(
                        'Sign in with facebook or google',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                      color: Colors.white,
                      thickness: 1,
                      indent: 10,
                      endIndent: 10,
                    ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => {},
                      child: Expanded(
                        child: Container(
                            margin: EdgeInsets.only(
                                left: 10, right: 10, top: 40, bottom: 20),
                            padding: EdgeInsets.only(
                                top: 20, bottom: 20, left: 10, right: 10),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: ColorManager.colorPrimaryLight)),
                            child: Row(
                              children: const [
                                Iconify(Logos.facebook),
                                Text(
                                  "    Login with facebook",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                )
                              ],
                            )),
                      ),
                    ),
                    InkWell(
                      onTap: () => usersController.signInWithGoogle(),
                      child: Expanded(
                          child: Container(
                        margin: EdgeInsets.only(
                            left: 10, right: 10, top: 40, bottom: 20),
                        padding: EdgeInsets.only(
                            top: 20, bottom: 20, left: 10, right: 10),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: ColorManager.colorPrimaryLight)),
                        child: Row(
                          children: const [
                            Iconify(Logos.google_icon),
                            Text(
                              "    Login with google",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            )
                          ],
                        ),
                      )),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: RichText(
                      text: TextSpan(children: [
                    const TextSpan(text: "Don't have an account?"),
                    const TextSpan(text: " "),
                    TextSpan(
                        text: "SignUp",
                        style: TextStyle(color: ColorManager.colorPrimaryLight),
                        recognizer: TapGestureRecognizer()..onTap = () => {})
                  ])),
                ),
              ],
            ),
          )),
    );
  }

  loginLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, top: 10),
            width: Get.width,
            child: const Text(
              'Welcome Back',
              style: TextStyle(
                  fontSize: 25, color: ColorManager.colorPrimaryLight),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, top: 10, right: 10),
            width: Get.width,
            child: const Text(
              'We are happy to see you again. To use your account, you should login first',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            width: Get.width,
            decoration: BoxDecoration(
                color: const Color(0xff353841),
                border: Border.all(color: Colors.transparent),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: TextFormField(
              onChanged: (text) => mobileNumber.value = text,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Mobile Number",
                hintStyle: const TextStyle(color: Colors.grey),
                isDense: true,
                counterText: '',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: ColorManager.colorPrimaryLight),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            width: Get.width,
            decoration: BoxDecoration(
                color: const Color(0xff353841),
                border: Border.all(color: Colors.transparent),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: TextFormField(
              onChanged: (text) {
                password.value = text;
              },
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Password",
                hintStyle: const TextStyle(color: Colors.grey),
                isDense: true,
                counterText: '',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: ColorManager.colorPrimaryLight),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // trueCallerLayout()=> ;
  submitButtonLayout() => InkWell(
        onTap: () async {
          usersController.loginUser(mobileNumber.value, password.value);
        },
        child: Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorManager.colorPrimaryLight,
                    ColorManager.colorAccent
                  ])),
          child: const Text(
            "Login",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );

  initTrueCallerLogin() {
    TruecallerSdk.initializeSDK(
        sdkOptions: TruecallerSdkScope.SDK_OPTION_WITH_OTP);
    TruecallerSdk.isUsable.then((isUsable) {
      if (isUsable) {
        TruecallerSdk.getProfile;

        TruecallerSdk.streamCallbackData.listen((event) {
          if (event.result == TruecallerSdkCallbackResult.success) {
            Get.to(BottomNavigation());
          }
          if (event.result == TruecallerSdkCallbackResult.verification) {
            Get.bottomSheet(manualVerification())
                .then((value) => createStreamBuilder());
          }
          if (event.result ==
              TruecallerSdkCallbackResult.verificationComplete) {
            Get.to(BottomNavigation());
          }
        });
      } else {
        var snackBar = const SnackBar(content: Text("Not Usable"));
        ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
        print("***Not usable***");
      }
    });
  }

  trueCallerLoginLayout() => InkWell(
        onTap: () async {
          initTrueCallerLogin();
        },
        child: Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorManager.colorPrimaryLight,
                    ColorManager.colorAccent
                  ])),
          child: const Text(
            "Login via truecaller",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );

  manualVerification() => Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      left: 10, right: 10, top: 10, bottom: 10),
                  width: Get.width,
                  decoration: BoxDecoration(
                      color: const Color(0xff353841),
                      border: Border.all(color: const Color(0xff353841)),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: TextFormField(
                    initialValue: mobileNumber.value,
                    onChanged: (text) => mobileNumber.value = text,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Mobile Number",
                      hintStyle: const TextStyle(color: Colors.grey),
                      isDense: true,
                      counterText: '',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: () => onProceedClick(), child: Text('Verify'))
              ],
            ),
          ),
        ),
      );

  void createStreamBuilder() {
    streamSubscription =
        TruecallerSdk.streamCallbackData.listen((truecallerUserCallback) {
      // make sure you're changing state only after number has been entered. there could be case
      // where user initiated missed call, pressed back, and came to this screen again after
      // which the call was received and hence it would directly open input name screen.
      if (mobileNumber.value.length == 10) {
        if (truecallerUserCallback.result !=
            TruecallerSdkCallbackResult.exception) {
          tempResult = truecallerUserCallback.result;
        }
        // showProgressBar =
        //     tempResult == TruecallerSdkCallbackResult.missedCallInitiated;
        // if (tempResult == TruecallerSdkCallbackResult.otpReceived) {
        //   otpController.text = truecallerUserCallback.otp!;
        // }
      }

      switch (truecallerUserCallback.result) {
        case TruecallerSdkCallbackResult.missedCallInitiated:
          // startCountdownTimer(
          //     double.parse(truecallerUserCallback.ttl!).floor());
          successToast(
              "Missed call Initiated with TTL : ${truecallerUserCallback.ttl}");
          break;
        case TruecallerSdkCallbackResult.missedCallReceived:
          // showSnackBar("Missed call Received");
          break;
        case TruecallerSdkCallbackResult.otpInitiated:
          // startCountdownTimer(
          //     double.parse(truecallerUserCallback.ttl!).floor());
          successToast(
              "OTP Initiated with TTL : ${truecallerUserCallback.ttl}");
          break;
        case TruecallerSdkCallbackResult.otpReceived:
          successToast("Your Otp is : ${truecallerUserCallback.otp}");
          // showSnackBar("OTP Received : ${truecallerUserCallback.otp}");
          break;
        case TruecallerSdkCallbackResult.verificationComplete:
          successToast(
              "Verification Completed : ${truecallerUserCallback.accessToken}");
          // showSnackBar(
          //     "Verification Completed : ${truecallerUserCallback.accessToken}");
          // _navigateToResult(fNameController.text);
          Get.to(BottomNavigation());

          break;
        case TruecallerSdkCallbackResult.verifiedBefore:
          successToast("truecallerUserCallback.profile!.accessToken}");
          // showSnackBar(
          //     "Verified Before : ${truecallerUserCallback.profile!.accessToken}");
          // _navigateToResult(truecallerUserCallback.profile!.firstName);

          Get.to(BottomNavigation());
          break;
        case TruecallerSdkCallbackResult.exception:
          showErrorToast(
              Get.context!,
              "${truecallerUserCallback.exception!.code}, "
              "${truecallerUserCallback.exception!.message}");
          // showSnackBar("Exception : ${truecallerUserCallback.exception!.code}, "
          //     "${truecallerUserCallback.exception!.message}");
          break;
        default:
          print(tempResult.toString());
          break;
      }
    });
  }

  void onProceedClick() {
    if (mobileNumber.value.length == 10) {
      // setProgressBarToActive();
      TruecallerSdk.requestVerification(phoneNumber: mobileNumber.value);
    }
  }
}

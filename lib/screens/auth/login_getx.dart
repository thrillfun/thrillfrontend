import 'dart:async';

import 'package:colorful_iconify_flutter/icons/logos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
                  //   trueCallerLoginLayout(),
                  const SizedBox(
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
                  InkWell(
                      onTap: () => {},
                      child: Container(
                          margin: const EdgeInsets.only(
                              left: 5, right: 5, top: 40, bottom: 10),
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: ColorManager.colorPrimaryLight)),
                          child: Row(
                            children: const [
                              Iconify(Logos.facebook),
                              Expanded(
                                child: Text(
                                  "Login with facebook",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontSize: 16),
                                ),
                              )
                            ],
                          ))),
                  InkWell(
                    onTap: () => usersController.signInWithGoogle(),
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 5, right: 5, top: 0, bottom: 20),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: ColorManager.colorPrimaryLight)),
                      child: Row(
                        children: const [
                          Iconify(Logos.google_icon),
                          Expanded(
                            child: Text(
                              "Login with google",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 16),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // SizedBox(
                  //   child: RichText(
                  //       text: TextSpan(children: [
                  //         const TextSpan(text: "Don't have an account?"),
                  //         const TextSpan(text: " "),
                  //         TextSpan(
                  //             text: "SignUp",
                  //             style: const TextStyle(color: ColorManager.colorPrimaryLight),
                  //             recognizer: TapGestureRecognizer()..onTap = () => {})
                  //       ])),
                  // ),
                ],
              ),
            )),
      ),
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
            margin: const EdgeInsets.only(left: 20, top: 10),
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
              // onFieldSubmitted: (text)=> mobileNumber.value = text,
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
      ),
    );
  }

  // trueCallerLayout()=> ;
  submitButtonLayout() => InkWell(
        onTap: () async {
          TruecallerSdk.streamCallbackData.listen((event) {
            switch (event.result) {
              case TruecallerSdkCallbackResult.success:
                {
                  String firstName = event.profile!.firstName;
                  String? lastName = event.profile!.lastName;
                  String phNo = event.profile!.phoneNumber;
                  Get.snackbar("title", "yay");
                  Get.back();
                  Get.to(BottomNavigation());

                }
                break;
              case TruecallerSdkCallbackResult.failure:
                Get.snackbar("title", "failed");
                break;
              case TruecallerSdkCallbackResult.verification:
                TruecallerSdk.requestVerification(phoneNumber: "9001155788");
                break;
              case TruecallerSdkCallbackResult.verificationComplete:
                Get.to(BottomNavigation());
                break;
            }
          });
          // usersController.loginUser(mobileNumber.value, password.value);
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

}

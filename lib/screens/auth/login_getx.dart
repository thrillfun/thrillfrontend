import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:colorful_iconify_flutter/icons/logos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/auth_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/screens/truecaller/non_tc_verification.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

var authController = Get.find<AuthController>();
var usersController = Get.find<UserController>();

class LoginGetxScreen extends StatelessWidget {
  LoginGetxScreen({Key? key}) : super(key: key);
  var mobileNumber = "".obs;
  var password = ''.obs;
  final Stream<TruecallerSdkCallback>? _stream =
      TruecallerSdk.streamCallbackData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(child: Container(
          height: Get.height,
          width: Get.width,
          child: Column(
          children: [
            ClipOval(
              child: Image.asset(
                "assets/logo.png",
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),

            loginLayout(),

            //   trueCallerLoginLayout(),

            // Row(
            //   children: const [
            //     Expanded(
            //         child: Divider(
            //       indent: 10,
            //       endIndent: 10,
            //       color: Colors.white,
            //       thickness: 1,
            //     )),
            //     SizedBox(
            //       child: Text(
            //         'Sign in with facebook or google',
            //         style: TextStyle(
            //             color: Colors.white,
            //             fontWeight: FontWeight.bold,
            //             fontSize: 14),
            //       ),
            //     ),
            //     Expanded(
            //         child: Divider(
            //       color: Colors.white,
            //       thickness: 1,
            //       indent: 10,
            //       endIndent: 10,
            //     ))
            //   ],
            // ),
            InkWell(
                onTap: () {
                  TruecallerSdk.initializeSDK(
                      sdkOptions: TruecallerSdkScope.SDK_OPTION_WITH_OTP);
                  TruecallerSdk.isUsable.then((isUsable) {
                    if (isUsable) {
                      TruecallerSdk.getProfile;
                    } else {
                      final snackBar = SnackBar(content: Text("Not Usable"));
                      ScaffoldMessenger.of(Get.context!).showSnackBar(snackBar);
                      print("***Not usable***");
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Iconify(Logos.trello),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Login with phone number",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        )
                      ],
                    ))),
            InkWell(
                onTap: () => {},
                child: Container(
                    margin:
                    const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    padding: const EdgeInsets.all(15),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Iconify(Logos.facebook),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Login with facebook",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        )
                      ],
                    ))),
            InkWell(
              onTap: () async => await usersController.signInWithGoogle(),
              child: Container(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, top: 0, bottom: 20),
                padding: const EdgeInsets.all(15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Iconify(Logos.google_icon),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Login with google",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              child: Text(
                'Or',
                style: TextStyle(fontSize: 18),
              ),
            ),
            submitButtonLayout(),

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
        ),),),
      ),
    );
  }

  loginLayout() => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, top: 10),
            width: Get.width,
            child: Text(
              'Lets you in',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, top: 10, right: 10),
            width: Get.width,
            child: const Text(
              'We are happy to see you again. To use your account, you should login first',
              style: TextStyle(fontSize: 16),
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
        onTap: () async {
          //  usersController.loginUser(mobileNumber.value, password.value);
        },
        child: Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: ColorManager.colorPrimaryLight,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: const Text(
            "Login with phone number",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      );

  StreamSubscription streamSubscription =
      TruecallerSdk.streamCallbackData.listen((truecallerSdkCallback) {
    switch (truecallerSdkCallback.result) {
      case TruecallerSdkCallbackResult.success:
        String firstName = truecallerSdkCallback.profile!.firstName;
        String? lastName = truecallerSdkCallback.profile!.lastName;
        String phNo = truecallerSdkCallback.profile!.phoneNumber;


        var random = Random.secure();
        var values = List<int>.generate(10, (i) =>  random.nextInt(255));
        var token =  base64UrlEncode(values);
      usersController.signinTrueCaller(
            token,
            "truecaller",
            truecallerSdkCallback.profile!.phoneNumber.substring(3,13),
            token,
            truecallerSdkCallback.profile!.firstName);
        break;
      case TruecallerSdkCallbackResult.failure:
        int errorCode = truecallerSdkCallback.error!.code;
        break;
      case TruecallerSdkCallbackResult.verification:
        Get.to(NonTcVerification());
        break;
      default:
        print("Invalid result");
    }
  });


}

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sim_data/sim_data.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/screens/truecaller/non_tc_verification.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/gradient_elevated_button.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

var usersController = Get.find<UserDetailsController>();

class LoginGetxScreen extends StatelessWidget {
  LoginGetxScreen({Key? key}) : super(key: key);
  var mobileNumber = "".obs;
  var password = ''.obs;
  final Stream<TruecallerSdkCallback>? _stream =
      TruecallerSdk.streamCallbackData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.dayNight,
      body: SafeArea(
        child: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Column(
            children: [
              loginLayout(),
            const SizedBox(height: 10,),
             Visibility(
               visible: usersController.isSimCardAvailable.isTrue,
               child:  InkWell(
                 onTap: () {
                   TruecallerSdk.initializeSDK(
                       sdkOptions: TruecallerSdkScope.SDK_OPTION_WITH_OTP);
                   TruecallerSdk.isUsable.then((isUsable) {
                     if (isUsable) {
                       TruecallerSdk.getProfile;
                     } else {
                       const GetSnackBar(title: "Truecaller not available",
                           message: "You cannot use trucaller on this device").show();
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
                         Icon(BoxIcons.bx_phone,
                           color: ColorManager.dayNightIcon,),
                         Expanded(
                             child: Text(
                               "Login with phone",
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                   fontWeight: FontWeight.w700,
                                   fontSize: 16,
                                   color: ColorManager.dayNightText),
                             ))
                       ],
                     ))),),
              InkWell(
                  onTap: () =>
                  {
                    Get.bottomSheet(
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: VerifyOtpLayout(),
                        ),
                        backgroundColor: ColorManager.dayNight)
                  },
                  child: Container(
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey)),
                      child: Row(
                        children: [
                          Icon(BoxIcons.bx_message,
                            color: ColorManager.dayNightIcon,),
                          Expanded(child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Login via OTP",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: ColorManager.dayNightText),
                            ),))
                        ],
                      ))),
              InkWell(
                onTap: () async => await usersController.signInWithGoogle(),
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
                        BoxIcons.bxl_google, color: ColorManager.dayNightIcon,),
                      Flexible(
                        child: Container(
                          width: Get.width,
                          alignment: Alignment.center,
                          child: Text(
                            "Login with google",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: ColorManager.dayNightText),
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
        ),
      ),
    );
  }


  loginLayout() =>
      Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, top: 10),
            width: Get.width,
            child: Text(
              'Lets you in',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.dayNightText),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, top: 10, right: 10),
            width: Get.width,
            child: Text(
              'We are happy to see you again. To use your account, you should login first',
              style: TextStyle(fontSize: 16, color: ColorManager.dayNightText),
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
  submitButtonLayout() =>
      InkWell(
        child: Text(
          "Login via OTP",
          style: TextStyle(fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ColorManager.dayNightText),
        ),
        onTap: () =>
            Get.bottomSheet(
                Container(
                  margin: const EdgeInsets.all(10),
                  child: VerifyOtpLayout(),
                ),
                backgroundColor: ColorManager.dayNight),
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
        await usersController.signinTrueCaller(phNo, phNo.substring(3, 13),
            token, firstName + " " + lastName.toString());
        break;
      case TruecallerSdkCallbackResult.failure:
        int errorCode = truecallerSdkCallback.error!.code;
        break;
      case TruecallerSdkCallbackResult.verification:
        Get.to(const NonTcVerification());
        break;
      default:
        print("Invalid result");
    }
  });
}

class VerifyOtpLayout extends GetView<UserDetailsController> {
  VerifyOtpLayout({Key? key}) : super(key: key);
  FocusNode fieldNode = FocusNode();
  TextEditingController phoneController = TextEditingController();

  var otp = "".obs;

  @override
  Widget build(BuildContext context) {
    _listenSmsCode();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Login via OTP",
          style: TextStyle(fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ColorManager.dayNightText),
        ),
        Container(
          child: TextFormField(
            focusNode: fieldNode,
            controller: phoneController,
            maxLength: 10,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              focusColor: ColorManager.colorAccent,
              fillColor: fieldNode.hasFocus
                  ? ColorManager.colorAccentTransparent
                  : Colors.grey.withOpacity(0.1),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: fieldNode.hasFocus
                    ? const BorderSide(
                  color: Color(0xff2DCBC8),
                )
                    : const BorderSide(
                  color: Color(0xffFAFAFA),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: fieldNode.hasFocus
                    ? const BorderSide(
                  color: Color(0xff2DCBC8),
                )
                    : BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
              filled: true,
              prefixIcon: Icon(
                Icons.call,
                color: fieldNode.hasFocus
                    ? ColorManager.colorAccent
                    : Colors.grey.withOpacity(0.3),
              ),
              prefixText: "+91",
              prefixStyle: TextStyle(
                  color: fieldNode.hasFocus
                      ? const Color(0xff2DCBC8)
                      : Colors.grey,
                  fontSize: 16),
              labelText: "Enter Phone number",
              labelStyle: TextStyle(
                  color: fieldNode.hasFocus
                      ? ColorManager.colorAccent
                      : Colors.grey,
                  fontSize: 16),
              hintText: "99999-99999",
              hintStyle: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                  fontSize: 16),
            ),
          ),
        ),
        InkWell(
          child: const Text("SEND OTP",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.colorAccent,
                  decoration: TextDecoration.underline)),
          onTap: () async {
            if (phoneController.text.isNotEmpty &&
                phoneController.text.length == 10) {
              await controller.sendOtp(phoneController.text);
            } else {
              phoneController.text.isEmpty
                  ? errorToast("field empty")
                  : phoneController.text.length != 10
                  ? errorToast("please enter 10 digits")
                  : errorToast("number is not correct");
            }
          },
        ),
        Obx(() =>
            Visibility(
                visible: controller.isOtpSent.isTrue,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  child: PinFieldAutoFill(
                      decoration: UnderlineDecoration(
                          colorBuilder:
                          FixedColorBuilder(ColorManager.dayNightText),
                          textStyle: TextStyle(
                              color: ColorManager.dayNightText)),
                      onCodeSubmitted: ((p0) => {}), //code submitted callback
                      onCodeChanged: ((p0) =>
                      {otp.value = p0.toString()}), //code changed callback
                      codeLength: 4 //code length, default 6
                  ),
                ))),
        Obx(() =>
            Visibility(
                visible: controller.isOtpSent.isTrue,
                child: GradientElevatedButton(
                    onPressed: () async =>
                        controller.verifyOtp(phoneController.text, otp.value),
                    child: const Text("submit"))))
      ],
    );
  }

  _listenSmsCode() async {
    await SmsAutoFill().listenForCode();
  }
}

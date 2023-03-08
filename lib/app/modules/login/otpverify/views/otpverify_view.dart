import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:thrill/app/utils/strings.dart';

import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/otpverify_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sim_data/sim_data.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'package:url_launcher/url_launcher.dart';

class OtpverifyView extends GetView<OtpverifyController> {
   OtpverifyView({Key? key}) : super(key: key);
  FocusNode fieldNode = FocusNode();
  TextEditingController phoneController = TextEditingController();

  var otp = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Login via OTP",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
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
                prefixText: "+91 ",
                prefixStyle: TextStyle(
                    color: fieldNode.hasFocus
                        ? ColorManager.colorAccent
                        : Colors.grey,
                    fontSize: 16),
                labelText: "Enter Phone number",
                labelStyle: TextStyle(
                    color: fieldNode.hasFocus
                        ? ColorManager.colorAccent
                        : Colors.grey,
                    fontSize: 16),
                hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                    fontSize: 16),
              ),
            ),
          ),
          InkWell(
            child: Container(
              width: Get.width,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ColorManager.colorAccent),
              child: const Text("SEND OTP",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  )),
            ),
            onTap: () async {
              if (phoneController.text.isNotEmpty &&
                  phoneController.text.length == 10) {
                await controller.sendOtp(phoneController.text);
                String test = phoneController.text;
                int numSpace = 5;
                String result = test.replaceRange(0, numSpace, '*' * numSpace);
                if(Get.isBottomSheetOpen!){
                  Get.back();

                }
                Get.bottomSheet(
                    Scaffold(
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: Get.width,
                            child: Text(
                              "Verification Code",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: Get.width,
                            child: Text(
                              "Please type the verification code we just send to +91${result}",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: PinFieldAutoFill(

                                onCodeSubmitted: ((p0) =>
                                {}), //code submitted callback
                                onCodeChanged: ((p0) => {
                                  otp.value = p0.toString()
                                }), //code changed callback
                                codeLength: 4 //code length, default 6
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: Get.width,
                            child: Container(
                                padding: const EdgeInsets.all(20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: ColorManager.colorAccent),
                                child: InkWell(
                                  onTap: () async {
                                    controller.verifyOtp(
                                        phoneController.text, otp.value);
                                    if (Get.isBottomSheetOpen!) {
                                      Get.back();
                                    }

                                  },
                                  child: const Text(
                                    "Submit",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )),
                          ),
                          SizedBox(
                            width: Get.width,
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: "By Login or Sign Up, you agree to our",
                                  ),
                                  TextSpan(
                                      text: " Terms of Service ",
                                      style: const TextStyle(
                                          color: ColorManager.colorPrimaryLight),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async => {
                                          launchUrl(
                                              Uri.parse(termsOfServiceUrl),
                                              mode: LaunchMode
                                                  .externalApplication)
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
                                              mode: LaunchMode
                                                  .externalApplication)
                                        })
                                ])),
                          ),
                        ],
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)));
              } else {
                phoneController.text.isEmpty
                    ? errorToast("field empty")
                    : phoneController.text.length != 10
                    ? errorToast("please enter 10 digits")
                    : errorToast("number is not correct");
              }
            },
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
                        style: const TextStyle(
                            color: ColorManager.colorPrimaryLight),
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
    );
  }
}

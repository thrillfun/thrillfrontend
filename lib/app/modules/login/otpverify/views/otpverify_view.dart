import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:thrill/app/utils/strings.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/otpverify_controller.dart';

class OtpverifyView extends StatefulWidget {
  const OtpverifyView({Key? key}) : super(key: key);

  @override
  State<OtpverifyView> createState() => _OtpverifyViewState();
}

class _OtpverifyViewState extends State<OtpverifyView> {
  TextEditingController phoneController = TextEditingController();

  var otp = "".obs;
  var controller = Get.find<OtpverifyController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "Login via OTP",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: TextFormField(
            controller: phoneController,
            maxLength: 10,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              filled: true,
              prefixIcon: Icon(
                Icons.call,
                color: controller.fieldNode.hasFocus
                    ? ColorManager.colorAccent
                    : Colors.grey.withOpacity(0.3),
              ),
              prefixText: "+91 ",
              prefixStyle: TextStyle(
                  color: controller.fieldNode.hasFocus
                      ? ColorManager.colorAccent
                      : Colors.grey,
                  fontSize: 16),
              labelText: "Enter Phone number",
              labelStyle: TextStyle(
                  color: controller.fieldNode.hasFocus
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
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ColorManager.colorAccent),
            child: const Text("SEND OTP",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          onTap: () async {
            if (phoneController.text.isNotEmpty &&
                phoneController.text.length == 10) {
              await controller.sendOtp(phoneController.text);
              String test = phoneController.text;
              int numSpace = 5;
              String result = test.replaceRange(0, numSpace, '*' * numSpace);
              Navigator.pop(context);
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) => CheckOtpView(
                        phoneNumber: phoneController.text,
                      ));
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
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            child: Text.rich(TextSpan(children: [
              const TextSpan(
                text: "By Login or Sign Up, you agree to our",
              ),
              TextSpan(
                  text: " Terms of Service ",
                  style: const TextStyle(color: ColorManager.colorPrimaryLight),
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
                  style: const TextStyle(color: ColorManager.colorPrimaryLight),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async => {
                          launchUrl(Uri.parse(privacyPolicyUrl),
                              mode: LaunchMode.externalApplication)
                        })
            ])),
          ),
        ),
      ],
    );
  }
}

class CheckOtpView extends StatefulWidget {
  CheckOtpView({required this.phoneNumber});

  String? phoneNumber;

  @override
  State<CheckOtpView> createState() => _CheckOtpViewState();
}

class _CheckOtpViewState extends State<CheckOtpView> {
  var otp = "".obs;
  var controller = Get.find<OtpverifyController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            width: Get.width,
            child: const Text(
              "Verification Code",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: Get.width,
            child: Text(
              "Please type the verification code we just send to +91${widget.phoneNumber}",
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          OtpTextField(
            numberOfFields: 4,
            fieldWidth: 60,
            cursorColor: ColorManager.colorAccent,
            fillColor: ColorManager.colorAccent,
            focusedBorderColor: ColorManager.colorAccent,
            autoFocus: true,
            borderColor: ColorManager.colorAccent,
            //set to true to show as box or false to show as dash
            showFieldAsBox: false,
            //runs when a code is typed in
            onCodeChanged: (String code) {
              //handle validation or checks here
            },
            //runs when every textfield is filled
            onSubmit: (String p0) {
              controller.verifyOtp(
                  widget.phoneNumber.toString(), p0.toString());
            }, // end onSubmit
          ),
          // Container(
          //   margin: EdgeInsets.all(10),
          //   child: PinFieldAutoFill(
          //       onCodeSubmitted: ((p0) => {
          //             controller.verifyOtp(
          //                 widget.phoneNumber.toString(), p0.toString())
          //           }), //code submitted callback
          //       onCodeChanged: ((p0) =>
          //           {otp.value = p0.toString()}), //code changed callback
          //       codeLength: 4 //code length, default 6
          //       ),
          // ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: Get.width,
            child: Container(
                padding: const EdgeInsets.all(15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ColorManager.colorAccent),
                child: InkWell(
                  onTap: () async {
                    controller.verifyOtp(
                        widget.phoneNumber.toString(), otp.value);
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                )),
          ),
          Center(
              child: InkWell(
            onTap: () => controller.sendOtp(widget.phoneNumber.toString()),
            child: Text(
              "Resend Otp",
              style: TextStyle(
                color: ColorManager.colorAccent,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          )),
          Container(
            width: Get.width,
            margin: EdgeInsets.all(10),
            child: Text.rich(TextSpan(children: [
              const TextSpan(
                text: "By Login or Sign Up, you agree to our",
              ),
              TextSpan(
                  text: " Terms of Service ",
                  style: const TextStyle(color: ColorManager.colorPrimaryLight),
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
                  style: const TextStyle(color: ColorManager.colorPrimaryLight),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async => {
                          launchUrl(Uri.parse(privacyPolicyUrl),
                              mode: LaunchMode.externalApplication)
                        })
            ])),
          ),
        ],
      ),
    );
  }
}

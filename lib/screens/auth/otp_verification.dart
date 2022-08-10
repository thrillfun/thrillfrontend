import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../common/color.dart';
import '../../utils/util.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({Key? key, required this.mobileNumber}) : super(key: key);
  final String mobileNumber;

  static const String routeName = '/otpVerification';

  static Route route(String number) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  OtpVerification(mobileNumber: number,),
    );
  }

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  TextEditingController phoneCtr = TextEditingController();
  String otp = '';
  Duration resendDuration = const Duration(seconds: 20);
  Timer? resendTimer;

  @override
  void initState() {
    startResendTimer();
    super.initState();
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: getHeight(context),
            width: getWidth(context),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/splash.png'), fit: BoxFit.cover),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                        },
                      icon: const Icon(Icons.close)
                  ),
                ),
                const Spacer(),
                Image.asset(
                  'assets/logo.png',
                  scale: 1.9,
                ),
                Text(
                  'Lorem Ipsum is simply\ndummy text',
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Container(
                  width: getWidth(context),
                  height: getHeight(context) * .70,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50))),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        Text(
                          "OTP Verification",
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 26),
                        ),
                        const SizedBox(height: 15,),
                        Text(
                            "4 Digit OTP sent to mobile number ending with ******${widget.mobileNumber.substring(6,10)}",
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.center,
                        ).w(MediaQuery.of(context).size.width*.70),
                        const SizedBox(
                          height: 35,
                        ),
                        PinCodeTextField(
                          appContext: context,
                          length: 4,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          mainAxisAlignment: MainAxisAlignment.center,
                          animationDuration: const Duration(milliseconds: 0),
                          cursorColor: ColorManager.cyan,
                          textStyle: const TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          pinTheme: PinTheme(
                              borderRadius: BorderRadius.circular(7),
                              fieldHeight: 50,
                              fieldWidth: 50,
                              activeColor: ColorManager.cyan,
                              //activeFillColor: const Color(extraLightBlue),
                              disabledColor: Colors.grey,
                              errorBorderColor: Colors.grey,
                              inactiveColor: Colors.grey,
                              borderWidth: 1,
                              shape: PinCodeFieldShape.box,
                              fieldOuterPadding: const EdgeInsets.only(left: 8, right: 8)),
                          onChanged: (text) =>
                              setState(() => otp = text),
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("OTP not received?", style: Theme.of(context).textTheme.headline5,),
                            const SizedBox(width: 5,),
                            resendDuration.inSeconds>0?
                            Text("Resend in ${resendDuration.inSeconds}s", style: Theme.of(context).textTheme.headline5):
                            GestureDetector(
                                onTap: (){
                                  startResendTimer();
                                  sendOTP();
                                  },
                                child: Text("Resend OTP", style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.blue)))
                          ],
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            if(otp.isNotEmpty){
                              if(otp.length==4){
                                verifyOTP();
                              } else {
                                showErrorToast(context, "OTP Must Be 4 Digit in Length");
                              }
                            } else {
                              showErrorToast(context, "Enter OTP");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              fixedSize: Size(getWidth(context) - 80, 55),
                              primary: ColorManager.deepPurple,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40))),
                          child: const Text(
                            "Submit",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  sendOTP()async{
    try{
      var response = await RestApi.sendOTP(widget.mobileNumber);
      var json = jsonDecode(response.body);
      if(json['status']){
        showSuccessToast(context, "OTP Sent Successfully");
      } else {
        showErrorToast(context, json['message'].toString());
      }
    } catch(e){
      Navigator.pop(context, false);
      showErrorToast(context, e.toString());
    }
  }

  verifyOTP()async{
    try{
      progressDialogue(context);
      var response = await RestApi.verifyOTP(widget.mobileNumber, otp);
      var json = jsonDecode(response.body);
      closeDialogue(context);
      if(json['status']){
        Navigator.pop(context, true);
      } else {
        showErrorToast(context, json['message'].toString());
      }
    } catch(e){
      closeDialogue(context);
      showErrorToast(context, e.toString());
    }
  }

  startResendTimer(){
    resendDuration = const Duration(seconds: 20);
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(resendDuration.inSeconds<=0){
        resendTimer?.cancel();
      } else {
        setState(()=>resendDuration -= const Duration(seconds: 1));
      }
    });
  }
}

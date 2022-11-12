import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/screens/home/home_getx.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';
import 'result_screen.dart';

class NonTcVerification extends StatefulWidget {
  const NonTcVerification({Key? key}) : super(key: key);

  @override
  _NonTcVerificationState createState() => _NonTcVerificationState();
}

class _NonTcVerificationState extends State<NonTcVerification> {
  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool invalidNumber = false;
  bool invalidFName = false;
  bool invalidOtp = false;
  bool showProgressBar = false;
  TextEditingController phoneController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  late StreamSubscription? streamSubscription;
  TruecallerSdkCallbackResult? tempResult;
  Timer? _timer;
  int? _ttl;

  @override
  void initState() {
    super.initState();
    createStreamBuilder();
  }

  bool showInputNumberView() {
    return tempResult == null;
  }

  bool showInputNameView() {
    return tempResult != null &&
        (tempResult == TruecallerSdkCallbackResult.missedCallReceived ||
            showInputOtpView());
  }

  bool showInputOtpView() {
    return tempResult != null &&
        ((tempResult == TruecallerSdkCallbackResult.otpInitiated) ||
            (tempResult == TruecallerSdkCallbackResult.otpReceived));
  }

  bool showRetryTextView() {
    return _ttl != null && !showInputNumberView();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    const double fontSize = 18.0;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: showProgressBar,
              child: const CircularProgressIndicator(
                strokeWidth: 6.0,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            Visibility(
              visible: showInputNumberView(),
              child: TextField(
                controller: phoneController,
                maxLength: 10,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.green, fontSize: fontSize),
                decoration: InputDecoration(
                  prefixText: "+91",
                  prefixStyle: const TextStyle(
                      color: Colors.lightGreen, fontSize: fontSize),
                  labelText: "Enter Phone number",
                  labelStyle:
                      const TextStyle(color: Colors.black, fontSize: fontSize),
                  hintText: "99999-99999",
                  errorText: invalidNumber
                      ? "Mobile Number must be of 10 digits"
                      : null,
                  hintStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: fontSize),
                ),
              ),
            ),
            const Divider(
              color: Colors.transparent,
              height: 20.0,
            ),
            Visibility(
              visible: showInputNameView(),
              child: TextField(
                controller: fNameController,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.green, fontSize: fontSize),
                decoration: InputDecoration(
                  prefixStyle: const TextStyle(
                      color: Colors.lightGreen, fontSize: fontSize),
                  labelText: "Enter First Name",
                  labelStyle:
                      const TextStyle(color: Colors.black, fontSize: fontSize),
                  hintText: "John",
                  errorText: invalidFName
                      ? "Invalid first name. Enter min 2 characters"
                      : null,
                  hintStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: fontSize),
                ),
              ),
            ),
            const Divider(
              color: Colors.transparent,
              height: 20.0,
            ),
            Visibility(
              visible: showInputNameView(),
              child: TextField(
                controller: lNameController,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.green, fontSize: fontSize),
                decoration: const InputDecoration(
                  prefixStyle:
                      TextStyle(color: Colors.lightGreen, fontSize: fontSize),
                  labelText: "Enter Last Name",
                  labelStyle:
                      TextStyle(color: Colors.black, fontSize: fontSize),
                  hintText: "Doe",
                  hintStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: fontSize),
                ),
              ),
            ),
            const Divider(
              color: Colors.transparent,
              height: 20.0,
            ),
            Visibility(
              visible: showInputOtpView(),
              child: TextField(
                controller: otpController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.green, fontSize: fontSize),
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  labelStyle:
                      const TextStyle(color: Colors.black, fontSize: fontSize),
                  hintText: "123-456",
                  errorText: invalidOtp ? "OTP must be 6 digits" : null,
                  hintStyle: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: fontSize),
                ),
              ),
            ),
            const Divider(
              color: Colors.transparent,
              height: 20.0,
            ),
            Visibility(
              visible: showInputNumberView() ||
                  showInputNameView() ||
                  showInputOtpView(),
              child: MaterialButton(
                minWidth: width - 50.0,
                height: 45.0,
                onPressed: () => onProceedClick(),
                child: const Text("Proceed",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                color: Colors.blue,
              ),
            ),
            const Divider(
              color: Colors.transparent,
              height: 30.0,
            ),
            Visibility(
              visible: showRetryTextView(),
              child: _ttl == 0
                  ? TextButton(
                      child: const Text(
                        "verification timed out, retry again",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue),
                      ),
                      onPressed: () => setState(() => tempResult = null))
                  : Text("Retry again in $_ttl seconds"),
            ),
          ],
        ),
      ),
    );
  }

  void startCountdownTimer(int ttl) {
    _ttl = ttl;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_ttl! < 1) {
            timer.cancel();
            showProgressBar = false;
          } else {
            _ttl = _ttl! - 1;
          }
        },
      ),
    );
  }

  void createStreamBuilder() {
    streamSubscription =
        TruecallerSdk.streamCallbackData.listen((truecallerUserCallback) {
      // make sure you're changing state only after number has been entered. there could be case
      // where user initiated missed call, pressed back, and came to this screen again after
      // which the call was received and hence it would directly open input name screen.
      if (phoneController.text.length == 10) {
        setState(() {
          if (truecallerUserCallback.result !=
              TruecallerSdkCallbackResult.exception) {
            tempResult = truecallerUserCallback.result;
          }
          showProgressBar =
              tempResult == TruecallerSdkCallbackResult.missedCallInitiated;
          if (tempResult == TruecallerSdkCallbackResult.otpReceived) {
            otpController.text = truecallerUserCallback.otp!;
          }
        });
      }

      switch (truecallerUserCallback.result) {
        case TruecallerSdkCallbackResult.missedCallInitiated:
          startCountdownTimer(
              double.parse(truecallerUserCallback.ttl!).floor());
          showSnackBar(
              "Missed call Initiated with TTL : ${truecallerUserCallback.ttl}");
          break;
        case TruecallerSdkCallbackResult.missedCallReceived:
          showSnackBar("Missed call Received");
          break;
        case TruecallerSdkCallbackResult.otpInitiated:
          startCountdownTimer(
              double.parse(truecallerUserCallback.ttl!).floor());
          showSnackBar(
              "OTP Initiated with TTL : ${truecallerUserCallback.ttl}");
          break;
        case TruecallerSdkCallbackResult.otpReceived:
          showSnackBar("OTP Received : ${truecallerUserCallback.otp}");
          break;
        case TruecallerSdkCallbackResult.verificationComplete:
          showSnackBar(
              "Verification Completed : ${truecallerUserCallback.accessToken}");
          _navigateToResult(fNameController.text);
          break;
        case TruecallerSdkCallbackResult.verifiedBefore:
          showSnackBar(
              "Verified Before : ${truecallerUserCallback.profile!.accessToken}");
          _navigateToResult(truecallerUserCallback.profile!.firstName);
          break;
        case TruecallerSdkCallbackResult.exception:
          showSnackBar("Exception : ${truecallerUserCallback.exception!.code}, "
              "${truecallerUserCallback.exception!.message}");
          break;
        default:
          print(tempResult.toString());
          break;
      }
    });
  }

  void showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _navigateToResult(String firstName) {
    Get.off(BottomNavigation());
  }

  void onProceedClick() {
    if (showInputNumberView() && validateNumber()) {
      setProgressBarToActive();
      TruecallerSdk.requestVerification(phoneNumber: phoneController.text);
    } else if (tempResult == TruecallerSdkCallbackResult.missedCallReceived &&
        validateName()) {
      setProgressBarToActive();
      TruecallerSdk.verifyMissedCall(
          firstName: fNameController.text, lastName: lNameController.text);
    } else if ((tempResult == TruecallerSdkCallbackResult.otpInitiated ||
            tempResult == TruecallerSdkCallbackResult.otpReceived) &&
        validateName() &&
        validateOtp()) {
      setProgressBarToActive();
      TruecallerSdk.verifyOtp(
          firstName: fNameController.text,
          lastName: lNameController.text,
          otp: otpController.text);
    }
  }

  void setProgressBarToActive() {
    setState(() {
      showProgressBar = true;
    });
  }

  bool validateNumber() {
    String phoneNumber = phoneController.text;
    setState(() {
      phoneNumber.length != 10 ? invalidNumber = true : invalidNumber = false;
    });
    return !invalidNumber;
  }

  bool validateOtp() {
    String otp = otpController.text;
    setState(() {
      otp.length != 6 ? invalidOtp = true : invalidOtp = false;
    });
    return !invalidOtp;
  }

  bool validateName() {
    String fName = fNameController.text;
    setState(() {
      fName.length < 2 ? invalidFName = true : invalidFName = false;
    });
    return !invalidFName;
  }

  @override
  void dispose() {
    phoneController.dispose();
    fNameController.dispose();
    lNameController.dispose();
    otpController.dispose();
    streamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
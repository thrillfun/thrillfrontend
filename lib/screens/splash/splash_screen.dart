import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../rest/rest_api.dart';
import '../../utils/util.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({Key? key}) : super(key: key);
  static const String routeName = '/splash';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const SplashScreen(),
    );
  }

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((bool isAllowed) {
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    _navigator();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/splash.png',
                  ),
                  fit: BoxFit.cover)),
          child: Center(
            child: SizedBox(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
                width: 200,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _navigator() async {
    await Future.delayed(const Duration(seconds: 2));
    var instance = await SharedPreferences.getInstance();
    try {
      var loginData=instance.getString('currentUser');
      if (loginData != null) {
        var result = await RestApi.checkAccountStatus();
        var json = jsonDecode(result.body);
        if (json['status']) {
          if (json['data']['status'] == 1) {
            closeDialogue(context);
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          } else {
            closeDialogue(context);
            showAlertDialog(context);
          }
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } on Exception {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
  showAlertDialog(BuildContext context) {
    Widget continueButton = TextButton(
      child: const Text("OK"),
      onPressed: () async {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.clear();
        GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        await FacebookAuth.instance.logOut();
        Get.back();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Account Deactivate"),
      content: const Text(
          "Your account is deactivated by admin, Please contact admin to activate your account."),
      actions: [
        continueButton,
      ],
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

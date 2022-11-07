import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/utils/util.dart';
import 'package:velocity_x/velocity_x.dart';

import '../common/color.dart';
import '../common/strings.dart';
import '../widgets/video_item.dart';

class Referral extends StatefulWidget {
  const Referral({Key? key}) : super(key: key);

  @override
  State<Referral> createState() => _ReferralState();
  static const String routeName = '/referral';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const Referral(),
    );
  }
}

class _ReferralState extends State<Referral> {
  bool checkBoxValue = true;
  User? userModel;
  int referralCount = 0;
  String referralCode = '';

  @override
  initState() {
    super.initState();
    getUserData();
    try {
      reelsPlayerController?.pause();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/splash.png'), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              const Border(bottom: BorderSide(color: Colors.white, width: 1)),
          centerTitle: true,
          title: const Text(referral),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
        ),
        body: Column(
          children: [
            const Spacer(),
            Image.asset(
              'assets/level1.png',
              scale: 2,
            ),
            const SizedBox(
              height: 10,
            ),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  const TextSpan(
                      text: totalReferral + '\n',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  TextSpan(
                      text: "$referralCount",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25)),
                ])),
            const Spacer(),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * .60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 35,
                  ),
                  const Text(
                    referMoreEarnMore,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      referMoreEarnMoreDialog,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    yourReferralCode,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * .60,
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey, width: 1)),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                          '${userModel?.referralCode}',
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        )),
                        IconButton(
                            onPressed: () {
                              try {
                                Clipboard.setData(ClipboardData(
                                        text: userModel?.referralCode))
                                    .then((_) {
                                  showSuccessToast(context,
                                      "Referral Code Copied to Clipboard!");
                                });
                              } catch (e) {
                                showErrorToast(context, e.toString());
                              }
                            },
                            icon: const Icon(Icons.copy))
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                          value: checkBoxValue,
                          activeColor: Colors.black,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (val) =>
                              setState(() => checkBoxValue = val!)),
                      const Text(
                        iAgreeToThe,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/privacyPolicy');
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text(
                            privacyPolicy,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 16,
                                color: Colors.black),
                          ))
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        //share();
                        if (checkBoxValue) {
                          Share.share(
                              "Hi, I am inviting you to Thrill a great short video app. Use my referral code: ${userModel?.referralCode} to earn rewards.");
                        } else {
                          showErrorToast(
                              context, "You must agree to Privacy Policy!");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: ColorManager.deepPurple,
                          fixedSize:
                              Size(MediaQuery.of(context).size.width * .90, 55),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      child: const Text(
                        referNow,
                        style: TextStyle(fontSize: 20),
                      )),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ).scrollVertical(),
            )
          ],
        ),
      ),
    );
  }


  getUserData() async {
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');
    User current = User.fromJson(jsonDecode(currentUser!));
    setState(() => userModel = current);
  }
}

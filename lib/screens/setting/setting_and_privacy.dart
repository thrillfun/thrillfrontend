import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ant_design.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/eva.dart';
import 'package:iconify_flutter/icons/fluent.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/icon_park_outline.dart';
import 'package:iconify_flutter/icons/iconoir.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/blocs/blocs.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/screens/privacy_policy.dart';
import 'package:thrill/screens/referal_screen.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/screens/terms_of_service.dart';
import 'package:thrill/utils/util.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../common/strings.dart';
import '../../rest/rest_url.dart';
import '../../widgets/video_item.dart';

class SettingAndPrivacy extends StatelessWidget {
  SettingAndPrivacy(
      {required this.avatar, required this.name, required this.userName});

  String avatar = "";
  String name = "";
  String userName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Get.height,
            child: loadSvgCacheImage("background_settings.svg"),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.transparent,
                              ),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(200))),
                          width: 60,
                          height: 60,
                          child: SizedBox(
                              height: 60,
                              width: 60,
                              child: avatar.isNotEmpty
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl:
                                            '${RestUrl.profileUrl}${avatar}',
                                        placeholder: (a, b) => const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: SvgPicture.asset(
                                        'assets/profile.svg',
                                        width: 10,
                                        height: 10,
                                        fit: BoxFit.contain,
                                      ),
                                    ))),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "@$userName",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.normal),
                          )
                        ],
                      )),
                      GestureDetector(
                        onTap: () => switchAccountLayout(),
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(200))),
                            width: 30,
                            height: 30,
                            child: const Iconify(
                              Eva.flip_2_fill,
                              color: Colors.white,
                              size: 20,
                            )),
                      )
                    ],
                  ),
                  Divider(
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //title(account),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Get.to(ManageAccount());
                        //        Navigator.pushNamed(context, '/manageAccount');
                      },
                      child: mainTile(Carbon.person, manageAccount)),
                  GestureDetector(
                      onTap: () {
                        Get.to(ReferalScreen());
                        //  Navigator.pushNamed(context, '/inbox');
                      },
                      child: mainTile(
                          Fluent.gift_card_arrow_right_24_regular, "Referral")),
                  GestureDetector(
                      onTap: () {
                        Get.to(const Inbox());
                        //  Navigator.pushNamed(context, '/inbox');
                      },
                      child: mainTile(Mdi.email_newsletter, "Invite Friends")),
                  GestureDetector(
                      onTap: () {
                        Get.to(const Inbox());
                        //  Navigator.pushNamed(context, '/inbox');
                      },
                      child: mainTile(Ic.twotone_favorite, 'Favourite')),
                  GestureDetector(
                      onTap: () {
                        Get.to(const Inbox());
                        //  Navigator.pushNamed(context, '/inbox');
                      },
                      child: mainTile(Ic.round_inbox, inbox)),
                  GestureDetector(
                      onTap: () {
                        Get.to(const Privacy());
                        //  Navigator.pushNamed(context, '/privacy');
                      },
                      child:
                          mainTile(IconParkOutline.personal_privacy, privacy)),
                  GestureDetector(
                      onTap: () {
                        Get.to(const Wallet());
                        //  Navigator.pushNamed(context, '/wallet');
                      },
                      child: mainTile(Ph.wallet_bold, wallet)),
                  GestureDetector(
                      onTap: () {
                        Get.to(const QrCode());
                        //  Navigator.pushNamed(context, '/qrcode');
                      },
                      child: mainTile(Iconoir.qr_code, qrCode)),
                  GestureDetector(
                      onTap: () {
                        //share();
                        Share.share(
                            'Hi, I am using Thrill to share and view great & entertaining Reels. Come and join to follow me.');
                      },
                      child: mainTile(Carbon.share, shareProfile)),

                  //  title(contentAndActivity),

                  GestureDetector(
                      onTap: () {
                        Get.to(const PushNotification());
                        //  Navigator.pushNamed(context, '/pushNotification');
                      },
                      child: mainTile(
                          Ic.outline_notifications_active, pushNotification)),
                  GestureDetector(
                    onTap: () {},
                    child: SizedBox(
                      height: 25,
                      child: ListTile(
                        title: const Text(
                          appLanguage,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        leading: Card(
                            margin: const EdgeInsets.only(right: 20),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              child: const Iconify(
                                Ic.baseline_language,
                                color: ColorManager.colorAccent,
                                size: 20,
                              ),
                            )),
                        trailing: const Text(
                          english,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        visualDensity: VisualDensity.compact,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 0,
                        minLeadingWidth: 30,
                        minVerticalPadding: 0,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Get.to(const TermsOfService());
                        //Navigator.pushNamed(context, '/termsOfService');
                      },
                      child: mainTile(
                          Mdi.newspaper_variant_multiple, termsOfService)),
                  GestureDetector(
                      onTap: () {
                        Get.to(const PrivacyPolicy());
                        //Navigator.pushNamed(context, '/privacyPolicy');
                      },
                      child: mainTile(Carbon.policy, privacyPolicy)),

                  // GestureDetector(
                  //     onTap: () {
                  //       switchAccountLayout();
                  //     },
                  //     child: mainTile(
                  //         AntDesign.user_switch_outlined, switchAccount)),
                  GestureDetector(
                      onTap: () async {
                        Get.defaultDialog(
                            title: "Logout?",
                            middleText:
                                "This will also logout from other accounts!",
                            confirm: ElevatedButton(
                                onPressed: () {
                                  GetStorage().remove("token");
                                  GetStorage().remove("user");
                                  Get.offAll(LoginGetxScreen());
                                },
                                child: const Text('Yes')),
                            cancel: ElevatedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text("No")));
                        // showDialog(
                        //     context: context,
                        //     builder: (_) => Center(
                        //           child: Material(
                        //             type: MaterialType.transparency,
                        //             child: Container(
                        //               width: getWidth(context) * .80,
                        //               padding: const EdgeInsets.symmetric(
                        //                   vertical: 15),
                        //               decoration: BoxDecoration(
                        //                   color: Colors.white,
                        //                   borderRadius:
                        //                       BorderRadius.circular(10)),
                        //               child: Column(
                        //                 mainAxisSize: MainAxisSize.min,
                        //                 children: [
                        //                   Text(
                        //                     "Are you sure you want to logout?",
                        //                     style: Theme.of(context)
                        //                         .textTheme
                        //                         .headline4,
                        //                     textAlign: TextAlign.center,
                        //                   ),
                        //                   const SizedBox(
                        //                     height: 5,
                        //                   ),
                        //                   Padding(
                        //                     padding: const EdgeInsets.symmetric(
                        //                         horizontal: 25),
                        //                     child: Text(
                        //                       "This will also logout all your linked account if any.",
                        //                       style: Theme.of(context)
                        //                           .textTheme
                        //                           .headline5!
                        //                           .copyWith(
                        //                               fontWeight:
                        //                                   FontWeight.normal),
                        //                       textAlign: TextAlign.center,
                        //                     ),
                        //                   ),
                        //                   const SizedBox(
                        //                     height: 25,
                        //                   ),
                        //                   Row(
                        //                     mainAxisSize: MainAxisSize.min,
                        //                     children: [
                        //                       ElevatedButton(
                        //                           onPressed: () {
                        //                             Get.back(
                        //                                 closeOverlays: true);
                        //                             //     Navigator.pop(context);
                        //                           },
                        //                           style: ElevatedButton.styleFrom(
                        //                               primary: Colors.red,
                        //                               fixedSize: Size(
                        //                                   getWidth(context) *
                        //                                       .26,
                        //                                   40),
                        //                               shape:
                        //                                   RoundedRectangleBorder(
                        //                                       borderRadius:
                        //                                           BorderRadius
                        //                                               .circular(
                        //                                                   10))),
                        //                           child: const Text("No")),
                        //                       const SizedBox(
                        //                         width: 15,
                        //                       ),
                        //                       ElevatedButton(
                        //                           onPressed: () async {
                        //                             SharedPreferences
                        //                                 preferences =
                        //                                 await SharedPreferences
                        //                                     .getInstance();
                        //                             await preferences.clear();
                        //                             GoogleSignIn googleSignIn =
                        //                                 GoogleSignIn();
                        //                             await googleSignIn
                        //                                 .signOut();
                        //                             await FacebookAuth.instance
                        //                                 .logOut();
                        //                             GetStorage()
                        //                                 .remove("token");
                        //                             Get.offAll(LoginGetxScreen());
                        //
                        //                             //Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => true);
                        //                           },
                        //                           style: ElevatedButton.styleFrom(
                        //                               primary: Colors.green,
                        //                               fixedSize: Size(
                        //                                   getWidth(context) *
                        //                                       .26,
                        //                                   40),
                        //                               shape:
                        //                                   RoundedRectangleBorder(
                        //                                       borderRadius:
                        //                                           BorderRadius
                        //                                               .circular(
                        //                                                   10))),
                        //                           child: const Text("Yes"))
                        //                     ],
                        //                   )
                        //                 ],
                        //               ),
                        //             ),
                        //           ),
                        //         ));
                      },
                      child: mainTile(Ic.baseline_login, logout)),
                  Card(
                    margin: const EdgeInsets.only(top: 20),
                    elevation: 10,
                    child: GestureDetector(
                      onTap: () {
                        Get.to(const CustomerSupport());
                        //Navigator.pushNamed(context, '/customerSupport');
                      },
                      child: Container(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: const Text(
                              "Technical Support",
                              style: TextStyle(
                                  color: ColorManager.colorAccent,
                                  fontSize: 18),
                            ),
                            leading: Card(
                              elevation: 10,
                              margin: const EdgeInsets.only(right: 20),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: const Iconify(Ic.sharp_support_agent,
                                    color: ColorManager.colorAccent, size: 20),
                              ),
                            ),
                            visualDensity: VisualDensity.compact,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            horizontalTitleGap: 0,
                            minLeadingWidth: 30,
                            minVerticalPadding: 0,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget mainTile(String icon, String text) {
    return SizedBox(
      child: ListTile(
        title: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: Card(
          margin: const EdgeInsets.only(right: 20),
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Iconify(icon, color: ColorManager.colorAccent, size: 20),
          ),
        ),
        visualDensity: VisualDensity.compact,
        dense: true,
        contentPadding: EdgeInsets.zero,
        horizontalTitleGap: 0,
        minLeadingWidth: 30,
        minVerticalPadding: 0,
      ),
    );
  }

  title(String txt) {
    return Text(
      txt,
      style: const TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  share() {
    return showModalBottomSheet(
        context: Get.context!,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        builder: (BuildContext context) {
          return Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                sendTo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 90,
                child: ListView.builder(
                    itemCount: 10,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              height: 60,
                              width: 60,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    'https://mir-s3-cdn-cf.behance.net/project_modules/disp/b3053232163929.567197ac6e6f5.png',
                                placeholder: (a, b) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              'User$index',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      );
                    }),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                shareTo,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundImage: const DecorationImage(
                              image: AssetImage('assets/message.png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          message,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundImage: const DecorationImage(
                              image: AssetImage('assets/whatsapp.png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          whatsApp,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundImage: const DecorationImage(
                              image: AssetImage('assets/facebook (2).png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          facebook,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundImage: const DecorationImage(
                              image: AssetImage('assets/messenger.png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          messenger,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                          radius: 60,
                          backgroundImage: const DecorationImage(
                              image: AssetImage('assets/sms.png')),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          sms,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VxCircle(
                            radius: 60,
                            backgroundColor: Colors.blue,
                            child: SvgPicture.asset(
                              'assets/link.svg',
                              color: Colors.white,
                            )),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          copyLink,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                ],
              ).scrollHorizontal(),
              const Divider(
                height: 30,
                color: Colors.grey,
              ),
              const Spacer(),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    cancel,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          );
        });
  }

  switchAccountLayout() async {
    var pref = await SharedPreferences.getInstance();
    List<String> users = pref.getStringList('allUsers') ?? [];
    List<User> usersModel = List.empty(growable: true);
    for (var element in users) {
      usersModel.add(User.fromJson(jsonDecode(element)));
    }
    return showModalBottomSheet(
        isScrollControlled: true,
        context: Get.context!,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (BuildContext context) {
          return SizedBox(
            height: 300,
            child: StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 50,
                        ),
                        const Expanded(
                          child: Text(
                            switchAccount,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close))
                      ],
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemCount: usersModel.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            if (index != 0) {
                              showDialog(
                                  context: context,
                                  builder: (_) => Center(
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Container(
                                            width: getWidth(context) * .80,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 15),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20),
                                                  child: Text(
                                                    "Are you sure you want to switch to ${usersModel[index].name}?",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline3,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 25,
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            primary: Colors.red,
                                                            fixedSize: Size(
                                                                getWidth(
                                                                        context) *
                                                                    .26,
                                                                40),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10))),
                                                        child:
                                                            const Text("No")),
                                                    const SizedBox(
                                                      width: 15,
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () async {
                                                          try {
                                                            await pref.setString(
                                                                '${usersModel[0].id}currentToken',
                                                                pref.getString(
                                                                    'currentUser')!);
                                                            await pref.setStringList(
                                                                '${usersModel[0].id}likeList',
                                                                pref.getStringList(
                                                                    'likeList')!);
                                                            await pref.setStringList(
                                                                '${usersModel[0].id}commentList',
                                                                pref.getStringList(
                                                                    'commentList')!);
                                                            await pref.setStringList(
                                                                '${usersModel[0].id}viewList',
                                                                pref.getStringList(
                                                                    'viewList')!);
                                                            await pref.setStringList(
                                                                '${usersModel[0].id}followList',
                                                                pref.getStringList(
                                                                    'followList')!);
                                                            await pref.setStringList(
                                                                '${usersModel[0].id}favSound',
                                                                pref.getStringList(
                                                                    'favSound')!);
                                                            await pref.setStringList(
                                                                '${usersModel[0].id}favTag',
                                                                pref.getStringList(
                                                                    'favTag')!);
                                                            await pref.setString(
                                                                '${usersModel[0].id}currentToken',
                                                                pref.getString(
                                                                    'currentToken')!);

                                                            String usr =
                                                                users[index];
                                                            users.removeAt(
                                                                index);
                                                            users.insert(
                                                                0, usr);
                                                            await pref
                                                                .setStringList(
                                                                    'allUsers',
                                                                    users);

                                                            await pref
                                                                .setString(
                                                              'currentUser',
                                                              usr,
                                                            );
                                                            await pref.setString(
                                                                'currentToken',
                                                                pref.getString(
                                                                    '${usersModel[index].id}currentToken')!);
                                                            await pref.setStringList(
                                                                'likeList',
                                                                pref.getStringList(
                                                                    '${usersModel[index].id}likeList')!);
                                                            await pref.setStringList(
                                                                'commentList',
                                                                pref.getStringList(
                                                                    '${usersModel[index].id}commentList')!);
                                                            await pref.setStringList(
                                                                'viewList',
                                                                pref.getStringList(
                                                                    '${usersModel[index].id}viewList')!);
                                                            await pref.setStringList(
                                                                'followList',
                                                                pref.getStringList(
                                                                    '${usersModel[index].id}followList')!);
                                                            await pref.setStringList(
                                                                'favSound',
                                                                pref.getStringList(
                                                                    '${usersModel[index].id}favSound')!);
                                                            await pref.setStringList(
                                                                'favTag',
                                                                pref.getStringList(
                                                                    '${usersModel[index].id}favTag')!);
                                                            Navigator
                                                                .pushNamedAndRemoveUntil(
                                                                    context,
                                                                    '/',
                                                                    (route) =>
                                                                        true);
                                                          } catch (e) {
                                                            Navigator.pop(
                                                                context);
                                                            showErrorToast(
                                                                context,
                                                                e.toString());
                                                          }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            primary:
                                                                Colors.green,
                                                            fixedSize: Size(
                                                                getWidth(
                                                                        context) *
                                                                    .26,
                                                                40),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10))),
                                                        child:
                                                            const Text("Yes"))
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ));
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(left: 10),
                            color: Colors.white,
                            child: Row(
                              children: [
                                Container(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    height: 60,
                                    padding: const EdgeInsets.all(2),
                                    width: 60,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color:
                                                ColorManager.spinColorDivider)),
                                    child: usersModel[index].avatar!.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  RestUrl.placeholderImage,
                                            ),
                                          )
                                        : ClipOval(
                                            child: CachedNetworkImage(
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.fill,
                                              imageUrl:
                                                  '${RestUrl.profileUrl}${usersModel[index].avatar}',
                                              placeholder: (a, b) =>
                                                  const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        usersModel[index].username!,
                                        style: const TextStyle(fontSize: 16),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        usersModel[index].name!,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      if (index != 0) {
                                        showDialog(
                                            context: context,
                                            builder: (_) => Center(
                                                  child: Material(
                                                    type: MaterialType
                                                        .transparency,
                                                    child: Container(
                                                      width: getWidth(context) *
                                                          .80,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 15),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        20),
                                                            child: Text(
                                                              "Are you sure you want to logout ${usersModel[index].name} ?",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline3,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 25,
                                                          ),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                      primary:
                                                                          Colors
                                                                              .red,
                                                                      fixedSize: Size(
                                                                          getWidth(context) *
                                                                              .26,
                                                                          40),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10))),
                                                                  child:
                                                                      const Text(
                                                                          "No")),
                                                              const SizedBox(
                                                                width: 15,
                                                              ),
                                                              ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await pref
                                                                        .remove(
                                                                            '${usersModel[index].id}currentToken');
                                                                    await pref
                                                                        .remove(
                                                                            '${usersModel[index].id}likeList');
                                                                    await pref
                                                                        .remove(
                                                                            '${usersModel[index].id}commentList');
                                                                    await pref
                                                                        .remove(
                                                                            '${usersModel[index].id}viewList');
                                                                    await pref
                                                                        .remove(
                                                                            '${usersModel[index].id}followList');
                                                                    await pref
                                                                        .remove(
                                                                            '${usersModel[index].id}favSound');
                                                                    await pref
                                                                        .remove(
                                                                            '${usersModel[index].id}favTag');
                                                                    users.removeAt(
                                                                        index);
                                                                    usersModel
                                                                        .removeAt(
                                                                            index);
                                                                    await pref.setStringList(
                                                                        'allUsers',
                                                                        users);
                                                                    setState(
                                                                        () {});
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                      primary:
                                                                          Colors
                                                                              .green,
                                                                      fixedSize: Size(
                                                                          getWidth(context) *
                                                                              .26,
                                                                          40),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              10))),
                                                                  child:
                                                                      const Text(
                                                                          "Yes"))
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ));
                                      }
                                    },
                                    padding: const EdgeInsets.only(right: 25),
                                    constraints:
                                        const BoxConstraints(minWidth: 90),
                                    icon: index == 0
                                        ? const Icon(
                                            Icons.check,
                                            size: 20,
                                            color: ColorManager.cyan,
                                          )
                                        : const Text(
                                            "Logout",
                                            style: TextStyle(
                                                fontSize: 13.5,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ))
                              ],
                            ),
                          ),
                        );
                      },
                    )),
                    const SizedBox(
                      height: 20,
                    ),
                    usersModel.length >= 2
                        ? Text(
                            "Max 2 Accounts can be linked",
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(color: Colors.red),
                          )
                        : GestureDetector(
                            onTap: () {
                              Get.to(const LoginScreen(
                                  isMultiLogin: "multiLogin"));
                              // Navigator.pushNamed(context, '/login',
                              //     arguments: 'multiLogin');
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                VxCircle(
                                  radius: 30,
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(Icons.add, size: 15),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                const Text(
                                  addAccount,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                );
              },
            ),
          );
        });
  }
}

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/blocs/blocs.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/models/user.dart';
import 'package:thrill/screens/privacy_policy.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/screens/terms_of_service.dart';
import 'package:thrill/utils/util.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:share_plus/share_plus.dart';
import '../../common/strings.dart';
import '../../rest/rest_url.dart';
import '../../widgets/video_item.dart';

class SettingAndPrivacy extends StatefulWidget {
  const SettingAndPrivacy({Key? key}) : super(key: key);

  @override
  State<SettingAndPrivacy> createState() => _SettingAndPrivacyState();
}

class _SettingAndPrivacyState extends State<SettingAndPrivacy> {
  @override
  void initState() {
    try {
      reelsPlayerController?.pause();
    } catch (_) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 50,
              left: 20,
            ),
            alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width,
            height: 250,
            child: Text(
              "Settings",
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: <Color>[
                    Color(0xFF171D22),
                    Color(0xff143035),
                    Color(0xff171D23)
                  ],
                )),
          ),
          Container(
            margin: const EdgeInsets.only(top: 150, left: 5, right: 5),
            height: MediaQuery.of(context).size.height,
            child: Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10))),
              elevation: 5,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      title(account),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            Get.to(ManageAccount());
                            //        Navigator.pushNamed(context, '/manageAccount');
                          },
                          child: mainTile(
                              Icons.account_box_outlined, manageAccount)),
                      GestureDetector(
                          onTap: () {
                            Get.to(Inbox());
                            //  Navigator.pushNamed(context, '/inbox');
                          },
                          child: mainTile(Icons.all_inbox, inbox)),
                      GestureDetector(
                          onTap: () {
                            Get.to(Privacy());
                            //  Navigator.pushNamed(context, '/privacy');
                          },
                          child: mainTile(Icons.lock_outline_rounded, privacy)),
                      /* const SizedBox(
                height: 10,
              ),
             GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/requestVerification');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_outlined, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      requestVerification,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),*/
                      GestureDetector(
                          onTap: () {
                            Get.to(Wallet());
                            //  Navigator.pushNamed(context, '/wallet');
                          },
                          child: mainTile(
                              Icons.account_balance_wallet_outlined, wallet)),
                      GestureDetector(
                          onTap: () {
                            Get.to(QrCode());
                            //  Navigator.pushNamed(context, '/qrcode');
                          },
                          child: mainTile(Icons.qr_code, qrCode)),
                      GestureDetector(
                          onTap: () {
                            //share();
                            Share.share(
                                'Hi, I am using Thrill to share and view great & entertaining Reels. Come and join to follow me.');
                          },
                          child: mainTile(Icons.share, shareProfile)),
                      const SizedBox(
                        height: 30,
                      ),
                      title(contentAndActivity),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            Get.to(PushNotification());
                            //  Navigator.pushNamed(context, '/pushNotification');
                          },
                          child: mainTile(Icons.notifications_none_outlined,
                              pushNotification)),
                      GestureDetector(
                        onTap: () {},
                        child: const SizedBox(
                          height: 25,
                          child: ListTile(
                            title: Text(
                              appLanguage,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            leading: Icon(
                              Icons.translate_outlined,
                              color: Colors.black,
                              size: 22,
                            ),
                            trailing: Text(
                              english,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
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
                        height: 30,
                      ),
                      /* const SizedBox(
                height: 20,
              ),
              title(cacheAndCellularData),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                Navigator.pushNamed(context, '/freeSpace');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restore_from_trash_outlined, color: Colors.grey, size: 18,),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      freeUpSpace,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    )
                  ],
                ),
              ),*/
                      title(about.toUpperCase()),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            Get.to(TermsOfService());
                            //Navigator.pushNamed(context, '/termsOfService');
                          },
                          child: mainTile(
                              Icons.library_books_outlined, termsOfService)),
                      GestureDetector(
                          onTap: () {
                            Get.to(PrivacyPolicy());
                            //Navigator.pushNamed(context, '/privacyPolicy');
                          },
                          child: mainTile(
                              Icons.library_books_outlined, privacyPolicy)),
                      GestureDetector(
                          onTap: () {
                            Get.to(CustomerSupport());
                            //Navigator.pushNamed(context, '/customerSupport');
                          },
                          child:
                              mainTile(Icons.chat_outlined, technicalSupport)),
                      const SizedBox(
                        height: 30,
                      ),
                      title(login.toUpperCase()),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                          onTap: () {
                            switchAccountLayout();
                          },
                          child:
                              mainTile(Icons.refresh_rounded, switchAccount)),
                      GestureDetector(
                          onTap: () async {
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
                                              Text(
                                                "Are you sure you want to logout?",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4,
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 25),
                                                child: Text(
                                                  "This will also logout all your linked account if any.",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5!
                                                      .copyWith(
                                                          fontWeight: FontWeight
                                                              .normal),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 25,
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Get.back(
                                                            closeOverlays:
                                                                true);
                                                        //     Navigator.pop(context);
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
                                                      child: const Text("No")),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  ElevatedButton(
                                                      onPressed: () async {
                                                        SharedPreferences
                                                            preferences =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        await preferences
                                                            .clear();
                                                        GoogleSignIn
                                                            googleSignIn =
                                                            GoogleSignIn();
                                                        await googleSignIn
                                                            .signOut();
                                                        await FacebookAuth
                                                            .instance
                                                            .logOut();
                                                        isLoggedIn.value =
                                                            false;
                                                        Get.off(LoginScreen());

                                                        // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => true);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          primary: Colors.green,
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
                                                      child: const Text("Yes"))
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ));
                          },
                          child: mainTile(Icons.login_outlined, logout)),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget mainTile(IconData icon, String text) {
    return SizedBox(
      height: 30,
      child: ListTile(
        title: Text(
          text,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        leading: Icon(
          icon,
          color: Colors.black,
          size: 22,
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
          color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  share() {
    return showModalBottomSheet(
        context: context,
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
    List<UserModel> usersModel = List.empty(growable: true);
    for (var element in users) {
      usersModel.add(UserModel.fromJson(jsonDecode(element)));
    }
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        builder: (BuildContext context) {
          return Container(
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
                            margin: EdgeInsets.only(left: 10),
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
                                    child: usersModel[index].avatar.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: SvgPicture.asset(
                                              'assets/profile.svg',
                                              width: 10,
                                              height: 10,
                                              fit: BoxFit.fill,
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
                                        usersModel[index].username,
                                        style: const TextStyle(fontSize: 16),
                                        maxLines: 1,
                                      ),
                                      Text(
                                        usersModel[index].name,
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
                              Navigator.pushNamed(context, '/login',
                                  arguments: 'multiLogin');
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/utils/utils.dart';

import '../../../rest/rest_urls.dart';
import '../../../utils/color_manager.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/strings.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(200))),
                      width: 60,
                      height: 60,
                      child: SizedBox(
                          height: 60,
                          width: 60,
                          child: GetStorage().read("avatar")!=null
                              ? ClipOval(
                                  child: imgProfile(
                                      '${GetStorage().read("avatar").toString()}'
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
                        Get.arguments["name"].toString(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "@${Get.arguments["username"].toString()}",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.normal),
                      )
                    ],
                  )),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(200))),
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.rotate_90_degrees_ccw,
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
                    Get.toNamed(Routes.PROFILE_DETAILS);
                    //        Navigator.pushNamed(context, '/manageAccount');
                  },
                  child: mainTile(Icons.person, manageAccount)),
              GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.REFERAL);
                  },
                  child: mainTile(Icons.gif, "Referral")),

              GestureDetector(
                  onTap: () async {
                    Get.toNamed(Routes.FAVOURITES);
                    // await favouritesController
                    //     .getFavourites()
                    //     .then((value) => Get.to(Favourites()));

                    //  Navigator.pushNamed(context, '/inbox');
                  },
                  child: mainTile(Icons.favorite, 'Favourite')),
              GestureDetector(
                  onTap: () async {
                    Get.toNamed(Routes.INBOX);
                    // await inboxController
                    //     .getInbox()
                    //     .then((value) => Get.to(Inbox()));

                    //  Navigator.pushNamed(context, '/inbox');
                  },
                  child: mainTile(Icons.message, inbox)),
              GestureDetector(
                  onTap: () {
                   Get.toNamed(Routes.PRIVACY);
                    //  Navigator.pushNamed(context, '/privacy');
                  },
                  child: mainTile(Icons.privacy_tip, privacy)),
              GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.WALLET);
                    //  Navigator.pushNamed(context, '/wallet');
                  },
                  child: mainTile(Icons.wallet, wallet)),
              GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.QR_CODE);
                    //  Navigator.pushNamed(context, '/qrcode');
                  },
                  child: mainTile(Icons.qr_code, qrCode)),
              GestureDetector(
                  onTap: () async {
                    //share();
                    await controller
                        .createDynamicLink(
                            GetStorage().read("userId").toString(),
                            "profile",
                            Get.arguments["username"].toString(),
                            Get.arguments["avatar"].toString())
                        .then((value) async {
                      Share.share(
                          'Hi, I am using Thrill to share and view great & entertaining Reels. Come and join to follow me. $value');
                    });
                  },
                  child: mainTile(Icons.share, shareProfile)),

              //  title(contentAndActivity),

              GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.NOTIFICATIONS_SETTINGS);
                    //  Navigator.pushNamed(context, '/pushNotification');
                  },
                  child: mainTile(Icons.notifications, pushNotification)),

              GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.TERMS_OF_SERVICE);
                    //Navigator.pushNamed(context, '/termsOfService');
                  },
                  child: mainTile(
                      Icons.dashboard_customize_outlined, termsOfService)),
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
                            onPressed: () async {
                              await controller.signOutUser().then(
                                  (value) => Get.offAllNamed(Routes.HOME));
                            },
                            child: const Text('Yes')),
                        cancel: ElevatedButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: const Text("No")));
                  },
                  child: mainTile(Icons.login, logout)),
              Card(
                margin: const EdgeInsets.only(top: 20),
                elevation: 10,
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.CUSTOMER_SUPPORT);
                    //Navigator.pushNamed(context, '/customerSupport');
                  },
                  child: Container(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: const Text(
                          "Technical Support",
                          style: TextStyle(
                              color: ColorManager.colorAccent, fontSize: 18),
                        ),
                        leading: Card(
                          elevation: 10,
                          margin: const EdgeInsets.only(right: 20),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: const Icon(Icons.support_agent,
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
      ),
    );
  }

  Widget mainTile(IconData icon, String text) {
    return SizedBox(
      child: ListTile(
        title: Text(
          text,
          style: TextStyle(fontSize: 18),
        ),
        leading: Card(
          margin: const EdgeInsets.only(right: 20),
          child: Container(
            padding: const EdgeInsets.all(5),
            child: Icon(icon, color: ColorManager.dayNightIcon, size: 20),
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
}

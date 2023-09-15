import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:thrill/app/modules/related_videos/controllers/related_videos_controller.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:thrill/app/widgets/no_liked_videos.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../rest/rest_urls.dart';
import '../../../utils/color_manager.dart';
import 'package:share_plus/share_plus.dart';

import '../../../utils/strings.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var relatedVideosController = Get.find<RelatedVideosController>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                const SizedBox(
                  height: 10,
                ),
                controller.obx(
                    (state) => InkWell(
                          onTap: () => Get.toNamed(Routes.PROFILE),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.toNamed(Routes.PROFILE);
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    width: 60,
                                    height: 60,
                                    child: SizedBox(
                                        height: 60,
                                        width: 60,
                                        child: imgProfile(
                                            state!.value.avatar.toString()))),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    state!.value.name.toString().isEmpty
                                        ? "@${state!.value.username}"
                                        : state.value.name.toString(),
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "@${state!.value.username}",
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              )),
                            ],
                          ),
                        ),
                    onLoading: settingsShimmer()),
                const SizedBox(
                  height: 10,
                ),
                const Divider(),

                //title(account),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.PROFILE_DETAILS);
                      //        Navigator.pushNamed(context, '/manageAccount');
                    },
                    child: mainTile(IconlyBroken.profile, manageAccount)),
                GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.REFERAL);
                    },
                    child: mainTile(IconlyBroken.user_3, "Referral")),

                GestureDetector(
                    onTap: () async {
                      Get.toNamed(Routes.FAVOURITES);
                    },
                    child: mainTile(IconlyBroken.heart, 'Favourite')),
                GestureDetector(
                    onTap: () async {
                      Get.toNamed(Routes.INBOX);
                    },
                    child: mainTile(IconlyBroken.message, inbox)),

                GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.WALLET);
                    },
                    child: mainTile(IconlyBroken.wallet, wallet)),
                GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.QR_CODE, arguments: {
                        "avatar": controller.userProfile.value.avatar
                      });
                      //  Navigator.pushNamed(context, '/qrcode');
                    },
                    child: mainTile(IconlyBroken.scan, qrCode)),
                GestureDetector(
                    onTap: () async {
                      //share();
                      await controller
                          .createDynamicLink(
                              GetStorage().read("userId").toString(),
                              "profile",
                              controller.userProfile.value.username,
                              controller.userProfile.value.avatar)
                          .then((value) async {
                        // var dio = Dio();
                        // dio.download(
                        //         "https://thrillvideonew.s3.ap-south-1.amazonaws.com/assets/logo.png",
                        //         saveCacheDirectory + "/logo.png")
                        //     .then((response) async {
                        //   await Share.shareFiles(
                        //       [saveCacheDirectory + "/logo.png"],
                        //       text: 'Hi, I am using Thrill to share and view great & entertaining Reels. Come and join to follow me. $value');
                        // });

                        Share.share(
                            'Hi, I am using Thrill to share and view great & entertaining Reels. Come and join to follow me. $value');
                      });
                    },
                    child: mainTile(IconlyBroken.send, shareProfile)),

                //  title(contentAndActivity),

                GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.NOTIFICATIONS_SETTINGS);
                      //  Navigator.pushNamed(context, '/pushNotification');
                    },
                    child:
                        mainTile(IconlyBroken.notification, pushNotification)),
                GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.PRIVACY_SETTINGS);
                    },
                    child:
                        mainTile(IconlyBroken.shield_done, "Privacy Settings")),
                GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.TERMS_OF_SERVICE);
                      //Navigator.pushNamed(context, '/termsOfService');
                    },
                    child: mainTile(IconlyBroken.shield_done, termsOfService)),
                // GestureDetector(
                //     onTap: () {
                //       switchAccountLayout();
                //     },
                //     child: mainTile(
                //         AntDesign.user_switch_outlined, switchAccount)),
                GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.PRIVACY);
                    },
                    child: mainTile(IconlyBroken.shield_done, privacy)),
                GestureDetector(
                    onTap: () async {
                      Get.defaultDialog(
                          title: "Logout?",
                          titleStyle: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 24),
                          middleText:
                              "This will also logout from other accounts!",
                          middleTextStyle:
                              const TextStyle(fontWeight: FontWeight.w600),
                          confirm: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () async {
                                await controller.signOutUser().then(
                                    (value) async => relatedVideosController
                                        .refereshVideos()
                                        .then((value) =>
                                            Get.offAllNamed(Routes.HOME)!));
                              },
                              child: const Text('Yes')),
                          cancel: ElevatedButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text("No")));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.only(right: 20),
                            child: Icon(IconlyBroken.logout,
                                color: Colors.red, size: 22),
                          ),
                          Expanded(
                            child: Text(
                              "Logout",
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red),
                            ),
                          ),
                          const Icon(IconlyBroken.arrow_right_2)
                        ],
                      ),
                    )),
                Card(
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: ColorManager.colorPrimaryLight),
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.only(top: 20),
                  elevation: 10,
                  child: GestureDetector(
                    onTap: () {
                      infoDialog(
                          title: "Looking for help?",
                          content:
                              "If you are facing product related issues or bugs or have any feedback in general, please drop us an email at:",
                          buttonText: "support@thrill.fun");
                      //Navigator.pushNamed(context, '/customerSupport');
                    },
                    child: Container(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: const Text(
                            "Technical Support",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          leading: Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(right: 20),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              child: const Icon(Icons.support_agent,
                                  color: ColorManager.colorAccent, size: 26),
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
                SizedBox(
                  height: 40,
                )
              ],
            )),
      ),
    );
  }

  infoDialog({String? title, String? content, String? buttonText}) =>
      Get.defaultDialog(
          titlePadding: EdgeInsets.only(top: 10, bottom: 10),
          title: title ?? "",
          titleStyle: TextStyle(fontWeight: FontWeight.w700),
          middleText: content ?? "",
          middleTextStyle: TextStyle(
            fontWeight: FontWeight.w400,
          ),
          confirm: InkWell(
            onTap: () {
              Uri emailURI = Uri(scheme: 'mailto', path: "support@thrill.fun");
              launchUrl(emailURI);
            },
            child: Text(
              buttonText ?? "",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                  decoration: TextDecoration.underline),
            ),
          ));
  Widget mainTile(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(right: 20),
            child: Icon(icon, color: ColorManager.dayNightIcon, size: 24),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          const Icon(IconlyBroken.arrow_right_2)
        ],
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

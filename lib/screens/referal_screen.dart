import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/rest/rest_url.dart';
import 'package:thrill/utils/util.dart';

import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:thrill/widgets/dashedline_vertical_painter.dart';

class ReferalScreen extends StatelessWidget {
  ReferalScreen({Key? key}) : super(key: key);

  var deepLink = ''.obs;

  @override
  Widget build(BuildContext context) {
    createDynamicLink();
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            decoration: const BoxDecoration(gradient: processGradient),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 40, left: 10, right: 10),
                  child: CachedNetworkImage(
                    imageUrl: RestUrl.assetsUrl + "trophy.png",
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin:
                          const EdgeInsets.only(top: 40, left: 10, right: 10),
                      child: CachedNetworkImage(
                        imageUrl: RestUrl.assetsUrl + "background_referal.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  alignment: Alignment.center,
                  width: Get.width,
                  child: Column(
                    children: [
                      Text(
                        "Refer a friend",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "And you can both save",
                        style: TextStyle(
                            color: Color(0xffB2B2B2),
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        "How it works",
                        style: TextStyle(
                            color: ColorManager.colorPrimaryLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(80),
                                    color: ColorManager.colorPrimaryLight),
                                child: const Icon(Icons.add),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Spend time\n watch videos",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                          CustomPaint(
                              size: Size(1, double.infinity),
                              painter: DashedLineVerticalPainter()),
                          Column(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(80),
                                    color: ColorManager.colorPrimaryLight),
                                child: const Icon(Icons.video_call_sharp),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Create videos\n get spins",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          ),
                          CustomPaint(
                              size: Size(1, double.infinity),
                              painter: DashedLineVerticalPainter()),
                          Column(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(80),
                                    color: ColorManager.colorPrimaryLight),
                                child: const Iconify(
                                  Mdi.medal,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Rewards",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      const Divider(
                        thickness: 1,
                        color: Color(0xff353841),
                        indent: 20,
                        endIndent: 20,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        height: 50,
                        margin: const EdgeInsets.only(
                            left: 20, right: 20, top: 80, bottom: 10),
                        width: Get.width,
                        decoration: BoxDecoration(
                            color: const Color(0xff353841),
                            border: Border.all(color: const Color(0xff353841)),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          children: [
                            Expanded(
                                child: Obx(() => Text(
                                      deepLink.value,
                                      style: TextStyle(color: Colors.white),
                                    ))),
                            Container(
                              padding: EdgeInsets.only(left: 15, right: 10),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        ColorManager.colorPrimaryLight,
                                        ColorManager.colorAccent
                                      ])),
                              child: InkWell(
                                onTap: () => {
                                  Clipboard.setData(ClipboardData(
                                      text: deepLink.value.toString())),
                                  successToast("Link copied!")
                                },
                                child: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      submitButtonLayout()
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 10, top: 10),
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(70)),
            child: InkWell(
              onTap: () => Get.back(),
              child: Icon(
                Icons.close,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  submitButtonLayout() => InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: deepLink.value.toString()));
          successToast("Link copied!");
        },
        child: Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorManager.colorPrimaryLight,
                    ColorManager.colorAccent
                  ])),
          child: const Text(
            "Refer Now",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );

  createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.page.link/',
      link: Uri.parse('https://thrillvideo.s3.amazonaws.com/test/'),
      androidParameters: AndroidParameters(
        packageName: 'com.thrill',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',x
      //   appStoreId: 'your_app_store_id',
      // ),
    );
    var dynamicUrl = await parameters.buildShortLink();
    deepLink.value = dynamicUrl.shortUrl.toString();
  }
}

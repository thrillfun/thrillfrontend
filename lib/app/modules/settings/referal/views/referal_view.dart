import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../utils/color_manager.dart';
import '../../../../utils/utils.dart';
import '../controllers/referal_controller.dart';

var deepLink = ''.obs;
var fullDeepLink = "".obs;

class ReferalView extends GetView<ReferalController> {
  const ReferalView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Stack(
            children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20),
                child: Lottie.asset("assets/referal.json", fit: BoxFit.fill),
              ),
              Container(
                width: Get.width,
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/background_referal.png",
                  fit: BoxFit.fill,
                  width: Get.width,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Refer a friend and get a chance to win Bitcoin worth 1 Lakh!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: ColorManager.colorAccent),
                          shape: BoxShape.circle,
                          color: ColorManager.colorAccentTransparent),
                      child: const Icon(
                        IconlyBroken.user_2,
                        color: ColorManager.colorAccent,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Invite your friend",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    )
                  ],
                ),
                const Expanded(
                    child: Divider(
                  color: ColorManager.colorAccent,
                  thickness: 1,
                )),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: ColorManager.colorAccent),
                            shape: BoxShape.circle,
                            color: ColorManager.colorAccentTransparent),
                        child: const Icon(
                          IconlyBroken.download,
                          color: ColorManager.colorAccent,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("download app",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12))
                    ],
                  ),
                ),
                const Flexible(
                    child: Center(
                  child: Divider(
                    color: ColorManager.colorAccent,
                    thickness: 1,
                  ),
                )),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: ColorManager.colorAccent),
                            shape: BoxShape.circle,
                            color: ColorManager.colorAccentTransparent),
                        child: const Icon(
                          IconlyBroken.star,
                          color: ColorManager.colorAccent,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("You both get reward",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12))
                    ],
                  ),
                ),
              ],
            ),
          ),
          referCodeLayout(),
          submitButtonLayout()
        ],
      ),
    );
  }

  referCodeLayout() => controller.obx(
      (state) => Container(
            margin:
                const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10),
            width: Get.width,
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: ColorManager.colorAccent),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    state!.value.referralCode.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                Container(
                  height: 50,
                  width: 50,
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
                  child: IconButton(
                    onPressed: () async {
                      await controller
                          .createDynamicLink(
                              state.value.id.toString(),
                              "referal",
                              state.value.username,
                              state.value.avatar,
                              referal: state.value.referralCode)
                          .then((value) {
                        Clipboard.setData(ClipboardData(text: value));
                        successToast("Link copied!");
                      });
                    },
                    icon: const Icon(
                      Icons.copy,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
      onLoading: loader());

  submitButtonLayout() => controller.obx((state) => InkWell(
        onTap: () async {
          await controller
              .createDynamicLink(state!.value.id.toString(), "referal",
                  state.value.username, state.value.avatar,
                  referal: state.value.referralCode)
              .then((value) {
            Share.share(value);
          });
        },
        child: Container(
          height: 50,
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ));

  createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.page.link/',
      link: Uri.parse(
          "https://thrill.fun/?id=${GetStorage().read("userId").toString()}"),
      androidParameters: const AndroidParameters(
        packageName: 'com.thrill.media',
        minimumVersion: 1,
      ),
      // iosParameters: IosParameters(
      //   bundleId: 'your_ios_bundle_identifier',
      //   minimumVersion: '1',x
      //   appStoreId: 'your_app_store_id',
      // ),
    );
    var dynamicUrl = await FirebaseDynamicLinks.instance.buildLink(parameters);
    deepLink.value = dynamicUrl.toString();
    fullDeepLink.value = dynamicUrl.toString();
    if (deepLink.value.length > 18) {
      deepLink.value = deepLink.value.substring(19, deepLink.value.length);
    }
  }
}

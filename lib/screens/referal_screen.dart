import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/dashedline_vertical_painter.dart';

User user = User.fromJson(GetStorage().read("user"));

class ReferalScreen extends StatelessWidget {
  ReferalScreen({Key? key}) : super(key: key);

  var deepLink = ''.obs;
  var fullDeepLink = "".obs;

  @override
  Widget build(BuildContext context) {
    createDynamicLink();

    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            height: Get.height,
            decoration: const BoxDecoration(gradient: processGradient),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: Get.width,
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        "assets/trophy.png",
                      ),
                    ),
                    Container(
                      height: 150,
                      width: Get.width,
                      alignment: Alignment.center,
                      child: Image.asset("assets/background_referal.png",fit: BoxFit.fill,width: Get.width,),
                    ),
                  ],
                ),
              ),
              referLayout()
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, top: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(70)),
            child: InkWell(
              onTap: () => Get.back(),
              child: const Icon(
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

  referLayout() => Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        width: Get.width,
        decoration: BoxDecoration(
            color: Color.fromRGBO(31, 33, 40, 0.5),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: referTitle(),
            ),
            const SizedBox(
              height: 10,
            ),
            referSubTitle(),
            const SizedBox(
              height: 50,
            ),
            referHowItWorks(),
            const SizedBox(
              height: 50,
            ),
            instructionsLayout(),
            const SizedBox(
              height: 50,
            ),
            Container(
              margin: const EdgeInsets.only(
                  left: 10, right: 10, top: 20, bottom: 30),
              child: Divider(
                color: Colors.grey[800],
              ),
            ),
            referalCodeTitle(),
            referCodeLayout(),
            submitButtonLayout()
          ],
        ),
      );

  referTitle() => const Text(
        'Refer a Friend',
        style: TextStyle(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
      );

  referSubTitle() => const Text(
        'And you can both save',
        style: TextStyle(
            color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w400),
      );

  referHowItWorks() => const Text(
        'How It works',
        style: TextStyle(
            color: ColorManager.colorPrimaryLight,
            fontWeight: FontWeight.w700,
            fontSize: 16),
      );

  referalCodeTitle() => const Text(
        'Your Referral Code',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16),
      );

  instructionsLayout() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  color: ColorManager.colorPrimaryLight,
                  child: const Icon(
                    Icons.add,
                  ),
                ),
              ),
              const Text(
                "Spend time \nwatch videos",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              )
            ],
          ),
          Container(
            height: 80,
            child: CustomPaint(
              painter: DashedLineVerticalPainter(Colors.grey[800]!),
            ),
          ),
          Column(
            children: [
              ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  color: ColorManager.colorPrimaryLight,
                  child: const Icon(
                    Icons.videocam_outlined,
                  ),
                ),
              ),
              const Text(
                "Create videos \nget spins",
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              )
            ],
          ),
          Container(
            height: 80,
            child: CustomPaint(
              painter: DashedLineVerticalPainter(Colors.grey[800]!),
            ),
          ),
          Column(
            children: [
              ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  color: ColorManager.colorPrimaryLight,
                  child: const Icon(
                    Icons.first_page,
                  ),
                ),
              ),
              const Text(
                "Reward",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              )
            ],
          ),
        ],
      );

  referCodeLayout() => Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10),
        width: Get.width,
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: const Color(0xff353841)),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Row(
          children: [
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                user.referralCode.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
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
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: fullDeepLink.value.toString()));
                  successToast("Link copied!");
                },
                icon: Icon(
                  Icons.copy,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );

  submitButtonLayout() => InkWell(
        onTap: () {
          Share.share(fullDeepLink.value);
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
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );

  createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.fun/',
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
    fullDeepLink.value = dynamicUrl.shortUrl.toString();
    if (deepLink.value.length > 18) {
      deepLink.value = deepLink.value.substring(19, deepLink.value.length);
    }
  }
}

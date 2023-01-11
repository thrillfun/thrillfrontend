import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/users/other_users_controller.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/screens/home/bottom_navigation.dart';
import 'package:thrill/screens/home/landing_page_getx.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/widgets/better_video_player.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../controller/videos/UserVideosController.dart';
import '../../controller/videos/like_videos_controller.dart';
import '../../rest/rest_url.dart';
import '../../utils/util.dart';
import 'package:get/get.dart';

class QrCode extends StatefulWidget {
  const QrCode({Key? key}) : super(key: key);

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  var usersController = Get.find<UserDetailsController>();
  var likedVideosController = Get.find<LikedVideosController>();
  var otherUsersController = Get.find<OtherUsersController>();
  var userVideosController = Get.find<UserVideosController>();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  User? userModel;

  @override
  void initState() {
    usersController.createDynamicLink(usersController.storage.read("userId").toString(),"profile", usersController.userProfile.value.name,"");

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.dayNight,
      body: qrView(),
    );
  }

  qrView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          height: 100,
          width: Get.width,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(),
              image: DecorationImage(
                  image: NetworkImage(
                      usersController.userProfile.value.avatar != null
                          ? RestUrl.profileUrl +
                              usersController.userProfile.value.avatar!
                          : RestUrl.placeholderImage))),
        ),
        Text(usersController.userProfile.value.name!,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
        const Text("Scan QR Code to follow account",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        Container(
          height: 250,
          decoration: BoxDecoration(
              color: ColorManager.dayNight,
              borderRadius: BorderRadius.circular(45)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Obx(() => QrImage(
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle),
                padding: const EdgeInsets.all(25),
                dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle),
                data: usersController.qrData.value,
                foregroundColor: Colors.black,
                version: QrVersions.auto,
                embeddedImage: Image.asset(
                  "assets/logo.png",
                ).image,
                embeddedImageStyle: QrEmbeddedImageStyle(),
              )),
        ),
        const SizedBox(
          height: 30,
        ),
        Flexible(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
                onTap: saveQrCode,
                borderRadius: BorderRadius.circular(10),
                splashColor: ColorManager.colorAccentTransparent,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download,
                        color: ColorManager.dayNightIcon,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        saveToDevice,
                        style: TextStyle(
                            fontSize: 16,
                            color: ColorManager.dayNightIcon,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                )),
            InkWell(
                onTap: () async {
                  String barcodeScanRes =
                      await FlutterBarcodeScanner.scanBarcode(
                          "#ff6666", "Cancel", true, ScanMode.QR);
                  if (barcodeScanRes.isNotEmpty && barcodeScanRes != '-1') {

                    final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getDynamicLink(Uri.parse(barcodeScanRes));

                    if (initialLink!.link.queryParameters["type"] == "profile") {
                      otherUsersController
                          .getOtherUserProfile(initialLink!.link.queryParameters["id"])
                          .then((value) {
                        likedVideosController.getOthersLikedVideos(int.parse(initialLink!.link.queryParameters["id"].toString())).then((value) {
                          userVideosController
                              .getOtherUserVideos(int.parse(initialLink!.link.queryParameters["id"].toString())).then((value) {
                            Get.to(ViewProfile(
                                initialLink!.link.queryParameters["id"],
                                0.obs,
                                initialLink!.link.queryParameters["name"],
                                initialLink!.link.queryParameters["something"]));
                          });

                        });

                      });
                    } else if (initialLink!.link.queryParameters["type"] == "video") {
                      successToast(initialLink!.link.queryParameters["id"].toString());
                    }



                  }
                },
                borderRadius: BorderRadius.circular(10),
                splashColor: Colors.white.withOpacity(0.50),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: ColorManager.dayNightIcon,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      InkWell(
                        onTap: () async {
                          String barcodeScanRes =
                              await FlutterBarcodeScanner.scanBarcode(
                                  "#ff6666", "Cancel", true, ScanMode.QR);

                          final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getDynamicLink(Uri.parse(barcodeScanRes));


                          if (initialLink!.link.queryParameters["type"] == "profile") {
                            otherUsersController
                                .getOtherUserProfile(initialLink!.link.queryParameters["id"])
                                .then((value) {
                              likedVideosController.getOthersLikedVideos(int.parse(initialLink!.link.queryParameters["id"].toString())).then((value) {
                                userVideosController
                                    .getOtherUserVideos(int.parse(initialLink!.link.queryParameters["id"].toString())).then((value) {
                                  Get.to(ViewProfile(
                                      initialLink!.link.queryParameters["id"],
                                      0.obs,
                                      initialLink!.link.queryParameters["name"],
                                      initialLink!.link.queryParameters["something"]));
                                });

                              });

                            });
                          } else if (initialLink!.link.queryParameters["type"] == "video") {
                            successToast(initialLink!.link.queryParameters["id"].toString());
                          }


                          showDialog(
                              context: context,
                              builder: (_) => Material(
                                    child: Center(child: Text(barcodeScanRes)),
                                  ));
                        },
                        child: Text(
                          scanQRCode,
                          style: TextStyle(
                              fontSize: 16,
                              color: ColorManager.dayNightIcon,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ))
      ],
    );
  }

  saveQrCode() async {
    // var status = await Permission.storage.isGranted;
    // if (!status) {
    //   Permission.storage.request();
    //   return;
    // }
    showLoadingDialog();
    try {
      DateTime dateTime = DateTime.now();
      File qrFile = File(
          '${saveDirectory}ThrillProfileQR-${dateTime.hour}${dateTime.minute}${dateTime.second}${dateTime.millisecond}.png');
      final qrValidationResult = QrValidator.validate(
        data: usersController.qrData.value,
        version: QrVersions.auto,
        
        errorCorrectionLevel: QrErrorCorrectLevel.L,
        
      );
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
          qr: qrCode!,
          color: const Color(0xFF000000),
          emptyColor: Colors.white,
          gapless: true,
          embeddedImageStyle: null,
          embeddedImage: null);

      final picData = await painter.toImageData(2048);
      final buffer = picData!.buffer;
      await File(qrFile.path).writeAsBytes(
          buffer.asUint8List(picData.offsetInBytes, picData.lengthInBytes));
      Get.back();
      showSuccessToast(context, "Successfully Saved QR Code!!");
    } catch (e) {
      Get.back();
      showErrorToast(context, "Failed to Save QR Code\n$e}");
    }
  }

  popUpDialog(String txt) {
    showDialog(
        context: context,
        builder: (_) => Center(
              child: Container(
                width: MediaQuery.of(context).size.width * .75,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close)),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SelectableText(
                            txt,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget scanqQr() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {},
        child: const Text("scan"),
      ),
    );
  }
}

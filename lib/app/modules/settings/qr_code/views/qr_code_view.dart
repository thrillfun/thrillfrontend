import 'dart:typed_data';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconly/iconly.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/strings.dart';
import '../../../../utils/utils.dart';
import '../controllers/qr_code_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeView extends GetView<QrCodeController> {
  const QrCodeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: MediaQuery.of(context).viewPadding.top,
        ),
        Container(
          height: 150,
          width: 150,
          child: imgProfile(Get.arguments["avatar"]),
        ),
        Text(GetStorage().read("name") ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 20,
          margin:
              const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                    "Scan QR Code to follow ${GetStorage().read("name")}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 20)),
              ),
              RepaintBoundary(
                key: controller.previewContainer,
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(45)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Obx(() => Visibility(
                          visible: controller.qrData.value.isNotEmpty,
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: QrImage(
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.circle,
                                  color: ColorManager.colorAccent,
                                ),
                                foregroundColor: ColorManager.colorAccent,
                                dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.circle),
                                data: controller.qrData.value,
                                version: QrVersions.auto,
                                embeddedImageStyle: QrEmbeddedImageStyle(),
                              ),
                            ),
                          ))),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 10,
                        child: Image.asset(
                          'assets/logo2.png',
                          fit: BoxFit.contain,
                          height: 40,
                          width: 50,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Flexible(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
                onTap: () async => await controller.captureSocialPng(),
                borderRadius: BorderRadius.circular(10),
                splashColor: ColorManager.colorAccentTransparent,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconlyBroken.download,
                        color: ColorManager.dayNightIcon,
                        size: 35,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        saveToDevice,
                        style: TextStyle(
                            fontSize: 18,
                            color: ColorManager.dayNightIcon,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                )),
            InkWell(
                onTap: () async {
                  Get.toNamed(Routes.QR_SCAN_VIEW);
                  // String barcodeScanRes =
                  //     await FlutterBarcodeScanner.scanBarcode(
                  //         "#ff6666", "Cancel", true, ScanMode.QR);
                  // if (barcodeScanRes.isNotEmpty && barcodeScanRes != '-1') {
                  //   final PendingDynamicLinkData? initialLink =
                  //       await FirebaseDynamicLinks.instance
                  //           .getDynamicLink(Uri.parse(barcodeScanRes));

                  //   if (initialLink!.link.queryParameters["type"] ==
                  //       "profile") {
                  //     Get.toNamed(Routes.OTHERS_PROFILE, arguments: {
                  //       "profileId": initialLink.link.queryParameters["id"]
                  //     });
                  //   }
                  // }
                },
                borderRadius: BorderRadius.circular(10),
                splashColor: Colors.white.withOpacity(0.50),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        IconlyBroken.scan,
                        color: ColorManager.dayNightIcon,
                        size: 35,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      InkWell(
                        onTap: () async {


                          // final PendingDynamicLinkData? initialLink =
                          //     await FirebaseDynamicLinks.instance
                          //         .getDynamicLink(Uri.parse(barcodeScanRes));
                          //
                          // if (initialLink!.link.queryParameters["type"] ==
                          //     "profile") {
                          //   // Get.to(ViewProfile(
                          //   //     initialLink!.link
                          //   //         .queryParameters["id"],
                          //   //     0.obs,
                          //   //     initialLink!.link
                          //   //         .queryParameters["name"],
                          //   //     initialLink!
                          //   //         .link
                          //   //         .queryParameters["something"]));
                          // } else if (initialLink!
                          //         .link.queryParameters["type"] ==
                          //     "video") {
                          //   successToast(initialLink!.link.queryParameters["id"]
                          //       .toString());
                          // }


                        },
                        child: Text(
                          scanQRCode,
                          style: TextStyle(
                              fontSize: 18,
                              color: ColorManager.dayNightIcon,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ))
      ],
    ));
  }
}

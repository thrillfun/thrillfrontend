import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../rest/rest_urls.dart';
import '../../../../utils/color_manager.dart';
import '../../../../utils/strings.dart';
import '../../../../utils/utils.dart';
import '../controllers/qr_code_controller.dart';

class QrCodeView extends GetView<QrCodeController> {
  const QrCodeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 100,
              width: Get.width,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(),
                  image: DecorationImage(
                      image: NetworkImage(GetStorage().read("avatar") != null
                          ? RestUrl.profileUrl + GetStorage().read("avatar")
                          : RestUrl.placeholderImage))),
            ),
            Text(GetStorage().read("name")??"",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24)),
            Text("Scan QR Code to follow account",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18)),
            RepaintBoundary(
              key: controller.previewContainer,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(45)),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45)),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Obx(() => Visibility(
                        visible: controller.qrData.value.isNotEmpty,
                          child: QrImage(
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.circle,
                          color: ColorManager.colorAccent,
                        ),
                        padding: const EdgeInsets.all(25),
                        foregroundColor: Colors.black,
                        dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle),
                        data: controller.qrData.value,
                        version: QrVersions.auto,
                        embeddedImageStyle: QrEmbeddedImageStyle(),
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
                        final PendingDynamicLinkData? initialLink =
                            await FirebaseDynamicLinks.instance
                                .getDynamicLink(Uri.parse(barcodeScanRes));

                        if (initialLink!.link.queryParameters["type"] ==
                            "profile") {
                          // Get.to(ViewProfile(
                          //     initialLink!.link
                          //         .queryParameters["id"],
                          //     0.obs,
                          //     initialLink!.link
                          //         .queryParameters["name"],
                          //     initialLink!
                          //         .link
                          //         .queryParameters["something"]));
                        } else if (initialLink!.link.queryParameters["type"] ==
                            "video") {
                          successToast(initialLink!.link.queryParameters["id"]
                              .toString());
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

                              final PendingDynamicLinkData? initialLink =
                                  await FirebaseDynamicLinks.instance
                                      .getDynamicLink(
                                          Uri.parse(barcodeScanRes));

                              if (initialLink!.link.queryParameters["type"] ==
                                  "profile") {
                                // Get.to(ViewProfile(
                                //     initialLink!.link
                                //         .queryParameters["id"],
                                //     0.obs,
                                //     initialLink!.link
                                //         .queryParameters["name"],
                                //     initialLink!
                                //         .link
                                //         .queryParameters["something"]));
                              } else if (initialLink!
                                      .link.queryParameters["type"] ==
                                  "video") {
                                successToast(initialLink!
                                    .link.queryParameters["id"]
                                    .toString());
                              }

                              showDialog(
                                  context: context,
                                  builder: (_) => Material(
                                        child:
                                            Center(child: Text(barcodeScanRes)),
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
        ));
  }
}

Widget scanqQr() {
  return Center(
    child: ElevatedButton(
      onPressed: () async {},
      child: const Text("scan"),
    ),
  );
}

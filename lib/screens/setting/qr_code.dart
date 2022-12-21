import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/controller/model/user_details_model.dart';
import 'package:thrill/controller/users/user_details_controller.dart';
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/screens/profile/view_profile.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
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

  String qrData = "";
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  User? userModel;

  @override
  void initState() {
    getUserModel();
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
          child: QrImage(
            eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle),
            padding: const EdgeInsets.all(25),
            dataModuleStyle:
                QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle),
            data: qrData,
            foregroundColor: Colors.black,
            version: QrVersions.auto,
            embeddedImage: Image.asset(
              "assets/logo.png",
            ).image,
            embeddedImageStyle: QrEmbeddedImageStyle(),
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
                    int _id = int.parse(
                        barcodeScanRes.split(':')[1].split('\n').first);
                    await usersController.getUserProfile(_id).then((value) {
                      Get.to(ViewProfile(
                          usersController.userProfile.value.id.toString(),
                          0.obs,
                          usersController.userProfile.value.name,
                          usersController.userProfile.value.avatar));
                    });
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
                      Text(
                        scanQRCode,
                        style: TextStyle(
                            fontSize: 16,
                            color: ColorManager.dayNightIcon,
                            fontWeight: FontWeight.bold),
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
    var status = await Permission.storage.isGranted;
    if (!status) {
      Permission.storage.request();
      return;
    }
    progressDialogue(context);
    try {
      DateTime dateTime = DateTime.now();
      File qrFile = File(
          '${saveDirectory}ThrillProfileQR-${dateTime.hour}${dateTime.minute}${dateTime.second}${dateTime.millisecond}.png');
      final qrValidationResult = QrValidator.validate(
        data: qrData,
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
      closeDialogue(context);
      showSuccessToast(context, "Successfully Saved QR Code!!");
    } catch (e) {
      closeDialogue(context);
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

  getUserModel() async {
    setState(() {
      qrData =
          "Thrill User ID :${GetStorage().read("userId")}\nProfile: www.google.com";
    });
  }

  Widget qr() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
              "#ff6666", "Cancel", true, ScanMode.QR);
          showDialog(
              context: context,
              builder: (_) => Material(
                    child: Center(child: Text(barcodeScanRes)),
                  ));
        },
        child: const Text("scan"),
      ),
    );
  }
}

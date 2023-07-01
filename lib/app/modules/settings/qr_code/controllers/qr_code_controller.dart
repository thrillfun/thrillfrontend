import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thrill/app/rest/models/user_details_model.dart';
import 'package:thrill/app/utils/utils.dart';

import '../../../../utils/strings.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class QrCodeController extends GetxController {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  User? userModel;
  final GlobalKey previewContainer = new GlobalKey();
  var qrData = ''.obs;
  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    createDynamicLink();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<String> createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://thrill.page.link/',
      link: Uri.parse(
          "https://thrill.fun?type=profile&id=${GetStorage().read("userId")}&name=${GetStorage().read("name")}&something=${GetStorage().read("avatar")}"),
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
    final dynamicLink =
        await FirebaseDynamicLinks.instance.buildLink(parameters);
    qrData.value = dynamicLink.toString();
    return dynamicLink.toString();
  }

  Future<void> captureSocialPng() {
    DateTime dateTime = DateTime.now();

    final RenderBox box = Get.context!.findRenderObject() as RenderBox;
    return Future.delayed(const Duration(milliseconds: 20), () async {
      RenderRepaintBoundary? boundary = previewContainer.currentContext!
          .findRenderObject() as RenderRepaintBoundary?;
      ui.Image image = await boundary!.toImage(pixelRatio: 10);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await File(
              '${saveDirectory}ThrillProfileQR-${dateTime.hour}${dateTime.minute}${dateTime.second}${dateTime.millisecond}.png')
          .writeAsBytes(pngBytes)
          .then((value) async {
        List<String> fileList = [];
        fileList.add(value.path);
        await Share.shareFiles(fileList,
            subject: 'Share',
            text: 'Check this Out!',
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      });
    });
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
        data: await createDynamicLink(),
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
      successToast("Successfully Saved QR Code!!");
    } catch (e) {
      Get.back();
      errorToast("Failed to Save QR Code\n$e}");
    }
  }
}

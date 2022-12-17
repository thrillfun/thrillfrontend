import 'dart:convert';
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
import 'package:thrill/controller/users_controller.dart';
import 'package:thrill/screens/profile/view_profile.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import '../../rest/rest_url.dart';
import '../../utils/util.dart';
import 'package:get/get.dart';

var usersController = Get.find<UserController>();
class QrCode extends StatefulWidget {
  const QrCode({Key? key}) : super(key: key);

  @override
  State<QrCode> createState() => _QrCodeState();



}

class _QrCodeState extends State<QrCode> {
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

  Widget qrView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(45)),
              padding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: QrImage(
                padding: const EdgeInsets.all(25),
                data: qrData,
                version: QrVersions.auto,
                embeddedImage: Image.asset("assets/logo_.png").image,
              ),
            ),
            Positioned(
              top: -60,
              child: Container(
                padding: const EdgeInsets.all(2),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorManager.spinColorDivider)),
                child:usersController.userProfile.value.avatar!.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset("assets/profile.svg"),
                )
                    : ClipOval(
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: 95,
                    width: 95,
                    imageUrl:
                    '${RestUrl.profileUrl}${usersController.userProfile.value.avatar}',
                    placeholder: (a, b) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              child: Text(usersController.userProfile.value.name!,
                  style: Theme.of(context).textTheme.headline3),
            ),
            Positioned(
              bottom: 30,
              child: Text("Scan QR Code to follow account",
                  style: Theme.of(context).textTheme.headline5),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
                onTap: saveQrCode,
                borderRadius: BorderRadius.circular(10),
                splashColor: Colors.white.withOpacity(0.50),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset('assets/download.svg'),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        saveToDevice,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
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
                    usersController.getUserProfile(_id).then((value) {
                      Get.to(ViewProfile(usersController.userProfile.value.id.toString(),0.obs,usersController.userProfile.value.name,usersController.userProfile.value.avatar));

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
                      SvgPicture.asset('assets/qr_small.svg'),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        scanQRCode,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ))
          ],
        )
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
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');
    User current = User.fromJson(jsonDecode(currentUser!));
    setState(() {
      qrData = "Thrill User ID :${GetStorage().read("userId")}\nProfile: www.google.com";
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

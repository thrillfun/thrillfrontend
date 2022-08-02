import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrill/models/user.dart';
import '../../common/color.dart';
import '../../common/strings.dart';
import '../../rest/rest_url.dart';
import '../../utils/util.dart';

class QrCode extends StatefulWidget {
  const QrCode({Key? key}) : super(key: key);

  @override
  State<QrCode> createState() => _QrCodeState();

  static const String routeName = '/qrcode';
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) =>  const QrCode(),
    );
  }
}

class _QrCodeState extends State<QrCode> {

  String qrData = "";
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  UserModel? userModel;

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
      backgroundColor: ColorManager.deepPurple,
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          qrCode,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        shape: const Border(bottom: BorderSide(color: Colors.white, width: 1)),
        backgroundColor: ColorManager.deepPurple,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.white,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: qrView(),
    );
  }
  Widget qrView(){
    if (userModel==null) {
      return const Center(child: Text("Something went wrong!"),);
    } else {
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
                  borderRadius: BorderRadius.circular(45)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
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
                  border: Border.all(color: ColorManager.spinColorDivider)
                ),
                child:userModel!.avatar.isEmpty
                 ? Padding(
                   padding: const EdgeInsets.all(10.0),
                   child: SvgPicture.asset("assets/profile.svg"),
                 )
                : ClipOval(
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    height: 95,width: 95,
                    imageUrl:
                    '${RestUrl.profileUrl}${userModel?.avatar}',
                    placeholder: (a, b) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(top: 40, child: Text(userModel!.name, style: Theme.of(context).textTheme.headline3),),
            Positioned(bottom: 30, child: Text("Scan QR Code to follow account", style: Theme.of(context).textTheme.headline5),),
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
                  String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.QR);
                  if(barcodeScanRes.isNotEmpty && barcodeScanRes!='-1'){
                    try{
                      if(barcodeScanRes.contains("Thrill")){
                        int _id = int.parse(barcodeScanRes.split(':')[1].split('\n').first);
                        if(_id==userModel!.id){
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route)=>false, arguments: {'index':3});
                        } else {
                          Navigator.pushNamed(context, "/viewProfile", arguments: {"id":_id, "getProfile":true});
                        }
                      } else {
                        popUpDialog(barcodeScanRes);
                      }
                    } catch(e){
                      popUpDialog(barcodeScanRes);
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

    }}
  saveQrCode()async{
    progressDialogue(context);
    try{
      DateTime dateTime = DateTime.now();
      File qrFile = File('${saveDirectory}ThrillProfileQR-${dateTime.hour}${dateTime.minute}${dateTime.second}${dateTime.millisecond}.png');
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
          embeddedImage: null
      );

      final picData = await painter.toImageData(2048);
      final buffer = picData!.buffer;
      await File(qrFile.path).writeAsBytes(
          buffer.asUint8List(picData.offsetInBytes, picData.lengthInBytes)
      );
      closeDialogue(context);
      showSuccessToast(context, "Successfully Saved QR Code!!");
    } catch(e){
      closeDialogue(context);
      showErrorToast(context, "Failed to Save QR Code\n$e}");
    }
  }
  popUpDialog(String txt){
    showDialog(context: context, builder: (_)=> Center(
      child: Container(
        width: MediaQuery.of(context).size.width*.75,
        height: 200,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    }, icon: const Icon(Icons.close)
                ),
              ),
              const Spacer(flex: 1,),
              Text(txt, textAlign: TextAlign.center,),
              const Spacer(flex: 3,),
            ],
          ),
        ),
      ),
    ));
  }
  getUserModel()async{
    var pref = await SharedPreferences.getInstance();
    var currentUser = pref.getString('currentUser');
    UserModel current = UserModel.fromJson(jsonDecode(currentUser!));
    setState(() {
      userModel = current;
      qrData = "Thrill User ID :${userModel?.id}\nProfile: www.google.com";
    });
  }
  Widget qr(){
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true, ScanMode.QR);
          showDialog(context: context, builder: (_)=>Material(
            child: Center(child: Text(barcodeScanRes)),
          ));
        },
        child: const Text("scan"),
      ),
    );
  }
}

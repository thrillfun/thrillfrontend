import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:thrill/main.dart';
import '../common/strings.dart';
import '../rest/rest_url.dart';

T getRandomElement<T>(List<T> list) {
  final random = Random();
  var i = random.nextInt(list.length);
  return list[i];
}

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

showErrorToast(BuildContext context,String msg)async{
  // final scaffold = ScaffoldMessenger.of(context);
  // scaffold.showSnackBar(
  //   SnackBar(content:  Text(msg,style: const TextStyle(color: Colors.white),),
  //     backgroundColor: Colors.red,
  //   ),
  // );
  showDialog(context: context, builder: (_)=> Center(
    child: Material(
      type: MaterialType.transparency,
      child: Container(
        width: getWidth(context)*.80,
        padding: const EdgeInsets.only(top: 7, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(failed, style: Theme.of(context).textTheme.headline2!.copyWith(color: Colors.red),),
            const Divider(color: Colors.red, thickness: 3, indent: 70, endIndent: 70,),
            const SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(msg,
                style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15,),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                  onPressed: (){
                    Get.back(closeOverlays: true);
                   // Navigator.pop(navigatorKey.currentContext!);
                    },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(right: 10),
                  ),
                  child: Text(ok, style: Theme.of(context).textTheme.headline3,)),
            )
          ],
        ),
      ),
    ),
  ));
  // try{
  //   await Future.delayed(const Duration(seconds: 7));
  //   if (!ModalRoute.of(context)!.isCurrent) Navigator.of(context, rootNavigator: true).pop();
  // } catch(_){}
}

showSuccessToast(BuildContext context,String msg) async {
  // final scaffold = ScaffoldMessenger.of(context);
  // scaffold.showSnackBar(
  //   SnackBar(content:  Text(msg,style: const TextStyle(color: Colors.white),),
  //     backgroundColor: Colors.green,
  //   ),
  // );
  showDialog(context: context, builder: (_)=> Center(
    child: Material(
      type: MaterialType.transparency,
      child: Container(
        width: getWidth(context)*.80,
        padding: const EdgeInsets.only(top: 7, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(successful, style: Theme.of(context).textTheme.headline2!.copyWith(color: Colors.green),),
            const Divider(color: Colors.green, thickness: 3, indent: 70, endIndent: 70,),
            const SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(msg,
                style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15,),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                  onPressed: (){
                    Get.back(closeOverlays: true);
              //      Navigator.pop(navigatorKey.currentContext!);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(right: 10),
                  ),
                  child: Text(ok, style: Theme.of(context).textTheme.headline3,)),
            )
          ],
        ),
      ),
    ),
  ));
  // try{
  //   await Future.delayed(const Duration(seconds: 7));
  //   if (!ModalRoute.of(context)!.isCurrent) Navigator.pop(context);
  // } catch(_){}
}

progressDialogue(BuildContext context) {
 /* AlertDialog alert = const AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Center(
      child: CircularProgressIndicator(),
    ),
  );*/

  showDialog(
    barrierDismissible: false,
    context:context,
    builder: (BuildContext context) {

      return WillPopScope(
        onWillPop: ()async{
          return false;
        },
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}

closeDialogue(BuildContext context) {
  Get.back(closeOverlays: true);
 // Navigator.pop(context);
}

Widget imgNet(String imgPath){

  return Container(
    child: CachedNetworkImage(
        placeholder: (a, b) => const Center(
          child: CircularProgressIndicator(),
        ),
        fit: BoxFit.cover,
        imageBuilder: (context, imageProvider) => Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            shape: BoxShape.rectangle,
            image: DecorationImage(
                image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        errorWidget: (context, string, dynamic)=>Image.network('${RestUrl.thambUrl}thumb-not-available.png'),
        imageUrl:imgPath),);
}

getTempDirectory()async{
  var directoryIOS = await getApplicationDocumentsDirectory();
  var directoryANDROID = await getTemporaryDirectory();
  if (Platform.isIOS) {
    saveDirectory = "${directoryIOS.path}/";
    saveCacheDirectory = "${directoryIOS.path}/";
  } else {
    saveDirectory = "/storage/emulated/0/Download/";
    saveCacheDirectory = "${directoryANDROID.path}/";
  }

  ///download spin sound spinWheel
  File file = File('${saveCacheDirectory}spin.mp3');
  if(!file.existsSync()) {
    await FileSupport().downloadCustomLocation(
      url: RestUrl.spinSound,
      path: saveCacheDirectory,
      filename: "spin",
      extension: ".mp3",
      progress: (progress) async {},
    );
  }
  }
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}


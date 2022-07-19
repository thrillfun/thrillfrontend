
import 'dart:math';

import 'package:flutter/material.dart';

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

showErrorToast(BuildContext context,String msg) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(content:  Text(msg,style: const TextStyle(color: Colors.white),),
      backgroundColor: Colors.red,
    ),
  );
}


showSuccessToast(BuildContext context,String msg) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(content:  Text(msg,style: const TextStyle(color: Colors.white),),
      backgroundColor: Colors.green,
    ),
  );
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
  Navigator.pop(context);
}

Widget imgNet(String imgPath){
  return Image.network(
    imgPath,
    loadingBuilder: (context, child, loadingProgress) =>
    (loadingProgress == null) ? child : const Center(child: CircularProgressIndicator()),
    errorBuilder: (context, error, stackTrace) => Image.network('${RestUrl.thambUrl}thumb-not-available.png', fit: BoxFit.fill,),
    fit: BoxFit.cover,
  );
}


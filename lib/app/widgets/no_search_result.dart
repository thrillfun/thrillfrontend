import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:lottie/lottie.dart';

class NoSearchResult extends StatelessWidget {
  NoSearchResult({this.text});

  String? text = "No results found!";
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset("assets/not_found.json", height: 250, width: 250),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            text ?? "",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
        )
      ],
    );
  }
}

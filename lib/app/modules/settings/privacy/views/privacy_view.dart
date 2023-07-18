import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/privacy_controller.dart';

class PrivacyView extends GetView<PrivacyController> {
  const PrivacyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading:
              IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close)),
          title: const Text(
            'Privacy Policy',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),
        body: controller.loadPrivacyPage("https://thrill.fun/privacy-policy"));
  }
}

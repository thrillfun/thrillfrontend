import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/terms_of_service_controller.dart';

class TermsOfServiceView extends GetView<TermsOfServiceController> {
  const TermsOfServiceView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: ()=>Get.back(), icon: Icon(Icons.close)),
          title: const Text('Terms of Service',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
          centerTitle: true,
        ),
        body: controller.loadPrivacyPage("https://thrill.fun/terms-conditions")
    );
  }
}

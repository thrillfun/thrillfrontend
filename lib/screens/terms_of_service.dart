import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/privacy_and_conditions/privacy_and_conditions_controller.dart';
import 'package:thrill/rest/rest_api.dart';

class TermsOfService extends GetView<PrivacyAndConditionsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.loadPrivacyPage("https://thrill.fun/terms-conditions"),
    );
  }
}

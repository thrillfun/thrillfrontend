import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:thrill/models/safety_preference_model.dart';
import 'package:thrill/rest/rest_api.dart';
import 'package:thrill/utils/util.dart';

import '../../common/strings.dart';
import '../../controller/privacy_and_conditions/privacy_and_conditions_controller.dart';

class Privacy extends GetView<PrivacyAndConditionsController> {
  const Privacy({Key? key}) : super(key: key);

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: controller.loadPrivacyPage() );
  }

 
}

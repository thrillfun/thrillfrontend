import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:get/get.dart';

import '../../../../utils/color_manager.dart';
import '../controllers/privacy_settings_controller.dart';

class PrivacySettingsView extends GetView<PrivacySettingsController> {
  const PrivacySettingsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Settings'),
        centerTitle: true,
      ),
      body: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Expanded(
                      child: Text(
                    "Allow Video Downloads",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  )),
                  Obx(() => FlutterSwitch(
                        onToggle: (bool value) {
                          controller.updateVideoDownloads(value);
                        },
                        width: 45,
                        height: 20,
                        padding: 0,
                        activeColor: ColorManager.colorAccentTransparent,
                        toggleColor: ColorManager.colorAccent,
                        inactiveToggleColor: Colors.black,
                        value: controller.isVideoDownloadble.value,
                      )),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Expanded(
                      child: Text(
                    "Allow Video Visibility",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  )),
                  Obx(() => FlutterSwitch(
                        onToggle: (bool value) {
                          controller.updateIsPostPublic(value);
                        },
                        width: 45,
                        height: 20,
                        padding: 0,
                        activeColor: ColorManager.colorAccentTransparent,
                        toggleColor: ColorManager.colorAccent,
                        inactiveToggleColor: Colors.black,
                        value: controller.isPostPublic.value,
                      )),
                ],
              ),
            ],
          )),
    );
  }
}

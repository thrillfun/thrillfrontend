import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:get/get.dart';

import '../../../../utils/color_manager.dart';
import '../../../../utils/strings.dart';
import '../controllers/notifications_settings_controller.dart';

class NotificationsSettingsView
    extends GetView<NotificationsSettingsController> {
  const NotificationsSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications Settings",style: TextStyle(fontSize: 24,fontWeight: FontWeight.w700),),),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Obx(
              () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          interactions,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                              fontSize: 18),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(child: Text(likes,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),)),
                            FlutterSwitch(
                              onToggle: (bool value) {
                                controller.likesSwitch.toggle();
                                controller.changeNotificationSettings(
                                    'likes', value ? 1 : 0);
                              },
                              width: 45,
                              height: 20,
                              padding: 0,
                              activeColor: ColorManager.cyan.withOpacity(0.40),
                              toggleColor: ColorManager.cyan,
                              inactiveToggleColor: Colors.black,
                              value: controller.likesSwitch.value,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          chooseToReceivePushNotificationOnLike,
                          style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(child: Text(comments,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),)),
                            FlutterSwitch(
                              onToggle: (bool value) {
                                controller.commentsSwitch.toggle();
                                controller.changeNotificationSettings(
                                    'comments', value ? 1 : 0);
                              },
                              width: 45,
                              height: 20,
                              padding: 0,
                              activeColor: ColorManager.cyan.withOpacity(0.40),
                              toggleColor: ColorManager.cyan,
                              inactiveToggleColor: Colors.black,
                              value: controller.commentsSwitch.value,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          chooseToReceivePushNotificationOnComment,
                          style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(child: Text(newFollowers,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),)),
                            FlutterSwitch(
                              onToggle: (bool value) {
                                controller.newFollowerSwitch.toggle();
                                controller.changeNotificationSettings(
                                    'new_followers', value ? 1 : 0);
                              },
                              width: 45,
                              height: 20,
                              padding: 0,
                              activeColor: ColorManager.cyan.withOpacity(0.40),
                              toggleColor: ColorManager.cyan,
                              inactiveToggleColor: Colors.black,
                              value: controller.newFollowerSwitch.value,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          chooseToReceivePushNotificationNewFollower,
                          style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            const Expanded(child: Text(mentions,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),)),
                            FlutterSwitch(
                              onToggle: (bool value) {
                                controller.mentionSwitch.toggle();
                                controller.changeNotificationSettings(
                                    'mentions', value ? 1 : 0);
                              },
                              width: 45,
                              height: 20,
                              padding: 0,
                              activeColor: ColorManager.cyan.withOpacity(0.40),
                              toggleColor: ColorManager.cyan,
                              inactiveToggleColor: Colors.black,
                              value: controller.mentionSwitch.value,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          chooseToReceivePushNotificationMentions,
                          style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),
                        ),
                        const Divider(
                          height: 50,
                          thickness: 2,
                        ),

                        Row(
                          children: [
                            const Expanded(child: Text(directMessages,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),)),
                            FlutterSwitch(
                              onToggle: (bool value) {
                                controller.directMessageSwitch.toggle();
                                controller.changeNotificationSettings(
                                    'direct_messages', value ? 1 : 0);
                              },
                              width: 45,
                              height: 20,
                              padding: 0,
                              activeColor: ColorManager.cyan.withOpacity(0.40),
                              toggleColor: ColorManager.cyan,
                              inactiveToggleColor: Colors.black,
                              value: controller.directMessageSwitch.value,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          chooseToReceivePushNotificationDirectMessage,
                          style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),
                        ),
                        const Divider(
                          height: 50,
                          thickness: 2,
                        ),

                        Row(
                          children: [
                            const Expanded(child: Text(videoUpdates,style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),)),
                            FlutterSwitch(
                              onToggle: (bool value) {
                                controller.followerVideoSwitch.toggle();
                                controller.changeNotificationSettings(
                                    'video_from_accounts_you_follow',
                                    value ? 1 : 0);
                              },
                              width: 45,
                              height: 20,
                              padding: 0,
                              activeColor: ColorManager.cyan.withOpacity(0.40),
                              toggleColor: ColorManager.cyan,
                              inactiveToggleColor: Colors.black,
                              value: controller.followerVideoSwitch.value,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          chooseToReceivePushNotificationVideoUpdates,
                          style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),
                        ),
                      ],
                    ),
            )),
      ),
    );
  }
}

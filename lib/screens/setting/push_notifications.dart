import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thrill/controller/settings/push_notifications_controller.dart';
import 'package:thrill/rest/rest_api.dart';

import '../../common/color.dart';
import '../../common/strings.dart';
import 'package:flutter_switch/flutter_switch.dart';

class PushNotification extends StatefulWidget {
  const PushNotification({Key? key}) : super(key: key);

  @override
  State<PushNotification> createState() => _PushNotificationState();

  static const String routeName = '/pushNotification';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => const PushNotification(),
    );
  }
}

class _PushNotificationState extends State<PushNotification> {


  var pushNotificationsController = Get.find<PushNotificationsController>();

  @override
  void initState() {
    loadSetting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          pushNotification,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Obx(()=>pushNotificationsController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                interactions,
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Expanded(child: Text(likes)),
                  FlutterSwitch(
                    onToggle: (bool value) {
                      setState(() {
                        pushNotificationsController.likesSwitch.toggle();
                        changeSetting('likes', value ? 1 : 0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: pushNotificationsController.likesSwitch.value,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                chooseToReceivePushNotificationOnLike,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Expanded(child: Text(comments)),
                  FlutterSwitch(
                    onToggle: (bool value) {
                      setState(() {
                        pushNotificationsController.commentsSwitch.toggle();
                        changeSetting('comments', value ? 1 : 0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: pushNotificationsController.commentsSwitch.value,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                chooseToReceivePushNotificationOnComment,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Expanded(child: Text(newFollowers)),
                  FlutterSwitch(
                    onToggle: (bool value) {
                      setState(() {
                        pushNotificationsController.newFollowerSwitch.toggle();
                        changeSetting('new_followers', value ? 1 : 0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: pushNotificationsController.newFollowerSwitch.value,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                chooseToReceivePushNotificationNewFollower,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Expanded(child: Text(mentions)),
                  FlutterSwitch(
                    onToggle: (bool value) {
                      setState(() {
                        pushNotificationsController.mentionSwitch.toggle();
                        changeSetting('mentions', value ? 1 : 0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: pushNotificationsController.mentionSwitch.value,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                chooseToReceivePushNotificationMentions,
                style: TextStyle(color: Colors.grey),
              ),
              const Divider(
                height: 50,
                color: Colors.grey,
                thickness: 2,
              ),
              const Text(
                message,
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Expanded(child: Text(directMessages)),
                  FlutterSwitch(
                    onToggle: (bool value) {
                      setState(() {
                        pushNotificationsController.directMessageSwitch.toggle();
                        changeSetting('direct_messages', value ? 1 : 0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: pushNotificationsController.directMessageSwitch.value,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                chooseToReceivePushNotificationDirectMessage,
                style: TextStyle(color: Colors.grey),
              ),
              const Divider(
                height: 50,
                color: Colors.grey,
                thickness: 2,
              ),
              const Text(
                videoUpdates,
                style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Expanded(child: Text(videoUpdates)),
                  FlutterSwitch(
                    onToggle: (bool value) {
                      setState(() {
                        pushNotificationsController.followerVideoSwitch.toggle();
                        changeSetting('video_from_accounts_you_follow',
                            value ? 1 : 0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: pushNotificationsController.followerVideoSwitch.value,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                chooseToReceivePushNotificationVideoUpdates,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),)
        ),
      ),
    );
  }

  void loadSetting() async {
    await pushNotificationsController.getNotificationsSettings();
  }

  Future<void> changeSetting(String type, int action) async {
    await pushNotificationsController.changeNotificationSettings(type,action);
  }
}

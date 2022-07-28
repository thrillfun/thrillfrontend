import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:thrill/rest/rest_api.dart';
import '../../common/color.dart';
import '../../common/strings.dart';

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

  bool likesSwitch = true;
  bool commentsSwitch = true;
  bool newFollowerSwitch = true;
  bool mentionSwitch = true;
  bool followerVideoSwitch = true;
  bool directMessageSwitch = true;
  bool isLoading = true;

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
          child: isLoading ? const Center(child: CircularProgressIndicator()) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                interactions,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                        likesSwitch = value;
                        changeSetting('likes', value?1:0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: likesSwitch,
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
                        commentsSwitch = value;
                        changeSetting('comments', value?1:0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: commentsSwitch,
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
                        newFollowerSwitch = value;
                        changeSetting('new_followers', value?1:0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: newFollowerSwitch,
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
                        mentionSwitch = value;
                        changeSetting('mentions', value?1:0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: mentionSwitch,
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                        directMessageSwitch = value;
                        changeSetting('direct_messages', value?1:0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: directMessageSwitch,
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                        followerVideoSwitch = value;
                        changeSetting('video_from_accounts_you_follow', value?1:0);
                      });
                    },
                    width: 45,
                    height: 20,
                    padding: 0,
                    activeColor: ColorManager.cyan.withOpacity(0.40),
                    toggleColor: ColorManager.cyan,
                    inactiveToggleColor: Colors.black,
                    inactiveColor: Colors.grey,
                    value: followerVideoSwitch,
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
          ),
        ),
      ),
    );
  }

  void loadSetting() async {
    var result = await RestApi.getNotificationSetting();
    var json = jsonDecode(result.body);
    if (json['status']) {
      likesSwitch = int.parse(json['data']['likes']) == 1 ? true : false;
      commentsSwitch = int.parse(json['data']['comments']) == 1 ? true : false;
      newFollowerSwitch = int.parse(json['data']['new_followers']) == 1 ? true : false;
      mentionSwitch = int.parse(json['data']['mentions']) == 1 ? true : false;
      followerVideoSwitch = int.parse(json['data']['video_from_accounts_you_follow']) == 1 ? true : false;
      directMessageSwitch = int.parse(json['data']['direct_messages']) == 1 ? true : false;
    }
    isLoading = false;
    setState(() {});
  }

  Future<bool> changeSetting(String type,int action)async{
    var result=await RestApi.setNotificationSetting(type, action);
    var json=jsonDecode(result.body);
    return json['status'];
  }
}

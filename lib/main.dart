import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:get/get.dart' as transition;
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/app/modules/home/app_bindings.dart';

import 'app/routes/app_pages.dart';
import 'firebase_options.dart';


List<CameraDescription> cameras = [];
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GlobalKey key = GlobalKey();
AwesomeNotifications? awesomeNotifications;

void main() async {

  await GetStorage.init();

  if (await Permission.notification.isGranted == false ||
      await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  MobileAds.instance.initialize();
  if (Platform.isIOS) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.ios);
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  }
  awesomeNotifications = AwesomeNotifications();
  awesomeNotifications?.initialize(
      'resource://drawable/icon',
      [
        NotificationChannel(
            channelGroupKey: 'normal_channel_group',
            channelKey: 'normal_channel',
            channelName: 'Normal Notifications',
            channelDescription: 'Notification channel for normal notifications',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupName: 'Normal group',
            channelGroupKey: 'normal_channel_group'),
      ],
      debug: true);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    awesomeNotifications?.createNotification(
      content: NotificationContent(
          id: Random().nextInt(111),
          channelKey: 'normal_channel',
          title: message.notification?.title,
          body: message.notification?.body,
          notificationLayout: NotificationLayout.Messaging,
          autoDismissible: false,
          showWhen: true),
    );
  });

  try {
    cameras = await availableCameras();
  } on CameraException catch (_) {}


  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final PendingDynamicLinkData? initialLink =
  await FirebaseDynamicLinks.instance.getInitialLink();


  runApp( GetMaterialApp(
    title: "Application",
    darkTheme: ThemeData.dark(),
    initialBinding: AppBindings(),
    initialRoute: AppPages.INITIAL,
    getPages: AppPages.routes,
  ),);
}


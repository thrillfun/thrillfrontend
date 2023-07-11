import 'dart:math';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/app/modules/bindings/app_bindings.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';

import 'app/routes/app_pages.dart';
import 'app/utils/utils.dart';
import 'firebase_options.dart';

List<CameraDescription> cameras = [];
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GlobalKey key = GlobalKey();
AwesomeNotifications? awesomeNotifications;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  if (await Permission.notification.isGranted == false ||
      await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  MobileAds.instance.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
  //   return true;
  // };
  awesomeNotifications = AwesomeNotifications();
  awesomeNotifications?.initialize(
      'resource://drawable/icon.png',
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

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent.withOpacity(0.0)));
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  FirebaseDynamicLinks.instance.onLink.listen(
    (pendingDynamicLinkData) async {
      // Set up the `onLink` event listener next as it may be received here
      if (pendingDynamicLinkData.link.queryParameters["type"] == "profile") {
        // Get.toNamed(Routes.OTHERS_PROFILE, arguments: {
        //   "profileId": pendingDynamicLinkData.link.queryParameters["id"]
        // });

      } else if (pendingDynamicLinkData.link.queryParameters["type"] ==
          "video") {

      } else if (pendingDynamicLinkData.link.queryParameters["type"] ==
          "referal") {
        await GetStorage().write("referral_code",
            pendingDynamicLinkData.link.queryParameters["referal"].toString());

      }
    },
  );
  VESDK.unlockWithLicense("assets/vesdk_android_license");

  runApp(
    GetMaterialApp(
      title: "Thrill",
      debugShowCheckedModeBanner: false,
      darkTheme: darkThemeData,
      theme: lightThemeData,
      initialBinding: AppBindings(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}

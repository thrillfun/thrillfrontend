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
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thrill/common/strings.dart';
import 'package:thrill/controller/bindings.dart';
import 'package:thrill/controller/model/inbox_model.dart';
import 'package:thrill/firebase_options.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/screens/chat/chat_screen.dart';
import 'package:thrill/screens/hash_tags/hash_tags_screen.dart';
import 'package:thrill/screens/home/discover_getx.dart';
import 'package:thrill/screens/home/home_getx.dart';
import 'package:thrill/screens/profile/profile.dart';
import 'package:thrill/screens/profile/view_profile.dart';
import 'package:thrill/screens/screen.dart';
import 'package:thrill/screens/search/search_getx.dart';
import 'package:thrill/screens/setting/profile_details.dart';
import 'package:thrill/screens/setting/qr_code.dart';
import 'package:thrill/screens/setting/wallet_getx.dart';
import 'package:thrill/utils/notification.dart';
import 'package:thrill/utils/util.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';

import 'screens/home/landing_page_getx.dart';

List<CameraDescription> cameras = [];
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GlobalKey key = GlobalKey();
AwesomeNotifications? awesomeNotifications;

void main() async {
  await GetStorage.init();

  WidgetsFlutterBinding.ensureInitialized();

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

  getTempDirectory();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return transition.GetMaterialApp(
        darkTheme: ThemeData(brightness: Brightness.dark),
        theme: ThemeData(brightness: Brightness.light),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        initialBinding: DataBindings(),
        home: LandingPageGetx());
  }
}

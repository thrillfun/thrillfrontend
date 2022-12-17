import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' as transition;
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/bindings.dart';
import 'package:thrill/utils/notification.dart';
import 'package:thrill/utils/util.dart';

import 'config/app_router.dart';
import 'config/theme.dart';
import 'screens/home/landing_page_getx.dart';
import 'screens/screen.dart';

List<CameraDescription> cameras = [];
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GlobalKey key = GlobalKey();

void main() async {
  Paint.enableDithering = true;
  
  await GetStorage.init();


  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  MobileAds.instance.initialize();
  if (Platform.isIOS) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            projectId: 'algebraic-envoy-350105',
            apiKey: 'AIzaSyCn2oXiqua7pqQ1mVz6HRubs7MQOzlBev0',
            messagingSenderId: '882291140458',
            appId: '1:882291140458:ios:876fc96cea6013bf3e6713'));
  } else {
    await Firebase.initializeApp();
  }
  await FirebaseMessaging.instance.getToken();
  CustomNotification.initialize();

  try {
    cameras = await availableCameras();
  } on CameraException catch (_) {}
  FirebaseMessaging.onMessage.listen((event) {
    CustomNotification.showNormal(
        title: event.notification?.title ?? "",
        body: event.notification?.body ?? "");
  });
  getTempDirectory();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  ThemeData _darkTheme = ThemeData(
      accentColor: ColorManager.colorAccent,
      fontFamily: "Urbanist",
      brightness: Brightness.dark,
      primaryColor: ColorManager.colorPrimaryLight,
      buttonTheme: const ButtonThemeData(
        buttonColor: ColorManager.colorAccent,
        disabledColor: Colors.blueGrey,
      ));

  ThemeData _lightTheme = ThemeData(
      accentColor: ColorManager.colorAccent,
      brightness: Brightness.light,
      fontFamily: "Urbanist",
      primaryColor: ColorManager.colorPrimaryLight,
      buttonTheme: const ButtonThemeData(
        buttonColor: ColorManager.colorAccent,
        disabledColor: Colors.blueGrey,
      ));

  runApp(transition.GetMaterialApp(
    theme: _lightTheme,
    darkTheme: _darkTheme,
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    initialBinding: DataBindings(),
    home: ShowCaseWidget(builder: Builder(builder: (context) => const MyApp())),
  ));
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
    return MaterialApp(
      title: 'Thrill',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: theme(),
      home: LandingPageGetx(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

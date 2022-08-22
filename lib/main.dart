import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:thrill/blocs/video/video_bloc.dart';
import 'package:thrill/repository/video/video_repository.dart';
import 'package:thrill/utils/notification.dart';
import 'package:thrill/utils/util.dart';
import 'package:thrill/widgets/video_item.dart';
import 'config/app_router.dart';
import 'config/theme.dart';
import 'screens/screen.dart';

List<CameraDescription> cameras = [];
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  MobileAds.instance.initialize();
  if(Platform.isIOS){
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            projectId: 'algebraic-envoy-350105',
            apiKey: 'AIzaSyCn2oXiqua7pqQ1mVz6HRubs7MQOzlBev0',
            messagingSenderId: '882291140458',
            appId: '1:882291140458:ios:876fc96cea6013bf3e6713'
        ));
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
        title: event.notification?.title??"",
        body: event.notification?.body??""
    );
  });
  getTempDirectory();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state){
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        try{
          reelsPlayerController?.pause();
        }catch(_){}
        break;
      case AppLifecycleState.detached:
        break;
  }
}

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => VideoBloc(videoRepository: VideoRepository())
              ..add(const VideoLoading(selectedTabIndex: 1))),
      ],
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }},
        child: MaterialApp(
          title: 'Thrill',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: theme(),
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: SplashScreen.routeName,
        ),
      ),
    );
  }
}

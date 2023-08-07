import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_data/sim_data.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:thrill/app/modules/login/views/login_view.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/utils/page_manager.dart';
import 'package:thrill/app/utils/strings.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';

import '../rest/rest_urls.dart';
import 'color_manager.dart';

var isPlaying = false.obs;
var isAudioLoading = true.obs;
var audioDuration = const Duration().obs;
var audioTotalDuration = const Duration().obs;
var audioBuffered = const Duration().obs;
final progressNotifier = ValueNotifier<ProgressBarState>(
  ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  ),
);

AudioPlayer audioPlayer = AudioPlayer();

var lightThemeData = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorManager.colorAccent))),
  dividerColor: Colors.grey,
  fontFamily: ('Roboto'),
  bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
  hintColor: Colors.black.withOpacity(0.3),
  indicatorColor: ColorManager.colorAccent,
  focusColor: ColorManager.colorAccent,
  dialogBackgroundColor: Colors.white,
  progressIndicatorTheme:
      const ProgressIndicatorThemeData(color: ColorManager.colorAccent),
  textSelectionTheme:
      const TextSelectionThemeData(cursorColor: ColorManager.colorAccent),
  inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: ColorManager.colorAccent,
      focusColor: ColorManager.colorAccent,
      fillColor: Colors.grey.withOpacity(0.1),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Colors.black,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.1),
    ),
  )),
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    button: TextStyle(color: Colors.white),
  ),
  tabBarTheme: const TabBarTheme(
      labelColor: Colors.black,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: ColorManager.colorAccent,
          fontSize: 18),
      indicatorColor: ColorManager.colorAccent,
      dividerColor: ColorManager.colorAccent),
  appBarTheme: const AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      color: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 0),
  primaryColor: ColorManager.colorAccent,
);
var darkThemeData = ThemeData(
  dividerColor: Colors.grey,
  fontFamily: ('Roboto'),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(ColorManager.colorAccent))),
  bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
  hintColor: Colors.white.withOpacity(0.3),
  indicatorColor: ColorManager.colorAccent,
  focusColor: ColorManager.colorAccent,
  backgroundColor: Colors.black,
  textSelectionTheme:
      const TextSelectionThemeData(cursorColor: ColorManager.colorAccent),
  inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: ColorManager.colorAccent,
      focusColor: ColorManager.colorAccent,
      fillColor: Colors.grey.withOpacity(0.1),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(
          color: Color(0xffFAFAFA),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(0.1),
        ),
      ),disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.1),
    ),
  )),
  dialogBackgroundColor: Colors.black,

  appBarTheme: const AppBarTheme(
    color: Colors.black,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 24,
    ),
  ),
  scaffoldBackgroundColor: Colors.black,
  cardColor: Colors.black,
  tabBarTheme: const TabBarTheme(
      indicatorSize: TabBarIndicatorSize.label,
      labelColor: Colors.white,
      labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: ColorManager.colorAccent,
          fontSize: 18),
      indicatorColor: ColorManager.colorAccent,
      dividerColor: ColorManager.colorAccent),
  progressIndicatorTheme:
      const ProgressIndicatorThemeData(color: ColorManager.colorAccent),
  colorScheme: const ColorScheme.dark(background: Colors.black),
  primaryColor: ColorManager.colorAccent,
);
const LinearGradient gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF162C31), Color(0xff181A20), Color(0xff1F2128)]);

const LinearGradient processGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      ColorManager.colorPrimaryLight,
      Color(0xff1F2128),
      Color(0xff1F2128),
      Color(0xff1F2128)
    ]);

const LinearGradient profile_gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromRGBO(22, 44, 49, 1),
      Color.fromRGBO(24, 26, 32, 1),
      Color.fromRGBO(31, 33, 40, 1)
    ]);
const LinearGradient profile_options_gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1F2128),
      Color(0xFF1F2128),
      Color(0xFF1F2128),
    ]);

T getRandomElement<T>(List<T> list) {
  final random = Random();
  var i = random.nextInt(list.length);
  return list[i];
}

double getHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

showErrorToast(BuildContext context, String msg) async {
  Get.showSnackbar(GetSnackBar(
    duration: const Duration(seconds: 3),
    barBlur: 10,
    borderColor: Colors.red,
    borderWidth: 1.5,
    margin: const EdgeInsets.only(
      left: 10,
      right: 10,
      bottom: 10,
    ),
    borderRadius: 10,
    backgroundColor: Colors.red.shade50,
    messageText: Text(
      msg,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    isDismissible: true,
    mainButton: IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(Icons.close),
    ),
    icon: const Icon(
      Icons.error,
      color: Colors.red,
    ),
  ));
}

errorToast(dynamic message) async {
  Get.showSnackbar(GetSnackBar(
    duration: const Duration(seconds: 30),
    barBlur: 10,
    borderColor: Colors.red.shade800,
    borderWidth: 1.5,
    margin: const EdgeInsets.only(
      left: 10,
      right: 10,
      bottom: 10,
    ),
    borderRadius: 10,
    backgroundColor: Colors.red.shade300,
    messageText: Text(
      message.toString(),
      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
    ),
    isDismissible: true,
    mainButton: IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(
        Icons.close,
        color: Colors.white,
      ),
    ),
    icon: Icon(
      Icons.error,
      color: Colors.white,
    ),
  ));
}

showSuccessToast(BuildContext context, String msg) async {
  Get.showSnackbar(GetSnackBar(
    duration: const Duration(seconds: 3),
    barBlur: 10,
    borderColor: Colors.green.shade800,
    borderWidth: 1.5,
    margin: const EdgeInsets.only(
      left: 10,
      right: 10,
      bottom: 10,
    ),
    borderRadius: 10,
    backgroundColor: Colors.green.shade600,
    messageText: Text(
      msg,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    isDismissible: true,
    mainButton: IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(Icons.close),
    ),
    icon: Icon(
      Icons.error,
      color: Colors.green.shade600,
    ),
  ));
}

successToast(String msg) async {
  Get.showSnackbar(GetSnackBar(
    duration: const Duration(seconds: 3),
    barBlur: 10,
    borderColor: ColorManager.colorAccent,
    borderWidth: 1.5,
    margin: const EdgeInsets.only(
      left: 10,
      right: 10,
      bottom: 10,
    ),
    borderRadius: 10,
    backgroundColor: ColorManager.colorAccent,
    messageText: Text(
      msg,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
    isDismissible: true,
    mainButton: IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(
        Icons.close,
        color: Colors.white,
      ),
    ),
    icon: const Icon(
      Icons.error,
      color: Colors.white,
    ),
  ));
}

uploadingToast(SimpleS3 _simpleS3) async {
  Get.showSnackbar(GetSnackBar(
    duration: null,
    barBlur: 10,
    borderColor: ColorManager.colorPrimaryLight,
    borderWidth: 1.5,
    margin: const EdgeInsets.only(
      left: 10,
      right: 10,
      bottom: 10,
    ),
    borderRadius: 10,
    backgroundColor: Colors.green.shade50,
    messageText: StreamBuilder<dynamic>(
        stream: _simpleS3.getUploadPercentage,
        builder: (context, snapshot) {
          return snapshot.data != null
              ? LinearProgressIndicator(
                  value: (snapshot.data as int).toDouble(),
                )
              : const LinearProgressIndicator(
                  value: 0,
                );
        }),
    isDismissible: false,
    mainButton: IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(Icons.close),
    ),
    icon: const Icon(
      Icons.error,
      color: Colors.green,
    ),
  ));
}

progressDialogue(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}

closeDialogue(BuildContext context) {
  Get.back();
  // Navigator.pop(context);
}

emptyListWidget({String data = "Oops Nothing Found"}) => Expanded(
      child: Center(
        child: Text(
          data,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

musicPlayerBottomSheet(
        RxString profilePic, RxString soundName, RxString soundUrl) =>
    Get.bottomSheet(
        Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/Image.png"),
                    imgProfile(profilePic.value),
                  ],
                ),
              ],
            )),
        backgroundColor: Get.isPlatformDarkMode ? Colors.grey : Colors.white);

void seek(Duration position) {
  audioPlayer.seek(position);
}
enableWakeLock()async{
  if(await Wakelock.enabled==false ){
    await Wakelock.enable();
  }
  Logger().wtf(await Wakelock.enabled);
}

disableWakeLock()async{
  if(await Wakelock.enabled){
    await Wakelock.disable();
  }
  Logger().wtf(await Wakelock.enabled);

}

Widget imgNet(String imgPath) {
  return CachedNetworkImage(
      placeholder: (a, b) => Center(
            child: loader(),
          ),
      fit: BoxFit.fitWidth,
      imageBuilder: (context, imageProvider) => Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle,
              image:
                  DecorationImage(image: imageProvider, fit: BoxFit.fitWidth),
            ),
          ),
      errorWidget: (context, string, dynamic) => CachedNetworkImage(
          placeholder: (a, b) => Center(
                child: loader(),
              ),
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
          imageUrl:
              'https://craftsnippets.com/articles_images/placeholder/placeholder.jpg'),
      imageUrl: imgPath);
}

Widget imgProfile(String imagePath) => Container(
      child: CachedNetworkImage(
          placeholder: (a, b) => const Center(
                child: CircularProgressIndicator(),
              ),
          fit: BoxFit.fill,
          height: 60,
          width: 60,
          imageBuilder: (context, imageProvider) => Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  shape: BoxShape.rectangle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
          errorWidget: (context, string, dynamic) => CachedNetworkImage(
              placeholder: (a, b) => Center(
                    child: loader(),
                  ),
              fit: BoxFit.fill,
              height: 60,
              width: 60,
              imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.fill),
                    ),
                  ),
              imageUrl: RestUrl.placeholderImage),
          imageUrl: RestUrl.profileUrl + imagePath),
    );

Widget imgProfileDetails(String imagePath) => Container(
      child: CachedNetworkImage(
          placeholder: (a, b) => const Center(
                child: CircularProgressIndicator(),
              ),
          fit: BoxFit.fill,
          imageBuilder: (context, imageProvider) => Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
          errorWidget: (context, string, dynamic) => CachedNetworkImage(
              placeholder: (a, b) => Center(
                    child: loader(),
                  ),
              fit: BoxFit.fill,
              height: 60,
              width: 60,
              imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.fill),
                    ),
                  ),
              imageUrl: RestUrl.placeholderImage),
          imageUrl: RestUrl.profileUrl + imagePath),
    );

Widget imgProfileDialog(String imagePath) => Container(
      child: CachedNetworkImage(
          placeholder: (a, b) => const Center(
                child: CircularProgressIndicator(),
              ),
          fit: BoxFit.fill,
          imageBuilder: (context, imageProvider) => Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
          errorWidget: (context, string, dynamic) => CachedNetworkImage(
              placeholder: (a, b) => Center(
                    child: loader(),
                  ),
              fit: BoxFit.fill,
              imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.fill),
                    ),
                  ),
              imageUrl: RestUrl.placeholderImage),
          imageUrl: RestUrl.profileUrl + imagePath),
    );

Widget imgSound(String imagePath) => Container(
      child: CachedNetworkImage(
          placeholder: (a, b) => Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: ColorManager.colorAccent.withOpacity(0.5),
                      width: 2),
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                ),
                child: CachedNetworkImage(
                    placeholder: (a, b) => Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/person_place_holder.png"),
                                opacity: 0.3,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.contain),
                          ),
                        ),
                    fit: BoxFit.contain,
                    imageBuilder: (context, imageProvider) => Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/person_place_holder.png"),
                                opacity: 0.3,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.contain),
                          ),
                        ),
                    imageUrl: RestUrl.placeholderImage),
              ),
          fit: BoxFit.fill,
          height: 60,
          width: 60,
          imageBuilder: (context, imageProvider) => Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(color: ColorManager.colorAccent),
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
          errorWidget: (context, string, dynamic) => Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: ColorManager.colorAccent.withOpacity(0.5),
                      width: 2),
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                ),
                child: CachedNetworkImage(
                    placeholder: (a, b) => Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/person_place_holder.png"),
                                opacity: 0.3,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.contain),
                          ),
                        ),
                    fit: BoxFit.contain,
                    imageBuilder: (context, imageProvider) => Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/person_place_holder.png"),
                                opacity: 0.3,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.contain),
                          ),
                        ),
                    imageUrl: RestUrl.placeholderImage),
              ),
          imageUrl: RestUrl.profileUrl + imagePath),
    );
getTempDirectory() async {
  var directoryIOS = await getApplicationDocumentsDirectory();
  var directoryANDROID = await getTemporaryDirectory();
  if (Platform.isIOS) {
    saveDirectory = "${directoryIOS.path}/";
    saveCacheDirectory = "${directoryIOS.path}/";
  } else {
    saveDirectory = "/storage/emulated/0/Download/";
    saveCacheDirectory = "${directoryANDROID.path}/";
  }

  ///download spin sound spinWheel
  File file = File('${saveCacheDirectory}spin.mp3');
  if (!file.existsSync()) {
    await FileSupport().downloadCustomLocation(
      url: RestUrl.spinSound,
      path: saveCacheDirectory,
      filename: "spin",
      extension: ".mp3",
      progress: (progress) async {},
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

loadLocalSvg(String name) => SvgPicture.asset(
      "assets/$name",
      fit: BoxFit.fill,
    );

errorWidget() => CachedNetworkImage(
      fit: BoxFit.fill,
      imageUrl:
          "https://cdn.dribbble.com/users/463734/screenshots/2016807/404_error_shot.png",
    );

showLoginAlert() {
  Get.defaultDialog(
      title: 'Login',
      middleText: 'Please Login to your account',
      confirm: TextButton(
          onPressed: () {
            Get.back(closeOverlays: true);
          },
          child: const Text('Cancel')),
      cancel: TextButton(
          onPressed: () {
            // Navigator.pushNamedAndRemoveUntil(
            //     context, '/login', (route) => false);
            Get.toNamed(Routes.LOGIN);
          },
          child: const Text('Ok')));
}

showLoadingDialog() =>
    Get.defaultDialog(title: "Please Wait", content: loader());

loader() => Container(
      height: 150,
      width: 150,
      alignment: Alignment.center,
      color: Colors.transparent.withOpacity(0.0),
      child: Lottie.asset("assets/loader.json", height: 150, width: 150),
    );

showWinDialog(String msg) => Get.defaultDialog(
      contentPadding: EdgeInsets.all(5),
      backgroundColor: Colors.transparent,
      title: "",
      content: Container(
          margin: const EdgeInsets.only(top: 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          width: Get.width,
          child: Stack(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      IgnorePointer(
                        child: Lottie.asset("assets/congrats.json",
                            fit: BoxFit.cover, height: 150, width: Get.width),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(bottom: 20),
                        child: Lottie.asset("assets/winning.json",
                            height: 200, fit: BoxFit.fill, width: 500),
                      ),
                    ],
                  ),
                  const Text(
                    "Congratulations!",
                    style: TextStyle(
                        color: ColorManager.colorPrimaryLight,
                        fontSize: 25,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    msg,
                    style: const TextStyle(
                        color: ColorManager.colorPrimaryLight,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  InkWell(
                    onTap: () {
                      // ScreenshotController()
                      //     .captureFromWidget(Container(
                      //         padding: const EdgeInsets.all(30.0),
                      //         decoration: BoxDecoration(
                      //           border: Border.all(
                      //               color: Colors.blueAccent, width: 5.0),
                      //           color: Colors.redAccent,
                      //         ),
                      //         child: Text("This is an invisible widget")))
                      //     .then((capturedImage) async {
                      //   var file = await File("${saveCacheDirectory}temp.png")
                      //       .writeAsBytes(capturedImage);
                      //   Logger().wtf(file.path);
                      //   // Handle captured image
                      // });
                    },
                    child: Container(
                      width: Get.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                ColorManager.colorPrimaryLight,
                                ColorManager.colorAccent
                              ])),
                      child: const Text(
                        "Excellent!",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Icon(
                    IconlyLight.close_square,
                    color: ColorManager.colorAccent,
                  ),
                ),
              )
            ],
          )),
    );

convertUTC(String format) {
  var str = format;
  var newStr = str.substring(0, 10) + ' ' + str.substring(11, 23);
  DateTime dt = DateTime.parse(newStr);
  return DateFormat("dd-MM-yyyy").format(dt).toString();
}

checkForLogin(VoidCallback action) async {
  if (await GetStorage().read("token") == null) {
    if (await Permission.phone.isGranted) {
      await SimDataPlugin.getSimData().then((value) => value.cards.isEmpty
          ? showLoginBottomSheet(false.obs)
          : showLoginBottomSheet(true.obs));
    } else {
      await Permission.phone.request().then((value) async =>
          await SimDataPlugin.getSimData().then((value) => value.cards.isEmpty
              ? showLoginBottomSheet(false.obs)
              : showLoginBottomSheet(true.obs)));
    }
  } else {
    action();
  }
}

showLoginBottomSheet(RxBool isPhoneAvailable) =>
    Get.bottomSheet(LoginView(isPhoneAvailable),shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.only(topRight: Radius.circular(15),topLeft: Radius.circular(15))),
        isScrollControlled: false,
        backgroundColor: Theme.of(Get.context!)
            .scaffoldBackgroundColor);

extension FormatViews on int {
  String formatViews() => NumberFormat.compact().format(this);
}

extension FormatCrypto on String{
  String formatCrypto() => isEmpty ? double.parse("0.0").toStringAsFixed(1).toString(): double.parse(this).toStringAsFixed(4).toString();
}

Widget myLabel(String txt){
  return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(txt, style: const TextStyle(color: Color(0xff21252E), fontWeight: FontWeight.w900, fontSize: 13),),
      ));
}
extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  DashedLineVerticalPainter(this.color) {}
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = color!
      ..strokeWidth = 1;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:iconly/iconly.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readmore/readmore.dart';
import 'package:shimmer/shimmer.dart';
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
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
      disabledBorder: OutlineInputBorder(
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
      ),
      disabledBorder: OutlineInputBorder(
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

Future<List<FileSystemEntity>> getFilesFromFolder(Directory folderPath) async {
  var entities = await folderPath.list().toList();
  return entities;
}

showVideoBottomSheet(
        VoidCallback deleteVideo,
        VoidCallback favUnfavVideo,
        VoidCallback createDynamicLink,
        VoidCallback checkVideoReported,
        VoidCallback downloadAndProcessVideo,
        VoidCallback checkUserBlocked,
        RxBool isUserBlocked,
        RxBool isVideoFavourite,
        bool isVideoDownloable,
        int userId) =>
    Get.bottomSheet(
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          IconlyLight.plus,
                          color: ColorManager.colorAccent,
                          size: 25,
                        ),
                      ),
                      const Text(
                        "Duet",
                        style: TextStyle(
                            color: ColorManager.colorAccent,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      Obx(
                        () => IconButton(
                            onPressed: () async {
                              checkForLogin(() async {
                                favUnfavVideo();
                              });
                            },
                            icon: isVideoFavourite.isFalse
                                ? const Icon(
                                    Icons.bookmark_add_outlined,
                                    color: ColorManager.colorAccent,
                                  )
                                : const Icon(
                                    Icons.bookmark,
                                    color: ColorManager.colorAccent,
                                  )),
                      ),
                      Obx(() => isVideoFavourite.isFalse
                          ? const Text(
                              "Favourite",
                              style: TextStyle(
                                  color: ColorManager.colorAccent,
                                  fontWeight: FontWeight.w700),
                            )
                          : const Text(
                              "Unfavourite",
                              style: TextStyle(
                                  color: ColorManager.colorAccent,
                                  fontWeight: FontWeight.w700),
                            ))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () async {
                            successToast("link copied successfully");
                          },
                          icon: const Icon(
                            Icons.link,
                            color: ColorManager.colorAccent,
                          )),
                      const Text(
                        "Link",
                        style: TextStyle(
                            color: ColorManager.colorAccent,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () {
                            if (isVideoDownloable == true) {
                              Get.back(closeOverlays: true);
                              downloadAndProcessVideo();
                            }
                          },
                          icon: Icon(
                            Icons.download,
                            color: isVideoDownloable == true
                                ? ColorManager.colorAccent
                                : Colors.grey,
                          )),
                      Text(
                        "Download",
                        style: TextStyle(
                            color: isVideoDownloable == true
                                ? ColorManager.colorAccent
                                : Colors.grey,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Divider(
              color: Colors.black.withOpacity(0.3),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () async {
                checkForLogin(() async {
                  checkVideoReported();
                });
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.chat,
                    color: Color(0xffFF2400),
                    size: 25,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Report...",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: Color(0xffFF2400)),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () async {
                checkForLogin(() async {
                  checkUserBlocked();
                });
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.block,
                    color: ColorManager.colorAccent,
                    size: 25,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Obx(() => Text(
                        isUserBlocked.isFalse
                            ? "Block User..."
                            : "Unblock User...",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorManager.colorAccent),
                      ))
                ],
              ),
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
          ]),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        isScrollControlled: false,
        backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor);

errorToast(dynamic message) async {
  Get.showSnackbar(GetSnackBar(
    duration: const Duration(seconds: 10),
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
    icon: const Icon(
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

showLikeDialog() {
  Get.dialog(
    Align(
      alignment: Alignment.center,
      child: Lottie.asset('assets/like.json', height: 150, width: 150),
    ),
    barrierColor: Colors.transparent.withOpacity(0.0),
  );

  1.seconds.delay().then((value) => Get.back());
}

enableWakeLock() async {
  if (await Wakelock.enabled == false) {
    await Wakelock.enable();
  }
  Logger().wtf(await Wakelock.enabled);
}

disableWakeLock() async {
  if (await Wakelock.enabled) {
    await Wakelock.disable();
  }
  Logger().wtf(await Wakelock.enabled);
}

Widget imgNet(String imgPath) {
  return CachedNetworkImage(
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
          imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
          errorWidget: (context, string, dynamic) => CachedNetworkImage(
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
          imageBuilder: (context, imageProvider) => Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.fill),
                ),
              ),
          errorWidget: (context, string, dynamic) => CachedNetworkImage(
              imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
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
      contentPadding: const EdgeInsets.all(5),
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
                        padding: const EdgeInsets.only(bottom: 20),
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
                  const SizedBox(
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
                  child: const Icon(
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
    Get.bottomSheet(LoginView(isPhoneAvailable),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        isScrollControlled: false,
        backgroundColor: Theme.of(Get.context!).scaffoldBackgroundColor);

extension FormatViews on int {
  String formatViews() => NumberFormat.compact().format(this);
}

extension FormatCrypto on String {
  String formatCrypto() => isEmpty
      ? double.parse("0.0").toStringAsFixed(1).toString()
      : double.parse(this).toStringAsFixed(4).toString();
}

Widget myLabel(String txt) {
  return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          txt,
          style: const TextStyle(
              color: Color(0xff21252E),
              fontWeight: FontWeight.w900,
              fontSize: 13),
        ),
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

profileShimmer() => SizedBox(
      width: 200.0,
      height: 100.0,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: ColorManager.colorAccent.withOpacity(0.3),
        child: GridView.count(
          padding: const EdgeInsets.all(10),
          shrinkWrap: true,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          children: List.generate(
              9,
              (index) => Stack(
                    fit: StackFit.expand,
                    children: [
                      imgNet(''),
                      Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    WidgetSpan(
                                      child: Icon(
                                        Icons.play_circle,
                                        size: 18,
                                        color: ColorManager.colorAccent,
                                      ),
                                    ),
                                    TextSpan(
                                        text: "0",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                  ],
                                ),
                              )
                            ],
                          )),
                    ],
                  )),
        ),
      ),
    );

videoShimmer() => Container(
      color: Colors.black,
      width: Get.width,
      height: Get.height,
      child: Stack(children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.3),
          highlightColor: ColorManager.colorAccent.withOpacity(0.3),
          child: GestureDetector(
              onDoubleTap: () {},
              onTap: () {},
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: Get.height / 2,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 50.0,
                            spreadRadius: 50, //New
                          )
                        ],
                      ),
                    ),
                  ),
                  //AspectRatio(aspectRatio: videoPlayerController.value.aspectRatio,child: VideoPlayer(videoPlayerController),)

                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () => null,
                      child: Container(
                        height: Get.height / 2,
                        width: 150,
                        alignment: Alignment.centerRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 10, bottom: 10, right: 20),
                              child: const Icon(
                                Icons.favorite,
                                size: 25,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () async {},
                                      icon: const Icon(
                                        IconlyLight.chat,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                  const Text(
                                    '0',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  right: 10, top: 10, bottom: 10),
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () async {},
                                      icon: const Icon(
                                        Icons.share,
                                        color: Colors.white,
                                        size: 22,
                                      )),
                                  const Text(
                                    "Share",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  right: 10, top: 10, bottom: 10),
                              child: Column(
                                children: [
                                  IconButton(
                                      onPressed: () async {},
                                      icon: const Icon(
                                        IconlyBold.more_circle,
                                        color: Colors.white,
                                        size: 25,
                                      )),
                                  const Text(
                                    "More",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                alignment: Alignment.bottomLeft,
                                width: 60,
                                height: 60,
                                child: CachedNetworkImage(
                                    fit: BoxFit.fill,
                                    height: 60,
                                    width: 60,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(60),
                                            shape: BoxShape.rectangle,
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.fill),
                                          ),
                                        ),
                                    imageUrl: RestUrl.placeholderImage),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        "User",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                        width: 10,
                                      ),
                                      Visibility(
                                        child: InkWell(
                                            onTap: () async {},
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              child: const Text(
                                                "Follow",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: ColorManager
                                                          .colorAccent),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                            )),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "@User",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Flexible(
                            child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 100, bottom: 10),
                          child: ReadMoreText(
                            " Description",
                            trimLines: 2,
                            colorClickableText: ColorManager.colorAccent,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: 'More',
                            trimExpandedText: 'Less',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                            moreStyle: TextStyle(
                                fontSize: 14,
                                color: ColorManager.colorAccent,
                                fontWeight: FontWeight.w700),
                            lessStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: ColorManager.colorAccent),
                          ),
                        )),
                        Visibility(
                          child: Container(
                            height: 35,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: ListView.builder(
                                itemCount: 5,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) => InkWell(
                                      onTap: () async {},
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: ColorManager.colorAccent,
                                            border: Border.all(
                                                color: Colors.transparent),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(5))),
                                        margin: const EdgeInsets.only(
                                            right: 5, top: 5, bottom: 5),
                                        padding: const EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'sample',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ),
                                    )),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                  "assets/spinning_disc.svg",
                                  height: 30,
                                ),

                                // Lottie.network(
                                //     "https://assets2.lottiefiles.com/packages/lf20_e3odbuvw.json",
                                //     height: 50),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Flexible(
                                  child: Text(
                                "Sample Audio",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              )),
                              const SizedBox(
                                width: 40,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ]),
    );

discoverShimmer() => Container(
    height: Get.height,
    width: Get.width,
    child: Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.3),
      highlightColor: ColorManager.colorAccent.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(Get.context!).viewPadding.top,
          ),
          NotificationListener<ScrollEndNotification>(
              onNotification: (scrollNotification) {
                return true;
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                      height: 5,
                    ),
                    GlassContainer(
                      color: ColorManager.colorAccent.withOpacity(0.5),
                      blur: 5,
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: InkWell(
                            onTap: () async {
                              Get.toNamed(Routes.SEARCH);
                            },
                            child: const Icon(
                              Icons.search,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Wrap(
                      runSpacing: 10,
                      children: List.generate(
                          10,
                          (index) => Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 20, bottom: 20),
                              child: GlassContainer(
                                blur: 10,
                                shadowColor: Colors.transparent,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.4)),
                                color:
                                    ColorManager.colorAccent.withOpacity(0.5),
                                child: InkWell(
                                    onTap: () async {},
                                    child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 10,
                                            bottom: 10),
                                        margin: const EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                        ),
                                        child: const Text(
                                          '#hastag',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white),
                                        ))),
                              ))),
                    )
                  ],
                ),
              )),
          NotificationListener<ScrollEndNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.pixels ==
                  scrollNotification.metrics.maxScrollExtent) {}

              return true;
            },
            child: Expanded(
                child: MediaQuery.removePadding(
                    removeTop: true,
                    context: Get.context!,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return Visibility(
                              child: Column(
                            children: [
                              InkWell(
                                onTap: () async {},
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                  color: ColorManager
                                                      .colorAccentTransparent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: const Icon(
                                                Icons.numbers,
                                                color: ColorManager.colorAccent,
                                              )),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Hashtag",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 18),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Text(
                                                "Trending Hashtag",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'more',
                                            style: TextStyle(
                                                decoration:
                                                    TextDecoration.underline,
                                                color: ColorManager.colorAccent,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 10),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_right,
                                            color: ColorManager.colorAccent,
                                            size: 18,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                        5,
                                        (videoIndex) => Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              height: 150,
                                              width: 120,
                                              child: InkWell(
                                                onTap: () {},
                                                child: InkWell(
                                                  onTap: () {},
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      imgNet(''),
                                                      Positioned(
                                                          bottom: 10,
                                                          left: 10,
                                                          right: 10,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              RichText(
                                                                text:
                                                                    const TextSpan(
                                                                  children: [
                                                                    WidgetSpan(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .play_circle,
                                                                        size:
                                                                            18,
                                                                        color: ColorManager
                                                                            .colorAccent,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                        text:
                                                                            "1",
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            fontSize: 16)),
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )),
                                  ),
                                ),
                              )
                            ],
                          ));
                        }))),
          )
        ],
      ),
    ));

settingsShimmer() => Container(
      child: Shimmer.fromColors(
        child: InkWell(
          onTap: () => Get.toNamed(Routes.PROFILE),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Get.toNamed(Routes.PROFILE);
                },
                child: Container(
                    alignment: Alignment.center,
                    width: 60,
                    height: 60,
                    child: SizedBox(
                        height: 60,
                        width: 60,
                        child: CachedNetworkImage(
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
                            imageUrl: RestUrl.placeholderImage))),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'user',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "@user",
                    textAlign: TextAlign.start,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  )
                ],
              )),
            ],
          ),
        ),
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: ColorManager.colorAccent.withOpacity(0.3),
      ),
    );

userProfileShimmer() => Container(
      child: Shimmer.fromColors(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(Get.context!).viewPadding.top,
            ),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Card(
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 20, top: 60),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 80,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 20,
                              width: Get.width / 3,
                              color: Colors.grey,
                            ),
                            Container(
                              height: 20,
                              width: Get.width / 4,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '@User',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const Visibility(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: ReadMoreText(
                              " ",
                              trimLines: 2,
                              textAlign: TextAlign.justify,
                              colorClickableText: ColorManager.colorAccent,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'More',
                              trimExpandedText: 'Less',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                              moreStyle: TextStyle(
                                  fontSize: 14,
                                  color: ColorManager.colorAccent,
                                  fontWeight: FontWeight.w700),
                              lessStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.colorAccent),
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Column(
                              children: const [
                                Text('${0}',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700)),
                                Text(following,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300))
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Column(
                              children: const [
                                Text('${0}',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700)),
                                Text(followers,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300))
                              ],
                            ),
                          ),
                          Column(
                            children: const [
                              Text('${0}',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700)),
                              Text(likes,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300))
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: InkWell(
                            onTap: () async {},
                            child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: ColorManager.colorAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: const Text("  Edit Profile",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontSize: 18))),
                          )),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/profile_progress.svg",
                          height: 100,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                        Container(
                          height: 80,
                          width: 80,
                          child: CachedNetworkImage(
                              placeholder: (a, b) => Center(
                                    child: loader(),
                                  ),
                              fit: BoxFit.fill,
                              height: 60,
                              width: 60,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                      shape: BoxShape.rectangle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                              imageUrl: RestUrl.placeholderImage),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: ColorManager.colorAccent.withOpacity(0.3),
      ),
    );

otherUserProfileShimmer() => Shimmer.fromColors(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(Get.context!).viewPadding.top,
          ),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Card(
                margin: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 20, top: 60),
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'User',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                    Text(
                      '@User',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Visibility(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: ReadMoreText(
                              "User Bio",
                              trimLines: 2,
                              colorClickableText: ColorManager.colorAccent,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'More',
                              trimExpandedText: 'Less',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                              moreStyle: TextStyle(
                                  fontSize: 14,
                                  color: ColorManager.colorAccent,
                                  fontWeight: FontWeight.w700),
                              lessStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: ColorManager.colorAccent),
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Column(
                            children: [
                              Text('0',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700)),
                              const Text(following,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300))
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Column(
                            children: [
                              Text('0',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700)),
                              const Text(followers,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300))
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text('0',
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w700)),
                            const Text(likes,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w300))
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: ColorManager.colorAccent),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: InkWell(
                                  onTap: () {},
                                  child: Text("Follow",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                ))),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: InkWell(
                              onTap: () {},
                              child: Column(
                                children: [
                                  Icon(
                                    IconlyBroken.user_2,
                                    size: 28,
                                    color: ColorManager.dayNightIcon,
                                  )
                                ],
                              )),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: () => Get.defaultDialog(
                    title: "",
                    middleText: "",
                    backgroundColor: Colors.transparent.withOpacity(0.0),
                    contentPadding: EdgeInsets.zero,
                    content: SizedBox(
                      height: Get.height / 2,
                      child: imgProfileDialog(''),
                    )),
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/profile_progress.svg",
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                      Container(
                        height: 80,
                        width: 80,
                        child: imgProfileDetails(''),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      baseColor: Colors.grey.withOpacity(0.3),
      highlightColor: ColorManager.colorAccent.withOpacity(0.3),
    );

walletShimmer() => Container(
      child: Shimmer.fromColors(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                  gradient: ColorManager.walletGradient,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              width: Get.width,
              height: Get.height / 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(Get.context!).viewPadding.top,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, bottom: 0, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Balance(BTC)",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w400),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Icon(
                                Icons.visibility_off,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: '',
                            ),
                            obscuringCharacter: '*',
                            obscureText: true,
                            style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: TextFormField(
                            enabled: false,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: '',
                            ),
                            obscuringCharacter: '*',
                            obscureText: true,
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.white.withOpacity(0.5),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {},
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Column(
                              children: const [
                                Icon(Icons.book),
                                Text("Withdraw")
                              ],
                            ),
                          ),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                        onTap: () => Get.toNamed(Routes.SPIN_WHEEL),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Column(
                              children: const [
                                Icon(Icons.card_giftcard),
                                Text("Earn")
                              ],
                            ),
                          ),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                        onTap: () => Get.toNamed(Routes.WALLET_TRASACTIONS),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Column(
                              children: const [
                                Icon(Icons.money),
                                Text("History")
                              ],
                            ),
                          ),
                        ),
                      )),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              width: Get.width,
              height: Get.height,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Portfolio",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 25,
                        ),
                      ),
                      // InkWell(
                      //   child: const Icon(Icons.book),
                      //   onTap: () {
                      //     Get.toNamed(Routes.WALLET_TRASACTIONS);
                      //   },
                      // ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 6,
                          itemBuilder: (context, index) => Visibility(
                                  child: Container(
                                margin: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 30,
                                          width: 30,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 20,
                                                width: Get.width / 3,
                                                color: Colors.grey,
                                              ),
                                              Container(
                                                height: 20,
                                                width: Get.width / 4,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                '0',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              index == 0
                                                  ? const Text("Coming soon",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400))
                                                  : Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text("0",
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400)),
                                                        Text(
                                                          "0",
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        )
                                                      ],
                                                    )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      child: const Divider(),
                                    ),
                                  ],
                                ),
                              ))))
                ],
              ),
            ))
          ],
        ),
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: ColorManager.colorAccent.withOpacity(0.3),
      ),
    );

searchOverviewShimmer() => Container(
      child: Shimmer.fromColors(
        child: Stack(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                Visibility(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: const Text(
                      "Users",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                ),
                Visibility(
                    child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            shrinkWrap: true,
                            itemBuilder: (context, index) => InkWell(
                                  onTap: () async {},
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: CachedNetworkImage(
                                              placeholder: (a, b) => Center(
                                                    child: loader(),
                                                  ),
                                              fit: BoxFit.fill,
                                              height: 60,
                                              width: 60,
                                              imageBuilder: (context,
                                                      imageProvider) =>
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              60),
                                                      shape: BoxShape.rectangle,
                                                      image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.fill),
                                                    ),
                                                  ),
                                              imageUrl:
                                                  RestUrl.placeholderImage),
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Flexible(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'User',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  "@" + 'User',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                )),
                                                Expanded(
                                                    child: Text(
                                                  "0 Followers",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ))
                                              ],
                                            )
                                          ],
                                        )),
                                        InkWell(
                                            onTap: () => {},
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                  color:
                                                      ColorManager.colorAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: const Text(
                                                "Follow",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                )))),
                Visibility(
                  child: Container(
                    child: const Text(
                      "Videos",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                  ),
                ),
                Visibility(
                    child: Container(
                  margin: const EdgeInsets.all(5),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.8,
                    mainAxisSpacing: 10,
                    children: List.generate(
                        3,
                        (index) => InkWell(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Stack(
                                      alignment: Alignment.bottomLeft,
                                      fit: StackFit.loose,
                                      children: [
                                        imgNet(''),
                                        Container(
                                          margin: const EdgeInsets.all(10),
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                const WidgetSpan(
                                                  child: Icon(
                                                    Icons.play_circle,
                                                    size: 14,
                                                    color: ColorManager
                                                        .colorAccent,
                                                  ),
                                                ),
                                                TextSpan(
                                                    style: const TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    text: "0"),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {},
                            )),
                  ),
                )),
                Visibility(
                    child: Container(
                  child: const Text(
                    "Hashtags",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                )),
                Visibility(
                    child: Container(
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            itemBuilder: (context, index) => InkWell(
                                  onTap: () async {},
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(
                                                        73, 204, 201, 0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                child: const Icon(
                                                  Icons.numbers,
                                                  color:
                                                      ColorManager.colorAccent,
                                                )),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Hashtag",
                                              style: const TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
                                            )
                                          ],
                                        ),
                                        Text(
                                          "Hashtag",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )))),
                Visibility(
                    child: Container(
                  child: const Text(
                    "Sounds",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                )),
                Visibility(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () async {},
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        child: imgSound(""),
                                      ),
                                      Icon(
                                        IconlyBold.play,
                                        size: 25,
                                        color: ColorManager.colorAccent,
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: InkWell(
                                    child: Container(
                                      margin: const EdgeInsets.all(0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sound',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              'User',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14),
                                            ),
                                          ]),
                                    ),
                                    onTap: () async {},
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => {},
                                  icon: Icon(
                                    IconlyBold.bookmark,
                                    color: ColorManager.colorAccent,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }))
              ],
            ),
          ],
        ),
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: ColorManager.colorAccent.withOpacity(0.3),
      ),
    );

searchVideosShimmer() => Container(
    child: Shimmer.fromColors(
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          childAspectRatio: 0.8,
          mainAxisSpacing: 10,
          children: List.generate(
              12,
              (index) => InkWell(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            fit: StackFit.loose,
                            children: [
                              imgNet(''),
                              Container(
                                margin: const EdgeInsets.all(10),
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      const WidgetSpan(
                                        child: Icon(
                                          Icons.play_circle,
                                          size: 14,
                                          color: ColorManager.colorAccent,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " 0 ",
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              child: CachedNetworkImage(
                                  placeholder: (a, b) => Center(
                                        child: loader(),
                                      ),
                                  fit: BoxFit.fill,
                                  height: 60,
                                  width: 60,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          shape: BoxShape.rectangle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.fill),
                                        ),
                                      ),
                                  imageUrl: RestUrl.placeholderImage),
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                              'User',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            ))
                          ],
                        )
                      ],
                    ),
                    onTap: () {},
                  )),
        ),
        baseColor: Colors.grey.withOpacity(0.3),
        highlightColor: ColorManager.colorAccent.withOpacity(0.3)));

searchSoundShimmer() => Container(
      child: Shimmer.fromColors(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () async {},
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: imgSound(""),
                                        ),
                                        const Icon(
                                          IconlyBold.play,
                                          size: 25,
                                          color: ColorManager.colorAccent,
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      child: InkWell(
                                    child: Container(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sound',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              'User',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14),
                                            ),
                                          ]),
                                    ),
                                    onTap: () async {},
                                  )),
                                  IconButton(
                                    onPressed: () => {},
                                    icon: Icon(
                                      IconlyBold.bookmark,
                                      color: ColorManager.colorAccent,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }))
                ],
              ),
            ],
          ),
          baseColor: Colors.grey.withOpacity(0.3),
          highlightColor: ColorManager.colorAccent.withOpacity(0.3)),
    );

searchHastagShimmer() => Container(
      child: Shimmer.fromColors(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) => InkWell(
                    onTap: () async {},
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                          73, 204, 201, 0.08),
                                      borderRadius: BorderRadius.circular(50)),
                                  child: const Icon(
                                    Icons.numbers,
                                    color: ColorManager.colorAccent,
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Hashtag',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              )
                            ],
                          ),
                          Text(
                            '0',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )),
          baseColor: Colors.grey.withOpacity(0.3),
          highlightColor: ColorManager.colorAccent.withOpacity(0.3)),
    );
searchUsersShimmer() => Container(
      child: Shimmer.fromColors(
          child: ListView(
            shrinkWrap: true,
            children: List.generate(
                10,
                (index) => InkWell(
                      onTap: () async {},
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: CachedNetworkImage(
                                  placeholder: (a, b) => Center(
                                        child: loader(),
                                      ),
                                  fit: BoxFit.fill,
                                  height: 60,
                                  width: 60,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(60),
                                          shape: BoxShape.rectangle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.fill),
                                        ),
                                      ),
                                  imageUrl: RestUrl.placeholderImage),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Flexible(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "@" + "User",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      "0 Followers",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    )
                                  ],
                                )
                              ],
                            )),
                            InkWell(
                                onTap: () => {},
                                child: (Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: ColorManager.colorAccent,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: const Text(
                                    "Follow",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )))
                          ],
                        ),
                      ),
                    )),
          ),
          baseColor: Colors.grey.withOpacity(0.3),
          highlightColor: ColorManager.colorAccent.withOpacity(0.3)),
    );

soundsViewShimmer() => Container(
      child: Shimmer.fromColors(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Flexible(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              InkWell(
                                onTap: () async {},
                                child: SvgPicture.asset(
                                  "assets/spinning_disc.svg",
                                  height: 100,
                                  width: 100,
                                ),
                              )

                              // imgProfile(Get.arguments["profile"] as String),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                            child: Text(
                          "Original",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ))
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: ColorManager.colorAccent, width: 2)),
                    child: InkWell(
                        onTap: () {
                          // userController.addToFavourites(
                          //     widget.map["sound_id"], "sound", 1);
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  Icons.bookmark,
                                  size: 18,
                                  color: ColorManager.colorAccent,
                                ),
                              ),
                              TextSpan(
                                  text: "  Add to Favourites",
                                  style: TextStyle(
                                      color: ColorManager.colorAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12)),
                            ],
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            imgProfile(""),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'User',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text("@User",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: const Divider(
                      color: Color.fromRGBO(238, 238, 238, 1),
                      thickness: 2,
                    ),
                  ),
                  Expanded(
                      child: NotificationListener<ScrollEndNotification>(
                          onNotification: (scrollNotification) {
                            return true;
                          },
                          child: GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            physics: const BouncingScrollPhysics(),
                            childAspectRatio: 0.8,
                            children: List.generate(
                                9,
                                (index) => Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Stack(
                                          fit: StackFit.expand,
                                          alignment: Alignment.center,
                                          children: [
                                            imgNet(''),
                                            Container(
                                                height: Get.height,
                                                alignment: Alignment.bottomLeft,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          const WidgetSpan(
                                                            child: Icon(
                                                              Icons.play_circle,
                                                              size: 18,
                                                              color: ColorManager
                                                                  .colorAccent,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                              text: "0",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      16)),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                )),
                                            const Icon(
                                              Icons.play_circle,
                                              color: Colors.white,
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                          ))),
                  const SizedBox(
                    height: 20,
                  ),
                ]),
              ),
              Container(
                height: Get.height,
                width: Get.width,
                margin: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: Get.width,
                  height: 60,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration: BoxDecoration(
                      color: ColorManager.colorAccent,
                      borderRadius: BorderRadius.circular(50)),
                  child: InkWell(
                      onTap: () async {},
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            WidgetSpan(
                              child: Icon(
                                Icons.music_note,
                                size: 18,
                              ),
                            ),
                            TextSpan(
                                text: "  Use this sound",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16)),
                          ],
                        ),
                      )),
                ),
              )
            ],
          ),
          baseColor: Colors.grey.withOpacity(0.3),
          highlightColor: ColorManager.colorAccent.withOpacity(0.3)),
    );

hashtagsViewShimmer() => Shimmer.fromColors(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 100,
                width: 100,
                child: const Icon(
                  Icons.numbers,
                  color: ColorManager.colorAccent,
                  size: 36,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: ColorManager.colorAccentTransparent),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  (Get.arguments["hashtag_name"] as String).replaceAll("#", ""),
                  style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w700,
                      fontSize: 24),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
              margin: const EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ColorManager.colorAccent),
              ),
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () async {},
                child: Text.rich(
                  TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(
                          Icons.bookmark,
                          size: 18,
                          color: ColorManager.colorAccent,
                        ),
                      ),
                      TextSpan(
                          text: " Add to Favourites",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: ColorManager.colorAccent,
                              fontSize: 14)),
                    ],
                  ),
                ),
              )),
          SizedBox(
            width: Get.width,
            height: 50,
            child: const Divider(
              thickness: 1,
            ),
          ),
          Expanded(
              child: NotificationListener<ScrollEndNotification>(
            onNotification: (scrollNotification) {
              return true;
            },
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              childAspectRatio: 0.8,
              mainAxisSpacing: 5,
              children: List.generate(9, (videoIndex) {
                return Stack(
                  children: [
                    InkWell(
                        onTap: () {},
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: imgNet('')),
                        )),
                    Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  const WidgetSpan(
                                    child: Icon(
                                      Icons.play_circle,
                                      size: 18,
                                      color: ColorManager.colorAccent,
                                    ),
                                  ),
                                  TextSpan(
                                      text: "0",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                ],
                              ),
                            )
                          ],
                        ))
                  ],
                );
              }),
            ),
          ))
        ],
      ),
    ),
    baseColor: Colors.grey.withOpacity(0.3),
    highlightColor: ColorManager.colorAccent.withOpacity(0.3));

followFollowingShimmer() => Shimmer.fromColors(
    child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => InkWell(
              onTap: () async {},
              child: Container(
                width: Get.width,
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: Colors.grey,
                                  height: 20,
                                  width: Get.width / 3,
                                ),
                                Container(
                                  color: Colors.grey,
                                  height: 20,
                                  width: Get.width / 4,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            color: ColorManager.colorAccent,
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text(
                          "Follow",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
    baseColor: Colors.grey.withOpacity(0.3),
    highlightColor: ColorManager.colorAccent.withOpacity(0.3));

walletTransactionsShimmer() => Shimmer.fromColors(
    child: ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: 10,
      shrinkWrap: true,
      itemBuilder: (context, index) => Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(color: Colors.grey),
        child: Container(
          margin: EdgeInsets.only(left: 5),
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                width: Get.width,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: ColorManager.colorAccent.withOpacity(0.2),
                        child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.payment,
                            )),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              color: Colors.grey,
                              height: 50,
                              width: Get.width / 3,
                            )
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.grey,
                        height: 50,
                        width: Get.width / 3,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    baseColor: Colors.grey.withOpacity(0.3),
    highlightColor: ColorManager.colorAccent.withOpacity(0.3));

withdrawViewShimmer() => Shimmer.fromColors(
    child: Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                myLabel("Currency"),
                InkWell(
                  child: TextFormField(
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 14),
                    readOnly: true,
                    decoration: const InputDecoration(
                      enabled: false,
                      filled: true,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Network",
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                      child: Icon(
                        Icons.info,
                        color: ColorManager.colorAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () => Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "Select Network",
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Flexible(
                                child: Text(
                              "Ensure the network matches the withdrawal address and the deposit platform supports it, or assets may be lost.",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            )),
                            SizedBox(
                              height: 50,
                            ),
                            ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: 5,
                                itemBuilder: (context, index) => Container(
                                      child: InkWell(
                                        onTap: () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          margin: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                color: Colors.grey,
                                                height: 20,
                                              ),
                                              Container(
                                                color: Colors.grey,
                                                height: 20,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )),
                            SizedBox(
                              height: 50,
                            )
                          ],
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      isScrollControlled: true,
                      backgroundColor:
                          Theme.of(Get.context!).scaffoldBackgroundColor),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      enabled: false,
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.warning_2,
                      color: ColorManager.colorAccent,
                      size: 20,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      color: Colors.grey,
                      height: 20,
                    )),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                myLabel("Address"),
                TextFormField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: "Withdrawal Address",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                myLabel("Amount"),
                TextFormField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(),
                  onChanged: (value) {},
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      color: Colors.grey,
                      height: 20,
                    )),
                    Container(
                      color: Colors.grey,
                      height: 20,
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      color: Colors.grey,
                      height: 20,
                    )),
                    Container(
                      color: Colors.grey,
                      height: 20,
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      color: Colors.grey,
                      height: 20,
                    )),
                    Container(
                      color: Colors.grey,
                      height: 20,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade400)),
                color: Theme.of(Get.context!).scaffoldBackgroundColor),
            padding: const EdgeInsets.all(10),
            width: Get.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.grey,
                        height: 20,
                      ),
                      Container(
                        color: Colors.grey,
                        height: 20,
                      ),
                      Row(
                        children: [
                          Flexible(
                              child: Container(
                            color: Colors.grey,
                            height: 20,
                          )),
                          SizedBox(
                            width: 5,
                          ),
                          InkWell(
                            child: Icon(
                              Icons.info,
                              color: ColorManager.colorAccent,
                              size: 20,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )),
                ElevatedButton(
                    onPressed: () async {},
                    style: ElevatedButton.styleFrom(
                        primary: ColorManager.colorAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 45, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text(
                      "Withdraw",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ))
              ],
            ),
          ),
        )
      ],
    ),
    baseColor: Colors.grey.withOpacity(0.3),
    highlightColor: ColorManager.colorAccent.withOpacity(0.3));

manageAccountShimmer() => Shimmer.fromColors(
    child: Column(
      children: [
        SizedBox(
            height: 160,
            width: 160,
            child: CachedNetworkImage(
                height: 160,
                width: 160,
                imageBuilder: (context, imageProvider) => Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.contain),
                      ),
                    ),
                errorWidget: (context, string, dynamic) => CachedNetworkImage(
                    fit: BoxFit.contain,
                    imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.contain),
                          ),
                        ),
                    imageUrl: RestUrl.placeholderImage),
                imageUrl: RestUrl.profileUrl + '')),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About You",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  IconlyLight.profile,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Flexible(
                    child: Container(
                        width: Get.width,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: Icon(IconlyLight.arrow_right_square))
                          ],
                        )))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  IconlyLight.tick_square,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Username",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                    child: Container(
                        width: Get.width,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: Icon(IconlyLight.arrow_right_square))
                          ],
                        )))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  IconlyLight.info_square,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Bio",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Flexible(
                    child: Container(
                        width: Get.width,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                height: 20,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: Icon(IconlyLight.arrow_right_square))
                          ],
                        )))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  IconlyLight.calendar,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "DOB",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Expanded(
                    child: Container(
                        width: Get.width,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: Icon(IconlyLight.arrow_right_square))
                          ],
                        )))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  Icons.male,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Gender",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Flexible(
                    child: Container(
                        width: Get.width,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: Icon(IconlyLight.arrow_right_square))
                          ],
                        )))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  IconlyLight.message,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Email",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Expanded(
                    child: Container(
                        width: Get.width,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: Icon(IconlyLight.arrow_right_square))
                          ],
                        )))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Icon(
                  IconlyLight.call,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Mobile",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Expanded(
                    child: Container(
                        width: Get.width,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: Icon(IconlyLight.arrow_right_square))
                          ],
                        )))
              ],
            ),
          ],
        )
      ],
    ),
    baseColor: Colors.grey.withOpacity(0.3),
    highlightColor: ColorManager.colorAccent.withOpacity(0.3));

spinLevelsShimmer() => Shimmer.fromColors(
    child: Wrap(
      children: List.generate(
          4,
          (index) => Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/spin_background.png"),
                        fit: BoxFit.fill)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Icon(
                      index == 0
                          ? Iconsax.video_octagon
                          : index == 1
                              ? Iconsax.people
                              : index == 2
                                  ? Iconsax.share
                                  : Iconsax.activity,
                      size: 65,
                      color: Colors.white,
                    ),
                    Html(
                      data: "Levels for  Users",
                      style: {
                        "body": Style(
                            fontSize: FontSize(22),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center),
                      },
                    ),
                    Container(
                      width: 20,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    Visibility(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Complete targets to earn spins!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    Visibility(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Earned Spins: ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text("0",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            Text(" / " + "100",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700))
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                        visible: false,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Level Completed!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700),
                          ),
                        )),
                    Visibility(
                      visible: true,
                      child: Divider(
                        thickness: 1,
                      ),
                    ),
                    Visibility(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: FAProgressBar(
                                currentValue: 1,
                                size: 7,
                                maxValue: 100,
                                changeColorValue: 100,
                                changeProgressColor: Colors.white,
                                backgroundColor:
                                    ColorManager.colorAccentTransparent,
                                progressColor: Colors.white,
                                animatedDuration:
                                    const Duration(milliseconds: 300),
                                direction: Axis.horizontal,
                                verticalDirection: VerticalDirection.up,
                                formatValueFixed: 2,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ClipOval(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 30,
                                  width: 30,
                                  color: ColorManager.colorPrimaryLight,
                                  child: ClipOval(
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 24,
                                      height: 24,
                                      child: Text(
                                        '0',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ClipOval(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 30,
                                  width: 30,
                                  color: ColorManager.colorPrimaryLight,
                                  child: ClipOval(
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 24,
                                      height: 24,
                                      child: Text('0',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
    ),
    baseColor: Colors.grey.withOpacity(0.3),
    highlightColor: ColorManager.colorAccent.withOpacity(0.3));

spinWheelShimmer() => Shimmer.fromColors(
    child: Column(
      children: [
        GlassmorphicContainer(
          width: Get.width,
          height: 100,
          borderRadius: 10,
          blur: 20,
          margin: const EdgeInsets.all(10),
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff0A8381).withOpacity(0.7),
                Colors.black.withOpacity(0.7),
                Color(0xff1D5855).withOpacity(0.7),
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFffffff).withOpacity(0.0),
              Color((0xFFFFFFFF)).withOpacity(0.0),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CachedNetworkImage(imageUrl: RestUrl.assetsUrl + "gift.png"),
                const SizedBox(
                  width: 20,
                ),
                Row(
                  children: [
                    Obx(() => Text(
                          "0",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 44,
                              color: Colors.white),
                        )),
                    const Text(
                      "Available \nChances ",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() => Text(
                          "0",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white),
                        )),
                    const Text(
                      "Last Reward  ",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.white),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
          height: Get.height / 2,
          decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
        ),
        Container(
          width: Get.width,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ColorManager.colorAccent,
                    ColorManager.colorAccent
                  ])),
          child: const Text(
            "Spin the wheel!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Wrap(
          children: List.generate(
              4,
              (index) => Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/spin_background.png"),
                            fit: BoxFit.fill)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Icon(
                          index == 0
                              ? Iconsax.video_octagon
                              : index == 1
                                  ? Iconsax.people
                                  : index == 2
                                      ? Iconsax.share
                                      : Iconsax.activity,
                          size: 65,
                          color: Colors.white,
                        ),
                        Html(
                          data: "Levels for  Users",
                          style: {
                            "body": Style(
                                fontSize: FontSize(22),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                textAlign: TextAlign.center),
                          },
                        ),
                        Container(
                          width: 20,
                          height: 4,
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        Visibility(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Complete targets to earn spins!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        Visibility(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Earned Spins: ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text("0",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                Text(" / " + "100",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700))
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                            visible: false,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Level Completed!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700),
                              ),
                            )),
                        Visibility(
                          visible: true,
                          child: Divider(
                            thickness: 1,
                          ),
                        ),
                        Visibility(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: FAProgressBar(
                                    currentValue: 1,
                                    size: 7,
                                    maxValue: 100,
                                    changeColorValue: 100,
                                    changeProgressColor: Colors.white,
                                    backgroundColor:
                                        ColorManager.colorAccentTransparent,
                                    progressColor: Colors.white,
                                    animatedDuration:
                                        const Duration(milliseconds: 300),
                                    direction: Axis.horizontal,
                                    verticalDirection: VerticalDirection.up,
                                    formatValueFixed: 2,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ClipOval(
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 30,
                                      width: 30,
                                      color: ColorManager.colorPrimaryLight,
                                      child: ClipOval(
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 24,
                                          height: 24,
                                          child: Text(
                                            '0',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ClipOval(
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 30,
                                      width: 30,
                                      color: ColorManager.colorPrimaryLight,
                                      child: ClipOval(
                                        child: Container(
                                          alignment: Alignment.center,
                                          width: 24,
                                          height: 24,
                                          child: Text('0',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700)),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
        ),
      ],
    ),
    baseColor: Colors.grey.withOpacity(0.3),
    highlightColor: ColorManager.colorAccent.withOpacity(0.3));

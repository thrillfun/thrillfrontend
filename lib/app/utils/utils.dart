import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage_2/provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:thrill/app/modules/login/views/login_view.dart';
import 'package:thrill/app/routes/app_pages.dart';
import 'package:thrill/app/utils/page_manager.dart';
import 'package:thrill/app/utils/strings.dart';

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

errorToast(String message) async {
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
      message,
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

showSuccessToast(BuildContext context, String msg) async {
  Get.showSnackbar(GetSnackBar(
    duration: const Duration(seconds: 3),
    barBlur: 10,
    borderColor: Colors.green,
    borderWidth: 1.5,
    margin: const EdgeInsets.only(
      left: 10,
      right: 10,
      bottom: 10,
    ),
    borderRadius: 10,
    backgroundColor: Colors.green.shade50,
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
      color: Colors.green,
    ),
  ));
}

successToast(String msg) async {
  Get.showSnackbar(GetSnackBar(
    duration: const Duration(seconds: 3),
    barBlur: 10,
    borderColor: Colors.green,
    borderWidth: 1.5,
    margin: const EdgeInsets.only(
      left: 10,
      right: 10,
      bottom: 10,
    ),
    borderRadius: 10,
    backgroundColor: Colors.green.shade50,
    messageText: Text(
      msg,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    ),
    isDismissible: true,
    mainButton: IconButton(
      onPressed: () {
        Get.back();
      },
      icon: const Icon(
        Icons.close,
        color: Colors.black,
      ),
    ),
    icon: const Icon(
      Icons.error,
      color: Colors.green,
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

Widget imgNet(String imgPath) {
  return CachedNetworkImage(
      placeholder: (a, b) => const Center(
            child: CircularProgressIndicator(),
          ),
      fit: BoxFit.cover,
      imageBuilder: (context, imageProvider) => Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              shape: BoxShape.rectangle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
      errorWidget: (context, string, dynamic) => CachedNetworkImage(
          placeholder: (a, b) => const Center(
                child: CircularProgressIndicator(),
              ),
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  shape: BoxShape.rectangle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
          imageUrl: '${RestUrl.thambUrl}thumb-not-available.png'),
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
              placeholder: (a, b) => const Center(
                    child: CircularProgressIndicator(),
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

loadSvgCacheImage(String url) {
  return FittedBox(
    fit: BoxFit.fill,
    child: SvgPicture(
      AdvancedNetworkSvg(
        RestUrl.assetsUrl + url,
        (theme) => (bytes, colorFilter, key) {
          return svg.svgPictureDecoder(
            bytes ?? Uint8List.fromList(const []),
            false,
            colorFilter,
            key,
            theme: theme,
          );
        },
        useDiskCache: true,
      ),
    ),
  );
}

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
      child: Lottie.network(
          "https://assets10.lottiefiles.com/packages/lf20_dkz94xcg.json",
          height: 150,
          width: 150),
    );

showWinDialog(String msg) => Get.defaultDialog(
      backgroundColor: Colors.transparent,
      title: "",
      content: Stack(
        children: [
          Container(
            height: 250,
            margin: const EdgeInsets.only(top: 50),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            width: Get.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Successful",
                  style: TextStyle(
                      color: ColorManager.colorPrimaryLight,
                      fontSize: 25,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  msg,
                  style: const TextStyle(
                      color: Color(0xff1C1E24),
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
                InkWell(
                  onTap: () {
                    Get.back();
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
          ),
          SizedBox(
            width: Get.width,
            child: CachedNetworkImage(
                fit: BoxFit.contain,
                height: 150,
                width: 150,
                imageUrl: RestUrl.assetsUrl + "you_won_logo.png"),
          )
        ],
      ),
    );

convertUTC(String format) {
  var str = format;
  var newStr = str.substring(0, 10) + ' ' + str.substring(11, 23);
  DateTime dt = DateTime.parse(newStr);
  return DateFormat("dd-MM-yyyy").format(dt).toString();
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

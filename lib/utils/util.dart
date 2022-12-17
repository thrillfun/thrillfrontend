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
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_s3/simple_s3.dart';
import 'package:thrill/common/color.dart';
import 'package:thrill/controller/model/public_videosModel.dart';
import 'package:thrill/screens/auth/login_getx.dart';
import 'package:thrill/utils/page_manager.dart';
import 'package:thrill/widgets/video_item.dart';

import '../common/strings.dart';
import '../rest/rest_url.dart';

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

videoItemLayout(List<dynamic> list) {
  PublicUser? publicUser;
  List<PublicVideos> videosList1 = [];
  if (list.isNotEmpty) {
    list.forEach((element) {
      publicUser = PublicUser(
          id: element.user!.id,
          name: element.user?.name.toString(),
          username: element.user?.username,
          email: element.user?.email,
          dob: element.user?.dob,
          phone: element.user?.phone,
          avatar: element.user!.avatar,
          socialLoginType: element.user?.socialLoginType,
          socialLoginId: element.user?.socialLoginId,
          firstName: element.user?.firstName,
          lastName: element.user?.lastName,
          gender: element.user?.gender,
          isfollow: element.isfollow ?? 0,
          likes: element.likes.toString());
      videosList1.add(PublicVideos(
        id: element.id,
        video: element.video,
        description: element.description,
        sound: element.sound,
        soundName: element.soundName,
        soundCategoryName: element.soundCategoryName,
        soundOwner: element.soundOwner,
        filter: element.filter,
        likes: element.likes,
        views: element.views,
        gifImage: element.gifImage,
        speed: element.speed,
        comments: element.comments,
        isDuet: "no",
        duetFrom: "",
        isCommentable: "yes",
        videoLikeStatus: element.videoLikeStatus,
        user: publicUser,
      ));
    });

    return VideoPlayerItem(
      videosList: videosList1,
    );
  }
}

emptyListWidget() => Center(
      child: Text(
        "Oops nothing found",
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: ColorManager.dayNightText),
      ),
    );
musicPlayerBottomSheet(
        RxString profilePic, RxString soundName, RxString soundUrl) =>
    Get.bottomSheet(
        Container(
            color: ColorManager.dayNight,
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
                Text(
                  soundName.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Obx(() => InkWell(
                    onTap: () async {
                      var duration = await audioPlayer
                          .setUrl(RestUrl.soundUrl + soundUrl.toString());
                      audioTotalDuration.value = duration!;
                      audioPlayer.positionStream.listen((position) {
                        final oldState = progressNotifier.value;
                        audioDuration.value = position;
                        progressNotifier.value = ProgressBarState(
                          current: position,
                          buffered: oldState.buffered,
                          total: oldState.total,
                        );
                      });
                      audioPlayer.bufferedPositionStream.listen((position) {
                        final oldState = progressNotifier.value;
                        audioBuffered.value = position;
                        progressNotifier.value = ProgressBarState(
                          current: oldState.current,
                          buffered: position,
                          total: oldState.total,
                        );
                      });

                      audioPlayer.playerStateStream.listen((event) {
                        if (event.playing) {
                          isPlaying.value = true;
                        } else {
                          isPlaying.value = false;
                        }
                      });
                      if (!isPlaying.value) {
                        await audioPlayer.play();
                      } else {
                        await audioPlayer.pause();
                      }
                    },
                    child: isPlaying.value
                        ? const Icon(
                            Icons.pause_circle,
                            color: ColorManager.colorAccent,
                            size: 80,
                          )
                        : const Icon(
                            Icons.play_circle,
                            color: ColorManager.colorAccent,
                            size: 80,
                          ))),
                Obx(() => ProgressBar(
                    bufferedBarColor: ColorManager.colorAccent.withOpacity(0.3),
                    thumbColor: ColorManager.colorAccent,
                    baseBarColor:
                        ColorManager.colorPrimaryLight.withOpacity(0.2),
                    progressBarColor: ColorManager.colorAccent.withOpacity(0.8),
                    onSeek: seek,
                    buffered: audioBuffered.value,
                    progress: audioDuration.value,
                    total: audioTotalDuration.value))
              ],
            )),
        backgroundColor: Get.isPlatformDarkMode ? Colors.grey : Colors.white);

void seek(Duration position) {
  audioPlayer.seek(position);
}

Widget imgNet(String imgPath) {
  return Container(
    child: CachedNetworkImage(
        placeholder: (a, b) => const Center(
              child: CircularProgressIndicator(),
            ),
        fit: BoxFit.fill,
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
            fit: BoxFit.fill,
            imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    shape: BoxShape.rectangle,
                    image:
                        DecorationImage(image: imageProvider, fit: BoxFit.fill),
                  ),
                ),
            imageUrl: '${RestUrl.thambUrl}thumb-not-available.png'),
        imageUrl: imgPath),
  );
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
            Get.to(() => LoginGetxScreen());
          },
          child: const Text('Ok')));
}

showLoadingDialog() =>
    Get.defaultDialog(title: "Please Wait", content: loader());

loader() => Container(
      color: Colors.transparent.withOpacity(0.0),
      child: Lottie.network(
          "https://assets10.lottiefiles.com/packages/lf20_dkz94xcg.json"),
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
          Container(
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

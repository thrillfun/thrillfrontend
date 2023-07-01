import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:thrill/app/modules/camera/controllers/camera_controller.dart';
import 'package:thrill/app/rest/models/sounds_model.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../rest/models/sound_details_model.dart';
import '../../../rest/models/user_details_model.dart' as user;
import '../../../rest/models/videos_by_sound_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../utils/page_manager.dart';
import '../../../utils/utils.dart';

class SoundsController extends GetxController
    with StateMixin<SoundDetails>, GetTickerProviderStateMixin {
  //TODO: Implement SoundsController
  late AudioPlayer audioPlayer;
  late Duration duration;
  late PlayerController playerController;
  var fileSupport = FileSupport();
  AnimationController? animationController;

  var progressCount = "".obs;
  var isPlaying = false.obs;
  var isAudioLoading = true.obs;
  var audioDuration = const Duration().obs;
  var audioTotalDuration = const Duration().obs;
  var audioBuffered = const Duration().obs;
  var isPlayerInit = false.obs;
  String saveCacheDirectory = "/data/data/com.thrill.media/cache/";
  var isFollow = 0.obs;
  final count = 0.obs;
  var userProfile = user.User().obs;

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var selectedSoundPath = "".obs;

  var cameraController = Get.find<CameraController>();

  var currentProgress = "0".obs;
  var soundDetails = SoundDetails();
  var isProfileLoading = false.obs;
  RxList<VideosBySound> videoList = RxList();
  var isVideosLoading = false.obs;
  var title = "";
  int id = Get.arguments["sound_id"];
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  @override
  void onInit() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 5000));

    super.onInit();
  }

  @override
  void dispose() {
    if (animationController != null) {
      animationController?.dispose();
    }
    audioPlayer.dispose();
    playerController.dispose();
    super.dispose();
  }

  @override
  void onReady() {
    getSoundDetails();
    super.onReady();
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  getSoundDetails() async {
    change(soundDetails, status: RxStatus.loading());
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };

    await dio.post("sound/get",
        queryParameters: {"id": Get.arguments["sound_id"]}).then((value) async {
      soundDetails = SoundDetailsModel.fromJson(value.data).data!;
      await getVideosBySound(soundDetails.sound!);

      await setupAudioPlayer(soundDetails.sound!);

      change(soundDetails, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(soundDetails, status: RxStatus.error(error.toString()));
    });
  }

  Future<void> getVideosBySound(String soundName) async {
    isVideosLoading.value = true;
    dio.post("sound/videosbysound", queryParameters: {"sound": soundName}).then(
        (value) {
      videoList = VideosBySoundModel.fromJson(value.data).data!.obs;
      isVideosLoading.value = false;
    }).onError((error, stackTrace) {
      Logger().wtf(error);
      isVideosLoading.value = false;
    });
    isVideosLoading.value = false;
  }

  setupAudioPlayer(String soundurl) async {
    playerController = PlayerController();

    audioPlayer = AudioPlayer();

    duration = (await audioPlayer.setUrl(RestUrl.soundUrl + soundurl))!;
    await FileSupport()
        .downloadCustomLocation(
      url: RestUrl.awsSoundUrl + soundurl,
      path: saveCacheDirectory,
      filename: basenameWithoutExtension(soundurl),
      extension: ".mp3",
      progress: (progress) async {},
    )
        .then((value) async {
      await playerController.preparePlayer(value!.path).then((value) {
        isPlayerInit.value = true;
      });
    });
    audioTotalDuration.value = duration;
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

    playerController.onCurrentDurationChanged.listen((duration) async {
      audioDuration.value = Duration(seconds: duration);
      Duration playerDuration = Duration(seconds: duration);
      if (playerDuration == audioTotalDuration.value) {
        audioPlayer.playerStateStream.drain();
        await playerController.seekTo(0);
        // isPlaying.value = false;
      }
    });
  }

  Future<void> addSoundToFavourite(int id, String action) async {
    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";
    dio.post(
      "favorite/add-to-favorite",
      queryParameters: {"id": id, "type": "sound", "action": action},
    ).then((value) {
      if (value.data["status"]) {
        getSoundDetails();
        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }

  downloadAudio(RxString soundUrl, RxString userName, RxString soundName,
      bool isFavourites) async {
    try {
      var file = File(saveCacheDirectory + soundUrl.value);
      Get.defaultDialog(
          title: "Downloading audio",
          content: Obx(() => Text(currentProgress.value)));
      await fileSupport
          .downloadCustomLocation(
        url: "${RestUrl.awsSoundUrl}$soundUrl",
        path: saveCacheDirectory,
        filename: basenameWithoutExtension(soundUrl.value),
        extension: ".mp3",
        progress: (progress) async {
          currentProgress.value = progress;
        },
      )
          .then((value) {
        // GetStorage().write("sound_path", value!.path);
        // GetStorage().write("sound_name", soundName);
        // GetStorage().write("sound_owner", userName);
        cameraController.userUploadedSound.value = file.uri.toString();
        cameraController.soundName = soundName;
        cameraController.soundOwner = userName;

        everAll([soundName, userName], (callback) {
          cameraController.userUploadedSound.value = file.uri.toString();
          cameraController.soundName = soundName;
          cameraController.soundOwner = userName;
        }, condition: value!.path.isNotEmpty);

        Get.toNamed(Routes.CAMERA);
      }).onError((error, stackTrace) {
        Logger().wtf(error);
      });
      // if (await file.exists()) {
      //   Get.toNamed(Routes.CAMERA, arguments: {
      //     "sound_url": file.uri.obs,
      //     "sound_name": soundName.obs,
      //     "sound_owner": userName.obs
      //   });
      // } else {

      // }
    } on Exception catch (e) {
      Logger().wtf(e);
    }
  }
}
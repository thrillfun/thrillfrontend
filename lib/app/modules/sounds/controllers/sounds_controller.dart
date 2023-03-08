import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_support/file_support.dart';

import '../../../rest/models/videos_by_sound_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../utils/page_manager.dart';
import '../../../utils/utils.dart';

class SoundsController extends GetxController
    with StateMixin<RxList<VideosBySound>> {
  //TODO: Implement SoundsController
  late AudioPlayer audioPlayer;
  late Duration duration;
  late PlayerController playerController;
  var fileSupport = FileSupport();

  var progressCount = "".obs;
  var isPlaying = false.obs;
  var isAudioLoading = true.obs;
  var audioDuration = const Duration().obs;
  var audioTotalDuration = const Duration().obs;
  var audioBuffered = const Duration().obs;
  var isPlayerInit = false.obs;
  String saveCacheDirectory =
      "/data/data/com.thrill.media/cache/";
  var isFollow = 0.obs;
  final count = 0.obs;

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var selectedSoundPath = "".obs;

  var currentProgress = "0".obs;

  RxList<VideosBySound> videoList = RxList();
  var title = "";
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  @override
  void onInit() {
    getVideosBySound();
    playerController = PlayerController();
    setupAudioPlayer();
    super.onInit();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    playerController.dispose();
    super.dispose();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  setupAudioPlayer() async {
    audioPlayer = AudioPlayer();
    duration = (await audioPlayer
        .setUrl(RestUrl.soundUrl + GetStorage().read("sound_url")))!;

    audioTotalDuration.value = duration;

    var soundName = GetStorage().read("sound_name");
    var directory = await getTemporaryDirectory();
    await FileSupport()
        .downloadCustomLocation(
      url: "${RestUrl.awsSoundUrl}$soundName",
      path: directory.path,
      filename: soundName.split('.').first,
      extension: ".${soundName.split('.').last}",
      progress: (progress) async {},
    )
        .then((value) async {
      await playerController.preparePlayer(value!.path).then((value) {
        isPlayerInit.value = true;
      });
    });

    audioTotalDuration.value = Duration(seconds: playerController.maxDuration);
    playerController.onCurrentDurationChanged.listen((duration) async {
      Duration playerDuration = Duration(seconds: duration);
      if (playerDuration == audioTotalDuration.value) {
        await playerController.seekTo(0);
        isPlaying.value = false;
      }
    });
  }

  Future<void> getVideosBySound() async {
    change(videoList,status: RxStatus.loading());
    dio.post("sound/videosbysound", queryParameters: {
      "sound": "${await GetStorage().read("sound_name")}"
    }).then((value) {
      videoList = VideosBySoundModel.fromJson(value.data).data!.obs;
      change(videoList,status: RxStatus.success());

    }).onError((error, stackTrace) {
      change(videoList,status: RxStatus.error(error.toString()));

    });
  }
  downloadAudio(String soundUrl, String userName, String soundName,
      bool isFavourites) async {
    try {
      Get.defaultDialog(
          title: "Downloading audio",
          content: Obx(() => Text(currentProgress.value)));
      await fileSupport
          .downloadCustomLocation(
        url: "${RestUrl.awsSoundUrl}$soundUrl",
        path: saveCacheDirectory,
        filename: soundName,
        extension: ".mp3",
        progress: (progress) async {
          currentProgress.value = progress;
        },
      )
          .then((value) {
        Get.back();
        if (!isFavourites) {
          // Get.to(CameraScreen(
          //   selectedSound: value!.path,
          //   owner: userName,
          //   id: id,
          //   soundName: soundName,
          // ));
        } else {
          selectedSoundPath.value = value!.path;
          Get.back();
        }
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
    } on Exception catch (e) {
      errorToast(e.toString());
    }
  }
}

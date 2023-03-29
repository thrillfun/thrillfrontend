import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:thrill/app/routes/app_pages.dart';

import '../../../rest/models/user_details_model.dart' as user;
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
  String saveCacheDirectory = "/data/data/com.thrill.media/cache/";
  var isFollow = 0.obs;
  final count = 0.obs;
  var userProfile = user.User().obs;

  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));
  var selectedSoundPath = "".obs;

  var currentProgress = "0".obs;

  var isProfileLoading = false.obs;
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
    getUserProfile().then((value) {
      getVideosBySound();
      setupAudioPlayer();
    });

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

  Future<void> getUserProfile() async {
    dio.options.headers = {
      "Authorization": "Bearer ${await GetStorage().read("token")}"
    };
    if (await GetStorage().read("token") == null ||
        await GetStorage().read("userId") == null) {
      Get.toNamed(Routes.LOGIN);
    } else {
      isProfileLoading.value = true;
      dio.post('/user/get-profile', queryParameters: {
        "id": "${GetStorage().read("profileId")}"
      }).then((result) {
        userProfile =
            user.UserDetailsModel.fromJson(result.data).data!.user!.obs;
        isProfileLoading.value = false;
      }).onError((error, stackTrace) {
        errorToast(error.toString());
        isProfileLoading.value = false;
      });
    }
  }

  setupAudioPlayer() async {
    playerController = PlayerController();

    audioPlayer = AudioPlayer();

    duration = (await audioPlayer
        .setUrl(RestUrl.soundUrl + Get.arguments["sound_name"]))!;
    await FileSupport()
        .downloadCustomLocation(
      url: RestUrl.awsSoundUrl + Get.arguments["sound_name"],
      path: saveCacheDirectory,
      filename: Get.arguments["sound_name"],
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

  Future<void> addSoundToFavourite() async {
    dio.options.headers["Authorization"] =
        "Bearer ${await GetStorage().read("token")}";
    dio.post(
      "favorite/add-to-favorite",
      queryParameters: {
        "id": "${await GetStorage().read("soundId")}",
        "type": "sound",
        "action": "1"
      },
    ).then((value) {
      if (value.data["status"]) {
        successToast(value.data["message"]);
      } else {
        errorToast(value.data["message"]);
      }
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });
  }

  Future<void> getVideosBySound() async {
    change(videoList, status: RxStatus.loading());
    dio.post("sound/videosbysound", queryParameters: {
      "sound": "${Get.arguments["sound_name"]}"
    }).then((value) {
      videoList = VideosBySoundModel.fromJson(value.data).data!.obs;
      change(videoList, status: RxStatus.success());
    }).onError((error, stackTrace) {
      change(videoList, status: RxStatus.error(error.toString()));
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
        // GetStorage().write("sound_path", value!.path);
        // GetStorage().write("sound_name", soundName);
        // GetStorage().write("sound_owner", userName);

        Get.toNamed(Routes.CAMERA, arguments: {
          "sound_url": value!.path,
          "sound_name": soundName,
          "sound_owner": userName
        });
      }).onError((error, stackTrace) {
        errorToast(error.toString());
      });
    } on Exception catch (e) {
      errorToast(e.toString());
    }
  }
}

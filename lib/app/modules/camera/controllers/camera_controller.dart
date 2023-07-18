import 'dart:io';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uri_to_file/uri_to_file.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../rest/models/sounds_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/page_manager.dart';
import '../../../utils/strings.dart';
import '../../../utils/utils.dart';

class CameraController extends GetxController with GetTickerProviderStateMixin {
  var fileSupport = FileSupport();

  var isSoundsLoading = false.obs;
  RxList<Sounds> soundsList = RxList();
  RxList<SongModel> localSoundsList = RxList();
  RxList<SongModel> localFilterList = RxList();
  List<imgly.AudioClip> audioClips = [];
  List<imgly.AudioClip> selectedAudioClips = [];
  List<imgly.AudioClipCategory> audioClipCategories = [];
  final OnAudioQuery audioQuery = OnAudioQuery();
  var selectedSoundPath = "".obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));

  late AudioPlayer audioPlayer;
  late Duration duration;
  late PlayerController playerController;
  var progressCount = "".obs;
  var timer = 60.obs;
  AnimationController? animationController;

  var isPlaying = false.obs;
  var isAudioLoading = true.obs;
  var audioDuration = const Duration().obs;
  var audioTotalDuration = const Duration().obs;
  var audioBuffered = const Duration().obs;
  var isPlayerInit = false.obs;
  List<FileSystemEntity> entities = [];
  var uint8list = RxList<Uint8List>();
  var videosList = RxList<String>();
  RxString selectedSound = "".obs;
  var userUploadedSound = "".obs;
  var soundName = "".obs;
  var soundOwner = "".obs;
  var thumbnail = "".obs;
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  @override
  void onInit() {
    initAnimationController();
    super.onInit();
  }

  Future<void> initAnimationController() async {
    animationController = AnimationController(
        vsync: this, duration: Duration(seconds: timer.value));
    ever(timer, (callback) {
      animationController?.reverse();
      animationController = AnimationController(
          vsync: this, duration: Duration(seconds: timer.value));
    });
  }

  @override
  void onReady() {
    getSoundsList();
    getAlbums();
    super.onReady();
  }

  @override
  void dispose() {
    if (animationController != null) {
      animationController?.dispose();
    }
    if (audioPlayer != null) {
      audioPlayer.dispose();
    }
    playerController.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    super.onClose();
  }

  deleteFilesandReturn() async {
    var tempDirectory = await getTemporaryDirectory();
    final dir = Directory(tempDirectory.path + "/videos");
    if (!await Directory(dir.path).exists()) {
      await Directory(dir.path).create();
    }
    final List<FileSystemEntity> entities = await dir.list().toList();
    if (entities.isNotEmpty) {
      Get.defaultDialog(
        title: "Are you sure?",
        middleText: "Are you sure you want to discard changes",
        cancel: ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: Text("Cancel")),
        confirm: ElevatedButton(
            onPressed: () async {
              uint8list.clear();
              dir.deleteSync(recursive: true);
              Get.offAllNamed(Routes.HOME);
            },
            child: Text("Ok")),
      );
    }
  }

  getVideoDirectory() async {}

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  Future<void> getAlbums() async {
    localSoundsList.clear();
    List<SongModel> filterList = await audioQuery.querySongs();
    localSoundsList = filterList
        .where((element) => element.fileExtension.contains("mp3"))
        .toList()
        .obs;
    if (filterList.isNotEmpty) {
      localFilterList.value = localSoundsList.toList();
    } else {
      localFilterList = localSoundsList;
    }
  }

  setupAudioPlayer(String soundPath) async {
    playerController = PlayerController();

    audioPlayer = AudioPlayer();
    duration = (await audioPlayer.setUrl(soundPath))!;

    await playerController.preparePlayer(soundPath).then((value) {
      isPlayerInit.value = true;
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

  Future<void> openEditor(bool isGallery, String path, String selectedSound,
      int id, String owner, bool isLocalSound) async {
    var file = File(selectedSound);

    List<SongModel> albums = [];
    if (await Permission.audio.isGranted == false) {
      await Permission.audio.request().then((value) async {
        List<SongModel> filterList = await OnAudioQuery().querySongs();
        albums = filterList
            .where((element) => element.fileExtension.contains("mp3"))
            .toList()
            .obs;
      });
    }
    try {} catch (e) {
      Logger().wtf(e);
    } finally {
      if (!isGallery) {
        var tempDirectory = await getTemporaryDirectory();
        final dir = Directory(tempDirectory.path + "/videos");
        if (!await Directory(dir.path).exists()) {
          await Directory(dir.path).create();
        }
        final List<FileSystemEntity> entities = await dir.list().toList();

        List<String> videosList = <String>[];

        entities.forEach((element) {
          videosList.add(element.path);
        });

        await VESDK
            .openEditor(Video.composition(videos: videosList),
                configuration: await setConfig(albums, owner))
            .then((value) async {
          Map<dynamic, dynamic> serializationData = await value?.serialization;
          var recentSelection = true.obs;
          var songPath = '';
          var songName = '';
          for (int i = 0;
              i < serializationData["operations"].toList().length;
              i++) {
            if (serializationData["operations"][i]["type"] == "audio") {
              recentSelection.value = false;
            }
            for (var element in albums) {
              print(element);
              if (serializationData["operations"][i]["options"]["clips"] !=
                  null) {
                for (int j = 0;
                    j <
                        serializationData["operations"][i]["options"]["clips"]
                            .toList()
                            .length;
                    j++) {
                  List<dynamic> clipsList = serializationData["operations"][i]
                          ["options"]["clips"]
                      .toList();
                  if (clipsList.isNotEmpty) {
                    if (element.title.contains(serializationData["operations"]
                            [i]["options"]["clips"][j]["options"]["identifier"]
                        .toString())) {
                      selectedSound = element.uri.toString();
                      songPath = element.uri.toString();
                      songName = element.displayName;
                    }
                  }
                }
              }
            }
            print(serializationData["operations"][i]["type"]);
          }

          if (value == null) {
            dir.exists().then((value) => dir.delete(recursive: true));
          }

          // await dir.delete(recursive: true);
          file = File(selectedSound);
          if (recentSelection.isFalse) {
            if (value != null) {
              if (await file.exists()) {
                Get.toNamed(Routes.POST_SCREEN, arguments: {
                  "sound_url": basename(selectedSound.toString()),
                  "file_path": value.video,
                  "is_original":
                      selectedSound.isNotEmpty && !isLocalSound ? false : true,
                  "sound_name":
                      selectedSound.isNotEmpty ? "sound by $owner" : "",
                  "sound_owner": owner.isEmpty
                      ? GetStorage().read("userId").toString()
                      : owner,
                });
              } else {
                Get.toNamed(Routes.POST_SCREEN, arguments: {
                  "sound_url": selectedSound.isNotEmpty && !isLocalSound
                      ? basename(selectedSound.toString())
                      : selectedSound,
                  "file_path": value.video.substring(7, value.video.length),
                  "is_original":
                      selectedSound.isNotEmpty && !isLocalSound ? false : true,
                  "sound_name":
                      selectedSound.isNotEmpty ? "sound by $owner" : "",
                  "sound_owner": owner.isEmpty
                      ? GetStorage().read("userId").toString()
                      : owner,
                });
              }
            }
          } else {
            if (file.existsSync()) {
              await FFmpegKit.execute(
                      '-y -i ${value!.video.substring(7, value.video.length)} -i $selectedSound -map 0:v -map 1:a  -shortest ${saveCacheDirectory}selectedVideo.mp4')
                  .then((ffmpegValue) async {
                final returnCode = await ffmpegValue.getReturnCode();
                var data = await ffmpegValue.getOutput();
                if (ReturnCode.isSuccess(returnCode)) {
                  Get.toNamed(Routes.POST_SCREEN, arguments: {
                    "sound_url": selectedSound,
                    "file_path": "${saveCacheDirectory}selectedVideo.mp4",
                    "is_original": selectedSound.isNotEmpty && !isLocalSound
                        ? false
                        : true,
                    "sound_name":
                        selectedSound.isNotEmpty ? "sound by $owner" : "",
                    "sound_owner": owner.isEmpty
                        ? GetStorage().read("userId").toString()
                        : owner,
                  });
                } else {
                  Logger().wtf(data);
                }
              });
            } else {
              await FFmpegKit.execute(
                      "-y -i ${value!.video} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
                  .then((audio) async {
                Get.toNamed(Routes.POST_SCREEN, arguments: {
                  "sound_url": "${saveCacheDirectory}originalAudio.mp3",
                  "file_path": value.video.substring(7, value.video.length),
                  "is_original":
                      selectedSound.isNotEmpty && !isLocalSound ? false : true,
                  "sound_name":
                      selectedSound.isNotEmpty ? "sound by $owner" : "",
                  "sound_owner": owner.isEmpty
                      ? GetStorage().read("userId").toString()
                      : owner,
                });
              });
            }
          }
        });
      } else {
        await VESDK
            .openEditor(Video(path),
                configuration: await setConfig(albums, owner))
            .then((value) async {
          Map<dynamic, dynamic> serializationData = await value?.serialization;

          print("data=>" + serializationData.toString());

          List<dynamic> operationData =
              serializationData['operations'].toList();

          var isOriginal = true.obs;
          var songPath = '';
          var songName = '';
          var file = await toFile(selectedSound);

          operationData.forEach((operation) async {
            Map<dynamic, dynamic> data = operation['options'];
            if (data.containsKey("clips")) {
              isOriginal.value = false;
              songPath = file.path;
              songName = basename(file.path);
            }
          });
          if (!isOriginal.value) {
            if (value != null) {
              Get.toNamed(Routes.POST_SCREEN, arguments: {
                "file_path": value.video.substring(7, value.video.length),
                "sound_url": file.existsSync() ? songPath : selectedSound,
                "is_original": false,
                "sound_owner": owner,
              });
            }
          } else if (selectedSound.isNotEmpty) {
            await FFmpegKit.execute(
                    '-y -i ${value!.video} -i $selectedSound -map 0:v -map 1:a  -shortest $saveCacheDirectory/selectedVideo.mp4')
                .then((ffmpegValue) async {
              final returnCode = await ffmpegValue.getReturnCode();
              var data = await ffmpegValue.getOutput();
              if (ReturnCode.isSuccess(returnCode)) {
                Get.toNamed(Routes.POST_SCREEN, arguments: {
                  "sound_url": selectedSound,
                  "file_path": "$saveCacheDirectory/selectedVideo.mp4",
                  "is_original":
                      selectedSound.isNotEmpty && !isLocalSound ? false : true,
                  "sound_name":
                      selectedSound.isNotEmpty ? "sound by $owner" : "",
                  "sound_owner": owner,
                });
              } else {
                Logger().wtf(data);
              }
            });
          } else {
            await FFmpegKit.execute(
                    "-y -i ${value!.video} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
                .then((audio) async {
              Get.toNamed(Routes.POST_SCREEN, arguments: {
                "sound_url": "${saveCacheDirectory}originalAudio.mp3",
                "file_path": value.video.substring(7, value.video.length),
                "is_original": true,
                "sound_owner": owner,
              });
            });
          }
        });
      }
    }
  }

  Future<imgly.Configuration> setConfig(
      List<SongModel> albums, String? userName,
      {double maxDuration = 60}) async {
    var audioFile = File(
        selectedSound.isEmpty ? userUploadedSound.value : selectedSound.value);
    selectedAudioClips.clear();
    audioClips.clear();
    soundsList.clear();
    audioClipCategories.clear();
    selectedAudioClips.add(imgly.AudioClip(userName.toString(), audioFile.path,
        title: userName,
        thumbnailURI: "https://sunrust.org/wiki/images/a/a9/Gallery_icon.png"));

    if (albums.isNotEmpty) {
      albums.forEach((element) {
        audioClips.add(imgly.AudioClip(
          element.title,
          element.uri.toString(),
          title: element.title,
          artist: element.artist,
        ));
      });
    }

    if (soundsList.isNotEmpty) {
      List<imgly.AudioClip> onlineAudioClips = [];
      soundsList.forEach((element) {
        onlineAudioClips.add(imgly.AudioClip(element.name.toString(),
            RestUrl.soundUrl + element.sound.toString(),
            title: element.name));
      });
    }

    if (selectedSound.isNotEmpty || userUploadedSound.isNotEmpty) {
      audioClipCategories.add(imgly.AudioClipCategory("", "selected sound",
          thumbnailURI: "assets/logo2.png", items: selectedAudioClips));
    }
    audioClipCategories.add(
      imgly.AudioClipCategory("audio_cat_1", "local",
          thumbnailURI: "assets/logo2.png", items: audioClips),
    );

    var audioOptions = imgly.AudioOptions(categories: audioClipCategories);

    var codec = imgly.VideoCodec.values;

    var exportOptions = imgly.ExportOptions(
      serialization: imgly.SerializationOptions(
          enabled: true, exportType: imgly.SerializationExportType.object),
      video: imgly.VideoOptions(quality: 1.0, codec: codec[0]),
    );

    // imgly.WatermarkOptions waterMarkOptions = imgly.WatermarkOptions(
    //     RestUrl.assetsUrl + "transparent_logo.png",
    //     alignment: imgly.AlignmentMode.topLeft);

    var stickerList = [
      imgly.StickerCategory.giphy(
          imgly.GiphyStickerProvider("Q1ltQCCxdfmLcaL6SpUhEo5OW6cBP6p0"))
    ];

    var trimOptions = imgly.TrimOptions(
      minimumDuration: 5,
      maximumDuration: maxDuration,
    );

    final configuration = imgly.Configuration(
      tools: [
        imgly.Tool.audio,
        imgly.Tool.composition,
        imgly.Tool.sticker,
        imgly.Tool.text,
        imgly.Tool.textDesign,
        imgly.Tool.transform,
        imgly.Tool.trim,
      ],
      theme: imgly.ThemeOptions(imgly.Theme(
        "default_editor_theme",
      )),
      trim: trimOptions,
      sticker:
          imgly.StickerOptions(personalStickers: true, categories: stickerList),
      audio: audioOptions,
      export: exportOptions,
      // watermark: waterMarkOptions,
    );

    return configuration;
  }

  Future<void> getVideoClips() async {
    videosList.clear();
    var tempDirectory = await getTemporaryDirectory();
    final dir = Directory(tempDirectory.path + "/videos");
    if (!await Directory(dir.path).exists()) {
      await Directory(dir.path).create();
    }
    entities = await dir.list().toList();
    for (var element in entities) {
      videosList.add(element.path);
    }

    if (videosList.isNotEmpty) {
      await generateThumbnail(videosList.last);
    }
  }

  Future<void> generateThumbnail(String videoUrl) async {
    try {
      var thumbnailFile = await VideoCompress.getFileThumbnail(videoUrl,
          quality: 15, // default(100)
          position: 1 // default(-1)
          );
      thumbnail.value = thumbnailFile.path;
    } catch (e) {}
  }

  getThumbnail() async {
    if (entities.isNotEmpty) {}
  }

  Future<void> getSoundsList() async {
    dio.options.headers["Authorization"] =
        "Bearer ${GetStorage().read("token")}";

    dio.post("/sound/list").then((value) {
      soundsList = SoundsModel.fromJson(value.data).data!.obs;
    }).onError((error, stackTrace) {
      Logger().wtf(error);
    });
  }
}

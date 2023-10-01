import 'dart:io';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:file_support/file_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
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
import '../select_sound/controllers/select_sound_controller.dart';

class CameraController extends GetxController with GetTickerProviderStateMixin {
  var fileSupport = FileSupport();
  late  imgly.Configuration configuration;
  late imgly.AudioOptions audioOptions;
  var isSoundsLoading = false.obs;
  RxList<Sounds> soundsList = RxList();
  RxList<SongModel> localSoundsList = RxList();
  RxList<SongModel> localFilterList = RxList();
  List<imgly.AudioClip> audioClips = [];
  List<imgly.AudioClip> selectedAudioClips = [];
  List<imgly.AudioClipCategory> audioClipCategories = [];
  List<imgly.AudioClip> onlineAudioClips = [];

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
  var soundAuthorName = ''.obs;
  var thumbnail = "".obs;
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  var selectSoundController = Get.find<SelectSoundController>();

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
              await dir.delete(recursive: true);
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
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt > 31) {
      if (await Permission.audio.isGranted) {
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
        // refreshAlreadyCapturedImages();
      } else if (await Permission.audio.isDenied ||
          await Permission.audio.isPermanentlyDenied) {
        await openAppSettings().then((value) async {
          if (value) {
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
          } else {
            errorToast('Audio Permission not granted!');
          }
        });
      } else {
        await Permission.audio.request().then((value) async {
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
        });
      }
    } else {
      if (await Permission.storage.isGranted) {
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
      } else if (await Permission.storage.isPermanentlyDenied ||
          await Permission.storage.isDenied) {
        await openAppSettings().then((value) async {
          if (value) {
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
          } else {
            errorToast('Audio Permission not granted!');
          }
        });
      } else {
        await Permission.storage.request().then((value) async {
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
        });
      }


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



  Future<imgly.Configuration> setConfig(
      List<SongModel> albums, String? userName,
      {double maxDuration = 60,imgly.Tool? tool}) async {
    var audioFile = File(
        selectedSound.isEmpty ? userUploadedSound.value : selectedSound.value);
    selectedAudioClips.clear();
    audioClips.clear();
    soundsList.clear();
    audioClipCategories.clear();
    selectedAudioClips.add(imgly.AudioClip(userName.toString(), audioFile.path,
        artist: soundAuthorName.value,
        title: userName,
        thumbnailURI: "https://sunrust.org/wiki/images/a/a9/Gallery_icon.png"));

    if (albums.isNotEmpty) {
      albums.forEach((element) {
        audioClips.add(imgly.AudioClip(
          element.title,
          element.uri.toString(),

        ));
      });

    }
    audioClipCategories.add(
      imgly.AudioClipCategory("audio_cat_1", "local",
          thumbnailURI: "assets/logo2.png", items: audioClips),
    );


    if (selectedSound.isNotEmpty || userUploadedSound.isNotEmpty) {
      audioClipCategories.add(imgly.AudioClipCategory("", "selected sound",
          thumbnailURI: "assets/logo2.png", items: selectedAudioClips));
    }

    audioOptions = imgly.AudioOptions(categories: audioClipCategories);


    var exportOptions = imgly.ExportOptions(
      serialization: imgly.SerializationOptions(
          enabled: true, exportType: imgly.SerializationExportType.object),
    );

    var stickerList = [
      imgly.StickerCategory.existing("imgly_sticker_category_emoticons"),
      imgly.StickerCategory.existing("imgly_sticker_category_shapes"),
      imgly.StickerCategory.existing("imgly_sticker_category_animated"),
      imgly.StickerCategory.giphy(
          imgly.GiphyStickerProvider("Q1ltQCCxdfmLcaL6SpUhEo5OW6cBP6p0"))
    ];

    var trimOptions = imgly.TrimOptions(
      minimumDuration: 5,
      maximumDuration: maxDuration,
    );
    final categories = <imgly.FilterCategory>[
      imgly.FilterCategory('Custom', 'Custom',
          thumbnailUri:
              'https://upload.wikimedia.org/wikipedia/commons/5/5e/Neutral_density_filter_demonstration.jpg',
          items: [
            imgly.Filter.existing("imgly_lut_ad1920"),
            imgly.Filter.existing("imgly_lut_bw"),
            imgly.Filter.existing("imgly_lut_x400"),
            imgly.Filter.existing("imgly_lut_litho"),
            imgly.Filter.existing("imgly_lut_sepiahigh"),
            imgly.Filter.existing("imgly_lut_plate"),
            imgly.Filter.existing("imgly_lut_sin"),
            imgly.Filter.existing("imgly_lut_blues"),
            imgly.Filter.existing("imgly_lut_front"),
            imgly.Filter.existing("imgly_lut_texas"),
            imgly.Filter.existing("imgly_lut_celsius"),
            imgly.Filter.existing("imgly_lut_cool"),
            imgly.Filter.existing("imgly_lut_chest"),
            imgly.Filter.existing("imgly_lut_winter"),
            imgly.Filter.existing("imgly_lut_kdynamic"),
            imgly.Filter.existing("imgly_lut_fall"),
            imgly.Filter.existing("imgly_lut_lenin"),
            imgly.Filter.existing("imgly_lut_pola669"),
            imgly.Filter.existing("imgly_lut_elder"),
            imgly.Filter.existing("imgly_lut_orchid"),
            imgly.Filter.existing("imgly_lut_bleached"),
            imgly.Filter.existing("imgly_lut_bleachedblue"),
            imgly.Filter.existing("imgly_lut_breeze"),
            imgly.Filter.existing("imgly_lut_blueshadows"),
            imgly.Filter.existing("imgly_lut_sunset"),
            imgly.Filter.existing("imgly_lut_eighties"),
            imgly.Filter.existing("imgly_lut_evening"),
            imgly.Filter.existing("imgly_lut_k2"),
            imgly.Filter.existing("imgly_lut_nogreen"),
            imgly.Filter.existing("imgly_lut_ancient"),
            imgly.Filter.existing("imgly_lut_cottoncandy"),
            imgly.Filter.existing("imgly_lut_classic"),
            imgly.Filter.existing("imgly_lut_colorful"),
            imgly.Filter.existing("imgly_lut_creamy"),
            imgly.Filter.existing("imgly_lut_fixie"),
            imgly.Filter.existing("imgly_lut_food"),
            imgly.Filter.existing("imgly_lut_fridge"),
            // imgly.Filter.existing("imgly_lut_glam"),
            imgly.Filter.existing("imgly_lut_gobblin"),
            imgly.Filter.existing("imgly_lut_highcontrast"),
            imgly.Filter.existing("imgly_lut_highcarb"),
            imgly.Filter.existing("imgly_lut_k1"),
            imgly.Filter.existing("imgly_lut_k6"),
            imgly.Filter.existing("imgly_lut_keen"),
            imgly.Filter.existing("imgly_lut_lomo"),
            imgly.Filter.existing("imgly_lut_lomo100"),
            imgly.Filter.existing("imgly_lut_lucid"),
            imgly.Filter.existing("imgly_lut_mellow"),
            imgly.Filter.existing("imgly_lut_neat"),
            imgly.Filter.existing("imgly_lut_pale"),
            imgly.Filter.existing("imgly_lut_pitched"),
            imgly.Filter.existing("imgly_lut_polasx"),
            imgly.Filter.existing("imgly_lut_pro400"),
            imgly.Filter.existing("imgly_lut_quozi"),
            imgly.Filter.existing("imgly_lut_settled"),
            imgly.Filter.existing("imgly_lut_seventies"),
            imgly.Filter.existing("imgly_lut_soft"),
            imgly.Filter.existing("imgly_lut_steel"),
            imgly.Filter.existing("imgly_lut_summer"),
            imgly.Filter.existing("imgly_lut_tender"),
            imgly.Filter.existing("imgly_lut_twilight"),
            imgly.Filter.existing("imgly_duotone_desert"),
            imgly.Filter.existing("imgly_duotone_peach"),
            imgly.Filter.existing("imgly_duotone_clash"),
            imgly.Filter.existing("imgly_duotone_plum"),
            imgly.Filter.existing("imgly_duotone_breezy"),
            imgly.Filter.existing("imgly_duotone_deepblue"),
            imgly.Filter.existing("imgly_duotone_frog"),
            imgly.Filter.existing("imgly_duotone_sunset"),
          ]),
    ];
    List<imgly.Tool> toolsList=[];

    if(tool!=null){
      toolsList.add(tool);
    }
    if(audioClipCategories.isEmpty &&localSoundsList.isEmpty){
      configuration=imgly.Configuration(
        theme: imgly.ThemeOptions(imgly.Theme(
          "default_editor_theme",
        )),
        trim: trimOptions,
        tools: toolsList.isNotEmpty?toolsList:[],
        filter:
        imgly.FilterOptions(categories: categories, flattenCategories: true),
        sticker:
        imgly.StickerOptions(personalStickers: true, categories: stickerList),
        export: exportOptions,
        // watermark: waterMarkOptions,
      );
    }


    else{
      configuration=imgly.Configuration(
        theme: imgly.ThemeOptions(imgly.Theme(
          "default_editor_theme",
        )),
        trim: trimOptions,
        filter:

        imgly.FilterOptions(categories: categories, flattenCategories: true),
        tools: toolsList.isNotEmpty?toolsList:[],

        sticker:
        imgly.StickerOptions(personalStickers: true, categories: stickerList),
        audio:audioOptions,
        export: exportOptions,
        // watermark: waterMarkOptions,
      );
    }

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
    isSoundsLoading.value = true;
    dio.post("/sound/list").then((value) {
      soundsList = SoundsModel.fromJson(value.data).data!.obs;
      if (soundsList.isNotEmpty) {
        isSoundsLoading.value = false;
      }
    }).onError((error, stackTrace) {
      isSoundsLoading.value = false;

      Logger().wtf(error);
    });
  }
}

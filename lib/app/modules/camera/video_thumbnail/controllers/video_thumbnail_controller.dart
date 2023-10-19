import 'dart:io';
import 'dart:typed_data';

import 'package:easy_audio_trimmer/easy_audio_trimmer.dart' as audioTrimmer;
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thrill/app/utils/utils.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_trimmer/video_trimmer.dart' ;

import '../../../../routes/app_pages.dart';
import '../../../../utils/strings.dart';
import '../../controllers/camera_controller.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;

class VideoThumbnailController extends GetxController {
  VideoPlayerController? videoPlayerController;
  Rx<Uint8List>? u8intList;
  var currentDuration = Duration().obs;
  var totalduration = Duration().obs;
  Trimmer? trimmer;
  var selectedThumbnail = ''.obs;
  RxList<FileSystemEntity> entities = RxList();
  var currentSelectedFrame = 999.obs;
  var isThumbnailReady = false.obs;
  var cameraController = Get.find<CameraController>();
  var isLocalSound = false.obs;
  var startValue = 0.0.obs;
  var endValue = 0.0.obs;
  var videoDuration = Duration().obs;
  var isVideoPlaying = true.obs;
  late imgly.Configuration configuration;
  late VideoEditorResult editedFile;
  var isInitialised = false.obs;
  MediaInformationSession? audioMediaInfo;
  MediaInformationSession? mediaInfo;
  var isAudioTrimmerInitialised = false.obs;
  RxString videoFile = (Get.arguments['video_file'] as String).obs;

  audioTrimmer.Trimmer? soundTrimmer;

  var audioStartValue =0.0.obs;
  var audioEndValue=0.0.obs;
  @override
  void onInit() {
    super.onInit();
    getVideoDuration();

    // extractFrames(File(videoFile.value).path);
  }

  @override
  void onReady() {
    super.onReady();
  }

  setVideoPlayer(String videofile){
    if(videoPlayerController!=null){
      videoPlayerController!.dispose();
      videoPlayerController=null;
    }
    videoPlayerController = VideoPlayerController.file(File(videoFile.value))..initialize().then((value) {
      playPauseVideo();
    });
    getVideoDuration();
  }
  getVideoDuration()async {
    mediaInfo =
    await FFprobeKit.getMediaInformation(videoFile.value);

   videoDuration.value=Duration(seconds: await mediaInfo!.getDuration());

    // if (cameraController.selectedSound.value.isNotEmpty ||
    //     cameraController.userUploadedSound.value.isNotEmpty) {
    //   audioMediaInfo = await FFprobeKit.getMediaInformation(
    //       cameraController.selectedSound.value.isNotEmpty
    //           ? cameraController.userUploadedSound.value
    //           : cameraController.selectedSound.value);
    //
    //   if (await audioMediaInfo!.getDuration() <
    //       await mediaInfo!.getDuration()) {
    //     Duration totalDuration =
    //     Duration(seconds: await audioMediaInfo!.getDuration());
    //     videoDuration.value = totalDuration;
    //   } else if (await audioMediaInfo!.getDuration() >
    //       await mediaInfo!.getDuration()) {
    //     Duration totalDuration =
    //     Duration(seconds: await mediaInfo!.getDuration());
    //     videoDuration.value = totalDuration;
    //   }
    // }
  }
  Future<void> initTrimmer(String audioFile) async {
    isAudioTrimmerInitialised.value = false;
    if(soundTrimmer!=null){
      soundTrimmer?.dispose();
      soundTrimmer=null;
    }
    soundTrimmer = audioTrimmer.Trimmer();
    var file = File(audioFile);
    await soundTrimmer?.loadAudio(audioFile:file).then((value) {
      isAudioTrimmerInitialised.value=true;
    });
  }
  @override
  void onClose() {
    trimmer?.dispose();
    super.onClose();
  }

  playPauseVideo() {
    if (videoPlayerController != null &&
        videoPlayerController!.value.isInitialized) {
      videoPlayerController!.value.isPlaying
          ? videoPlayerController!.pause()
          : videoPlayerController!.play();
    }
    isVideoPlaying.value = videoPlayerController!.value.isPlaying;
  }



  Future<void> initialiseVideoTrimmer(String videoFile) async {
    isInitialised.value = false;
    trimmer = Trimmer();
    print(videoFile);
    var file = File(videoFile);
    setVideoPlayer(videoFile);

    await trimmer?.loadVideo(videoFile: file).then((value) {
      isInitialised.value = true;
    });
    getVideoDuration();

  }

  extractFrames(String videoFilePath) async {
    var directory = await checkforDirectory();

    entities.clear();
    if (directory.existsSync()) {
      FFmpegKit.execute(
              '-i $videoFilePath -r 1 -f image2 -compression_level 0 ${directory.path}image-%3d.png')
          .then((session) async {
        final returnCode = await session.getReturnCode();
        var frameFiles = await directory.list().toList();
        entities.value = await getFilesFromFolder(directory);
        selectedThumbnail.value = entities[0].path;
      }).then((value) {
        isThumbnailReady.value = true;
      });
    }
  }

  Future<Directory> checkforDirectory() async {
    var tempDirectory = await getTemporaryDirectory();
    final dir = Directory(tempDirectory.path + "/frames/");
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    await dir.create();

    return dir;
  }

  Future<VideoEditorResult> openGalleryEditor(String videoFile,
      {imgly.Tool? tool}) async {
    editedFile = (await VESDK.openEditor(Video(videoFile),
        configuration: await setConfig(
            cameraController.localSoundsList, cameraController.soundName.value,
            maxDuration: cameraController
                .animationController!.duration!.inSeconds
                .toDouble(),
            tool: tool)))!;

    if (editedFile.video.isNotEmpty) {
      var file = File(editedFile.video);
      Map<dynamic, dynamic> serializationData = await editedFile.serialization;
      var recentSelection = true.obs;
      var songPath = '';
      var songName = '';
      var isAudioAvailale = 0.obs;
      List<dynamic> operations =
          (serializationData['operations'] as List<dynamic>);
      for (var audio in operations) {
        if (audio['type'] == 'audio') {
          isAudioAvailale.value = 1;
        }
      }
      if (isAudioAvailale.value == 0) {
        cameraController.selectedSound.value = "";
        cameraController.userUploadedSound.value = "";
        cameraController.soundName.value = "";
        cameraController.soundOwner.value = "";
      }
      for (int i = 0;
          i < serializationData["operations"].toList().length;
          i++) {
        if (serializationData["operations"][i]["type"] == "audio") {
          recentSelection.value = false;
        }

        for (var element in cameraController.localSoundsList) {
          print(element);
          if (serializationData["operations"][i]["options"]["clips"] != null) {
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
                if (element.title ==
                    serializationData["operations"][i]["options"]["clips"][j]
                            ["options"]["identifier"]
                        .toString()) {
                  cameraController.selectedSound.value = element.uri.toString();
                  songPath = element.uri.toString();
                  songName = element.displayName;
                  cameraController.soundName.value = element.displayName;
                  isLocalSound.value = true;
                } else if (element.title !=
                        serializationData["operations"][i]["options"]["clips"]
                                [j]["options"]["identifier"]
                            .toString() &&
                    cameraController.selectedSound.value ==
                        cameraController.userUploadedSound.value) {
                  cameraController.selectedSound.value =
                      cameraController.userUploadedSound.value;
                }
              }
            }
          }
        }
        print(serializationData["operations"][i]["type"]);
      }

      // if (cameraController.selectedSound.value.isEmpty &&
      //     cameraController.userUploadedSound.value.isEmpty) {
      //   await FFmpegKit.execute(
      //           "-y -i ${video!.video} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
      //       .then((audio) async {
      //     Get.toNamed(Routes.POST_SCREEN, arguments: {
      //       "sound_url": "${saveCacheDirectory}originalAudio.mp3",
      //       "file_path": video.video.substring(7, video.video.length),
      //       "is_original": isLocalSound.isTrue
      //           ? "local"
      //           : cameraController.userUploadedSound.isNotEmpty
      //               ? "original"
      //               : "extracted",
      //       "sound_name": cameraController.soundName.value.isNotEmpty
      //           ? "${cameraController.soundName.value}"
      //           : null,
      //       "sound_owner": cameraController.soundOwner.isEmpty
      //           ? GetStorage().read("userId").toString()
      //           : cameraController.soundOwner.value,
      //     });
      //   });
      // } else {
      //   Get.toNamed(Routes.POST_SCREEN, arguments: {
      //     "sound_url": cameraController.selectedSound.value.isEmpty
      //         ? cameraController.userUploadedSound.value
      //         : cameraController.selectedSound.value,
      //     "file_path": file.path,
      //     "is_original": isLocalSound.isTrue
      //         ? "local"
      //         : cameraController.userUploadedSound.isNotEmpty
      //             ? "original"
      //             : "original",
      //     "sound_name": cameraController.soundName.value.isNotEmpty
      //         ? "${cameraController.soundName.value}"
      //         : null,
      //     "sound_owner": cameraController.soundOwner.isEmpty
      //         ? GetStorage().read("userId").toString()
      //         : cameraController.soundOwner.value,
      //   });
      // }
      // video.release();
    }
    return editedFile;
  }

  openPostScreen(String filePath) async {
    if (cameraController.selectedSound.value.isEmpty &&
        cameraController.userUploadedSound.value.isEmpty) {
      await FFmpegKit.execute(
              "-y -i ${filePath} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
          .then((audio) async {
        Get.toNamed(Routes.POST_SCREEN, arguments: {
          "sound_url": "${saveCacheDirectory}originalAudio.mp3",
          "file_path": filePath.substring(7, filePath.length),
          "is_original": isLocalSound.isTrue
              ? "local"
              : cameraController.userUploadedSound.isNotEmpty
                  ? "original"
                  : "extracted",
          "sound_name": cameraController.soundName.value.isNotEmpty
              ? "${cameraController.soundName.value}"
              : null,
          "sound_owner": cameraController.soundOwner.isEmpty
              ? GetStorage().read("userId").toString()
              : cameraController.soundOwner.value,
        });
      });
    } else {
      Get.toNamed(Routes.POST_SCREEN, arguments: {
        "sound_url": cameraController.selectedSound.value.isEmpty
            ? cameraController.userUploadedSound.value
            : cameraController.selectedSound.value,
        "file_path": filePath,
        "is_original": isLocalSound.isTrue
            ? "local"
            : cameraController.userUploadedSound.isNotEmpty
                ? "original"
                : "original",
        "sound_name": cameraController.soundName.value.isNotEmpty
            ? "${cameraController.soundName.value}"
            : null,
        "sound_owner": cameraController.soundOwner.isEmpty
            ? GetStorage().read("userId").toString()
            : cameraController.soundOwner.value,
      });
    }
  }

  Future<imgly.Configuration> setConfig(
      List<SongModel> albums, String? userName,
      {double maxDuration = 60, imgly.Tool? tool}) async {
    var audioFile = File(cameraController.selectedSound.isEmpty
        ? cameraController.userUploadedSound.value
        : cameraController.selectedSound.value);
    cameraController.selectedAudioClips.clear();
    cameraController.audioClips.clear();
    cameraController.soundsList.clear();
    cameraController.audioClipCategories.clear();
    cameraController.selectedAudioClips.add(imgly.AudioClip(
        userName.toString(), audioFile.path,
        artist: cameraController.soundAuthorName.value,
        title: userName,
        thumbnailURI: "https://sunrust.org/wiki/images/a/a9/Gallery_icon.png"));

    if (albums.isNotEmpty) {
      albums.forEach((element) {
        cameraController.audioClips.add(imgly.AudioClip(
          element.title,
          element.uri.toString(),
        ));
      });
    }
    cameraController.audioClipCategories.add(
      imgly.AudioClipCategory("audio_cat_1", "local",
          thumbnailURI: "assets/logo2.png", items: cameraController.audioClips),
    );

    if (cameraController.selectedSound.isNotEmpty ||
        cameraController.userUploadedSound.isNotEmpty) {
      cameraController.audioClipCategories.add(imgly.AudioClipCategory(
          "", "selected sound",
          thumbnailURI: "assets/logo2.png",
          items: cameraController.selectedAudioClips));
    }

    cameraController.audioOptions =
        imgly.AudioOptions(categories: cameraController.audioClipCategories);

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
    List<imgly.Tool> toolsList = [];

    if (tool != null) {
      toolsList.add(tool);
    }
    if (cameraController.audioClipCategories.isEmpty &&
        cameraController.localSoundsList.isEmpty) {
      configuration = imgly.Configuration(
        theme: imgly.ThemeOptions(imgly.Theme(
          "default_editor_theme",
        )),
        trim: trimOptions,
        tools: toolsList.isNotEmpty ? toolsList : [],
        filter: imgly.FilterOptions(
            categories: categories, flattenCategories: true),
        sticker: imgly.StickerOptions(
            personalStickers: true, categories: stickerList),
        export: exportOptions,
        // watermark: waterMarkOptions,
      );
    } else {
      configuration = imgly.Configuration(
        theme: imgly.ThemeOptions(imgly.Theme(
          "default_editor_theme",
        )),
        trim: trimOptions,
        filter: imgly.FilterOptions(
            categories: categories, flattenCategories: true),
        tools: toolsList.isNotEmpty ? toolsList : [],

        sticker: imgly.StickerOptions(
            personalStickers: true, categories: stickerList),
        audio: cameraController.audioOptions,
        export: exportOptions,
        // watermark: waterMarkOptions,
      );
    }

    return configuration;
  }
}

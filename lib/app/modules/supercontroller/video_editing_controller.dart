import 'dart:io';

import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:get/get.dart';

import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;
import 'package:on_audio_query/on_audio_query.dart';

import 'package:uri_to_file/uri_to_file.dart';
import 'package:file_support/file_support.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../rest/models/sounds_model.dart';
import '../../rest/rest_urls.dart';
import '../../routes/app_pages.dart';
import '../../utils/strings.dart';
import '../../utils/utils.dart';

class VideoEditingController extends GetxController {
  var fileSupport = FileSupport();
  RxList<SongModel> localSoundsList = RxList();
  List<FileSystemEntity> entities = [];
  List<String> videosList = <String>[];

  @override
  void onInit() {
    getCreatedClips();
    getLocalAlbums();
    super.onInit();
  }

  Future<void> openEditor(bool isGallery, String path, String selectedSound,
      int id, String owner) async {
    try {} catch (e) {
      errorToast(e.toString());
    } finally {
      if (!isGallery) {

        await VESDK
            .openEditor(Video.composition(videos: videosList),
                configuration: setConfig(localSoundsList, selectedSound, owner))
            .then((value) async {
          Map<dynamic, dynamic> serializationData = await value?.serialization;
          var isOriginal = true.obs;
          var songPath = '';
          var songName = '';
          for (int i = 0;
              i < serializationData["operations"].toList().length;
              i++) {
            if (serializationData["operations"][i]["type"] == "audio") {
              isOriginal.value = false;
            }
            for (var element in localSoundsList) {
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
            await deleteClipsDirectory();
          }

          // await dir.delete(recursive: true);

          if (isOriginal.isFalse) {
            selectedSound = "";
            if (value != null) {
              Get.toNamed(Routes.POST_SCREEN,
                  arguments: {"sound_url": songPath, "file_path": value.video});
            }
          } else {
            if (selectedSound.isNotEmpty) {
              await FFmpegKit.execute(
                      '-y -i ${value!.video.substring(7, value.video.length)} -i $selectedSound -map 0:v -map 1:a  -shortest $saveCacheDirectory/selectedVideo.mp4')
                  .then((ffmpegValue) async {
                final returnCode = await ffmpegValue.getReturnCode();
                var data = await ffmpegValue.getOutput();
                Get.toNamed(Routes.POST_SCREEN, arguments: {
                  "sound_url": selectedSound,
                  "file_path": "$saveCacheDirectory/selectedVideo.mp4"
                });
              });
            } else {
              await FFmpegKit.execute(
                      "-y -i ${value!.video} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
                  .then((audio) async {
                Get.toNamed(Routes.POST_SCREEN, arguments: {
                  "sound_url": "${saveCacheDirectory}originalAudio.mp3",
                  "file_path": value.video.substring(7, value.video.length)
                });
              });
            }
          }
        });
      } else {
        await VESDK
            .openEditor(Video(path),
                configuration: setConfig(localSoundsList, selectedSound, owner))
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
                "sound_url": selectedSound.isEmpty ? songPath : selectedSound
              });
            }
          } else {
            var dir = await getTempDirectory();
            await FFmpegKit.execute(
                    "-y -i ${value!.video} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
                .then((audio) async {
              Get.toNamed(Routes.POST_SCREEN, arguments: {
                "file_path": value.video.substring(7, value.video.length),
                "sound_url": "${saveCacheDirectory}originalAudio.mp3",
              });
            });
          }
        });
      }
    }
  }


  deleteClipsDirectory()async {
    var tempDirectory = await getTemporaryDirectory();
    final dir = Directory(tempDirectory.path + "/videos");
    dir.exists().then((value) => dir.delete(recursive: true));

  }
  getLocalAlbums() async {
    if(await Permission.audio.isRestricted)
    if (await Permission.audio.isGranted == false) {
      await Permission.audio.request().then((value) async {
        localSoundsList.value = await OnAudioQuery().querySongs();
      });
    }
    localSoundsList.value = await OnAudioQuery().querySongs();
  }

  getCreatedClips()async {
    var tempDirectory = await getTemporaryDirectory();
    final dir = Directory(tempDirectory.path + "/videos");
    if (!await Directory(dir.path).exists()) {
    await Directory(dir.path).create();
    }

     entities = await dir.list().toList();
      entities.forEach((element) {
    videosList.add(element.path);
    });
  }
  imgly.Configuration setConfig(
      List<SongModel> albums, String selectedSound, String? userName) {
    List<imgly.AudioClip> audioClips = [];
    List<imgly.AudioClip> selectedAudioClips = [];
    List<imgly.AudioClipCategory> audioClipCategories = [];

    var audioFile = File(selectedSound);
    if (audioFile.existsSync()) {
      selectedAudioClips.add(imgly.AudioClip("", selectedSound,
          title: "Original by ${userName ?? GetStorage().read("username")}",));
    }

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


    if (selectedSound.isNotEmpty) {
      audioClipCategories.add(imgly.AudioClipCategory("", "selected sound",
          items: selectedAudioClips));
    }

    var audioOptions = imgly.AudioOptions(categories: audioClipCategories);

    var codec = imgly.VideoCodec.values;

    var exportOptions = imgly.ExportOptions(
      serialization: imgly.SerializationOptions(
          enabled: true, exportType: imgly.SerializationExportType.object),
      video: imgly.VideoOptions(quality: 0.9, codec: codec[1]),
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
        maximumDuration: 60,
        forceMode: imgly.ForceTrimMode.always);
    final configuration = imgly.Configuration(
      theme: imgly.ThemeOptions(imgly.Theme("")),
      trim: trimOptions,
      sticker:
          imgly.StickerOptions(personalStickers: true, categories: stickerList),
      audio: audioOptions,
      export: exportOptions,
      // watermark: waterMarkOptions,
    );

    return configuration;
  }
}

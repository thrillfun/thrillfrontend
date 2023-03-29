import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_support/file_support.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../rest/models/sounds_model.dart';
import '../../../rest/rest_urls.dart';
import '../../../routes/app_pages.dart';
import '../../../utils/strings.dart';
import '../../../utils/utils.dart';
import 'package:video_editor_sdk/video_editor_sdk.dart';
import 'package:imgly_sdk/imgly_sdk.dart' as imgly;
import 'package:on_audio_query/on_audio_query.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:uri_to_file/uri_to_file.dart';

class CameraController extends GetxController {
  var fileSupport = FileSupport();

  var isSoundsLoading = false.obs;
  RxList<Sounds> soundsList = RxList();
  RxList<SongModel> localSoundsList = RxList();
  var selectedSoundPath = "".obs;
  var dio = Dio(BaseOptions(baseUrl: RestUrl.baseUrl));


  @override
  void onInit() {
    super.onInit();
    getAlbums();
    getSoundsList();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  getAlbums() async {
    var storagePermission = await Permission.storage.status;
    if (storagePermission.isGranted) {
      localSoundsList.value = await OnAudioQuery().querySongs();
    } else {
      Permission.storage.request();
    }
  }

  Future<void> openEditor(bool isGallery, String path, String selectedSound,
      int id, String owner) async {

    var file = File(selectedSound);

    List<SongModel> albums = [];
    if (await Permission.audio.isGranted == false) {
      await Permission.audio.request().then((value) async {
        albums = await OnAudioQuery().querySongs();
      });
    }
    albums = await OnAudioQuery().querySongs();
    try {} catch (e) {
      errorToast(e.toString());
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
                configuration: setConfig(albums, selectedSound, owner))
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

          if (isOriginal.isFalse) {
            selectedSound = "";
            if (value != null) {

              if(file.existsSync()){
                Get.toNamed(Routes.POST_SCREEN, arguments: {
                  "sound_url":selectedSound,
                  "file_path": "$saveCacheDirectory/selectedVideo.mp4"
                });
              }
              else{
                Get.toNamed(Routes.POST_SCREEN, arguments: {
                  "sound_url":null,
                  "file_path": "$saveCacheDirectory/selectedVideo.mp4"
                });
              }

            }
          } else {
            if (file.existsSync()) {
              await FFmpegKit.execute(
                      '-y -i ${value!.video.substring(7, value.video.length)} -i $selectedSound -map 0:v -map 1:a  -shortest $saveCacheDirectory/selectedVideo.mp4')
                  .then((ffmpegValue) async {
                final returnCode = await ffmpegValue.getReturnCode();
                var data = await ffmpegValue.getOutput();
                if (ReturnCode.isSuccess(returnCode)) {
                  Get.toNamed(Routes.POST_SCREEN, arguments: {
                    "sound_url":selectedSound,
                    "file_path": "$saveCacheDirectory/selectedVideo.mp4"
                  });
                } else {
                  errorToast(data.toString());
                }
              });
            } else {
              await FFmpegKit.execute(
                      "-y -i ${value!.video} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
                  .then((audio) async {
                Get.toNamed(Routes.POST_SCREEN, arguments: {
                  "sound_url":"${saveCacheDirectory}originalAudio.mp3",
                  "file_path": value.video.substring(7, value.video.length)
                });
              });
            }
          }
        });
      } else {
        await VESDK
            .openEditor(Video(path),
                configuration: setConfig(albums, selectedSound, owner))
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
                "sound_url": file.existsSync()?songPath:selectedSound
              });
            }
          } else {
            var dir = await getTempDirectory();
            await FFmpegKit.execute(
                    "-y -i ${value!.video} -map 0:a -acodec libmp3lame ${saveCacheDirectory}originalAudio.mp3")
                .then((audio) async {
              Get.toNamed(Routes.POST_SCREEN, arguments: {
                "file_path": value.video.substring(7, value.video.length),
                "sound_url":"${saveCacheDirectory}originalAudio.mp3",
              });
            });
          }
        });
      }
    }
  }

  imgly.Configuration setConfig(
      List<SongModel> albums, String selectedSound, String? userName) {
    List<imgly.AudioClip> audioClips = [];
    List<imgly.AudioClip> selectedAudioClips = [];
    List<imgly.AudioClipCategory> audioClipCategories = [];

    var audioFile = File(selectedSound);
    if (audioFile.existsSync()) {
      selectedAudioClips.add(imgly.AudioClip("",
          selectedSound,
          title: "Original by ${userName ?? GetStorage().read("username")}",
          thumbnailURI:
              "https://sunrust.org/wiki/images/a/a9/Gallery_icon.png"));
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

    if (soundsList.isNotEmpty) {
      List<imgly.AudioClip> onlineAudioClips = [];
      soundsList.forEach((element) {
        onlineAudioClips.add(imgly.AudioClip(element.name.toString(),
            RestUrl.soundUrl + element.sound.toString(),
            title: element.name));
      });
    }

    if (selectedSound.isNotEmpty && audioFile.existsSync()) {
      audioClipCategories.add(imgly.AudioClipCategory("", "selected sound",
          items: selectedAudioClips));
    }
    audioClipCategories.add(
      imgly.AudioClipCategory("audio_cat_1", "local",
          thumbnailURI: "https://sunrust.org/wiki/images/a/a9/Gallery_icon.png",
          items: audioClips),
    );

    var audioOptions = imgly.AudioOptions(categories: audioClipCategories);

    var codec = imgly.VideoCodec.values;

    var exportOptions = imgly.ExportOptions(
      serialization: imgly.SerializationOptions(
          enabled: true, exportType: imgly.SerializationExportType.object),
      video: imgly.VideoOptions(quality: 0.9, codec: codec[0]),
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

  Future<void> getSoundsList() async {
    dio.options.headers["Authorization"] =
        "Bearer ${GetStorage().read("token")}";

    dio.post("/sound/list").then((value) {
      soundsList = SoundsModel.fromJson(value.data).data!.obs;
    }).onError((error, stackTrace) {
      errorToast(error.toString());
    });
  }
}
